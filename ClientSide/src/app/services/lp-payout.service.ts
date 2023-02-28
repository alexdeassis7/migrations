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

export class LpPayoutService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {

    this.urlsApi = {
      postInsertPayOut: environment.urlApi + '/payouts/payout',
      getListPayouts: environment.urlApi + '/payouts/list',
      postFilePayOut: environment.urlApi + '/payouts/upload',
      testDownload: environment.urlApi + '/payouts/download',
      payoutsDownload: environment.urlApi + '/payouts/list_payouts',
      payoutsManage: environment.urlApi + '/payouts/validate_payouts',
      payoutsCancel: environment.urlApi + '/payouts/cancel_payouts',
      payoutsReceived: environment.urlApi + '/payouts/received_payouts',
      rejectPayouts: environment.urlApi + '/payouts/update_payouts',
      cancelPayouts: environment.urlApi + '/payouts/cancel_payouts',
      getOnHoldPayouts: environment.urlApi + '/payouts/get_onhold_payouts',
      putOnHoldPayouts: environment.urlApi + '/payouts/put_onhold_payouts',
      putReceivedPayouts: environment.urlApi + '/payouts/put_received_payouts',
      revertDownload: environment.urlApi + '/payouts/revert_download',
      getExecutedPayouts: environment.urlApi + '/payouts/executed_payouts',
      returnPayouts: environment.urlApi + '/payouts/return_payouts'
    }

  }

  postInsertPayOut(body: any, customer: string, countryCode: string, byAdmin: boolean) {
    let customHeaders:Header[] = []
    if (byAdmin == true) {

       customHeaders = [
    
        { 'customerByAdmin': customer },
        { 'countryCodeByAdmin': countryCode },

      ]
    }
    return this.http.post(this.urlsApi.postInsertPayOut, body, { headers: this.securityDataService.getHttpHeaders(customHeaders)})
  }
  getListPayouts() {
    return this.http.get(this.urlsApi.getListPayouts, { headers: this.securityDataService.getHttpHeaders() })
  }

  postFilePayOut(body: any, countryCode: string, providerName: string) {

    const customHeaders: Header[] = [
      { 'providerName': providerName.toString() }
    ]
    return this.http.post(this.urlsApi.postFilePayOut, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }
  testDownload(body: any, countryCode: string, providerName: string, hourTo: any, internalFiles: any = 0) {
    const customHeaders: Header[] = [
      { 'providerName': providerName.toString() },
      { 'hourTo': hourTo },
      { 'internalFiles': internalFiles }
    ]


    return this.http.post(this.urlsApi.testDownload, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  payoutsToDownload(body: any, countryCode: string, hourTo: any) {
    const customHeaders: Header[] = [
      {'hourTo': hourTo}
    ]
    return this.http.post(this.urlsApi.payoutsDownload, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  payoutsToManage(body: any, countryCode: string) {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.payoutsManage, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  payoutsToCancel(body: any, countryCode: string) {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.payoutsReceived, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  payoutsFromOnHoldToReceivedOrCancel(body: any, countryCode: string) {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.getOnHoldPayouts, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  updatePayouts(body: any, countryCode: string, providerName: string, rejected: string, statusCode: string)
  {
    const customHeaders: Header[] = [
      { 'providerName': providerName.toString() },
      { 'statusCode': statusCode}
    ]
    return this.http.post(this.urlsApi.rejectPayouts, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  manageCancelOnHoldPayouts(body: any, countryCode: string, statusCode: string) {
    if(statusCode == "OnHold"){
      return this.onHoldPayouts(body, countryCode);
    }
    return this.cancelPayouts(body, countryCode);
  }

  manageCancelReceivedPayouts(body: any, countryCode: string, statusCode: string) {
    console.log(statusCode);
    if(statusCode == "Received"){
      return this.receivedPayouts(body, countryCode);
    }
    return this.cancelPayouts(body, countryCode);
  }

  onHoldPayouts(body: any, countryCode: string) {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.putOnHoldPayouts, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  cancelPayouts(body: any, countryCode: string) {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.cancelPayouts, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  receivedPayouts(body: any, countryCode: string) {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.putReceivedPayouts, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  revertDownload(body: any, countryCode: string) {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.revertDownload, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }
  
  getExecutedListPayout(body: any, countryCode: string)
  {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.getExecutedPayouts, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  ReturnPayout(body: any, countryCode: string,providerName: string, status: string)
  {
    const customHeaders: Header[] = [
      { 'providerName': providerName.toString() },
      { 'status': status},
    ]
    return this.http.post(this.urlsApi.returnPayouts, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }
}
