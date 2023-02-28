import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { User } from 'src/app/models/userModel';
import { Payout } from 'src/app/models/payoutModel';
import { Observable } from 'rxjs/observable';
// import { JSONP_ERR_WRONG_RESPONSE_TYPE } from '@angular/common/http/src/jsonp';
import { environment } from 'src/environments/environment'
import { Router, NavigationEnd } from '@angular/router';
import * as moment from 'moment'
import { Country } from 'src/app/models/countryModel';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service';
import { filter } from 'rxjs/operators';
import { BnNgIdleService } from 'bn-ng-idle';
import { Token } from '@angular/compiler/src/ml_parser/lexer';
import { JwtHelperService } from "@auth0/angular-jwt";
declare var $: any;

interface Header {
  [key: string]: string
}
@Injectable({
  providedIn: 'root'
})
export class LpSecurityDataService {
  
  UserLogued: User
  urlsApi: any
  CountriesAvailables: Country[];
  public jwtHelper: JwtHelperService = new JwtHelperService();

  constructor(private http: HttpClient, private router: Router, private modalServiceLp: ModalServiceLp, private bnIdle: BnNgIdleService) {

    this.UserLogued = this.loadCurrentUser()
    this.CountriesAvailables = this.loadCountries();
    this.urlsApi = {

      postLogout: environment.urlApi + '/log/logout_session',

    }

  }

  checkTokenExpired(){
    const token = localStorage.getItem('Token_User');
    const expired = this.jwtHelper.isTokenExpired(token);
    return expired;
  }

  clearSession(){
    localStorage.clear()
    this.modalServiceLp.showModalSessionExpired();
  }

  //////////////////////////////////////////////////////////////////////////
  getTokenUser(username: string, password: string, otpLogin: string) {
    var user = {};
    //Llamar a metodo que genera el token y devolverlo
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': username,
      'api_key': password,
      'otplogin': otpLogin,
      'app': 'True'
    });

    return this.http.post(environment.urlApi + '/Tokens', user, { headers });
  }

  getFirstFactor(username: string, password: string) {
    var user = {};
    //Llamar a metodo que genera el token y devolverlo
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': username,
      'api_key': password,
      'app': 'True'
    });

    return this.http.post(environment.urlApi + '/firstfactor', user, { headers });
  }

  getUserData(username: string, token: string) {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': username,
      'Authorization': 'Bearer ' + token
    });

    return this.http.get(environment.urlApi + '/users/user', { headers });
  }

  getListUsers() {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.UserLogued.Token
    });
    return this.http.get(environment.urlApi + '/users/ListUsers', { headers });
  }

  getListAccounts() {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.UserLogued.Token
    });
    return this.http.get(environment.urlApi + '/users/ListAccounts', { headers });
  }

  checkAccountIfExists(data: any) {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.UserLogued.Token
    });
    return this.http.post(environment.urlApi + '/users/CheckAccountExists', data, { headers });
  }

  createAccount(data:any) {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.UserLogued.Token
    });
    return this.http.post(environment.urlApi + '/users/CreateAccount', data, { headers });
  }

  createUsers(data:any) {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.UserLogued.Token
    });
    return this.http.post(environment.urlApi + '/users/CreateUsers', data, { headers });
  }

  getIdIdentity(data:any) {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.UserLogued.Token
    });
    return this.http.post(environment.urlApi + '/users/GetIdEntityByClientName', data, { headers });
  }

  getListKeyUsers() {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.UserLogued.Token
    });
    return this.http.get(environment.urlApi + '/users/ListUsersKeys', { headers });
  }

  assingUserKey(identification: string) {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.UserLogued.Token,
    });
    return this.http.post(environment.urlApi + '/users/CreateUserKeys', identification, { headers });
  }

  loadCurrentUser(): User {
    let token = localStorage.getItem('Token_User');
    let country = localStorage.getItem("Country");

    if (token === null) return

    let payload = JSON.parse(atob(token.split('.')[1]));
    let Userdata = JSON.parse(payload.user_data);
    let countrySelect = JSON.parse(country);
    let userLog = {};

    userLog = {
      customer_id: payload.unique_name,
      UserSiteIdentification: Userdata.UserSiteIdentification,
      Token: token,
      Permisos: Userdata.Admin == "true" ? 'ADMIN' : 'COMMON',
      Merchant: Userdata.Merchant,
      TypeUser: Userdata.TypeUser,
      idEntityUser: Userdata.idEntityUser,
      idEntityAccount: Userdata.idEntityAccount
    }

    let currentUser = new User(userLog);

    currentUser.Country = countrySelect;
    currentUser.idEntityUser = countrySelect.idEntityUser
    currentUser.UserSiteIdentification = countrySelect.DescriptionUser

    return currentUser
  }

  IntervalAuthentication() {
    this.bnIdle.startWatching(7200).subscribe((res) => {
      if(res) {
          this.clearSession();
      }
    })
  }

  loadCountries(): Country[] {
    let countries = JSON.parse(localStorage.getItem('ListCountries'))

    return countries;


  }
  isAuthenticated(): boolean {
    return this.UserLogued != null ? true : false;
  };

  get currentUser(): User {
    return this.UserLogued;
  }

  set currentUser(_user: User) {
    this.UserLogued = _user;
  }

  set setCountries(countries: Country[]) {

    this.CountriesAvailables = countries;
  }
  get getCountriesAvailables(): Country[] {

    return this.CountriesAvailables;
  }
  get userPermission(): string {
    return this.UserLogued != null ? this.UserLogued.Permisos : null
  }

  closeSession() {
    localStorage.clear()
    window.location.href = environment.baseHref
  }

  postLogout() {
    return this.http.get(this.urlsApi.postLogout, { headers: this.getHttpHeaders() });
  }

  getHttpHeaders(additionalsHeaders?: Header[], countryCode?: string): HttpHeaders {
    
    let headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
      'Authorization': 'Bearer ' + this.UserLogued.Token,
      'TransactionMechanism': 'true',
      'countryCode': countryCode == null ? this.UserLogued.Country.Code : countryCode,
      'permissionUser': this.UserLogued.Permisos
    })

    if (additionalsHeaders) {
      additionalsHeaders.map(additionalHeader => {
        headers = headers.append(Object.keys(additionalHeader)[0], Object.values(additionalHeader)[0])
      })
    }

    return headers
  }

  //Generate a new token based on the customer_id
  refreshToken() {

    var user = {};
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'customer_id': this.UserLogued.customer_id,
    });

    return this.http.post(environment.urlApi + '/RefreshToken', user, { headers });
  }

  getAccessToken() {
    return this.UserLogued.Token;
  }

  //Update saved token in the local storage 
  updateToken(token: string) {
    localStorage.setItem("Token_User", token);
    this.UserLogued = this.loadCurrentUser()
  }
}
