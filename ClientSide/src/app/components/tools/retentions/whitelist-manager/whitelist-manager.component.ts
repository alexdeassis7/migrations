import { Component, OnInit } from '@angular/core';
import { Whitelist } from 'src/app/models/whitelistModel';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { BsModalService } from 'ngx-bootstrap/modal';
import { WhitelistAMComponent } from '../whitelist-am/whitelist-am.component';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service';
import { ModalConfirmComponent } from 'src/app/components/shared/modals/modal-confirm/modal-confirm.component';
import { WhitelistDetailComponent } from '../whitelist-detail/whitelist-detail.component';
import { Country } from 'src/app/models/countryModel';


@Component({
  selector: 'app-whitelist-manager',
  templateUrl: './whitelist-manager.component.html',
  styleUrls: ['./whitelist-manager.component.css']
})
export class WhitelistManagerComponent implements OnInit {

  modalRef: BsModalRef;

  ListWhitelist: Whitelist[] = [];
  CuitSelect: string = "";
  params: any = {};
  offset: number = 0;
  pageSize: number = 15
  positionTop: string = "translateY(0px)"
  cuitFilter: string = null;

  ListMerchants: any[];
  ListSubMerchant: any[];
  ListSubmerchantFilter: any[] = [];
  ListRetentionReg: any[] = []
  ListCountries: Country[] = [];
  merchantSelect: any = null;
  regSelect: any = null;
  subMerchantSelect: any = null;
  idRetentionTypeSelect: any = null
  idCountrySelect: any = null;
  listRetentions: any = [{ name: 'AFIP', id: 1 }, { name: 'ARBA', id: 2 }]
  constructor(
    private modalService: BsModalService,
    private LpServices: LpMasterDataService,
    private modalServiceLp: ModalServiceLp
  ) { }

  ngOnInit() {

    this.params = {
      idRetentionType: null,
      idEntitySubMerchant: null,
      idCountry: null,
      IdentificationNumber: null,
      pageSize: this.pageSize,
      offset: this.offset


    }

    this.getWhitelist(this.params);
    this.getListClients();
    this.getListSubmerchant();
    this.getListCountries();
  }

  getWhitelist(body: any) {

    this.LpServices.Retentions.getListWhitelist(body).subscribe((data: any) => {

      if (data != null) {

        data.forEach(white => {
          this.ListWhitelist.push(new Whitelist(white))
          // this.ListWhitelist.push(new Whitelist(white))
          // this.ListWhitelist.push(new Whitelist(white))
        });

        this.params.offset = this.params.offset + this.pageSize
      }

    }
      , error => {


      })

    // this.ListWhitelist.push(new Whitelist({ RecipientCUIT: '204045546504', Name: 'Matias', LastName: 'Llanos', RetAFIP: true, RetARBA: false }))

  }


  createWhitelist(event: any) {
    event.stopPropagation();
    // ignoreBackdropClick: true, keyboard: false 
    let initialState = {

      typeOperation: 'CREATE'

    }
    this.modalRef = this.modalService.show(WhitelistAMComponent, { initialState, class: 'modal-lg' });

    (<WhitelistAMComponent>this.modalRef.content).onClose.subscribe(responseAM => {

      if (responseAM.Status == "OK") {

        this.refreshDataWhitelist();
        this.modalServiceLp.openModal('SUCCESS', 'Success', "Added CUIT to Whitelist");


      }

      if (responseAM.Status == 'RECOVER') {
        this.refreshDataWhitelist();
        this.modalServiceLp.openModal('SUCCESS', 'Success', "The record is recovery!");
      }

      // if (responseAM.Status == "WARNING") {

      //   this.modalRef = this.modalServiceLp.openModal('CONFIRM', 'Confirm', 'Do you want to recover the record?');
      //   let idWhite = responseAM.idWhitelist;

      //   (<ModalConfirmComponent>this.modalRef.content).confirmAction.subscribe(response => {

      //     if (response == true) {
      //       let body = {
      //         // 'idWhitelist': this.whitelistEdit.idWhitelist,
      //         // 'Details': this.ListDetailWL.filter((e => (e.idWhiteListRetentionType == -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == true) || (e.idWhiteListRetentionType != -1 && e.Active == false)))
      //         idWhitelist: responseAM.idWhitelist,

      //       }

      //       this.LpServices.Retentions.updateWhitelist(body, "RECOVER").subscribe((data: any) => {

      //         if (data.Status == 'OK') {

      //           this.refreshDataWhitelist();
      //           this.modalServiceLp.openModal('SUCCESS', 'Exito', "The record is recovery!");


      //         }
      //       }
      //         , error => {

      //           this.modalServiceLp.openModal(error.Status, 'Error', error.StatusMessage);

      //         })

      //     }

      //   })
      // }

      if (responseAM.Status == 'ERROR') {

        this.modalServiceLp.openModal('ERROR', 'Error', responseAM.StatusMessage);
      }


    })
  }


  editWhitelist(white: Whitelist) {

    let initialState = {

      typeOperation: 'EDIT',
      whitelistEdit: white

    }

    this.modalRef = this.modalService.show(WhitelistAMComponent, { initialState, class: 'modal-lg' });

    (<WhitelistAMComponent>this.modalRef.content).onClose.subscribe(response => {

      if (response.Status = "OK") {

        this.refreshDataWhitelist();
        this.modalServiceLp.openModal('SUCCESS', 'Success', "The CUIT was updated!");

      }


    })
  }

  onScrollReport() {
    // this.getMoreDataDashboard(this.paramsFilter);
    this.getWhitelist(this.params);
  }

  filterWhitelist() {

    this.offset = 0;
    this.ListWhitelist = [];
    this.params = {

      IdentificationNumber: this.cuitFilter != undefined && this.cuitFilter.length > 0 ? this.cuitFilter : null,
      idRetentionType: this.idRetentionTypeSelect,
      idEntitySubMerchant: this.subMerchantSelect,
      idEntityUser: this.merchantSelect,
      idCountry: this.idCountrySelect,
      pageSize: this.pageSize,
      offset: this.offset


    }
    this.getWhitelist(this.params);

  }
  showDetails(data: Whitelist) {



    let initialState = {
      IdentificationNumber: data.IdentificationNumber,
      nameComplete: data.LastName + ', ' + data.FirstName,
      ListDetailRetention: data.Details

    }

    this.modalRef = this.modalService.show(WhitelistDetailComponent, { initialState, class: 'modal-lg' });

  }
  deleteWhitelist(white) {
    this.CuitSelect = white.IdentificationNumber

    this.modalRef = this.modalServiceLp.openModal('CONFIRM', 'Confirm', 'Are you sure you want to delete this CUIT?');


    (<ModalConfirmComponent>this.modalRef.content).confirmAction.subscribe(response => {

      if (response == true) {
        let body = {

          Numberdoc: this.CuitSelect
        }
        this.LpServices.Retentions.deleteWhitelist(body).subscribe((data: any) => {

          this.modalServiceLp.openModal('SUCCESS', 'Success', "The selected CUIT was deleted!");

          this.refreshDataWhitelist();

        }, error => {

        })   
      }
    })
    // RecipientCUIT
  }

  scrollFixedHead($event: Event) {

    let divTabla: HTMLDivElement = <HTMLDivElement>$event.srcElement
    let scrollOffset = divTabla.scrollTop;
    let tabla: HTMLTableElement = <HTMLTableElement>divTabla.children[0]

    let offsetBottom = (tabla.offsetHeight - divTabla.offsetHeight + 15) * -1 + scrollOffset
    // this.positionBottom = "translateY(" + offsetBottom + "px)"
    this.positionTop = "translateY(" + scrollOffset + "px)"

  }
  refreshDataWhitelist() {

    this.ListWhitelist = [];
    this.offset = 0;
    this.params = {

      RecipientCUIT: null,
      pageSize: this.pageSize,
      offset: this.offset


    }
    this.getWhitelist(this.params);

  }

  getListSubmerchant() {

    this.LpServices.Filters.getListSubMerchantUser().subscribe((_listSubmerchant: any[]) => {

      let auxArray = [];

      _listSubmerchant.forEach(subM => {

        auxArray.push(subM)

      });

      this.ListSubMerchant = auxArray;
      console.log(this.ListSubMerchant)
    },
      error => {


      })

  }

  loadSubmerchantFilter(idEntity: number) {

    // console.log('id Merchant  ' + idEntity)
    this.subMerchantSelect = null;
    this.ListSubmerchantFilter = this.ListSubMerchant.filter(e => e.idEntityUser == idEntity)

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
  getListCountries() {

    let country = new Country({ idCountry: 1, Code: 'ARG', Name: 'ARGENTINA', FlagIcon: null, NameCode: null, Description: null })
    // country.addIcon()
    this.ListCountries.push(country)
    country = new Country({ idCountry: 49, Code: 'COL', Name: 'COLOMBIA', FlagIcon: null, NameCode: null, Description: null })
    // country.addIcon()
    this.ListCountries.push(country)

  }




}
