import { Component, OnInit } from '@angular/core';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { EnumViews } from '../../services/enumViews';
import { Currency } from 'src/app/models/currencyModel'
import { OperationRetention } from 'src/app/models/operationRetentionModel'
import { RetentionReg } from 'src/app/models/RetentionRegModel';

import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';

@Component({
  selector: 'app-operation-retention-report',
  templateUrl: './operation-retention-report.component.html',
  styleUrls: ['./operation-retention-report.component.css']
})
export class OperationRetentionReportComponent implements OnInit {

  constructor(private LpServices: LpMasterDataService,
    private modalServiceLp: ModalServiceLp,
    private clientData: ClientDataShared,
    private securityService: LpSecurityDataService) { }

  ListColumns: any = ['ID TX','Transaction Date','ProcessedDate',   'Ticket', 'Merchant ID', 'FileName', 'Certificate Number','Retention Type', 'Gross Amount','WithHoldings', 'NetAmount',
   'CUIT', 'Name','CBU','Regime Number']
  itemsBreadcrumb: any = ['Home', 'Reports', 'Merchant Withholding'];
  ListOperationRetention: any[] = [];

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
  ListRetentionReg: any[] = []
  merchantSelect: any = null;
  regSelect: any = null;
  subMerchantSelect: any = null;
  statusExport: boolean = false
  toggleFitro = false;
  //Filtros
  dateFrom: Date = new Date(Date.now());
  dateTo: Date = new Date(Date.now());
  lotFrom: string = null;
  lotTo: string = null;
  currencySelect: any = null;
  clientSelect: any = null;
  cuit:string = null;
  idTransaction:string = null;
  ticketSearch:string = null;
  merchantIdSearch:string = null
  

  ngOnInit() {


    this.modalServiceLp.showSpinner();
    this.paramsFilter = {
      "pageSize": this.pageSize,
      "offset": this.offset,
      "dateFrom": this.dateFrom != null ? this.dateFrom.toISOString().replace(/-|T.*/g, '') : null,
      "dateTo": this.dateTo!= null ? this.dateTo.toISOString().replace(/-|T.*/g, '') : null,
      "lotFrom": null,
      "lotTo": null,
      "ticket":null,
      "merchantId": null,
      "idEntitySubMerchant": null,
      "idEntityUser": null
    }
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.REPORTS, 'OperationRetention');
    this.getListReport(this.paramsFilter)
    this.getListClients();
    this.getListSubmerchant();
    this.getListRetentionsReg();
    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY' ,showWeekNumbers: false});
  }

  getListReport(params: any, autoScroll: boolean = false) {

    this.LpServices.Reports.getListOperationRetention(params).subscribe((data: any[]) => {


      if (autoScroll == false) { this.ListOperationRetention = []; }

      if (data != null) {
        data.forEach(operRet => {
          let _operRet = new OperationRetention(operRet)
          this.ListOperationRetention.push(_operRet);
        });
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
  downloadFile(content, filename) {
    var a = document.createElement('a');
    a.href = "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64," + content;
    a.download = filename;
    a.click();
  }
  exportToExcel() {
    this.statusExport = true;
    var _dateTo = new Date();
    let paramsFilter = {
      "pageSize": null,
      "offset": 0,
      "dateFrom": this.paramsFilter.dateFrom == null ? null : this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.paramsFilter.dateTo == null ? null : this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "lotFrom": null,
      "lotTo": null,
      "idReg":this.regSelect,
      "cuit": this.cuit,
      "idTransaction": this.idTransaction ==  "" ? null : this.idTransaction ,
      "idEntitySubMerchant": this.subMerchantSelect,
      "ticket":this.ticketSearch != null && this.ticketSearch.trim().length > 0 ? this.ticketSearch : null,
      "merchantId": this.merchantIdSearch != null && this.merchantIdSearch.trim().length > 0 ? this.merchantIdSearch : null,

      "idEntityAccount": this.userPermission == 'ADMIN' ? this.merchantSelect : this.securityService.UserLogued.idEntityUser,
    }
    let body = {

      columnsReport: this.ListColumns,
      TypeReport: 'OPERATION_RETENTION',
      requestReport: paramsFilter

    }
    this.LpServices.Export.testExport(body).subscribe((data: any) => {
      if (data != null) {

        let nameFile = 'MerchantWithholdingReport .xlsx';

        this.downloadFile(data, nameFile);
        this.statusExport = false;
      }

    }
      , error => {

      })
  }


  filterReport() {
    this.modalServiceLp.showSpinner();
    this.ListOperationRetention = [];
    var myDiv = document.getElementById('divContainerTable');
    if (myDiv != null) { myDiv.scrollTop = 0;  }

    this.offset = 0;
    var _dateTo = new Date();
    this.paramsFilter = {
      "pageSize": this.pageSize,
      "offset": this.offset,
      "dateFrom": this.dateFrom != null ? this.dateFrom.toISOString().replace(/-|T.*/g, '') : null,
      "dateTo": this.dateTo!= null ? this.dateTo.toISOString().replace(/-|T.*/g, '') : null,
      "lotFrom": this.lotFrom != null && this.lotFrom.trim().length > 0 ? this.lotFrom : null,
      "lotTo": this.lotTo != null && this.lotTo.trim().length > 0 ? this.lotTo : null,
      "idReg":this.regSelect,
      "cuit": this.cuit,
      "idTransaction": this.idTransaction ==  "" ? null : this.idTransaction ,
      "ticket":this.ticketSearch != null && this.ticketSearch.trim().length > 0 ? this.ticketSearch : null,
      "merchantId": this.merchantIdSearch != null && this.merchantIdSearch.trim().length > 0 ? this.merchantIdSearch : null,
      "idEntitySubMerchant": this.subMerchantSelect,
      "idEntityAccount": this.userPermission == 'ADMIN' ? this.merchantSelect : this.securityService.UserLogued.idEntityUser

    }
    this.getListReport(this.paramsFilter);
  }
  getListSubmerchant() {
    let idEntityUser = (this.userPermission == "COMMON") ? this.securityService.UserLogued.customer_id.toString() : '0';
    this.LpServices.Filters.getListSubMerchantUser(idEntityUser).subscribe((_listSubmerchant: any[]) => {

      let auxArray = [];

      _listSubmerchant.forEach(subM => {

        auxArray.push(subM)

      });
      
      this.ListSubMerchant = auxArray;
      if(this.userPermission == "COMMON"){
        this.loadSubmerchantFilter(this.securityService.UserLogued.idEntityUser);
      }
    },
      error => {


      })

  }

  loadSubmerchantFilter(idEntity: number) {
    this.subMerchantSelect = null;
    this.ListSubmerchantFilter = this.ListSubMerchant.filter(e => e.idEntityUser == idEntity)

  }

  getListClients() {
    let idEntityUser = (this.userPermission == "COMMON") ? this.securityService.UserLogued.idEntityAccount : '0';
    this.LpServices.Filters.getListClients(idEntityUser.toString()).subscribe((data: any) => {
      this.ListMerchants = data;

      if (data != null) {
        if(this.userPermission == 'COMMON'){
          this.merchantSelect = this.ListMerchants[0].idEntityUser;
        }

      }

    }, error => {

      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }

  getListRetentionsReg() {
    this.LpServices.Filters.getListRetentionsReg().subscribe((data: any) => {

      if (data != null) {
        let aux = [];
        data.forEach(ret => {

          aux.push(new RetentionReg(ret));

        });
        this.ListRetentionReg = aux;
      }
    },
      error => {       })

  }
  clearDateFilter(filter:string){
    if(filter == 'DATEFROM'){

      this.dateFrom = null;
    }
    if(filter == 'DATETO'){

      this.dateTo = null;
    }
  }

}
