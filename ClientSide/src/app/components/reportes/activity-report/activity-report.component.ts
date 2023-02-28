
import { Component, OnInit, Input, EventEmitter, Output, ChangeDetectorRef } from '@angular/core';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { Payout, TransactionList } from 'src/app/models/payoutModel';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { TransactionReport } from 'src/app/models/transactionModel';
import { EnumViews } from '../../services/enumViews';
import { Status } from 'src/app/models/statusModel';
import { Currency } from 'src/app/models/currencyModel'
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { Country } from 'src/app/models/countryModel';
import { environment } from '../../../../environments/environment.prod';

@Component({
  selector: 'app-activity-report',
  templateUrl: './activity-report.component.html',
  styleUrls: ['./activity-report.component.css']
})
export class ActivityReportComponent implements OnInit {

  @Input() fromDashboard: boolean = false;
  @Input() titleReport: string = "";
  @Input() IdFilter: number;
  @Input() typeReport: string
  @Output() backToDashboard = new EventEmitter();

  resp: any;
  payout: Payout;
  locale = 'es';

  itemsBreadcrumb: any = ['Home', 'Reports','Activity Report'];

  ListPayIns: any[] = [];
  modalRef: BsModalRef;
  checkTest: boolean = false;
  bsConfig: Partial<BsDatepickerConfig>;
  listColumns: string[] = [];
  userPermission: string = this.securityService.userPermission;
  transactionList: any[];
  currentModal: string = "";

  listCurrency: any = []
  ListMetodos: any[];


  //Filtros
  dateFrom: Date = new Date(Date.now());;
  dateTo: Date =new Date(Date.now());;
  lotFrom: string;
  lotTo: string;
  merchantSelect: any = null;
  statusSelect: any = null;
  grossAmount: string = null;
  netAmount: string = null;
  methodSelect: any;
  currencySelect: any = null;
  grossSign: any = null;
  netSign: any = null;
  statusExport: boolean = false
  ListMerchants: any = [];
  ListMerchantFilter: any[] = [];
  impuestoCredito: string = ""
  lotId: string = null;
  ticketId: string = null;
  merchantId: string = null;
  ListCountries: any[] = [];
  countryCode: any = null;
  //
  currentLot: string;
  ListOrderBy: any[] = [{
    name: "Processed Date",
    value: 1
  }, {
    name: "Transaction Date",
    value: 2
  },
  {
    name: "Transaction Type",
    value: 3
  },
  {
    name: "Status",
    value: 4
  }];
  
  orderBy: any = 1;

  ListOrderType: any[] = [
    {
      name: "Ascending",
      value: 1
    },
    {
      name: "Descending",
      value: 2
    }
  ];
  orderType: any = 1;

  ListDateFilterBy: any[] = [
    {
      name: 'Processed Date',
      value: 1
    },
    {
      name: 'Transaction Date',
      value: 2
    }
  ];
  dateFilterBy: any = 1;

  toggleFitro = true;
  ListMeses: any[] = [{ name: 'ENERO', val: '1' }, { name: 'FEBRERO', val: '2' }, { name: 'MARZO', val: '3' }, { name: 'ABRIL', val: '4' }, { name: 'MAYO', val: '5' },
  { name: 'JUNIO', val: '6' }, { name: 'JULIO', val: '7' }, { name: 'AGOSTO', val: '8' }, { name: 'SEPTIEMBRE', val: '9' }, { name: 'OCTUBRE', val: '10' },
  { name: 'NOVIEMBRE', val: '11' }, { name: 'DICIEMBRE', val: '12' }]

  ListTransactions: any = [{ name: 'PayIn', val: '1' }, { name: 'PayOut', val: '2' }]
  accionSelect: any = this.ListTransactions[0].val;
  ListEstados: any = []
  Totales = {
    'GrossValue': 0, 'Amount': 0, 'Withholding': 0, 'Payable': 0, 'Pending': 0, 'Confirmed': 0, 'Com': 0, 'NetCom': 0, 'TotCom': 0, 'AccountArs': 0,
    'AccountUsd': 0, 'ProviderCost': 0, 'VatCostProv': 0, 'TotalCostProv': 0, 'PercIIBB': 0, 'PercVat': 0, 'PercProfit': 0, 'PercOthers': 0, 'Sircreb': 0
    , 'TaxDebit': 0, 'TaxCredit': 0, 'RdoOperative': 0, 'VatToPay': 0, 'RdoFx': 0
  }

  //filtros dashboard
  clientSelect: any = null;
  cicloSelect: any = null;
  estSelect: any = null;
  trSelect: any = null;

  //filtros modal carga
  clientSelectCarga: any = null;

  estSelectTransact: number = 0;


  offset: number = 0;
  offsetTr: number = 0;
  transactionLotSelect: string;
  pageSize: number = 15;
  positionTop: string = "translateY(0px)"
  paramsFilter: any = {};
  positionBottom: string = ""
  searchInput: string = ""

  constructor(private clientData: ClientDataShared, private securityService: LpSecurityDataService, private cdRef: ChangeDetectorRef, private LpServices: LpMasterDataService, private modalServiceLp: ModalServiceLp) { }

  ngOnInit() {

    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY' ,showWeekNumbers: false});
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.NEWREPORTS, 'ActivityReport');

    this.paramsFilter = { 
      "idEntityUser": null, 
      "idEntityAccount": null, 
      "cycle": null, "id_status": null, 
      "idTransactioOper": null, 
      "pageSize": this.pageSize, 
      "offset": this.offset 
    };

    this.getListClients();
    this.getCountries();
    this.getListStatus();
    this.getListTransactionType();
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

  getCountries() {

    if(this.userPermission  == 'ADMIN'){
      environment.Countries.map((item) => {
        let country = new Country({
          Code: item.Code,
          Name: item.Name,
          Currency: item.Currency,
          FlagIcon: item.FlagIcon,
          NameCode: item.NameCode,
          Description: item.Description
        })
        country.addIcon()
        this.ListCountries.push(country)
      });
    }
    else{
      let countries = JSON.parse(localStorage.getItem('ListCountries'))
      
      if (countries.length > 0) {
                    
        countries.forEach(count => {

          let country = new Country(count)
          country.addIcon();

          this.ListCountries.push(country)

        }); 
      }
    }
    
    if(this.userPermission == "COMMON") {
      this.countryCode = this.securityService.UserLogued.Country.Code;
    }
  }

  loadProviderFilter(code: any) {
    this.currencySelect = null
    this.merchantSelect = null
    let countrySelect = this.ListCountries.filter(e => {
      if(e.Code == code){
        return e
      }
    });
    if(countrySelect.length > 0){
      this.currencySelect = countrySelect[0].Currency;
    }
    this.ListMerchantFilter = this.ListMerchants.filter(e => e.CountryCode == code);
  }

  getListClients() {
    let idEntityUser = (this.userPermission == "COMMON") ? this.securityService.UserLogued.idEntityAccount.toString() : '0';
    this.LpServices.Filters.getListClients(idEntityUser).subscribe((data: any) => {
      if (data != null) {

        this.ListMerchants = data;
        this.clientSelectCarga = this.ListMerchants[0];

        if(this.userPermission == 'COMMON'){
          this.loadProviderFilter(this.securityService.UserLogued.Country.Code);
          this.merchantSelect = this.ListMerchantFilter[0].idEntityUser;
        }

      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }

  getListTransactionType() {
    this.LpServices.Filters.getTransactionTypes().subscribe((data: any) => {
      if (data != null) {
        this.ListMetodos = data
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
    })
  }

  filterReport() {
    var myDiv = document.getElementById('divContainerTable');
    if(myDiv != null){ myDiv.scrollTop = 0;  }
    
    this.modalServiceLp.showSpinner();
    this.offset = 0;
    this.paramsFilter = {
      "idEntityUser": this.merchantSelect == null ? this.securityService.UserLogued.idEntityUser : this.merchantSelect,
      "idEntityAccount": this.securityService.UserLogued.idEntityAccount,
      'customer_id': this.securityService.UserLogued.customer_id,
      "pageSize": this.pageSize,
      "offset": this.offset,
      "dateFrom": this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "merchantId": this.searchInput != null && this.searchInput.trim().length > 0 ? this.searchInput : null,

      "payMethod": this.methodSelect,
      "transactionType": this.methodSelect,
      "id_status": this.statusSelect,
      "orderBy": this.orderBy,
      "orderType": this.orderType,
      "countryCode": this.countryCode,
      "dateFilterBy": this.dateFilterBy
    }
    this.getListReportMerchant(this.paramsFilter);

  }
  onScrollReport() {
   
    //this.getListReportMerchant(this.paramsFilter, true);
  }
  // exportAgrouped(){
  //   var dateFrom = this.paramsFilter.dateFrom == null ? this.dateFrom.toISOString().replace(/-|T.*/g, '') : this.paramsFilter.dateFrom;
  //   var dateTo = this.paramsFilter.dateTo == null ? this.dateTo.toISOString().replace(/-|T.*/g, '') : this.paramsFilter.dateTo;
  //   var paramsArr = [{Key: "merchantId", Val: this.merchantSelect.idEntityUser },{Key: "dateFrom", Val: dateFrom },{Key: "dateTo", Val: dateTo }];

  //   if (this.statusSelect)
  //     paramsArr.push({Key: "statusId", Val: this.statusSelect});

  //   let body = {
  //     FileName: 'Merchant_Report_Agrouped_' + dateFrom + '_' + dateTo,
  //     Name: "LP_Filter.GetMerchantReportAgrouped",
  //     IsSP:true,
  //     Parameters: paramsArr
  //   }

  //   this.LpServices.Export.ExportReport(body).subscribe((data:any)=>{
  //     if (data != null) {

  //       this.downloadFile(data, body.FileName + this.merchantSelect.FirstName + '.xlsx');
  //     } 
  //   })
  // }
  exportToExcel() {
    // this.paramsFilter.offset = 0;
    var _dateTo = new Date();
    _dateTo.setDate(this.dateTo.getDate() + 1)
    this.statusExport = true;
    let paramsFilter = {
      "idEntityUser": this.merchantSelect == null ? this.securityService.UserLogued.idEntityUser : this.merchantSelect,
      "idEntityAccount": this.securityService.UserLogued.idEntityAccount,
      'customer_id': this.securityService.UserLogued.customer_id,
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
      "merchantId": this.searchInput != null && this.searchInput.trim().length > 0 ? this.searchInput : null,
      "grossSign": this.grossAmount != null && this.grossAmount.trim().length > 0 ? this.grossSign : null,
      "grossAmount": this.formatNumber(this.grossAmount),
      "netSign": this.netAmount != null && this.netAmount.trim().length > 0 ? this.netSign : null,
      "netAmount": this.formatNumber(this.netAmount),
      "currency": this.currencySelect,
      "id_status": this.statusSelect,
      "transactionType": this.methodSelect,
      "orderBy": this.orderBy,
      "orderType": this.orderType,
      "countryCode": this.countryCode,
      "dateFilterBy": this.dateFilterBy
    }
    let body = {
      columnsReport: this.listColumns,
      TypeReport: "ACTIVITYREPORT",
      requestReport: paramsFilter
    }
    this.LpServices.Export.testExport(body).subscribe((data: any) => {
      if (data != null) {
      
        let nameFile = 'ActivityReport.xlsx';
      
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

  getListReportMerchant(params: any, autoScroll: boolean = false) {
    this.LpServices.Reports.getListActivityReport(params).subscribe((data: any) => {

      if (autoScroll == false) {
        this.ListPayIns = [];
      }

      if (data != null) {
        let index = 0;
        data.forEach(_pay => {
          if(index == 0){
            this.listColumns = Object.keys(_pay);
          }
          this.ListPayIns.push(_pay);
          index++;
        });
        this.paramsFilter.offset = this.paramsFilter.offset + this.pageSize;
      }
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    }, error => {
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    })
  }

  backDashboard() {
    this.backToDashboard.emit();
  }

  initializeTotals() {
    let auxTotals = this.Totales;
    Object.keys(auxTotals).forEach(function (key) { auxTotals[key] = 0 }); //Inicializo los totalizadores a cero
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
}
