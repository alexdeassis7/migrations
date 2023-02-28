import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment'
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'


@Injectable({
  providedIn: 'root'
})
export class LpDashboardService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {

    this.urlsApi = {
      getDollarToday: environment.urlApi + '/dashboard/dollarToday',
      getMainReport: environment.urlApi + '/dashboard/mainReport',
      getClientReport: environment.urlApi + '/dashboard/clientReport',
      getProviderCycle: environment.urlApi + '/dashboard/providerCycle',
      getMerchantCycle: environment.urlApi + '/dashboard/merchantCycle',
      cashCycleProvider: environment.urlApi + '/dashboard/cashProvider',
      payCycleMerchant: environment.urlApi + '/dashboard/cashMerchant'
    }
  }

  getDollarToday() {
    return this.http.get(this.urlsApi.getDollarToday, { headers: this.securityDataService.getHttpHeaders() })
  }

  getMainReport(type: string) {
    return this.http.get(this.urlsApi.getMainReport + `?type=${type}`, { headers: this.securityDataService.getHttpHeaders() })
  }

  getClientReport(){
    return this.http.get(this.urlsApi.getClientReport, {headers: this.securityDataService.getHttpHeaders()});
  }

  getProviderCycle() {
    return this.http.get(this.urlsApi.getProviderCycle, { headers: this.securityDataService.getHttpHeaders() })
  }

  getMerchantCycle() {

    return this.http.get(this.urlsApi.getMerchantCycle, { headers: this.securityDataService.getHttpHeaders() })
  }
  cashCycleProvider(body: any) {
    return this.http.post(this.urlsApi.cashCycleProvider, body, { headers: this.securityDataService.getHttpHeaders() })

  }
  payCycleMerchant(body: any) {

    return this.http.post(this.urlsApi.payCycleMerchant, body, { headers: this.securityDataService.getHttpHeaders() })
  }


}
