import { Component, OnInit } from '@angular/core';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { EnumViews } from '../../services/enumViews';
import { Currency } from 'src/app/models/currencyModel'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { HistoricalFx } from 'src/app/models/historicalFxModel'

@Component({
  selector: 'app-historical-fx',
  templateUrl: './historical-fx.component.html',
  styleUrls: ['./historical-fx.component.css']
})
export class HistoricalFxComponent implements OnInit {

  itemsBreadcrumb: any = ['Home', 'Reports', 'Historical FX'];
  ListHistoricalFx: HistoricalFx[] = [];
  paramsFilter: any = {};
  offset: number = 0;
  pageSize: number = 20;
  userPermission: string = this.securityService.userPermission;
  positionTop: string = "translateY(0px)"
  positionBottom: string = "";
  bsConfig: Partial<BsDatepickerConfig>;
  statusExport: boolean = false;
  toggleFitro = false;
  //Filtros
  dateFrom: Date = new Date(Date.now());
  dateTo: Date = new Date(Date.now());
  lotFrom: string = null;
  lotTo: string = null;
  currencySelect: any = null;
  clientSelect: any = null;
  merchantSelect: any = null;
  ListMerchants: any[];

  constructor(private LpServices: LpMasterDataService,
    private modalServiceLp: ModalServiceLp,
    private clientData: ClientDataShared,
    private securityService: LpSecurityDataService) { }

  ngOnInit() {

    this.modalServiceLp.showSpinner();
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.REPORTS, 'HistoricalFx');
    this.paramsFilter = {
      "dateFrom": this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "pageSize": this.pageSize,
      "offset": this.offset
    }
    this.getListHistoricalFx(this.paramsFilter);
    this.getListClients();
    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY',showWeekNumbers: false });
  }

  getListHistoricalFx(params: any, autoScroll: boolean = false) {

    this.LpServices.Reports.getListHistoricalFx(this.paramsFilter).subscribe((data: any) => {
      if (autoScroll == false) { this.ListHistoricalFx = []; }
      if (data != null) {
        data.forEach(histFx => {
          // let hFx = new HistoricalFx(histFx)
          this.ListHistoricalFx.push(new HistoricalFx(histFx));
          // HistoricalFx
        });
        this.paramsFilter.offset = this.paramsFilter.offset + this.pageSize;
        // console.log(this.ListHistoricalFx);

      }
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    },
    error=> {

      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    })
  }
  onScrollReport() {
    // this.getMoreDataDashboard(this.paramsFilter);
    this.getListHistoricalFx(this.paramsFilter, true);
  }
  filterReport() {
    this.modalServiceLp.showSpinner();
    this.ListHistoricalFx = [];
    var myDiv = document.getElementById('divContainerTable');

    if(myDiv != null){ myDiv.scrollTop = 0;  }
    // this.modalServiceLp.showSpinner();
    this.offset = 0;
    var _dateTo = new Date();
    // _dateTo.setDate(this.dateTo.getDate() + 1)
    this.paramsFilter = {
      "pageSize": this.pageSize,
      "offset": this.offset,
      "dateFrom": this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
      // "lotFrom": this.lotFrom != null && this.lotFrom.trim().length > 0 ? this.lotFrom : null,
      // "lotTo": this.lotTo != null && this.lotTo.trim().length > 0 ? this.lotTo : null,
      // "currency": this.currencySelect,
      "idEntityAccount": this.userPermission == 'ADMIN' ? this.merchantSelect : this.securityService.UserLogued.idEntityUser,

    }
    this.getListHistoricalFx(this.paramsFilter);
  }
  scrollFixedHead($event: Event) {
    let divTabla: HTMLDivElement = <HTMLDivElement>$event.srcElement
    let scrollOffset = divTabla.scrollTop;
    let tabla: HTMLTableElement = <HTMLTableElement>divTabla.children[0]

    let offsetBottom = (tabla.offsetHeight - divTabla.offsetHeight + 15) * -1 + scrollOffset
    this.positionBottom = "translateY(" + offsetBottom + "px)"
    this.positionTop = "translateY(" + scrollOffset + "px)"
  }

  exportToExcel() {
    this.statusExport = true;
    // this.paramsFilter.offset = 0;
    var _dateTo = new Date();
    // _dateTo.setDate(this.dateTo.getDate() + 1)
    let paramsFilter = {
      "pageSize": null,
      "offset": 0,
      "dateFrom":this.paramsFilter.dateFrom == null ? null : this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
      // "lotFrom": this.lotFrom != null && this.lotFrom.trim().length > 0 ? this.lotFrom : null,
      // "lotTo": this.lotTo != null && this.lotTo.trim().length > 0 ? this.lotTo : null,
      // "currency": this.currencySelect,
      "idEntityAccount": this.userPermission == 'ADMIN' ? this.merchantSelect : this.securityService.UserLogued.idEntityUser,
    }
    let body = {
      // columnsReport: this.ListColumns,
      TypeReport:'HISTORICAL_FX',
      requestReport: paramsFilter
    }
    this.LpServices.Export.testExport(body).subscribe((data: any) => {
      if (data != null) {

        let nameFile = 'HistoricalFx.xlsx';

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

  
  getListClients() {
    this.LpServices.Filters.getListClients().subscribe((data: any) => {

      if (data != null) {

        this.ListMerchants = data;
        
      }

    }, error => {

      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }


}
