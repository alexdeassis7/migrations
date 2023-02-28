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
export class LpWalletService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {

    this.urlsApi = {
      postSaldo: environment.urlApi + '/wallet/accreditation',

    }
    
  }

  postSaldo(body: any) {
    const customHeaders: Header[] = [
      { 'api-key': 'Janus90' }
    ]

    return this.http.post(this.urlsApi.postSaldo, body, { headers: this.securityDataService.getHttpHeaders(customHeaders) })
  }
}
