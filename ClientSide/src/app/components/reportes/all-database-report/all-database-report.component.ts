import { Component, OnInit, ChangeDetectorRef, Input, EventEmitter, Output } from '@angular/core';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { DomSanitizer } from '@angular/platform-browser';
import { Payout } from 'src/app/models/payoutModel';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { BsLocaleService } from 'ngx-bootstrap/datepicker';
import { TransactionReport } from 'src/app/models/transactionModel';
import { EnumViews } from '../../services/enumViews';
import { Status } from 'src/app/models/statusModel';
import { Currency } from 'src/app/models/currencyModel'
import * as moment from 'moment-timezone'
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { Subscription } from 'rxjs';
import { Merchant } from 'src/app/models/merchantModel';
import { TransactionType } from 'src/app/models/transactionTypeModel';
import { THIS_EXPR } from '@angular/compiler/src/output/output_ast';


@Component({
  selector: 'app-all-database-report',
  templateUrl: './all-database-report.component.html',
  styleUrls: ['./all-database-report.component.css']
})
export class AllDatabaseReportComponent implements OnInit {

  payout: Payout;
  locale = 'es';
  itemsBreadcrumb: any = ['Home', 'Reports', 'All Database'];
  itemsBreadcrumbMerchant: any = ['Home', 'Reports', 'Merchant Report'];
  ListPayIns: TransactionReport[] = []
  modalRef: BsModalRef;
  bsConfig: Partial<BsDatepickerConfig>;
  listColumns: string[] = [];
  listCurrency: Currency[] = [];
  userPermission: string = this.securityService.userPermission;
  countryCodeLogged:string = this.securityService.UserLogued.Country.Code
  transactionList: any[];
  currentModal: string = "";
  CurrencyLocal: string = ""
  //Filtros
  dateFrom: Date = new Date(Date.now());
  dateTo: Date = new Date(Date.now());
  lotFrom: string = null;
  lotTo: string = null;
  merchantSelect: any = null;
  statusSelect: any = null;
  grossAmount: string = null;
  netAmount: string = null;
  methodSelect: any = null;
  currencySelect: any = null;
  grossSign: any = null;
  netSign: any = null;
  statusExport: boolean = false
  objTest2: Subscription;
  lotId: string = null;
  ticketId: string = null;
  merchantId: string = null;

  @Input() fromDashboard: string = "";
  @Input() titleReport: string = "";
  @Input() IdFilter: number;
  @Input() typeReport: string
  @Output() backToDashboard = new EventEmitter();
  mainTitleReport: string = ""
  ListMerchants: any[] = [];
  ListMetodos: any[];

  //
  currentLot: string;
  totalizadores: TransactionReport = new TransactionReport({});

  Totales = {
    'GrossValue': 0, 'Amount': 0, 'Withholding': 0, 'Payable': 0, 'Pending': 0, 'Confirmed': 0, 'Com': 0, 'NetCom': 0, 'TotCom': 0, 'AccountArs': 0,
    'AccountUsd': 0, 'ProviderCost': 0, 'VatCostProv': 0, 'TotalCostProv': 0, 'PercIIBB': 0, 'PercVat': 0, 'PercProfit': 0, 'PercOthers': 0, 'Sircreb': 0
    , 'TaxDebit': 0, 'TaxCredit': 0, 'RdoOperative': 0, 'VatToPay': 0, 'RdoFx': 0
  }

  toggleFitro = true;
  ListEstados: any = [];
  ListSignos: any = [{ id: '1', symbol: '<' }, { id: '2', symbol: '<=' }, { id: '3', symbol: '>' }, { id: '4', symbol: '>=' }, { id: '5', symbol: '=' },]


  //filtros modal carga
  clientSelectCarga: any = null;
  statusSelectTransact: number = 0;

  offset: number = 0;
  pageSize: number = 20;
  transactionLotSelect: string;

  positionTop: string = "translateY(0px)"
  positionBottom: string = "";
  paramsFilter: any = {};
  urlTest: string = ""
  constructor(private clientData: ClientDataShared, private securityService: LpSecurityDataService,
    private modalServiceLp: ModalServiceLp, private bsLocaleService: BsLocaleService, private cdRef: ChangeDetectorRef, private sanitizer: DomSanitizer, private LpServices: LpMasterDataService
  ) {
   
  }

  ngOnInit() {
    if (this.fromDashboard == "true") {
      if (this.typeReport == 'PROVIDER') {
        this.mainTitleReport = 'REPORT PROVIDER COLLECTION CYCLE'
        this.paramsFilter = {
          "idEntityAccount": null,
          "id_transactioOper": null,
          "pageSize": this.pageSize,
          "offset": this.offset,
          "dateFrom": null,
          "dateTo": null,
          "lotFrom": null,
          "lotTo": null,
          "lotId": null,
          "merchantId": null,
          "merchant": null,
          "ticket": null,
          "grossSign": null,
          "grossAmount": null,
          "netSign": null,
          "netAmount": null,
          "payMethod": null,
          "currency": null,
          "id_status": null,
          "transactionType": this.IdFilter
        }
      }

      if (this.typeReport == 'MERCHANT') {
        this.mainTitleReport = 'REPORT MERCHANT PAYMENT CYCLE'
        this.paramsFilter = {
          "idEntityAccount": this.IdFilter,
          "id_transactioOper": null,
          "pageSize": this.pageSize,
          "offset": this.offset,
          "dateFrom": null,
          "dateTo": null,
          "lotFrom": null,
          "lotTo": null,
          "lotId": null,
          "merchantId": null,
          "ticket": null,
          "grossSign": null,
          "grossAmount": null,
          "netSign": null,
          "netAmount": null,
          "payMethod": null,
          "currency": null,
          "id_status": null

        }
      }
    }
    else {
      this.clientData.refreshItemsBreadCrumb(this.userPermission == 'ADMIN' ? this.itemsBreadcrumb : this.itemsBreadcrumbMerchant);
      this.clientData.setCurrentView(EnumViews.REPORTS, 'AllDbReport');
      this.paramsFilter = {
        "idEntityAccount": this.userPermission == 'ADMIN' ? null : this.securityService.UserLogued.idEntityUser,
        "id_transactioOper": null,
        "pageSize": this.pageSize,
        "offset": this.offset,
        "dateFrom": null,
        "dateTo": null,
        "lotFrom": null,
        "lotTo": null,
        "lotId": null,
        "merchant_id": null,
        "merchant": null,
        "ticket": null,
        "grossSign": null,
        "grossAmount": null,
        "netSign": null,
        "netAmount": null,
        "payMethod": null,
        "currency": null,
        "id_status": null,
        "transactionType": null

      }

    }

    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY', showWeekNumbers: false });
    this.getListClients();
    this.getListStatus();
    this.getListCurrency();
    this.getListTransactionType();

    if (this.userPermission == 'ADMIN') {

      // this.listColumns = [/*Datos*/'Processed Date', 'Provider Date', 'Payment Date', 'Ticket', 'Provider', 'Type of TX', 'Automatic', 'ID Lot', 'Merchant ID', 'Status',
      //   'Detail Status', 'Cashed', 'Paid', 'Merchant', 'User ID', /*'Gross (ARS)',*/ /*Merchant*/ 'Amount', 'Withholding', 'Payable', 'Fx Merchant', 'Pending (ARS)', 'Confirmed (ARS)',
      //   'Confirmed (USD)', 'Net Com', 'Tot Com', 'Account (ARS)', 'Account (USD)', /*Admin*/'Provider Cost', 'VAT', 'Total', 'Perc IIBB', 'Perc Vat', 'Perc Profit', 'Others', 'Sircreb',
      //   'Tax Debit', 'Tax Credit', 'Rdo Operative', 'Vat to Pay', 'FX LP', 'Rdo FX'];

      this.listColumns = [/*Datos*/'Transaction Date', 'Lot Out Date', 'Processed Date', 'Payment Date', 'Collection Date','Cashed', 'Paid', 'ID LP', 'Ticket','ID Lot Out' ,'Provider', 'Type of TX', 'Automatic', 'ID Lot', 'User ID',
        'Status', 'Detail Status', 'Merchant', 'SubMerchant', 'Merchant ID',  /*Merchant*/ 'Amount', 'AFIP Withholding', 'ARBA Withholding', 'Payable', 'Fx Merchant', 'Pending', 'Pending At LP Fx', 'Confirmed','Local Tax', 'Account Without Commission',
        'Net Com', 'Vat Com', 'Tot Com', 'Account', 'Account (USD)', /*Admin*/ 'Costo Proveedor', 'IVA', 'Total', 'Perc IIBB', 'Perc Iva', 'Perc Ganancias', 'Otros', 'Sircreb',
        'Impuesto Debito', 'Impuesto Credito', 'Rdo Operativo', 'Iva a pagar', 'FX LP', 'Rdo FX'];

    }
    else {
      this.listColumns = [/*Datos*/'Transaction Date', 'Processed Date', /*'Payment Date',*/ 'Ticket', 'Type Of TX', 'Automatic', 'ID Lot', 'Merchant', 'SubMerchant','Merchant ID', 'Status', 'Detail Status',
      /*Merchant*/ 'Amount', 'AFIP Withholding', 'ARBA Withholding', 'Payable', 'Fx Merchant', 'Pending', 'Confirmed','Local Tax','Account Without Commission', 'Net Com', 'Vat Com', 'Tot Com', 'Account', 'Account (USD)'];

      this.objTest2 = this.clientData.reloadAllDB().subscribe((data: boolean) => {

        if (data == true) {
          this.paramsFilter.offset = 0

          this.paramsFilter = {
            "idEntityAccount": this.userPermission == 'ADMIN' ? null : this.securityService.UserLogued.idEntityUser,
            "id_transactioOper": null,
            "pageSize": this.pageSize,
            "offset": 0,
            "dateFrom": null,
            "dateTo": null,
            "lotFrom": null,
            "lotTo": null,
            "lotId": null,
            "merchantId": null,
            "merchant": null,
            "ticket": null,
            "grossSign": null,
            "grossAmount": null,
            "netSign": null,
            "netAmount": null,
            "payMethod": null,
            "currency": null,
            "id_status": null,
            "transactionType": null

          }
          this.clearsFilters();
          this.countryCodeLogged = this.securityService.UserLogued.Country.Code
          this.ListPayIns = [];
        }
      })
    }

  }
  getListReport(params: any, autoScroll: boolean = false) {

    this.LpServices.Reports.getListTransactionsPayInOut(params).subscribe((data: any) => {
      if (autoScroll == false) {

        this.ListPayIns = [];
      }

      if (data != null) {
        data.forEach(_pay => {

          var payin = new TransactionReport(_pay);
          this.ListPayIns.push(payin)

        });
        this.paramsFilter.offset = this.paramsFilter.offset + this.pageSize;

        this.CurrencyLocal = this.ListPayIns[0].CurrencyLocal;
      }
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)


    }, error => {
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    })
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

  getListStatus() {

    this.LpServices.Filters.getListStatus().subscribe((data: any) => {
      if (data != null) {
        let listStatus = [];
        data.forEach(st => listStatus.push(new Status(st)))

        this.ListEstados = listStatus
      }


    }, error => { })
  }

  getListCurrency() {

    this.LpServices.Filters.getListCurrency().subscribe((_listCurrency: any) => {

      if (_listCurrency != null) {
        let listCurrency = []
        _listCurrency.forEach(cur => listCurrency.push(new Currency(cur)))
        this.listCurrency = listCurrency;
      }  
    },
      error => { })
  }

  getListTransactionType() {
    this.LpServices.Filters.getTransactionTypes().subscribe((data: any) => {
      if (data != null) {
      let listTP = []
        data.forEach(tp => listTP.push(new TransactionType(tp)))
        this.ListMetodos = listTP

      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
    })
  }
  backDashboard() {

    this.backToDashboard.emit();

  }
  filterReport() {
    var myDiv = document.getElementById('divContainerTable');
    if (myDiv != null) { myDiv.scrollTop = 0; }

    this.modalServiceLp.showSpinner();
    this.offset = 0;

    this.paramsFilter = {
      "idEntityAccount": this.userPermission == 'ADMIN' ? this.merchantSelect.idEntityUser : this.securityService.UserLogued.idEntityUser,
      "cycle": null,
      "id_transactioOper": null,
      "pageSize": this.pageSize,
      "offset": this.offset,
      "dateFrom": this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "lotFrom": this.lotFrom != null && this.lotFrom.trim().length > 0 ? this.lotFrom : null,
      "lotTo": this.lotTo != null && this.lotTo.trim().length > 0 ? this.lotTo : null,
      "lotId": this.lotId != null && this.lotId.trim().length > 0 ? this.lotId : null,
      "ticket": this.ticketId != null && this.ticketId.trim().length > 0 ? this.ticketId : null,
      "merchantId": this.merchantId != null && this.merchantId.trim().length > 0 ? this.merchantId : null,
      "grossSign": this.grossAmount != null && this.grossAmount.trim().length > 0 ? this.grossSign : null,
      "grossAmount": this.formatNumber(this.grossAmount),
      "netSign": this.netAmount != null && this.netAmount.trim().length > 0 ? this.netSign : null,
      "netAmount": this.formatNumber(this.netAmount),
      "currency": this.currencySelect,
      "id_status": this.statusSelect,
      "transactionType": this.methodSelect // reemplaza a paymethod
    }

    let indexColumnTax =  this.listColumns.findIndex( e=> e =="Local Tax" || e == "GMF 0.4%" || e =="IOF 0.38%")
    let _countryCode = this.userPermission == 'ADMIN' ? this.merchantSelect.CountryCode : this.countryCodeLogged
    this.listColumns[indexColumnTax] = _countryCode== "COL" ? "GMF 0.4%" : _countryCode == "ARG" ? "Local Tax"  : _countryCode == "BRA" ? "IOF 0.38%" : "";
    

    this.getListReport(this.paramsFilter);
  }

  exportToExcel() {
    this.statusExport = true;
    var _dateTo = new Date();
    let paramsFilter = {
      "idEntityAccount": this.userPermission == 'ADMIN' ? this.merchantSelect.idEntityUser : this.securityService.UserLogued.idEntityUser,
      "cycle": null,
      "id_transactioOper": null,
      "pageSize": null,
      "offset": 0,
      "dateFrom": this.paramsFilter.dateFrom == null ? null : this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.paramsFilter.dateTo == null ? null : this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "lotFrom": this.lotFrom != null && this.lotFrom.trim().length > 0 ? this.lotFrom : null,
      "lotTo": this.lotTo != null && this.lotTo.trim().length > 0 ? this.lotTo : null,
      "lotId": this.lotId != null && this.lotId.trim().length > 0 ? this.lotId : null,
      "ticket": this.ticketId != null && this.ticketId.trim().length > 0 ? this.ticketId : null,
      "merchantId": this.merchantId != null && this.merchantId.trim().length > 0 ? this.merchantId : null,
      "grossSign": this.grossAmount != null && this.grossAmount.trim().length > 0 ? this.grossSign : null,
      "grossAmount": this.formatNumber(this.grossAmount),
      "netSign": this.netAmount != null && this.netAmount.trim().length > 0 ? this.netSign : null,
      "netAmount": this.formatNumber(this.netAmount),
      "currency": this.currencySelect,
      "id_status": this.statusSelect,
      "transactionType": this.methodSelect // reemplaza a paymethod
    }
    let body = {
      columnsReport: this.listColumns,
      TypeReport: this.userPermission == "ADMIN" ? "ALLDATABASE" : "MERCHANT",
      requestReport: paramsFilter
    }

    this.LpServices.Export.testExport(body).subscribe((data: any) => {
      if (data != null || data != "") {

        let nameFile = this.userPermission == "ADMIN" ? 'AllDatabaseReport.xlsx' : 'MerchantReport.xlsx';

        this.downloadFile(data, nameFile);
        this.statusExport = false;
      }

    }
      , error => {

      })
  }

  downloadFile(content, filename) {
    var a = document.createElement('a');
    a.href = "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64," + content;
    a.download = filename;
    a.click();
  }
  calcTotalizers(arrayValues: any, listTotals: any) {
    var props = Object.keys(listTotals);
    arrayValues.forEach(dt => {
      props.forEach(pr => {
        if (dt.hasOwnProperty(pr)) {
          listTotals[pr] = listTotals[pr] + (parseFloat(dt[pr] || 0))

        }
      })
    })
  }

  onScrollReport() {
    this.getListReport(this.paramsFilter, true);
  }

  scrollFixedHead($event: Event) {
    let divTabla: HTMLDivElement = <HTMLDivElement>$event.srcElement
    let scrollOffset = divTabla.scrollTop;
    let tabla: HTMLTableElement = <HTMLTableElement>divTabla.children[0]

    let offsetBottom = (tabla.offsetHeight - divTabla.offsetHeight + 15) * -1 + scrollOffset
    this.positionBottom = "translateY(" + offsetBottom + "px)"
    this.positionTop = "translateY(" + scrollOffset + "px)"
  }

  reOrderTfootIndicators() {
    let _divTabla: HTMLDivElement = <HTMLDivElement>document.getElementById('divContainerTable')
    let scrollOffset = _divTabla.scrollTop;
    let tabla: HTMLTableElement = <HTMLTableElement>_divTabla.children[0]
    let offsetBottom = (tabla.offsetHeight - _divTabla.offsetHeight + 15) * -1 + scrollOffset
    this.positionBottom = "translateY(" + offsetBottom + "px)"

  }

  formatNumber(numAmount: string): string {
    var newMonto = numAmount;
    if (numAmount != null && numAmount.trim().length > 0) {
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


    }
    else {
      newMonto = null;

    }

    return newMonto;
  }

  validateNumber(value: any) {
    if (value != "" || value != null) {
      var regexNumber = /^\d*\.?\d*$/;
      return regexNumber.test(value);
    }
    else {
      return true;
    }
  }

  inputOnlyNumber(event) {
    // const pattern = /[0-9]/;
    const pattern = /^-?\d*[.,]?\d*$/;
    const inputChar = String.fromCharCode(event.charCode);

    if (!pattern.test(inputChar)) { event.preventDefault(); }
  }
  initializeTotals() {
    let auxTotals = this.Totales;
    Object.keys(auxTotals).forEach(function (key) { auxTotals[key] = 0 }); //Inicializo los totalizadores a cero

  }
  sanitize(url: string) {
    return this.sanitizer.bypassSecurityTrustUrl(url);
  }
  clearsFilters() {

    this.dateFrom = new Date(Date.now());
    this.dateTo = new Date(Date.now());
    this.lotFrom = null;
    this.lotTo = null;
    this.merchantSelect = null;
    this.statusSelect = null;
    this.grossAmount = null;
    this.netAmount = null;
    this.methodSelect = null;
    this.currencySelect = null;
    this.grossSign = null;
    this.netSign = null;
    this.statusExport = false

  }


  ngOnDestroy() {

    if (this.objTest2 != undefined) {

      this.objTest2.unsubscribe();
    }


  }


}
