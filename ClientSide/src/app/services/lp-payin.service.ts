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

export class LpPayinService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) { 

    this.urlsApi = {
      postCheckOut: environment.urlApi + '/payin/cash_payment',
      postFilePayIn: environment.urlApi + '/payin/upload',
      payinsManage: environment.urlApi + '/payins/manage_payins',
      rejectPayins: environment.urlApi + '/payins/update_payins',
    }
  }

  postCheckOut(body: any, idCustomerIdTo: string) {
    const customHeaders: Header[] = [
      { 'customer_id_to': idCustomerIdTo.toString() }
    ]

    return this.http.post(this.urlsApi.postCheckOut, body, { headers: this.securityDataService.getHttpHeaders(customHeaders),  })
  }
  postFilePayIn(body: any) {
    return this.http.post(this.urlsApi.postFilePayIn, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  payinsToManage(body: any, countryCode: string) {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.payinsManage, body, { headers: this.securityDataService.getHttpHeaders(customHeaders, countryCode) })
  }

  updatePayins(body: any, countryCode: string)
  {
    const customHeaders: Header[] = [
    ]
    return this.http.post(this.urlsApi.rejectPayins, body, { headers: this.securityDataService.getHttpHeaders(customHeaders,countryCode) })
  }

}
