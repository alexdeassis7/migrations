import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { SpinnerWaitComponent } from 'src/app/components/shared/spinner/spinner.component';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { BsModalService } from 'ngx-bootstrap/modal';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { LpConsultDataService } from 'src/app/services/lp-consult-data.service';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { EnumViews } from '../../../services/enumViews';
import * as XLSX from 'xlsx';
import { Payout, PayoutResponseARG, PayoutResponseCOL, PayoutResponseBRA, PayoutResponseURY, PayoutResponseMEX, PayoutResponseCHL, PayoutResponseECU, PayoutResponsePER, PayoutResponsePRY, PayoutResponseBOL  } from 'src/app/models/payout_apiModel';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import Utils from 'src/app/utils';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { Merchant } from 'src/app/models/merchantModel';
import { LpReportService } from 'src/app/services/lp-report.service'



type AOA = any[][];
@Component({
  selector: 'app-payout-gestion-merchant',
  templateUrl: './payout-gestion-merchant.component.html',
  styleUrls: ['./payout-gestion-merchant.component.css']
})


export class PayoutGestionMerchantComponent implements OnInit {

  data: AOA = [[1, 2], [3, 4]];
  wopts: XLSX.WritingOptions = { bookType: 'xlsx', type: 'array' };
  inputElementFile: HTMLInputElement
  filesUpload: any[] = [];
  files: any;
  res: any = [];
  itemsBreadcrumb: any = ['Home', 'Files Manager', 'PayOut', 'Merchant Management'];
  action: string;
  stateLoad: boolean = false;
  stateValidation: boolean = false;
  stateUpload: boolean = false;
  positionTop: string = "translateY(0px)"
  fileBase64: any;
  bsModalRef: BsModalRef;
  ListTransactions: any = [{ name: 'Pago de Haberes', val: '1' }, { name: 'Pago a Proveedores', val: '2' }]
  trSelect: any = null;
  dataTxt: string = "";
  downloadStatus: string = null;
  userPermission: string = this.securityService.userPermission;
  userId: string = this.securityService.UserLogued.customer_id;
  dollarPrice: string = ""
  listTransactionsUpload: any
  contError: number = 0;
  contOk: number = 0;
  CodeCountry: string ="ARG"
  Customer:string=""
  ListMerchants: Merchant[] = []
  merchantSelect: Merchant = null;

  constructor(private http: HttpClient, private clientData: ClientDataShared, private modalService: BsModalService, private servLP: LpConsultDataService,
    private modalServiceLp: ModalServiceLp, private securityService: LpSecurityDataService, private LpServices: LpMasterDataService, private sanitizer: DomSanitizer, private lpReport : LpReportService) { }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.FILE_MANAGER, 'PayOut', 'PayOutGestMerchant');
    this.action = 'upload';
    this.getListClients();
    // console.log(this.CodeCountry);

  }

  onFileChange(event) {
    if (event.target.files.length > 0) {
      this.filesUpload = event.target.files;
      this.files = event
      this.inputElementFile = <HTMLInputElement>event.srcElement
      this.stateValidation = true;
      this.stateUpload = false;
      this.listTransactionsUpload = [];
      this.contError = 0;
      this.contOk = 0;
    }


  }

  uploadServer() {
    if (this.userPermission == 'ADMIN') {

      this.CodeCountry = this.merchantSelect.CountryCode
      this.Customer = this.merchantSelect.UserSiteIdentification

    }
    else {

      this.CodeCountry = this.securityService.UserLogued.Country.Code
      this.Customer = this.securityService.UserLogued.customer_id

    }
    this.modalServiceLp.showSpinner();
    let event = this.files;

    /* wire up file reader */
    const target: DataTransfer = <DataTransfer>(event.target);
    
    if (target.files.length !== 1) throw new Error('Cannot use multiple files');
    const reader: FileReader = new FileReader();

    reader.onload = (e: any) => {

      /* read workbook */
      const bstr: string = e.target.result;
      const wb: XLSX.WorkBook = XLSX.read(bstr, { type: 'binary' });

      /* grab first sheet */
      const wsname: string = wb.SheetNames[0];
      const ws: XLSX.WorkSheet = wb.Sheets[wsname];

      /* save data */
      this.data = <AOA>(XLSX.utils.sheet_to_json(ws, { header: 1 }));



      let GralObject = [];
      let Listpayoutapi = [];

      if (this.CodeCountry == "ARG") { // Argentina
        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Argentina = new Payout.Argentina(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }

      }

      if (this.CodeCountry == "COL") { // Colombia

        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Colombia = new Payout.Colombia(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }
      }

      if (this.CodeCountry == "BRA") { // Brasil

        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Brasil = new Payout.Brasil(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }
      }

      if (this.CodeCountry == "MEX") { // Mexico

        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Mexico = new Payout.Mexico(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }
      }

      if (this.CodeCountry == "URY") {

        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Uruguay = new Payout.Uruguay(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }
      }

      if (this.CodeCountry == "CHL") {

        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Chile = new Payout.Chile(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }
      }
      if (this.CodeCountry == "ECU") {

        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Ecuador = new Payout.Ecuador(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }
      }

      if (this.CodeCountry == "PER") {

        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Peru = new Payout.Peru(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }
      }

      if (this.CodeCountry == "PRY") {

        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Paraguay = new Payout.Paraguay(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }
      }

      if (this.CodeCountry == "BOL") {

        for (let index = 1; index < this.data.length; index++) {
          if (this.data[index].length == 0) { break; }

          let payoutapi: Payout.Bolivia = new Payout.Bolivia(this.data[index]);

          Listpayoutapi.push(payoutapi);
        }
      }

      let body = {
        customer: this.Customer
        ,countryCode: this.CodeCountry
      }
      let byAdmin = this.userPermission == 'ADMIN' ? true : false
      this.LpServices.Payout.postInsertPayOut(Listpayoutapi,this.Customer,this.CodeCountry,byAdmin).subscribe((data: any) => {


        let TransactionDetail = [];
        let withError: boolean = false;

        if (this.CodeCountry == "ARG") {
          data.forEach(result => {
            let payoutapi: PayoutResponseARG = new PayoutResponseARG(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);

          });

        }
        if (this.CodeCountry == "COL") {
          data.forEach(result => {
            let payoutapi: PayoutResponseCOL = new PayoutResponseCOL(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);

          });


        }

        if (this.CodeCountry == "BRA") {
          data.forEach(result => {
            let payoutapi: PayoutResponseBRA = new PayoutResponseBRA(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);

          });
        }

        if (this.CodeCountry == "MEX") {
          data.forEach(result => {
            let payoutapi: PayoutResponseMEX = new PayoutResponseMEX(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);

          });


        }

        if (this.CodeCountry == "URY") {
          data.forEach(result => {
            let payoutapi: PayoutResponseURY = new PayoutResponseURY(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);

          });
        }

        if (this.CodeCountry == "CHL") {
          data.forEach(result => {
            let payoutapi: PayoutResponseCHL = new PayoutResponseCHL(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);
          });
        }

        if (this.CodeCountry == "ECU") {
          data.forEach(result => {
            let payoutapi: PayoutResponseECU = new PayoutResponseECU(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);
          });
        }

        if (this.CodeCountry == "PER") {
          data.forEach(result => {
            let payoutapi: PayoutResponsePER = new PayoutResponsePER(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);
          });
        }

        if (this.CodeCountry == "PRY") {
          data.forEach(result => {
            let payoutapi: PayoutResponsePRY = new PayoutResponsePRY(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);
          });
        }
        if (this.CodeCountry == "BOL") {
          data.forEach(result => {
            let payoutapi: PayoutResponseBOL = new PayoutResponseBOL(result);

            if (payoutapi.error.HasError) {
              withError = true;
              this.contError = this.contError + 1;
            }
            else {
              this.contOk = this.contOk + 1;
            }
            TransactionDetail.push(payoutapi);
          });
        }

        this.listTransactionsUpload = TransactionDetail
        this.stateUpload = true;
     
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
        
        //#region  notification_email
        var lotIds : string[] = data.map(({payout_id}) => payout_id)
        lotIds = lotIds.filter(x => x != '0')
        var uniqeLotIds = Array.from( new Set(lotIds));
        if (uniqeLotIds.length > 0) {
          this.lpReport.adminEmailNotification(uniqeLotIds.toString()).subscribe(); 
        }
        //#endregion
        
        this.modalServiceLp.openModal('UPLOADED', 'Success', 'The file was uploaded correctly')
      }, error => {
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
        this.modalServiceLp.openModal('ERROR', 'API ERROR', 'There was an error reading the document');
      });

    };
    reader.readAsBinaryString(target.files[0]);
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

    //   'PaymentType': this.trSelect
    // }
    // this.LpServices.Payout.testDownload(params)
    //   .subscribe((datos: any) => {

    //     if (datos.Status == "OK" && datos.Rows > 0) {
    //       this.downloadStatus = "OK";
    //       this.dataTxt = atob(datos.FileBase64);
    //       this.downloadFile(this.dataTxt, 'Payout.txt');
    //     }
    //     else if (datos.Status == "OK" && datos.Rows == 0) {
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

  clearFiles() {
    this.stateUpload = false;
    this.stateValidation = false;
    this.filesUpload = [];
    this.listTransactionsUpload = [];

    this.inputElementFile.form.reset();
    this.contError = 0;
    this.contOk = 0;
  }
  scrollFixedHead($event: Event) {
    let divTabla: HTMLDivElement = <HTMLDivElement>$event.srcElement
    let scrollOffset = divTabla.scrollTop;
    let tabla: HTMLTableElement = <HTMLTableElement>divTabla.children[0]

    let offsetBottom = (tabla.offsetHeight - divTabla.offsetHeight + 15) * -1 + scrollOffset
    // this.positionBottom = "translateY(" + offsetBottom + "px)"
    this.positionTop = "translateY(" + scrollOffset + "px)"
  }
  getListClients() {
    if (this.userPermission == 'ADMIN') {
      this.LpServices.Filters.getListClients().subscribe((data: Merchant[]) => {

        if (data != null) {
          this.ListMerchants = data
        }

      }, error => {

        console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
      })
    }
  }

  getHtmlPopover(errors: any): SafeHtml {

    let html: string = ``
    let errorsFormated = Utils.mergeErrorPopover(errors)

    errorsFormated.forEach(error => {
      html = html + error + '<br> <div  class="dropdown-divider" style="border-color: lightgray;"></div>'
    });

    return this.sanitizer.bypassSecurityTrustHtml(html);
  }

}