import { Injectable } from '@angular/core'
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http'
import { User } from 'src/app/models/userModel'
import { environment } from 'src/environments/environment'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'

interface Header {
  [key: string]: string
}

type ApiURLs = {
  [key: string]: string
}

@Injectable({
  providedIn: 'root'
})
export class LpConsultDataService {
  resp: any[] = []
  pp: Blob
  urlsApi: ApiURLs
  user: User

  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {
    this.urlsApi = {
      postSaldo: environment.urlApi + '/wallet/accreditation',
      // postInsertPayOut: environment.urlApi + '/payouts/payout',
      // getListPayouts: environment.urlApi + '/payouts/list',
      // getListClients: environment.urlApi + '/filters/getClients',
      // getListDashboard: environment.urlApi + '/Dashboard/list',
      // getListTransactions: environment.urlApi + '/Dashboard/list/transactions',
      // postCheckOut: environment.urlApi + '/payin/cash_payment',
      // postFilePayIn: environment.urlApi + '/payin/upload',
      // postFilePayOut: environment.urlApi + '/payouts/upload',
      getListTransactionsPayInOut: environment.urlApi + '/report/list_transaction',
      // getListCurrency: environment.urlApi + '/filters/ListCurrency',
      // getListCountries: environment.urlApi + '/filters/ListCountries',
      // getListStatus: environment.urlApi + '/filters/ListStatus',
      // testExport: environment.urlApi + '/export/exportToExcel',
      // getDollarToday: environment.urlApi + '/dashboard/dollarToday',
      // getMainReport: environment.urlApi + '/dashboard/mainReport',
      // postCreateTransaction: environment.urlApi + '/transactions/create',
      getAfipRetentions: environment.urlApi + '/afip/downloadRetentions',
      // getProviderCycle: environment.urlApi + '/dashboard/providerCycle',
      // getMerchantCycle: environment.urlApi + '/dashboard/merchantCycle',
      // cashCycleProvider: environment.urlApi + '/dashboard/cashProvider',
      // payCycleMerchant: environment.urlApi + '/dashboard/cashMerchant',
      // getTransactionTypes: environment.urlApi + '/filters/getTransactionTypes'

    }
  }

  getHttpHeaders(additionalsHeaders?: Header[]): HttpHeaders {
    let headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.securityDataService.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.securityDataService.UserLogued.Token,
      'TransactionMechanism': 'true'
    })

    if (additionalsHeaders) {
      additionalsHeaders.map(additionalHeader => {
        headers = headers.append(Object.keys(additionalHeader)[0], Object.values(additionalHeader)[0])
      })
    }

    return headers
  }

  getAfipRetentions() {
    // return this.http.get(this.urlsApi.getAfipRetentions, { headers: this.getHttpHeaders() , responseType: 'arraybuffer' }  )
    return this.http.get(this.urlsApi.getAfipRetentions, { headers: this.getHttpHeaders()  }  )
  }

  postCheckOut(body: any, idCustomerIdTo: string) {
    const customHeaders: Header[] = [
      { 'customer_id_to': idCustomerIdTo.toString() }
    ]

    return this.http.post(this.urlsApi.postCheckOut, body, { headers: this.getHttpHeaders(customHeaders),  })
  }

  postSaldo(body: any) {
    const customHeaders: Header[] = [
      { 'api-key': 'Janus90' }
    ]

    return this.http.post(this.urlsApi.postSaldo, body, { headers: this.getHttpHeaders(customHeaders) })
  }

  getListPayouts() {
    return this.http.get(this.urlsApi.getListPayouts, { headers: this.getHttpHeaders() })
  }

  getListClients() {
    return this.http.get(this.urlsApi.getListClients, { headers: this.getHttpHeaders() })
  }

  getListDashboard(body: any) {
    return this.http.post(this.urlsApi.getListDashboard, body, { headers: this.getHttpHeaders() })
  }

  getListTransactionsPayInOut(body: any) {
    return this.http.post(this.urlsApi.getListTransactionsPayInOut, body, { headers: this.getHttpHeaders() })
  }

  getListTransactions(body: any) {
    return this.http.post(this.urlsApi.getListTransactions, body, { headers: this.getHttpHeaders() })
  }


  testDownload(body: any) {


    return this.http.post(environment.urlApi + '/payouts/download', body, { headers: this.getHttpHeaders() })
  }

  getIndicators() {
    let body = {
      "cycle": "1"
    }

    return this.http.post(this.urlsApi.getIndicators, body, { headers: this.getHttpHeaders() })
  }

  getListCountries() {
    return this.http.get(this.urlsApi.getListCountries, { headers: this.getHttpHeaders() })
  }

  getListCurrency() {
    return this.http.get(this.urlsApi.getListCurrency, { headers: this.getHttpHeaders() })
  }

  getListStatus() {
    return this.http.get(this.urlsApi.getListStatus, { headers: this.getHttpHeaders() })
  }

  getTransactionTypes () {
    return this.http.get(this.urlsApi.getTransactionTypes, { headers: this.getHttpHeaders() })
  }

  postFilePayIn(body: any) {
    return this.http.post(this.urlsApi.postFilePayIn, body, { headers: this.getHttpHeaders() })
  }

  postFilePayOut(body: any) {
    return this.http.post(this.urlsApi.postFilePayOut, body, { headers: this.getHttpHeaders() })
  }

  getProviderCycle() {
    return this.http.get(this.urlsApi.getProviderCycle, { headers: this.getHttpHeaders() })
  }

  testExport(body: any) {
    // const customHeaders: Header[] = [
    //   {
    //     'responseType': 'ArrayBuffer'
    //   }
    // ]
    // customHeaders
    return this.http.post(this.urlsApi.testExport, body, { headers: this.getHttpHeaders() })

  }

  getDollarToday() {
    return this.http.get(this.urlsApi.getDollarToday, { headers: this.getHttpHeaders() })
  }

  getMainReport(type: string) {
    return this.http.get(this.urlsApi.getMainReport + `?type=${type}`, { headers: this.getHttpHeaders() })
  }
  getMerchantCycle() {

    return this.http.get(this.urlsApi.getMerchantCycle, { headers: this.getHttpHeaders() })
  }

  postCreateTransaction(body: any) {
    return this.http.post(this.urlsApi.postCreateTransaction, body, { headers: this.getHttpHeaders() })
  }

  cashCycleProvider(body: any) {
    return this.http.post(this.urlsApi.cashCycleProvider , body, { headers: this.getHttpHeaders() })

  }
  payCycleMerchant(body: any) {

    return this.http.post(this.urlsApi.payCycleMerchant, body, { headers: this.getHttpHeaders() })
  }

  postInsertPayOut(body: any) {
    return this.http.post(this.urlsApi.postInsertPayOut, body, { headers: this.getHttpHeaders() })
  }

}
