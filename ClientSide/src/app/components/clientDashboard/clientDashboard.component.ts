import { Component, OnInit } from '@angular/core';
import { defineLocale } from 'ngx-bootstrap/chronos';
import { esLocale } from 'ngx-bootstrap/locale';
import { EnumViews } from '../services/enumViews';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ClientDashboardData } from 'src/app/models/clientDashboardModel';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';

defineLocale('es', esLocale);

@Component({
  selector: 'app-client-dashboard',
  templateUrl: './clientDashboard.component.html',
  styleUrls: ['./clientDashboard.component.css']
})

export class ClientDashboardComponent implements OnInit {
  itemsBreadcrumb: any = ['Home', 'Dashboard'];
  ListClientReport: ClientDashboardData[];
  ClientReportTotals: ClientDashboardData[] = [];

  constructor(
    private LpServices: LpMasterDataService,
    private clientData: ClientDataShared
  ) {}

  ngOnInit() {
    this.clientData.setCurrentView(EnumViews.DASHBOARD);
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    // init totals
    // get client report data
    this.getClientReport();
  }

  getClientReport() {
    this.LpServices.Dashboard.getClientReport().subscribe((data: any) => {
      if (data != null) {
        this.ListClientReport = data;
        var groupedReports = this.groupBy(data, report => report.CurrencyCode)
        groupedReports.forEach((Reports) => {
          var report = new ClientDashboardData(
            {
              SaldoActual: 0,
              AmtInProgressPO: 0,
              cntInProgressPO: 0,
              AmtInProgressPI: 0,
              cntInProgressPI: 0,
              AmtReceived: 0,
              AmtOnHoldPO: 0,
              cntReceived: 0,
              cntOnHoldPO: 0,
              CurrencyCode: Reports[0].CurrencyCode,
              CommTaxesInProgressPI: 0,
              CommTaxesInProgressPO: 0
            }
          );
          Reports.forEach((item) => {
            if (item.SaldoActual != null) {
              report.SaldoActual += item.SaldoActual;
            }
            if (item.CurrencyCode != null){
              report.CurrencyCode = item.CurrencyCode;
            }
            if (item.AmtInProgressPO != null) {
              report.AmtInProgressPO += item.AmtInProgressPO;
            }
            if (item.cntInProgressPO != null) {
              report.cntInProgressPO += item.cntInProgressPO;
            }
            if (item.AmtInProgressPI != null) {
              report.AmtInProgressPI += item.AmtInProgressPI;
            }
            if (item.cntInProgressPI != null) {
              report.cntInProgressPI += item.cntInProgressPI;
            }
            if (item.AmtReceived != null) {
              report.AmtReceived += item.AmtReceived;
            }
            if (item.AmtOnHoldPO != null) {
              report.AmtOnHoldPO += item.AmtOnHoldPO;
            }
            if (item.cntReceived != null) {
              report.cntReceived += item.cntReceived;
            }
            if (item.cntOnHoldPO != null) {
              report.cntOnHoldPO += item.cntOnHoldPO;
            }
            if (item.CommTaxesInProgressPI != null) {
              report.CommTaxesInProgressPI += item.CommTaxesInProgressPI;
            }
            if (item.CommTaxesInProgressPO != null) {
              report.CommTaxesInProgressPO += item.CommTaxesInProgressPO;
            }
          });
          this.ClientReportTotals.push(report);
        })
      }
    }, error => {
      console.log('Error');
    });
  }

   groupBy(list, keyGetter) {
    const map = new Map();
    list.forEach((item) => {
         const key = keyGetter(item);
         const collection = map.get(key);
         if (!collection) {
             map.set(key, [item]);
         } else {
             collection.push(item);
         }
    });
    return map;
  }  
}
