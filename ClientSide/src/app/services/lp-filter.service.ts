import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment'
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'
import { Merchant } from '../models/merchantModel';
import { map } from 'rxjs/operators';
import { Currency } from '../models/currencyModel';
Currency

interface Header {
  [key: string]: string
}
@Injectable({
  providedIn: 'root'
})
export class LpFilterService {
  urlsApi: any;
  constructor(private http: HttpClient, private securityDataService: LpSecurityDataService) {

    this.urlsApi = {
      getListClients: environment.urlApi + '/filters/getClients',
      getListCurrency: environment.urlApi + '/filters/ListCurrency',
      getListCountries: environment.urlApi + '/filters/ListCountries',
      getListStatus: environment.urlApi + '/filters/ListStatus',
      getTransactionTypes: environment.urlApi + '/filters/getTransactionTypes',
      getListSubMerchantUser: environment.urlApi + '/filters/ListSubMerchantUser',
      getListRetentionsReg: environment.urlApi + '/filters/ListRetentionsReg',
      getListCountriesMerchant: environment.urlApi + '/filters/ListCountriesMerchant',
      getListRejectedReasons: environment.urlApi + '/filters/GetInternalStatusProviders',
      getListFieldsValidation: environment.urlApi + '/filters/ListFieldsValidation',
      getListErrorTypes: environment.urlApi + '/filters/ListErrorTypes',
      getListSettlement: environment.urlApi + '/filters/getListSettlements',
      getProviders: environment.urlApi + '/filters/getProviders',
      getInternalStatuses: environment.urlApi + '/filters/getInternalStatus',
      getBanks: environment.urlApi + '/filters/getBanks'
    }

  }

  getListClients(idUser: string = '0') {
    const customHeaders: Header[] = [
      { 'idEntityUser': idUser }
    ]
    return this.http.get<Merchant[]>(this.urlsApi.getListClients, { headers: this.securityDataService.getHttpHeaders(customHeaders) })
      .pipe(map(data => {
        if (data != null) { return data.map(merch => new Merchant(merch)) } else { return null }
      }))

  }
  getListCurrency() {
    return this.http.get<Currency[]>(this.urlsApi.getListCurrency, { headers: this.securityDataService.getHttpHeaders() })
      .pipe(map(data => { if (data != null) { return data.map(currency => new Currency(currency)) } else { return null } }))
  }
  getListCountries() {
    return this.http.get(this.urlsApi.getListCountries, { headers: this.securityDataService.getHttpHeaders() })
  }

  getListStatus() {
    return this.http.get(this.urlsApi.getListStatus, { headers: this.securityDataService.getHttpHeaders() })
  }

  getTransactionTypes() {
    return this.http.get(this.urlsApi.getTransactionTypes, { headers: this.securityDataService.getHttpHeaders() })
  }
  getListSubMerchantUser(idUser: string = '0') {
    const customHeaders: Header[] = [
      { 'idEntityUser': idUser }
    ]
    return this.http.get(this.urlsApi.getListSubMerchantUser, { headers: this.securityDataService.getHttpHeaders(customHeaders) })
  }

  getListRetentionsReg() {

    return this.http.get(this.urlsApi.getListRetentionsReg, { headers: this.securityDataService.getHttpHeaders() })

  }

  getListCountriesMerchant() {

    const customHeaders: Header[] = [
      { 'idMerchant': '4' }
    ]

    return this.http.get(this.urlsApi.getListCountriesMerchant, { headers: this.securityDataService.getHttpHeaders(customHeaders) })

  }

  getListFieldsValidation() {

    return this.http.get(this.urlsApi.getListFieldsValidation, { headers: this.securityDataService.getHttpHeaders() })

  }

  getListErrorTypes(){
    return this.http.get(this.urlsApi.getListErrorTypes, { headers: this.securityDataService.getHttpHeaders() })

  }

  getListSettlement(body: any) {
    return this.http.post(this.urlsApi.getListSettlement, body, { headers: this.securityDataService.getHttpHeaders() })
  }

  getProviders(provider: string) {
    const customHeaders: Header[] = [
      { 'provider': provider }
    ]
    
    return this.http.get(this.urlsApi.getProviders, { headers: this.securityDataService.getHttpHeaders(customHeaders) })
  }

  getInternalStatuses() {    
    return this.http.get(this.urlsApi.getInternalStatuses, { headers: this.securityDataService.getHttpHeaders()})
  }

  getBanks() {
    return this.http.get(this.urlsApi.getBanks, { headers: this.securityDataService.getHttpHeaders() })
  }
}
