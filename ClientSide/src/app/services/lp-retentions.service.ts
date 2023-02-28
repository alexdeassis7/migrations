
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
export class LpRetentionsService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {

    this.urlsApi = {
      getRetentions: environment.urlApi + '/retention/downloadRetentions',
      getListWhitelist: environment.urlApi + '/retention/ListWhitelist',
      createWhitelist: environment.urlApi + '/retention/whiteListInsert',
      updateWhitelist: environment.urlApi + '/retention/whiteListUpdate',
      deleteWhitelist: environment.urlApi + '/retention/DeleteListWhite',
      downloadTxtMonthly: environment.urlApi + '/retention/downloadTxtRetentions',
      downloadExcelMonthly: environment.urlApi + '/retention/downloadExcelRetentions',
      downloadTxtArba: environment.urlApi + '/retention/downloadTxtARBARetentions',
      downloadExcelArba: environment.urlApi + '/retention/downloadExcelARBARetentions',
      getListTransactionsAgRetentions: environment.urlApi + '/retention/TransactionsForRetentions',
      downloadTransactionsAgrouped: environment.urlApi + '/retention/downloadRetentionForaDate',
      getListRetention: environment.urlApi + '/retention/list_retentions',
      refundTransaction: environment.urlApi + '/retention/refund_retentions',
      downloadCertificates: environment.urlApi + '/retention/downloadCertificates',
    }

  }

  downloadTransactionsAgrouped(body: any) {
    return this.http.post(this.urlsApi.downloadTransactionsAgrouped, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getRetentions(code) {

    const customHeaders: Header[] = [
      { 'retention_type': code }
    ]
    return this.http.get(this.urlsApi.getRetentions, { headers: this.securityDataService.getHttpHeaders(customHeaders) })
  }

  downloadTxtMonthly(body: any) {

    return this.http.post(this.urlsApi.downloadTxtMonthly, body, { headers: this.securityDataService.getHttpHeaders() })

  }

  downloadExcelMonthly(body: any) {

    return this.http.post(this.urlsApi.downloadExcelMonthly, body, { headers: this.securityDataService.getHttpHeaders() })

  }

  downloadTxtArba(body: any) {

    return this.http.post(this.urlsApi.downloadTxtArba, body, { headers: this.securityDataService.getHttpHeaders() })

  }

  downloadExcelArba(body: any) {

    return this.http.post(this.urlsApi.downloadExcelArba, body, { headers: this.securityDataService.getHttpHeaders() })

  }

  getListWhitelist(body: any) {

    return this.http.post(this.urlsApi.getListWhitelist, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getListTransactionsAgRetentions(body: any) {
    return this.http.post(this.urlsApi.getListTransactionsAgRetentions, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  createWhitelist(body: any) {

    return this.http.post(this.urlsApi.createWhitelist, body, { headers: this.securityDataService.getHttpHeaders() })

  }


  updateWhitelist(body: any, updateType:string) {

    
    const customHeaders: Header[] = [
      { 'updateType': updateType }
    ]
    
    return this.http.post(this.urlsApi.updateWhitelist, body, { headers: this.securityDataService.getHttpHeaders(customHeaders) })

  }
  deleteWhitelist(body: any) {

    return this.http.post(this.urlsApi.deleteWhitelist, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getListRetention(body: any) {
    return this.http.post(this.urlsApi.getListRetention, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  refundTransactions(body: any) {
    return this.http.post(this.urlsApi.refundTransaction, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  downloadCertificates(body: any) {
    return this.http.post(this.urlsApi.downloadCertificates, body, { headers: this.securityDataService.getHttpHeaders() })

  }

}
