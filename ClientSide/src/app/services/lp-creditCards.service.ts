import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment'
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'

@Injectable({
  providedIn: 'root'
})
export class LpCreditCardsService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {

    this.urlsApi = {
      postConfirmPayment: environment.urlApi + '/decidir/pay_transaction',
   
    }

   }
   postConfirmPayment(body: any) {
    return this.http.post(this.urlsApi.postConfirmPayment, body, { headers: this.securityDataService.getHttpHeaders() })
  }
  //ver como le agrego los headers adicionales (en lp-wallet.service.ts hay)
}
