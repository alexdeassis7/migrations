import { Component, OnInit, Input, EventEmitter, Output } from '@angular/core'
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service'
import { saveAs } from 'file-saver'
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from '../../services/lp-modal.service';
import { Alert } from 'selenium-webdriver';
import { Type } from '@angular/compiler';
import { BsDatepickerConfig, BsDatepickerViewMode } from 'ngx-bootstrap/datepicker';

enum TypeRetention {

  CODE_ARBA = 'RET-ARBA',
  CODE_AFIP = 'RET-AFIP'

}

@Component({
  selector: 'app-retentions',
  templateUrl: './retentions.component.html',
  styleUrls: ['./retentions.component.css']
})
export class RetentionsComponent implements OnInit {
  itemsBreadcrumb: Array<String> = ['Home', 'Tools', 'Withholdings']
  stateDownloadAfip: boolean = false;
  stateDownloadArba: boolean = false;
  itemSelect: string = 'FILES'
  totalRetAfip: number = 500
  currentLoadAfip: number = 0
  listFileTypes: any = [{ name: 'Text plain file (.txt)', code: 'TXT' }, { name: 'Worksheet file (.xlsx)', code: 'XLSX' }]
  // bsValue: Date = new Date(2019/11)
  WithholdingSelect: any = null
  // monthSelect: any = new Date();
  monthSelect: any = null
  currentMonth: any = new Date().getMonth() + 1
  currentYear:any = new Date().getFullYear()
  errorMonthValidation:boolean = false;
  TransAgroupedByDayList: any = [];
   offset: 0;
  offsetTr: 0;
  pageSize: 15;
  positionTop: 'translateY(0px)'
  // Filtro
  toggleFitro = true;
  dateFrom: Date =   new Date(new Date().setMonth(new Date().getMonth() - 1));
  dateTo: Date =new Date(Date.now());
  listRetentions:  any = [{ name: 'AFIP', id: 'RET-AFIP' }, { name: 'ARBA', id: 'RET-ARBA' }];
  ListMerchants: any = [];
  certifiedTypeSelect: any = null;

  merchantSelect: any = null;
  fileTypeSelect: any = null;
  paramsFilter: any = {};

  // validationDownload: boolean = true;

  bsConfigByDay: Partial<BsDatepickerConfig>;
  bsConfigByMonth: Partial<BsDatepickerConfig>;
  constructor(
    private clientData: ClientDataShared,
    private LpServices: LpMasterDataService,
    private modalServiceLp: ModalServiceLp

  ) { }

   filterList() {
    var myDiv = document.getElementById('divContainerTable');
    if(myDiv != null){ myDiv.scrollTop = 0;  }
    
    this.modalServiceLp.showSpinner();
    this.offset = 0;
    // var _dateTo = new Date();
    // _dateTo.setDate(this.dateTo.getDate() + 1) 
    this.paramsFilter = {
      "MerchantId": this.merchantSelect != null ? this.merchantSelect.idEntityUser : null,
      "CertTypeCode": this.certifiedTypeSelect != null ? this.certifiedTypeSelect.id : null,
      "dateFrom": this.dateFrom.toISOString().replace(/T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/T.*/g, '')
    }
    // this.initializeTotals();

    this.getTransactionsAgrouped(this.paramsFilter);

  }
  onValueChange($event: any) {


    if ($event != undefined) {

      let dateFrom = Date.parse($event);
      let dateTo = Date.parse(this.dateTo.toDateString())

      if (dateTo > dateFrom) {

        // console.log('fecha hasta es mayor que fecha desde')
      }
      if (dateTo < dateFrom) {

        // console.log('fecha desde es mayor que fecha hasta')
      }

      if (dateTo == dateFrom) {

        // console.log('son iguales')
      }


    }
  }

  getTransactionsAgrouped(params: any){
    this.LpServices.Retentions.getListTransactionsAgRetentions(params).subscribe((data: any) => {
      this.TransAgroupedByDayList = data;
    setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    }, error => {
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    });
  }

  getListClients() {
    this.LpServices.Filters.getListClients().subscribe((data: any) => {
      if (data != null) {
        this.ListMerchants = data;
      }
    }, error => {

      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }
  getRetentionTypeByCode(Code: string){
    return this.listRetentions.find(x=>x.id == Code);
  }

  getRetentions(code: string) {

    this.modalServiceLp.showSpinner();

    let codeRet = code == 'afip' ? TypeRetention.CODE_AFIP : TypeRetention.CODE_ARBA
    // if(codeRet == TypeRetention.CODE_AFIP){ this.stateDownloadAfip = true; }
    // if(codeRet == TypeRetention.CODE_ARBA){ this.stateDownloadArba = true; }

    this.LpServices.Retentions.getRetentions(codeRet).subscribe((data: any) => {

      if (data === null || data == 'NOTPENDINGFILES') {

        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
        this.modalServiceLp.openModal('SUCCESS', 'Information', 'No pending certificates to download')
        // console.log("No hay certificados pendientes de descarga")

        return
      }

      var b64Data = data.file_bytes_compressed;
      var contentType = "application/octet-stream";
      var sliceSize = 512;
      var byteCharacters = atob(b64Data);
      var byteArrays = [];
      for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        var slice = byteCharacters.slice(offset, offset + sliceSize);
        var byteNumbers = new Array(slice.length);
        for (var i = 0; i < slice.length; i++) {
          byteNumbers[i] = slice.charCodeAt(i);
        }
        var byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
      }
      var blob = new Blob(byteArrays, { type: contentType });
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      saveAs(blob, data.file_name_zip);

    }, error => {
      console.log(error.error.Status + ' - ' + error.error.StatusMessage)
    })
  }

  downloadTransactionsAgrouped(transactionSelected: any){
    this.modalServiceLp.showSpinner();
    let transactionsToDownload = {
      'Merchant':transactionSelected.Merchant,
      'date': transactionSelected.Fecha.replace(/T.*/g, ''),
      'Certificates_Created': transactionSelected.Certificates_Created,
      'Organism': {'Id':transactionSelected.OrganismoCode, 'Name': this.getRetentionTypeByCode(transactionSelected.OrganismoCode).name }
    };

    this.LpServices.Retentions.downloadTransactionsAgrouped(transactionsToDownload).subscribe((data: any) => {
    
      var b64Data = data.file_bytes_compressed;
      var contentType = "application/octet-stream";
      var sliceSize = 512;
      var byteCharacters = atob(b64Data);
      var byteArrays = [];
      for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        var slice = byteCharacters.slice(offset, offset + sliceSize);
        var byteNumbers = new Array(slice.length);
        for (var i = 0; i < slice.length; i++) {
          byteNumbers[i] = slice.charCodeAt(i);
        }
        var byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
      }
      var blob = new Blob(byteArrays, { type: contentType });
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      saveAs(blob, data.file_name_zip);

    }, error => {
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      console.log(error.error.Status + ' - ' + error.error.StatusMessage)
    });

  }

  downloadMonthlyFiles() {

    this.modalServiceLp.showSpinner();

    if (this.WithholdingSelect == TypeRetention.CODE_ARBA) {

      if (this.fileTypeSelect == 'TXT') { this.downloadTxtArba(); }

      if (this.fileTypeSelect == 'XLSX') { this.downloadExcelArba(); }

    }
 
    if (this.WithholdingSelect == TypeRetention.CODE_AFIP) {

      if (this.fileTypeSelect == 'TXT') { this.downloadTxtAfip(); }

      if (this.fileTypeSelect == 'XLSX') { this.downloadExcelAfip(); }

    }

    // setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
  }

  downloadTxtAfip() {

    let currentMonth =this.monthSelect.getMonth() + 1;
    let currentYear = this.monthSelect.getFullYear();

    let body = {
      month: currentMonth,
      year: currentYear,
      typeFile: 'TXT'

    }
    this.LpServices.Retentions.downloadTxtMonthly(body).subscribe((data: any) => {

      if (data.Status == 'OK' && data.Rows > 0) {

        this.downloadFile(data.FileBase64, 'AFIP_WITHHOLDINGS_MONTH_' + currentYear.toString() + '_' + currentMonth.toString(), 'text/plain')
      }
      if (data.Status == 'OK' && data.Rows == 0) {

        this.modalServiceLp.openModal('SUCCESS', 'Information', 'No pending records to download')
      }

      //falta error
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

    },
      error => {
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      })
  }

  downloadExcelAfip() {

    let currentMonth = this.monthSelect.getMonth() + 1;
    let currentYear = this.monthSelect.getFullYear();

    let body = {
      month: currentMonth,
      year: currentYear,
      typeFile: 'EXCEL'
    }

    this.LpServices.Retentions.downloadExcelMonthly(body).subscribe((data: any) => {
      
      if(data != null) {
        
        this.downloadFile(data, 'AFIP_WITHHOLDINGS_MONTH_' + currentYear.toString() + '_' + currentMonth.toString(), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      }
      else {

        this.modalServiceLp.openModal('SUCCESS', 'Information', 'No pending records to download')
      }

      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

    },
      error => {
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      })

  }

  downloadTxtArba() {

    let currentMonth = this.monthSelect.getMonth() + 1;
    let currentYear = this.monthSelect.getFullYear();

    let body = {
      month: currentMonth,
      year: currentYear,
      typeFile: 'TXT'

    }
    this.LpServices.Retentions.downloadTxtArba(body).subscribe((data: any) => {

      if (data.Status == 'OK' && data.Rows > 0) {

        this.downloadFile(data.FileBase64, 'ARBA_WITHHOLDINGS_MONTH_' + currentYear.toString() + '_' + currentMonth.toString(), 'text/plain')
      }
      if (data.Status == 'OK' && data.Rows == 0) {

        this.modalServiceLp.openModal('SUCCESS', 'Information', 'No pending records to download')
      }
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

    },
      error => {
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      })
  }

  downloadExcelArba() {

    let currentMonth =this.monthSelect.getMonth() + 1;
    let currentYear = this.monthSelect.getFullYear();

    let body = {
      month: currentMonth,
      year: currentYear,
      typeFile: 'EXCEL'

    }

    this.LpServices.Retentions.downloadExcelArba(body).subscribe((data: any) => {

      if(data != null ) {

        this.downloadFile(data, 'ARBA_WITHHOLDINGS_MONTH_' + currentYear.toString() + '_' + currentMonth.toString(), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      }
      else {

        this.modalServiceLp.openModal('SUCCESS', 'Information', 'No pending records to download')
      }

      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

    },
      error => {
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      })

  }

  downloadFile(content, filename, typeFile) {
    var a = document.createElement('a');
    var blob = new Blob([this.s2ab(atob(content))], { 'type': typeFile });
    a.href = window.URL.createObjectURL(blob);
    a.download = filename;
    a.click();
  }
  s2ab(s) {
    var buf = new ArrayBuffer(s.length);
    var view = new Uint8Array(buf);
    for (var i = 0; i != s.length; ++i) view[i] = s.charCodeAt(i) & 0xFF;
    return buf;
  }
  ngOnInit() {

    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(4, 'withholdings');
    this.bsConfigByDay = { containerClass: 'theme-default',  dateInputFormat: 'DD/MM/YYYY', showWeekNumbers: false, maxDate: new Date(), minMode: "day" }
    this.bsConfigByMonth = { containerClass: 'theme-default',  dateInputFormat: 'MM/YYYY', showWeekNumbers: false, maxDate: new Date(), minMode: "month" }

     this.getListClients();

    // console.log(TypeRetention.CODE_AFIP);
  }
  validateMonth(monthSelect: any) {
    let _monthSelect = monthSelect.getMonth() + 1  
    let yearSelect = monthSelect.getFullYear() 
    
    if ((_monthSelect >= this.currentMonth && yearSelect == this.currentYear) || yearSelect > this.currentYear) {

      this.errorMonthValidation = true;
    }
    else {

      this.errorMonthValidation = false;
    }

  }
  public get validationDownload() : boolean {


    return this.WithholdingSelect != null && this.monthSelect != null && this.fileTypeSelect != null && this.errorMonthValidation == false
  }
  
}
