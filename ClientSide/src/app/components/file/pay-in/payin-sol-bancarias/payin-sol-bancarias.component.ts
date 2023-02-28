import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BsModalService } from 'ngx-bootstrap/modal';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { LpConsultDataService } from 'src/app/services/lp-consult-data.service';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { EnumViews } from '../../../services/enumViews';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
@Component({
  selector: 'app-payin-sol-bancarias',
  templateUrl: './payin-sol-bancarias.component.html',
  styleUrls: ['./payin-sol-bancarias.component.css']
})
export class PayinSolBancariasComponent implements OnInit {

  filesUpload: any[] = [];
  fileBase64: any;
  res: any = [];
  action: string;
  itemsBreadcrumb: any = ['Home', 'Files Manager', 'PayIn','Bank Solutions'];
  stateLoad: boolean = false;
  stateValidation: boolean = false;
  stateLoadServer: boolean = false;
  bsModalRef: BsModalRef;
  target: any;
  trRead: string;
  trDismiss: string;
  trProcess: string;
  listTransaction: any;
  ListMetodos: any[] = [{ name: 'PAGO FACIL', val: 'PAFA' }, { name: 'RAPIPAGO', val: 'RAPA' }, { name: 'BAPRO', val: 'BAPR' }, { name: 'COBROEXPRESS', val: 'COEX' },]
  metodoSelect: any = this.ListMetodos[0].val;
  userPermission: string = this.securityService.userPermission;
  inputElementFile: HTMLInputElement

  constructor(private http: HttpClient, private clientData: ClientDataShared, private modalService: BsModalService, private modalServiceLp: ModalServiceLp,
     private servLP: LpConsultDataService,private securityService: LpSecurityDataService,private LpServices: LpMasterDataService) { }

  ngOnInit() {

    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.FILE_MANAGER, 'Payin','PayinSolBancarias');
    this.action = 'upload';

  }

  onFileChange(event) {
    if (event.target.files.length > 0) { 
      this.filesUpload = event.target.files;
      this.readThis(event.target);
      this.inputElementFile = <HTMLInputElement> event.srcElement;
    }    
  }

  readThis(inputValue: any): any {

    var file: File = inputValue.files[0];
    var myReader: FileReader = new FileReader();

    myReader.onloadend = (e) => {

      // this.fileSend = myReader.result;
      //   var nn = new Uint8Array(myReader.result);
      this.stateValidation = true;
      this.fileBase64 = btoa(String.fromCharCode.apply(null, new Uint8Array(<ArrayBuffer>myReader.result)));

    }
    myReader.readAsArrayBuffer(file);

  }
  uploadServer() {
    this.modalServiceLp.showSpinner();

    var params = {
      "TransactionType": this.metodoSelect,
      "File": this.fileBase64,
      "FileName": this.filesUpload[0].name
    }
    this.LpServices.Payin.postFilePayIn(params).subscribe((data: any) => {
      var response = JSON.parse(data);

      if (response.Status == "ERROR") {
        setTimeout(() => {
          //  this.bsModalRef.hide();
          this.modalServiceLp.openModal('ERROR', 'Alert', response.Status + ' - ' + response.StatusMessage);
        }, 1000);
      }
      if (response.Status == "OK") {

        this.stateLoadServer = true;
        this.trRead = response.QtyTransactionRead;
        this.trDismiss = response.QtyTransactionDismiss;
        this.trProcess = response.QtyTransactionProcess;
        var dismiss = [];
        var process = [];

        if (parseInt(this.trDismiss) > 0) {

          dismiss = response.TrDismissDetail;
          dismiss.forEach(element => {
            element.status = 'error'
          });
        }
        if (parseInt(this.trProcess) > 0) {

          process = response.TrProcessDetail;
          process.forEach(element => {
            element.status = 'ok'
          });
        }

        this.listTransaction = dismiss.concat(process);
      }
 setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    }, error => {
      this.modalServiceLp.openModal('ERROR', 'Alert', error.error);
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      //  console.log(error);
    });

  }

  cargarArchivo() {

    this.stateLoad = true;

  }

  validarArchivo() {

    // this.bsModalRef = this.modalService.show(SpinnerWaitComponent, Object.assign({}, { class: "modal-dialog-centered", ignoreBackdropClick: true }));
    this.modalServiceLp.showSpinner();
    setTimeout(() => {
      this.stateValidation = true;
      this.modalServiceLp.hideSpinner();
    }, 1000);

  }

  clearFiles() {
    this.stateLoad = false;
    this.stateValidation = false;
    this.filesUpload = [];
    this.inputElementFile.form.reset();

  }

}
