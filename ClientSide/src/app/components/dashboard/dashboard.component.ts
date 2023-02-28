import { Component, OnInit, ChangeDetectorRef } from '@angular/core'
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service'
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { defineLocale } from 'ngx-bootstrap/chronos'
import { esLocale } from 'ngx-bootstrap/locale'
import { EnumViews } from '../services/enumViews'
import { Router } from '@angular/router'
import { AppConstants } from '../../constant'
import { ListMain } from 'src/app/models/ListMainModel';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { Subscription } from 'rxjs'
import { ClientDashboardData } from 'src/app/models/clientDashboardModel';
// import { MediaMatcher } from '@angular/cdk/layout';

// import { ToastrService } from 'ngx-toastr';

defineLocale('es', esLocale)

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})

export class DashboardComponent implements OnInit {
  accionSelect: any = AppConstants.ListTransactions[0].val
  bsConfig: Partial<BsDatepickerConfig>
  ciclo: string = 'WEEK'
  clientSelectCarga: any = null
  fecha: Date = new Date(Date.now())
  idSelect: number
  typeReport: string

  impuestoCredito: string = "";
  itemsBreadcrumb: any = ['Home', 'Dashboard'];
  ListClients: any[];
  ListDollarToday: any[];
  ListMainReport: ListMain[];

  ListProviderCycle: any[]
  ListMerchantCycle: any[]
  modalRef: BsModalRef

  monto: string = ""
  positionTop: string = "translateY(0px)"
  showReportState: boolean = false
  titleSelect: string = ""
  userPermission: string = this.securityService.userPermission
  totalsTest = { 'spot': 0, 'sell': 0, 'base_sell': 0, 'buy': 0, 'base_buy': 0 };
  //
  mainReportTotals = { 'gross': 0, 'txsQuantity': 0 }
  providerCycleTotals = { 'gross': 0, 'comission': 0, 'vat': 0, 'percIIBB': 0, 'percVat': 0, 'percProfit': 0, 'net': 0 }
  merchantCycleTotals = { 'gross': 0, 'comission': 0, 'vat': 0, 'ars': 0, 'usd': 0, 'exchange': 0, 'revenueOper': 0, 'revenueFx': 0 }

  resMatch: MediaQueryList ;
  // resChange: boolean  = false;

  subs:Subscription
  ListClientReport: ClientDashboardData[];
  ListClientReportFilter: ClientDashboardData[];
  ClientReportTotals: ClientDashboardData;
  balanceCountryCodes: any = [];
  balanceSelectedCountry: any = null;
  countryTotals: ClientDashboardData[] = [];


  constructor(
    private clientData: ClientDataShared,
    private securityService: LpSecurityDataService,
    private modalServiceLp: ModalServiceLp,
    private router: Router,
    private LpServices: LpMasterDataService,
    private chRef:ChangeDetectorRef
  
  ) {
 
    // this.resMatch =  window.matchMedia("(min-width: 1305px)")
    this.resMatch =  window.matchMedia("(min-width: 1320px)")

    
    this.WidthChange = () =>  chRef.detectChanges();


    
    this.resMatch.addListener(this.WidthChange);
 
    //  this.WidthChange(this.resMatch);
  }
  ngOnInit() {
    this.modalServiceLp.showSpinner();
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb)
    this.clientData.setCurrentView(EnumViews.DASHBOARD)
    
    this.getListClients()
    this.getDollarToday()
    this.getMainReport(this.ciclo)
    this.getProviderCycle()
    this.getMerchantCycle() 
    this.getMerchantReport();

    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY' ,showWeekNumbers: false})
  
  }

  orderBy(field){
    this.ListClientReportFilter.sort((a, b) => (a[field] > b[field]) ? 1 : -1);
  }

  hideReport() {
    this.showReportState = false
  }

  private WidthChange: () => void;

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

  getDollarToday() {
    this.LpServices.Dashboard.getDollarToday().subscribe((data: any) => {
      if (data != null) {
        this.ListDollarToday = data;
        this.calcTotalizers(this.ListDollarToday, this.totalsTest);
      }
    }, error => {
 
      console.log('error')

    })
  }

  getListClients() {
    this.LpServices.Filters.getListClients().subscribe((data: any) => {
      if (data != null) {
        this.ListClients = data
        // this.clientSelect = this.ListClients[0]
        this.clientSelectCarga = this.ListClients[0]
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
    })
  }

  getMainReport(type: string) {
    this.LpServices.Dashboard.getMainReport(type).subscribe((data: any) => {
      if (data != null) {
        this.ListMainReport = data;
        // data.forEach(res => {
        // this.ListMainReport.push(res);
        // })
        // this.calcTotalizers(this.ListMainReport, this.mainReportTotals)
        // mainReportTotals
      }
    }, error => {
      console.log('Error')
    })
  }

  getProviderCycle() {
    this.LpServices.Dashboard.getProviderCycle().subscribe((data: any) => {
      if (data != null) {
        this.ListProviderCycle = data
        this.calcTotalizers(this.ListProviderCycle, this.providerCycleTotals);
      }
    }, error => {
      console.log('Error')
    })
  }
  getMerchantCycle() {
    this.LpServices.Dashboard.getMerchantCycle().subscribe((data: any) => {
      if (data != null) {
        this.ListMerchantCycle = data

        this.calcTotalizers(this.ListMerchantCycle, this.merchantCycleTotals);

      }
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    }, error => {
      console.log('Error')
    })
  }
  handleRadioButton(type: string) {
    this.getMainReport(type)
    let auxTotals = this.mainReportTotals;
    Object.keys(auxTotals).forEach(function (key) { auxTotals[key] = 0 }); //Inicializo los totalizadores a cero
    // this.toastr.success('Hello world!', 'Toastr fun!');

  }



  payMerchant(idMerchant: number, startCycle: string, endCycle: string) {

    var parametros = {
      idEntityMerchant: idMerchant,
      startCycle: startCycle,
      endCycle: endCycle

    }
    this.LpServices.Dashboard.payCycleMerchant(parametros).subscribe((datos: any) => {

      var data = JSON.parse(datos);
      if (datos != null && data.Status == 'OK') {
        this.modalServiceLp.openModal('SUCCESS', 'Exito', 'Se pagaron todas las transacciones para el ciclo seleccionado.')
      }
      else {
        //this.modalRef.hide()
        this.modalServiceLp.openModal('ERROR', 'Operacion erronea', datos.Status + ' - ' + datos.StatusMessage)
      }
    },
      error => {
        // this.modalRef.hide()
        if (error.status == 404) {

          this.modalServiceLp.openModal('ERROR', 'Operacion erronea', error.message)
        }
        else {

          this.modalServiceLp.openModal('ERROR', 'Operacion erronea', error.error.ExceptionType + ' - ' + error.error.ExceptionMessage)
        }

      })
  }

  showReport(nameReport: string, idElement: any, typeReport: string) {
    this.titleSelect = nameReport.toUpperCase()
    this.idSelect = idElement
    this.typeReport = typeReport

    // this.dataReport = { method: payMethod, id:  idMethod}
    this.showReportState = true
  }


  validateNumber(value: any) {
    if (value != "") {
      var regexNumber = /^\d*\.?\d*$/
      return regexNumber.test(value)
    }
    else {
      return true
    }
  }


  getMerchantReport() 
  {
    this.LpServices.Dashboard.getClientReport().subscribe((data: ClientDashboardData[]) => {
      if (data != null) {
        this.ListClientReport = data.filter( 
          x => x.SaldoActual < 0 || x.SaldoActual > 0 || x.AmtInProgressPI > 0 || x.AmtInProgressPO > 0 || x.AmtReceived > 0);
        
          this.ListClientReportFilter = this.ListClientReport;
        this.ListClientReport.forEach(item => {
          if(this.balanceCountryCodes.indexOf(item.CountryCode) == -1){
            this.balanceCountryCodes.push(item.CountryCode);
          }
        });
      }
    }, 
    error => {
      console.log('Error');
    });
  }

  filterBalanceList(){
    if(this.balanceSelectedCountry){
      this.ListClientReportFilter = this.ListClientReport.filter(x => x.CountryCode == this.balanceSelectedCountry)

      let currencies = Array.from(new Set(this.ListClientReportFilter.map( item => item.CurrencyCode))); 


      currencies.forEach(item => {
        let currencyItems = this.ListClientReportFilter.filter(x => x.CurrencyCode == item);
        let totals = [];
        currencyItems.forEach(client => {
          totals["AmtInProgressPO"] = ((totals["AmtInProgressPO"]) ? totals["AmtInProgressPO"] : 0) + ((client.AmtInProgressPO) ? client.AmtInProgressPO : 0);
          totals["AmtInProgressPI"] = totals["AmtInProgressPI"] || 0 + ((client.AmtInProgressPI) ? client.AmtInProgressPI : 0);
          totals["AmtReceived"] = (totals["AmtReceived"] || 0) + ((client.AmtReceived) ? client.AmtReceived : 0);
          totals["AmtOnHoldPO"] = (totals["AmtOnHoldPO"] || 0) + ((client.AmtOnHoldPO) ? client.AmtOnHoldPO : 0);
          totals["CommTaxesInProgressPI"] = (totals["CommTaxesInProgressPI"] || 0) + ((client.CommTaxesInProgressPI) ? client.CommTaxesInProgressPI : 0);
          totals["CommTaxesInProgressPO"] = (totals["CommTaxesInProgressPO"] || 0) + ((client.CommTaxesInProgressPO) ? client.CommTaxesInProgressPO : 0);
          totals["SaldoActual"] = ((totals["SaldoActual"]) ? totals["SaldoActual"] : 0) + ((client.SaldoActual) ? client.SaldoActual : 0);
          totals["cntInProgressPI"] = (totals["cntInProgressPI"] || 0) + ((client.cntInProgressPI) ? client.cntInProgressPI : 0);
          totals["cntInProgressPO"] = (totals["cntInProgressPO"] || 0)+ ((client.cntInProgressPO) ? client.cntInProgressPO : 0);
          totals["cntOnHoldPO"] = (totals["cntOnHoldPO"] || 0)+ ((client.cntOnHoldPO) ? client.cntOnHoldPO : 0);
          totals["cntReceived"] = (totals["cntReceived"] || 0) + (client.cntReceived || 0);
          totals["CurrencyCode"] = item;
          totals["LastName"] = "TOTALS " + item;
        });

        this.ListClientReportFilter.push(new ClientDashboardData(totals));
      });

    } else {
      this.ListClientReportFilter = this.ListClientReport;
    }
  }

  ngOnDestroy() {
    
    this.resMatch.removeListener(this.WidthChange)
    
    // this.resMatch = null

  }
  
  // public get resChange() : Boolean {
  //   return !this.resMatch.matches
  //   // return true
  // }
  
  //  httpPromise (resource) {

  //   return new Promise((resolve, rejection) => {
  //     $.get(baseURL + resource, (data) => {
  //       // Caso de opereación exitosa
  //       resolve(data)
  //     })
  //     .fail(function(err) {
  //       // Caso de opereación fallida
  //       rejection(err)
  //     })
  //   })
  // }
}
