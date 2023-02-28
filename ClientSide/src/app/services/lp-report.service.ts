import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment'
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'
interface Header {
  [key: string]: string
}
@Injectable({
  providedIn: 'root'
})
export class LpReportService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) { 

    this.urlsApi = {
      getListTransactionsPayInOut: environment.urlApi + '/report/list_transaction',
      getListAccountTransactions: environment.urlApi + '/report/account_transaction',
      getListTransactionsClientDetails: environment.urlApi + '/report/list_transaction_client_details',
      getListHistoricalFx: environment.urlApi + '/report/list_historical_fx',
      getListOperationRetention: environment.urlApi + '/report/list_operation_retention',
      getListReconciliationReport: environment.urlApi + '/report/list_merchant_report',
      getListOperationRetentionAFIPMonthly: environment.urlApi + '/report/list_operation_retention_monthly',
      getListTransactionsError: environment.urlApi + '/report/list_rejected_transaction',
      adminEmailNotification: environment.urlApi + '/report/admin_email_notification',
      getListMerchantBalanceReport: environment.urlApi + '/report/list_merchant_balance',
      getListMerchantProyectedAccountBalanceReport: environment.urlApi + '/report/list_merchant_proyected_balance',
      getListActivityReport: environment.urlApi + '/report/activity_report',
      getListClientsConfig: environment.urlApi + '/report/list_clients_config'
    }

  }

  getListTransactionsPayInOut(body: any) {
    // let customHeaders:Header[] = []
    //     customHeaders = [     
    //      { 'countryCodeMerchant': countryCodeMerchant } 
    //    ]
    return this.http.post(this.urlsApi.getListTransactionsPayInOut, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getListAccountTransactions(body: any){
    return this.http.post(this.urlsApi.getListAccountTransactions, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getListTransactionsClientDetails(body: any) {
    return this.http.post(this.urlsApi.getListTransactionsClientDetails, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getListHistoricalFx(body: any) {
    return this.http.post(this.urlsApi.getListHistoricalFx, body, { headers: this.securityDataService.getHttpHeaders() })
  }
  getListOperationRetention(body:any){

    return this.http.post(this.urlsApi.getListOperationRetention, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getListOperationRetentionAFIPMonthly(body:any){

    return this.http.post(this.urlsApi.getListOperationRetentionAFIPMonthly, body, { headers: this.securityDataService.getHttpHeaders() })
  }
  getListReconciliationReport(body:any){

    return this.http.post(this.urlsApi.getListReconciliationReport, body, { headers: this.securityDataService.getHttpHeaders() })
  }
  
  getListTransactionsError(body:any){

    return this.http.post(this.urlsApi.getListTransactionsError, body, { headers: this.securityDataService.getHttpHeaders() })

  }
  adminEmailNotification(body:any){

    return this.http.post(this.urlsApi.adminEmailNotification, body, { headers: this.securityDataService.getHttpHeaders() })

  }

  getListMerchantBalanceReport(body:any){
    return this.http.post(this.urlsApi.getListMerchantBalanceReport, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getListMerchantProyectedBalanceReport(body:any){
    return this.http.post(this.urlsApi.getListMerchantProyectedAccountBalanceReport, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getListActivityReport(body: any){
    return this.http.post(this.urlsApi.getListActivityReport, body, {headers: this.securityDataService.getHttpHeaders() } )
  }
  getListClientsConfig(body: any){
    return this.http.post(this.urlsApi.getListClientsConfig, body, {headers: this.securityDataService.getHttpHeaders() } )
  }

}
