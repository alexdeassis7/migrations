import { Component, OnInit } from '@angular/core';
import { Whitelist, DetailWhitelist, DetailWhitelistInsert } from 'src/app/models/whitelistModel';
import { Subject, Subscription } from 'rxjs';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { BsModalRef } from 'ngx-bootstrap/modal';
import { ModalConfirmComponent } from 'src/app/components/shared/modals/modal-confirm/modal-confirm.component';
import Utils from 'src/app/utils';
import { Router, ActivationStart } from '@angular/router';

declare var jQuery: any;
declare var $: any;
@Component({
  selector: 'app-whitelist-am',
  templateUrl: './whitelist-am.component.html',
  styleUrls: ['./whitelist-am.component.css']
})
export class WhitelistAMComponent implements OnInit {



  constructor(
    private LpServices: LpMasterDataService,
    private modalServiceLp: ModalServiceLp,
    public bsModalRef: BsModalRef,
    private route:Router
  ) { }

  modalRef: BsModalRef;
  typeOperation: String;
  whitelistEdit: Whitelist = null;
  ListSubmerchantFilter: any[] = [];
  whitelistE: Whitelist;
  subCloseModalError: Subscription
  
  //
  checkAFIP: boolean = false;
  checkARBA: boolean = false;
  typeDocSelect: number = null
  cuitBeneficiary: string = ""
  nameBeneficiary: string = ""
  lastNameBeneficiary: string = ""
  retentionsSelect: any[] = []
  titleModal: string;
  buttonText: string

  ListDetailWL: DetailWhitelist[] = [];
  ListSubMerchant: any[];
  ListMerchants: any[];
  validateRepeatFlag: boolean = false;

  public onClose: Subject<any>;

  listRetentions: any = [{ name: 'AFIP', id: 1 }, { name: 'ARBA', id: 2 }]
  ListTypeDoc: any = [{ name: 'CUIT', id: 4 }]

  ngOnInit() {

    // console.log(this.typeOperation);

    if (this.typeOperation == 'EDIT') {
      this.titleModal = 'Edit Data'
      this.buttonText = 'Save changes'
      this.onClose = new Subject();

      this.typeDocSelect = this.whitelistEdit.idEntityIdentificationType
      this.cuitBeneficiary = this.whitelistEdit.IdentificationNumber
      this.nameBeneficiary = this.whitelistEdit.FirstName
      this.lastNameBeneficiary = this.whitelistEdit.LastName

      this.getListClients();
      this.getListSubmerchant();


      //
      // this.whitelistEdit.Details
      // this.whitelistEdit.Details.forEach(det => {

      //   det.ListSubmerchantFilter =  this.ListSubMerchant.filter(e => e.idEntityUser == det.idMerchant )


      // });
      // this.ListDetailWL = this.whitelistEdit.Details;
      //

    }

    if (this.typeOperation == 'CREATE') {

      this.onClose = new Subject();

      this.titleModal = 'Add '
      this.buttonText = 'Save'
      this.getListClients();
      this.getListSubmerchant();

    }


  }
  public get validateFrm(): boolean {

    return (this.retentionsSelect.length > 0) && (this.cuitBeneficiary.length > 0) && (this.nameBeneficiary.length > 0) && (this.lastNameBeneficiary.length > 0)

  }
  sendData() {

    if (this.typeOperation == 'CREATE') {

      this.createWhiteList()
    }
    if (this.typeOperation == 'EDIT') {

      this.updateWhitelist()
    }
  }


  createWhiteList() {

    let body = {

      'Numberdoc': this.cuitBeneficiary,
      'FirstName': this.nameBeneficiary,
      'LastName': this.lastNameBeneficiary,
      'idEntityIdentificationType': this.typeDocSelect,
      'Details': this.ListDetailWL.filter((e => (e.idWhiteListRetentionType == -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == false)))
    }

    this.LpServices.Retentions.createWhitelist(body).subscribe((data: any) => {

      // this.bsModalRef.hide();

      if (data.Status == "WARNING") {
        this.modalRef = this.modalServiceLp.openModal('CONFIRM', 'Confirm', 'Do you want to recover the record?', 'second');
        let idWhite = data.idWhitelist;

        (<ModalConfirmComponent>this.modalRef.content).confirmAction.subscribe(response => {

          if (response == true) {
            let body = {
              // 'idWhitelist': this.whitelistEdit.idWhitelist,
              // 'Details': this.ListDetailWL.filter((e => (e.idWhiteListRetentionType == -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == false)))
              idWhitelist: data.idWhitelist,

            }

            this.LpServices.Retentions.updateWhitelist(body, "RECOVER").subscribe((data: any) => {

              if (data.Status == 'OK') {
                this.bsModalRef.hide();
                this.onClose.next({ Status: data.Status, StatusMessage: data.StatusMessage, action: 'RECOVER' });
                // this.ListWhitelist = [];
                // this.refreshDataWhitelist();
                // this.modalServiceLp.openModal('SUCCESS', 'Exito', "The record is recovery!");


              }
            }
              , error => {

                this.modalServiceLp.openModal(error.Status, 'Error', error.StatusMessage);


              })

          }

        })

      }
      if (data.Status == "OK") {
        this.bsModalRef.hide();
        this.onClose.next({ Status: data.Status, StatusMessage: data.StatusMessage, action: 'OK' });
      }
      if (data.Status == "ERROR") {

        this.modalServiceLp.openModal(data.Status, 'Error', data.StatusMessage, 'second');
        this.subCloseModalError = this.modalServiceLp.ModalService.onHide.subscribe((reason: string) => {
          $('#bd-second').remove();
          this.subCloseModalError.unsubscribe();
        })
      }


    }
      , error => {
        this.bsModalRef.hide();
      })
    // this.onClose.next(this.selectedCountry);
  }
  updateWhitelist() {

    let body = {
      'idWhitelist': this.whitelistEdit.idWhitelist,
      'Details': this.ListDetailWL.filter((e => (e.idWhiteListRetentionType == -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == false)))

    }

    this.LpServices.Retentions.updateWhitelist(body, "UPDATE").subscribe((data: any) => {

      if (data.Status == 'OK') {

        this.bsModalRef.hide();
        this.onClose.next({ Status: 'OK', StatusMessage: 'OK' });

      }
    }
      , error => {

        this.modalServiceLp.openModal(error.Status, 'Error', error.StatusMessage);

      })


  }

  addDetail() {
    let detail = new DetailWhitelist({});
    detail.Active = true;
    detail.ListSubmerchantFilter = this.ListSubMerchant
    this.ListDetailWL.push(detail);
  }

  removeDetail(detailRemove: DetailWhitelist) {

    detailRemove.Active = false;
    // this.ListDetailWL.re

  }
  getListSubmerchant() {

    this.LpServices.Filters.getListSubMerchantUser().subscribe((_listSubmerchant: any[]) => {

      let auxArray = [];

      _listSubmerchant.forEach(subM => {

        auxArray.push(subM)

      });

      this.ListSubMerchant = auxArray;


      if (this.typeOperation == 'EDIT') {

        this.whitelistEdit.Details.forEach(det => {
          let detalle = new DetailWhitelist(det)
          detalle.Active = true;
          detalle.ListSubmerchantFilter = this.ListSubMerchant.filter(e => e.idEntityUser == det.idMerchant)
          this.ListDetailWL.push(new DetailWhitelist(detalle))
          // det.ListSubmerchantFilter = this.ListSubMerchant.filter(e => e.idEntityUser == det.idMerchant)


        });
      }

      // this.ListDetailWL = this.whitelistEdit.Details;
      // console.log(this.ListSubMerchant)
    },
      error => {


      })

  }

  getListClients() {
    this.LpServices.Filters.getListClients().subscribe((data: any) => {

      if (data != null) {

        this.ListMerchants = data;
        // this.clientSelect = this.ListMerchants[0];

      }

    }, error => {

      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }


  loadSubmerchantFilter(idEntity: number, currentDetail) {

    // console.log('id Merchant  ' + idEntity)

    currentDetail.ListSubmerchantFilter = this.ListSubMerchant.filter(e => e.idEntityUser == idEntity)
    currentDetail.idEntitySubMerchant = null

  }

  validateRepeat(idEntity: number, currentWL: DetailWhitelist): boolean {

    let ListServer = this.ListDetailWL.filter((e => (e.idWhiteListRetentionType == -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == false)))
    let flag: boolean = false
    let count = 0;
    ListServer.forEach(det => {
      // det.isRepeat = false;

      if (det.idRetentionType == currentWL.idRetentionType && det.idMerchant == currentWL.idMerchant && det.idEntitySubMerchant == currentWL.idEntitySubMerchant) {

        count++

        if (count > 1) {

          flag = true;
          det.isRepeat = true;

        }
        else if (count <= 1 && det.isRepeat) { det.isRepeat = false }

      }


    })
    //
    let flag2: boolean = false
    ListServer.forEach(det => {

      if (det.isRepeat) {

        flag2 = true;

      }

    })
    this.validateRepeatFlag = flag2;

    // if (flag) { console.log('repetido') }
    // this.validateRepeatFlag = flag;
    return flag;
  }


  // public get validateRepeat2(): boolean {

  //   let ListServer = this.ListDetailWL.filter((e => (e.idWhiteListRetentionType == -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == false)))
  //   let flag: boolean = false
  //   ListServer.forEach(det => {

  //     if (det.isRepeat) {

  //       flag = true;

  //     }

  //   })
  //   this.validateRepeatFlag = flag;
  //   return flag;

  // }


  public get validateBtn(): boolean {

    let ListServer = this.ListDetailWL.filter((e => (e.idWhiteListRetentionType == -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == false)))
    let flagDetails: boolean = true
    let flagData: boolean = ListServer.length > 0 ? true : false

    if (this.typeDocSelect == null || this.cuitBeneficiary == "" || this.nameBeneficiary == "" || this.lastNameBeneficiary == "" || !this.validateNumber(this.cuitBeneficiary)) {

      flagData = false

    }
    ListServer.forEach(det => {

      if (det.idRetentionType == null || det.idMerchant == null || det.idEntitySubMerchant == null) {

        flagDetails = false;

      }

    })
    return flagData && flagDetails && !this.validateRepeatFlag;
  }

  validateNumber(value: any):boolean {

    return Utils.validateNumber(value)

  }



}
