import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { User } from 'src/app/models/userModel';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { BsModalService } from 'ngx-bootstrap/modal';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { ChooseCountryComponent } from '../choose-country/choose-country.component';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service';
import { Country } from 'src/app/models/countryModel';
import { observable, Observable, Subscription } from 'rxjs';


@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  loginForm: FormGroup;
  submitted = false;
  returnUrl: string;
  loading = false;
  userLogin: string = "";
  passLogin: string = "";
  otpLogin: string = "";
  validateEmail: boolean = false;
  loginWithoutOtp : boolean = false;
  userLogued: User;
  modalRef: BsModalRef;
  subModalCountry: Subscription;
  objTest2: Subscription;
  ListCountries: Country[] = [];
  regex = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;

  constructor(
    private router: Router,
    private securityService: LpSecurityDataService,
    private modalServiceLp: ModalServiceLp,
    private modalService: BsModalService,
    private LpServices: LpMasterDataService,
  ) {

  }

  Login() {
     localStorage.clear();
     var errorLogin = "";
     this.valEmail(this.userLogin);

    if (!this.validateEmail) {

     this.securityService.getTokenUser(this.userLogin, this.passLogin, this.otpLogin)
        .subscribe((data: any) => {
          localStorage.setItem("Token_User", data.token_id);
          let Userdata = JSON.parse(JSON.parse(atob(data.token_id.split('.')[1])).user_data)
          let userLog = {};

         userLog = {
           customer_id: data.customer_id,
           UserSiteIdentification: Userdata.UserSiteIdentification,
            Token: data.token_id,
            Permisos: Userdata.Admin == "true" ? 'ADMIN' : 'COMMON',
           Merchant: Userdata.Merchant,
           TypeUser: Userdata.TypeUser,
           idEntityUser: Userdata.idEntityUser,
           idEntityAccount: Userdata.idEntityAccount
           }

          this.userLogued = new User(userLog);

           this.securityService.currentUser = this.userLogued;
           this.securityService.IntervalAuthentication();

           if (this.userLogued.Permisos == 'ADMIN') {

            this.userLogued.Country = new Country(Userdata.lCountry[0])
            this.userLogued.Country.addIcon();

            localStorage.setItem("Country", JSON.stringify(this.userLogued.Country));
             this.router.navigate(['./Home/Dashboard']);
           }
          else {
             setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400);
             if (Userdata.lCountry.length > 0) {
              
               Userdata.lCountry.forEach(count => {

                 let country = new Country(count)
                country.addIcon();

                 this.ListCountries.push(country)

               }); 
             }

             let initialState = {
             ListCountries: this.ListCountries,
             isLogin: true
             }

             this.modalRef = this.modalService.show(ChooseCountryComponent, { initialState, ignoreBackdropClick: true, keyboard: false });

             (<ChooseCountryComponent>this.modalRef.content).onClose.subscribe(countrySelect => {

               this.userLogued.Country = countrySelect;
               this.userLogued.idEntityUser = countrySelect.idEntityUser
               this.securityService.setCountries = this.ListCountries
               this.userLogued.UserSiteIdentification = countrySelect.DescriptionUser
               localStorage.setItem("Country", JSON.stringify(countrySelect));
               localStorage.setItem("ListCountries", JSON.stringify(this.ListCountries))

               this.subModalCountry = this.modalService.onHide.subscribe((reason: string) => {

                 this.router.navigate(['./Home/ClientDashboard']);
               })
             })
          }
         },
           error => {
            setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400);
           this.modalServiceLp.openModal('ERROR', 'Authentication Error', error.error);
          }
         );
     }
   }

  firstStep()
  {

    localStorage.clear();
    var errorLogin = "";
    this.valEmail(this.userLogin);
    if (!this.validateEmail) {
      if(this.loginWithoutOtp){
        this.Login();
        return;
      }
      this.securityService.getFirstFactor(this.userLogin, this.passLogin)
        .subscribe((data: any) => {
          this.loginWithoutOtp = data;          
        },
        error => {
          setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400);

          this.modalServiceLp.openModal('ERROR', 'Authentication Error', error.error.ValidationResult.ValidationMessage);


        }
        );
    }
  }

  ngOnDestroy() {

    if (this.subModalCountry != undefined) {

      this.subModalCountry.unsubscribe();
    }


  }
  valEmail(mail: string) {

    this.validateEmail = !this.regex.test(mail);
  }





  ngOnInit() {
    this.loginForm = new FormGroup({});
  }

  get btnLoginDisabled(): boolean {

    return this.userLogin.length > 0 && this.passLogin.length > 0 && this.regex.test(this.userLogin) ? false : true;

  }



}

