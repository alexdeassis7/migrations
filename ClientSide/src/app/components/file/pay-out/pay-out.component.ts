import { Component, OnInit, ɵConsole } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { SpinnerWaitComponent } from 'src/app/components/shared/spinner/spinner.component';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { BsModalService } from 'ngx-bootstrap/modal';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { LpConsultDataService } from 'src/app/services/lp-consult-data.service';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { EnumViews } from '../../services/enumViews';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
@Component({
  selector: 'app-pay-out',
  templateUrl: './pay-out.component.html',
  styleUrls: ['./pay-out.component.css']
})
export class PayOutComponent implements OnInit {
  filesUpload: any[] = [];
  res: any = [];
  itemsBreadcrumb:any =  ['Home','Gestor Archivos','PayOut'];
  action: string;
  stateLoad: boolean = false;
  stateValidation: boolean = false;
  fileBase64 : any;
  bsModalRef:BsModalRef;
  ListTransactions: any = [{ name: 'Pago de Haberes', val: '1' }, { name: 'Pago a Proveedores', val: '2' }]
  trSelect: any = null;
  dataTxt: string = "";
  downloadStatus:string = null;
  userPermission: string = this.securityService.userPermission;
  dollarPrice:string = ""
  listTransactionsUpload:any
  constructor(private http: HttpClient, private clientData: ClientDataShared,private modalService: BsModalService,private servLP: LpConsultDataService,
    private modalServiceLp: ModalServiceLp,private securityService: LpSecurityDataService, private LpServices: LpMasterDataService ) { }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.FILE_MANAGER,'Payout');
    this.action = 'upload';
  }
  onFileChange(event) {
    // this.bsModalRef = this.modalService.show(SpinnerWaitComponent, Object.assign({}, { class: "modal-dialog-centered", ignoreBackdropClick: true }));
    this.filesUpload = event.target.files;
    // this.readThis(event.target);
  
  }



  validarArchivo() {

    this.bsModalRef = this.modalService.show(SpinnerWaitComponent, Object.assign({}, { class: "modal-dialog-centered", ignoreBackdropClick: true }));

    setTimeout(() => {
      this.stateValidation = true;
      this.bsModalRef.hide();
    }, 1000);

  }

  
  getFileTxt() {

    // var params = {

    //   'PaymentType':this.trSelect
    // }
    // this.LpServices.Payout.testDownload(params)
    //   .subscribe((datos: any) => {
        
    //     if(datos.Status =="OK" && datos.Rows > 0 ){
    //     this.downloadStatus = "OK";
    //     this.dataTxt = atob(datos.FileBase64);
    //     this.downloadFile(this.dataTxt, 'Payout.txt');
    //     }
    //     else if(datos.Status =="OK" && datos.Rows == 0) {
    //       this.downloadStatus = "NOTPROCESS";

    //     }
      
    //   },
    //     error => {
    //       // console.log(error.message) // error path
    //       this.downloadStatus = "ERROR";
          
    //     });
  }
  formatNumber(numAmount: string): string {


    var newMonto = numAmount;
    if (numAmount.includes(',')) {

      var aux = newMonto.split(',');
      newMonto = aux.join('');
    }
    if (numAmount.includes('.')) {

      var aux = newMonto.split('.');
      newMonto = aux.join('');
    }

    if (!numAmount.includes('.') && !numAmount.includes(',')) {

      newMonto = newMonto + '00';
    }
    if (newMonto.length < 8) {
      var emptyNumbers = "";
      for (let x = 0; x < (8 - newMonto.length); x++) {

        emptyNumbers = "0" + emptyNumbers;

      }
      newMonto = emptyNumbers + newMonto;
    }

    return newMonto;
  }
  validateNumber(value: any) {
    if (value != "") {
      var regexNumber = /^\d*\.?\d*$/;
      return regexNumber.test(value);
    }
    else {
      return true;
    }
  }
  downloadFile(content, filename) {
    var a = document.createElement('a');
    var blob = new Blob([content], { 'type': 'text/plain' });
    a.href = window.URL.createObjectURL(blob);
    a.download = filename;
    a.click();
  }

  clearFiles(){
    this.stateLoad = false;
    this.stateValidation = false;
    this.filesUpload = [];
  }

}
