import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment'
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'
import * as moment from 'moment-timezone'
interface Header {
  [key: string]: string
}
@Injectable({
  providedIn: 'root'
})

export class LpExportService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {

    this.urlsApi = {
      testExport: environment.urlApi + '/export/exportToExcel',
      ExportReport: environment.urlApi + '/export/ExportList'
    }
   }
   ExportReport(body: any){
    return this.http.post(this.urlsApi.ExportReport, body, { headers: this.securityDataService.getHttpHeaders() })
   }
   testExport(body: any) {
     
    const customHeaders: Header[] = [
      { 'currentTimeZone':  moment.tz.guess() }
    ]


    return this.http.post(this.urlsApi.testExport, body, { headers: this.securityDataService.getHttpHeaders(customHeaders) })

  }
}
