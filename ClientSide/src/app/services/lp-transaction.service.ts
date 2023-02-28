import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment'
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'

@Injectable({
  providedIn: 'root'
})
export class LpTransactionService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {

    this.urlsApi = {
      postCreateTransaction: environment.urlApi + '/transactions/create',
      getAuditLogs: environment.urlApi + '/transactions/auditLogs',
    }

   }
   postCreateTransaction(body: any) {
    return this.http.post(this.urlsApi.postCreateTransaction, body, { headers: this.securityDataService.getHttpHeaders() })
  }
  getAuditLogs(body: any) {
    return this.http.post(this.urlsApi.getAuditLogs, body, { headers: this.securityDataService.getHttpHeaders() })
  }
}
