import { Component, OnInit } from '@angular/core';
import { formatDate } from '@angular/common';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { EnumViews } from '../../services/enumViews';
import { Currency } from 'src/app/models/currencyModel'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { ReconciliationReport } from 'src/app/models/reconciliationReportModel';


@Component({
  selector: 'app-reconciliation-report',
  templateUrl: './reconciliation-report.component.html',
  styleUrls: ['./reconciliation-report.component.css']
})
export class ReconciliationReportComponent implements OnInit {

  constructor(private LpServices: LpMasterDataService,
    private modalServiceLp: ModalServiceLp,
    private clientData: ClientDataShared,
    private securityService: LpSecurityDataService) { }

  ListColumns: any = ['Provider Name', 'CCY', 'Date', 'Account Number', 'BIC', 'Trx Type', 'Description', 'Payoneer ID', 'Internal ID', 'Debit', 'Credit', 'Available Balance']
  itemsBreadcrumb: any = ['Home', 'Reports', 'Merchant', 'Payoneer Report'];
  ListReconciliationReport: ReconciliationReport[] = [];

  bsConfig: Partial<BsDatepickerConfig>;
  listCurrency: Currency[];
  positionTop: string = "translateY(0px)"
  positionBottom: string = "";
  paramsFilter: any = {};
  offset: number = 0;
  pageSize: number = 15;
  userPermission: string = this.securityService.userPermission;
  ListMerchants: any[];
  ListSubMerchant: any[];
  ListSubmerchantFilter: any[] = [];
  merchantSelect: any = null;
  subMerchantSelect: any = null;
  statusExport_Excel: boolean = false;
  statusExport_Csv: boolean = false;
  statusExport_Pdf: boolean = false;
  toggleFitro = false;

  //Filtros
  date: Date = new Date(Date.now());
  // dateFrom: Date = null;
  // dateTo:  Date = null;
  lotFrom: string = null;
  lotTo: string = null;
  currencySelect: any = null;
  clientSelect: any = null;


  ngOnInit() {


    this.modalServiceLp.showSpinner();
    this.merchantSelect = 12
    this.paramsFilter = {
      "pageSize": 20,
      "offset": 0,
      "date": null,
      "dateFrom": null,
      "dateTo": null,
      "lotFrom": null,
      "lotTo": null,
      // "currency":null,
      "idEntitySubMerchant": null,
      "idEntityAccount": this.userPermission == 'ADMIN' ? this.merchantSelect : this.securityService.UserLogued.idEntityUser,

    }
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.REPORTS, 'MerchantReport', 'PayoneerReport');
    this.getListReport(this.paramsFilter)
    this.getListClients();
    this.getListSubmerchant();
    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY', showWeekNumbers: false });
    setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
  }

  getListReport(params: any, autoScroll: boolean = false) {

    this.LpServices.Reports.getListReconciliationReport(params).subscribe((data: any[]) => {


      if (autoScroll == false) { this.ListReconciliationReport = []; }

      if (data != null) {

        data.forEach(_rec => this.ListReconciliationReport.push(new ReconciliationReport(_rec))
         

        );

    this.paramsFilter.offset = this.paramsFilter.offset + this.pageSize;

  }
  setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

    }

      , error => {

  setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
})

  }
scrollFixedHead($event: Event) {
  let divTabla: HTMLDivElement = <HTMLDivElement>$event.srcElement
  let scrollOffset = divTabla.scrollTop;
  let tabla: HTMLTableElement = <HTMLTableElement>divTabla.children[0]

  let offsetBottom = (tabla.offsetHeight - divTabla.offsetHeight + 15) * -1 + scrollOffset
  this.positionBottom = "translateY(" + offsetBottom + "px)"
  this.positionTop = "translateY(" + scrollOffset + "px)"
}

onScrollReport() {

  this.getListReport(this.paramsFilter, true);
}

downloadFile(content, filename, extensionFile) {
  var a = document.createElement('a');
  if (extensionFile == 'xlsx') {
    a.href = "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64," + content;
  }
  else if (extensionFile = 'csv') {
    a.href = "data:text/plain;base64," + content;
  }
  else {
    // a.href = "data:application/pdf;base64," + content;
    a.href = "data:text/plain;base64," + content;

  }
  a.download = filename;
  a.click();
}

exportReport(extensionFile: string) {
  if (extensionFile == 'xlsx') {
    this.statusExport_Excel = true;
  }
  else if (extensionFile == 'csv') {
    this.statusExport_Csv = true;
  }
  else {
    this.statusExport_Pdf = true;
  }
  // this.paramsFilter.offset = 0;
  var _dateTo = new Date();
  // _dateTo.setDate(this.dateTo.getDate() + 1)
  let paramsFilter = {
    "pageSize": null,
    "offset": 0,
    "date": this.paramsFilter.date == null ? null : this.date.toISOString().replace(/-|T.*/g, ''),
    "lotFrom": null,
    "lotTo": null,
    "idEntitySubMerchant": null,   
    "idEntityAccount": this.userPermission == 'ADMIN' ? this.merchantSelect : this.securityService.UserLogued.idEntityUser,
  }
  let body = {
    columnsReport: this.ListColumns,
    TypeReport: 'MERCHANT_REPORT_' + extensionFile.toUpperCase(),
    requestReport: paramsFilter
  }
  this.LpServices.Export.testExport(body).subscribe((data: any) => {
    if (data != null) {

      // let nameFile = 'PayoneerMerchantReport.xlsx';
      let nameFile = 'PayoneerMerchantReport.' + extensionFile;
      if(extensionFile == 'csv'){
        let formattedDate = formatDate(this.date, 'yyyyMMdd', 'en-US');
        nameFile = 'Payoneer_Statement_' + formattedDate + '.csv';
      }


      this.downloadFile(data, nameFile, extensionFile);
      this.statusExport_Excel = false;
      this.statusExport_Csv = false;
      this.statusExport_Pdf = false;


    }

  }
    , error => {

    })
}

filterReport() {
  this.modalServiceLp.showSpinner();
  this.ListReconciliationReport = [];
  var myDiv = document.getElementById('divContainerTable');
  if (myDiv != null) { myDiv.scrollTop = 0; }

  this.offset = 0;
  var _dateTo = new Date();
  // _dateTo.setDate(this.dateTo.getDate() + 1)
  this.paramsFilter = {
    "pageSize": this.pageSize,
    "offset": this.offset,
    "date": this.date.toISOString().replace(/-|T.*/g, ''),
    // "dateFrom": this.dateFrom.toISOString().replace(/-|T.*/g, ''),
    // "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
    "lotFrom": this.lotFrom != null && this.lotFrom.trim().length > 0 ? this.lotFrom : null,
    "lotTo": this.lotTo != null && this.lotTo.trim().length > 0 ? this.lotTo : null,
    // "currency": this.currencySelect,
    "idEntitySubMerchant": this.subMerchantSelect,
    "idEntityAccount": this.userPermission == 'ADMIN' ? this.merchantSelect : this.securityService.UserLogued.idEntityUser

  }
  this.getListReport(this.paramsFilter);
}
getListSubmerchant() {

  this.LpServices.Filters.getListSubMerchantUser().subscribe((_listSubmerchant: any[]) => {

    let auxArray = [];

    _listSubmerchant.forEach(subM => {

      auxArray.push(subM)

    });

    this.ListSubMerchant = auxArray;
    // console.log(this.ListSubMerchant)
  },
    error => {


    })

}

getListClients() {
  this.LpServices.Filters.getListClients().subscribe((data: any[]) => {

    if (data != null) {

      this.ListMerchants = data.filter(e => e.idEntityUser == 12 || e.idEntityUser == 16)
      // this.clientSelect = this.ListMerchants[0];

    }

  }, error => {

    console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
  })
}

}
