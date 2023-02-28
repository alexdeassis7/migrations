import { Component, OnInit } from '@angular/core';
import { DetailClientTransaction } from 'src/app/models/detailClientTransactionModel'
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { EnumViews } from '../../services/enumViews';
import { Currency } from 'src/app/models/currencyModel'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { Country } from 'src/app/models/countryModel';
import { environment } from '../../../../environments/environment.prod';
@Component({
  selector: 'app-details-clients-transaction-report',
  templateUrl: './details-clients-transaction-report.component.html',
  styleUrls: ['./details-clients-transaction-report.component.css']
})
export class DetailsClientsTransactionReportComponent implements OnInit {
  constructor(private LpServices: LpMasterDataService,
    private modalServiceLp: ModalServiceLp,
    private clientData: ClientDataShared,
    private securityService: LpSecurityDataService) { }



  ListColumns: any = ['ID TX', 'ID Lot', 'Tx Date','Processed Date','Transaction Type' ,'Ticket', 'Alternative Ticket','Status', 'Detail Status', 'ID Lot Out', 'Lot Out Date', 'Merchant', 'ID Merchant', 'SubMerchant', 'Name', 'Country', 'City', 'Address', 'Email', 'Birthdate', 'Document Number', 'Phone Number', 'Bank Branch', 'Bank Code', 'Account Number', 'Sender Email', 'Sender Phone Number', 'Amount','Amount (USD)', 'Payable', 'FxMerchant', 'Pending', 'Confirmed', 'LocalTax', 'Commission']
  
  itemsBreadcrumb: any = ['Home', 'Reports', 'Details Client Transaction'];
  ListDCT: DetailClientTransaction[] = [];
  bsConfig: Partial<BsDatepickerConfig>;
  listCurrency: Currency[];
  positionTop: string = "translateY(0px)"
  positionBottom: string = "";
  paramsFilter: any = {};
  offset: number = 0;
  pageSize: number = 80;
  userPermission: string = this.securityService.userPermission;
  ListMerchants: any[];
  ListSubMerchant: any[];
  merchantSelect: any = null;
  subMerchantSelect: any = null;
  statusExport: boolean = false
  ListSubmerchantFilter: any[] = [];
  //Filtros
  dateFrom: Date = new Date(Date.now());
  dateTo: Date = new Date(Date.now());
  lotFrom: string = null;
  lotTo: string = null;
  currencySelect: any = null;
  clientSelect: any = null;
  toggleFitro = false;
  merchantId: any;
  idTransaction: any;
  ListCountries: any[] = []
  countryCode: any = null;
  ListMerchantsFilter: any[] = [];

  ngOnInit() {
    this.modalServiceLp.showSpinner();
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.REPORTS, 'TrClientDetails');
    this.paramsFilter = {
      "pageSize": this.pageSize,
      "offset": this.offset,
      "dateFrom": this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "lotFrom": null,
      "lotTo": null,
      "idEntitySubMerchant": null,
      "idEntityUser": this.merchantSelect == null ? this.securityService.UserLogued.idEntityUser : this.merchantSelect,
      "idEntityAccount": this.securityService.UserLogued.idEntityAccount,
      'customer_id': this.securityService.UserLogued.customer_id,
      "countryCode": null
    }

    this.getListSubmerchant();
    this.getListReport(this.paramsFilter);
    this.getListCurrency();
    this.getListClients();
    this.getCountries();

    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY', showWeekNumbers: false });
  }

  getListReport(params: any, autoScroll: boolean = false) {

    this.LpServices.Reports.getListTransactionsClientDetails(params).subscribe((data: any) => {

      if (autoScroll == false) { this.ListDCT = []; }

      if (data != null) {
        data.forEach(DCT => {
          let _dct = new DetailClientTransaction(DCT)
          this.ListDCT.push(_dct);
        });
        this.paramsFilter.offset = this.paramsFilter.offset + this.pageSize;
        // console.log(this.ListDCT)
      }
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    },
      error => {
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
    // this.getMoreDataDashboard(this.paramsFilter);
    this.getListReport(this.paramsFilter, true);
  }

  filterReport() {
    this.ListDCT = [];
    var myDiv = document.getElementById('divContainerTable');

    if (myDiv != null) { myDiv.scrollTop = 0; }

    this.modalServiceLp.showSpinner();
    this.offset = 0;
    var _dateTo = new Date();
    // _dateTo.setDate(this.dateTo.getDate() + 1)
    this.paramsFilter = {
      "pageSize": this.pageSize,
      "offset": this.offset,
      "dateFrom": this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "idEntitySubMerchant": this.subMerchantSelect,
      "merchantId": this.merchantId != null && this.merchantId.trim().length > 0 ? this.merchantId : null,
      "countryCode": this.countryCode != null ? this.countryCode : null,
      "idEntityUser": this.merchantSelect == null ? this.securityService.UserLogued.idEntityUser : this.merchantSelect,
      "idEntityAccount": this.securityService.UserLogued.idEntityAccount,
      'customer_id': this.securityService.UserLogued.customer_id,
    }

    this.getListReport(this.paramsFilter);
  }

  loadMerchantFilter(code: any) {
    this.merchantSelect = null
    this.ListMerchantsFilter = this.ListMerchants.filter(e => e.CountryCode == code);
    if(this.ListMerchantsFilter.length == 1){
      this.merchantSelect = this.ListMerchantsFilter[0].code;
    }
    this.merchantSelect = null
    this.subMerchantSelect = null;
  }

  merchantSelectIsColombia(idMerchant: number) {
    var colombiaName = 'colombia';
    var merchant = this.ListMerchants.find(m => m.idEntityUser == idMerchant);
    return merchant.FirstName.toLowerCase().indexOf(colombiaName) !== -1;
  }

  exportColombiaReport() {
    var dateFrom = this.dateFrom.toISOString().replace(/-|T.*/g, '');
    var dateTo = this.dateTo.toISOString().replace(/-|T.*/g, '');
    var paramsArr = [{ Key: "idEntityUser", Val: this.merchantSelect }, { Key: "fromDate", Val: dateFrom }, { Key: "toDate", Val: dateTo }];

    let body = {
      FileName: 'Colombia_TD_Report_' + dateFrom + '_' + dateTo,
      Name: "LP_Operation.GetTransactionDetailGenericByUser",
      IsSP: true,
      Parameters: paramsArr
    }

    this.LpServices.Export.ExportReport(body).subscribe((data: any) => {
      if (data != null) {

        this.downloadFile(data, body.FileName + '.xlsx');
      }
    })
  }

  exportToExcel() {
    this.statusExport = true;
    // this.paramsFilter.offset = 0;
    var _dateTo = new Date();
    // _dateTo.setDate(this.dateTo.getDate() + 1)
    let paramsFilter = {
      "pageSize": null,
      "offset": 0,
      "dateFrom": this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "lotFrom": this.lotFrom != null && this.lotFrom.trim().length > 0 ? this.lotFrom : null,
      "lotTo": this.lotTo != null && this.lotTo.trim().length > 0 ? this.lotTo : null,
      "idEntitySubMerchant": this.subMerchantSelect,
      // "currency": this.currencySelect,
      "idEntityUser": this.merchantSelect == null ? this.securityService.UserLogued.idEntityUser : this.merchantSelect,
      "idEntityAccount": this.securityService.UserLogued.idEntityAccount,
      "merchantId": this.merchantId != null && this.merchantId.trim().length > 0 ? this.merchantId : null,
      "idTransaction":this.idTransaction != null && this.idTransaction.trim().length > 0 ? this.idTransaction : null,
      "countryCode": this.countryCode != null ? this.countryCode : null
    }
    let body = {
      columnsReport: this.ListColumns,
      TypeReport: 'DETAILS_TRANSACTION_CLIENT',
      requestReport: paramsFilter
    }
    this.LpServices.Export.testExport(body).subscribe((data: any) => {
      if (data != null) {

        let nameFile = 'TxsDetailReport.xlsx';

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
  getListCurrency() {

    this.LpServices.Filters.getListCurrency().subscribe((_listCurrency: any) => {

      if (_listCurrency != null) {
        let listCurr = []
        _listCurrency.forEach(cur => listCurr.push(new Currency(cur)));

        this.listCurrency = listCurr;

      }

    },
      error => { })
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
  getListSubmerchant() {
    let idEntityUser = (this.userPermission == "COMMON") ? this.securityService.UserLogued.customer_id.toString() : '0';
    this.LpServices.Filters.getListSubMerchantUser(idEntityUser).subscribe((_listSubmerchant: any[]) => {

      let auxArray = [];

      _listSubmerchant.forEach(subM => {

        auxArray.push(subM);

      });

      this.ListSubMerchant = auxArray;
      // console.log( this.ListSubMerchant )
    },
      error => {


      })

  }


  getListClients() {
    let idEntityUser = (this.userPermission == "COMMON") ? this.securityService.UserLogued.idEntityAccount : '0';
    this.LpServices.Filters.getListClients(idEntityUser.toString()).subscribe((data: any) => {

      if (data != null) {

        this.ListMerchants = data;
        this.ListMerchantsFilter = data;

        if(this.userPermission == 'COMMON'){
          this.merchantSelect = this.ListMerchantsFilter[0].idEntityUser;
          this.loadSubmerchantFilter(this.ListMerchantsFilter[0].idEntityUser)
        }
        // this.clientSelect = this.ListMerchants[0];

      }

    }, error => {

      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }
  loadSubmerchantFilter(idEntity: number) {
    this.subMerchantSelect = null;
    this.ListSubmerchantFilter = this.ListSubMerchant.filter(e => e.idEntityUser == idEntity)

  }

  inputOnlyNumber(event) {
    // const pattern = /[0-9]/;
    const pattern = /^-?\d*[.,]?\d*$/;
    const inputChar = String.fromCharCode(event.charCode);

    if (!pattern.test(inputChar)) { event.preventDefault(); }


  }
}
