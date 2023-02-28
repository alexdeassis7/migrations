import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment'
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'

@Injectable({
  providedIn: 'root'
})
export class LpAfipService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {

    this.urlsApi = {
      
      getAfipRetentions: environment.urlApi + '/afip/downloadRetentions',

    }

   }

   getAfipRetentions() {
  
    return this.http.get(this.urlsApi.getAfipRetentions, { headers: this.securityDataService.getHttpHeaders()  }  )
  }

}
