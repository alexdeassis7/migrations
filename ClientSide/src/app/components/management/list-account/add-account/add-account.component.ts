import { Component, OnInit } from '@angular/core';
import { FormArray, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service';
import { ClientDataShared } from '../../../services/lp-client-data.service';
import { ModalServiceLp } from '../../../services/lp-modal.service';
import { environment } from '../../../../../environments/environment.prod';
import { Country } from 'src/app/models/countryModel';
import { ToastrService } from 'ngx-toastr';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { BsModalRef } from 'ngx-bootstrap/modal';
@Component({
  selector: 'app-add-account',
  templateUrl: './add-account.component.html',
  styleUrls: ['./add-account.component.css']
})
export class AddAccountComponent implements OnInit {

  myForm: FormGroup;
  myFormArray: FormArray;
  itemsBreadcrumb: any = ['Home', 'Tools', 'Create Account'];
  ListMainCountries: any[] = [];
  ListMainCurrencies: any[] = [];
  ListCountries: any[] = [];
  ListCurrenciesFilter: any[] = [];
  ListCountriesSelected: any[] = [];
  public accountExists: boolean = false;
  public loading: boolean = false;
  public responseAPI: any = null;
  public AccountDataTextArea: any;
  copied = false;

  constructor(
    private clientData: ClientDataShared,
    private securityService: LpSecurityDataService,
    private modalService : ModalServiceLp,
    private LpServices: LpMasterDataService,
    public bsModalRef: BsModalRef,
    public fb: FormBuilder,
    private _toast : ToastrService
  ) {
    this.myForm = this.fb.group({
      //dataToSearch: ['', [Validators.required,Validators.minLength(3),Validators.maxLength(100)]],
      MerchantName: ['', Validators.required],
      SubMerchantName: ['', Validators.required],
      Mail: ['', [Validators.required, Validators.pattern("^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}$")]],
      FxPeriod: ['', Validators.required],
      //DataCountries: this.fb.array([this.newCountryArray()]),
      DataCountries: this.fb.array([]),
      Alias: ['', Validators.required],
    });

    this.AccountDataTextArea = `Hola: buenas\nHola2: Buenas`
  }



  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb)
    this.getCountries();
    this.getCurrencies();
    this.initialCountries();
  }



  checkAccount(){

    const payload = {
      merchantName: this.myForm.get('MerchantName').value,
      email: this.myForm.get('Mail').value,
    }
    this.securityService.checkAccountIfExists(payload).subscribe(response =>{
      console.log("mostrando response",response);
      if(response){
        this.accountExists = true;
        this._toast.error("This merchant name or email already exists");
        return;
      }
      this.accountExists = false;
      

    },
    error =>{console.log(error)})
  }

  getCountries() {
    environment.Countries.filter(data => data.active === true).map((item:any) => {
      let country = new Country({
        Code: item.Code,
        Name: item.Name,
        Currency: item.Currency,
        FlagIcon: item.FlagIcon,
        NameCode: item.NameCode,
        Description: item.Description,
        Currencies: item.currencies
      })
      country.addIcon()
      this.ListMainCountries.push(country)
      this.ListCountries.push(country)
    });
    console.log("Mostrando get List countries",this.ListCountries);
    console.log("Mostrando get List countries",this.ListMainCountries);
    console.log("List countries selected",this.ListCountriesSelected);
  }

  getCurrencies() {
    environment.Countries.filter(data => data.active === true).map((item) => {
      let currencies = new CountryCurrency({
        Code: item.Code,
        Name: item.Name,
        Currencies: item.currencies
      })
      this.ListMainCurrencies.push(currencies)
    });
    console.log("mostrando currencies", this.ListMainCurrencies)
  }

  addCountriesAfterRemove(code) {
    environment.Countries.filter(data => data.Code == code && data.active === true).map((item) => {
      let country = new Country({
        Code: item.Code,
        Name: item.Name,
        Currency: item.Currency,
        FlagIcon: item.FlagIcon,
        NameCode: item.NameCode,
        Description: item.Description,
        Currencies: item.currencies
      })
      country.addIcon()
      this.ListCountries.unshift(country)
    });
    console.log("List countries",this.ListCountries);
    console.log("List countries selected",this.ListCountriesSelected);
  }

  


  changeCountry(e,i){
    //Check Actual Country Selected
    this.myFormArrays.controls[i].get('CountryDisplay').setValue(e.Name);
    let countryCodeSelected = this.myFormArrays.controls[i].get('CountryName').value;
    let countryCurrencies = ((this.myForm.get('DataCountries') as FormArray).at(i).get('Currencies') as FormArray);
    countryCurrencies.reset()
    let filtered = this.ListMainCountries.filter(data => data.Code == countryCodeSelected);
    for (let index = 0; index < filtered[0].Currencies.length; index++) {
      const element = filtered[0].Currencies[index];
      countryCurrencies.push(this.fb.group({Name: element.name}))
    }
    
    // if(countryCodeSelected){
    //   this.ListCountriesSelected = this.ListCountriesSelected.filter(data => data != countryCodeSelected);
    // }
    // this.ListCountriesSelected.push(e.Code)
    // this.ListCountries = this.ListMainCountries.filter(data => this.ListCountriesSelected.indexOf(data.Code) === -1);
    // //this.addCountriesAfterRemove(countryCode);
    // this.myFormArrays.controls[i].get('CountryName').setValue(e.Code);
    // this.myFormArrays.controls[i].get('CountryDisplay').setValue(e.Name);
    
    // console.log("Mostrando contries selected", this.ListCountriesSelected)
  }
  

  loadCurrencies(code : any){
    this.ListCurrenciesFilter = this.ListMainCurrencies.filter(e => e.Code == code);
    console.log("mostrando currencies filter", this.ListCurrenciesFilter);
  }

  //Methods to array forms

  //Get
  get myFormArrays(): FormArray {
    return this.myForm.get("DataCountries") as FormArray
  }

  //New Form
  newCountryArray(): FormGroup {
    return this.fb.group({
      CountryName: ['', Validators.required],
      CountryDisplay: ['',],
      CurrencyAccount: ['', Validators.required],
      CommisionValue: ['', Validators.required],
      CommissionCurrency: ['', Validators.required],
      Spread: ['', Validators.required],
      AfipRetention: [''],
      ArbaRetention: [''],
      LocalTax: ['%', Validators.required],
      Alias: [''],
      Currencies: this.fb.array([])
    })
  }

  newCountryArray2(country: any, countryName: any): FormGroup {
    return this.fb.group({
      CountryName: [country, Validators.required],
      CountryDisplay: [countryName],
      CurrencyAccount: ['', Validators.required],
      CommisionValue: ['', Validators.required],
      CommissionCurrency: ['', Validators.required],
      Spread: ['', Validators.required],
      AfipRetention: [''],
      ArbaRetention: [''],
      LocalTax: ['%', Validators.required],
      Alias: [''],
      Currencies: this.filteredCurrencies(country)
    })
  }

  currencyCountry () : FormGroup{
    return this.fb.group({
      Name: ['USD'],
    })
  }

  filteredCurrencies(code: any){
    let filtered = this.ListMainCountries.filter(data => data.Code == code).map(data => data.Currencies);
    let tmpArr = filtered[0].map((data)=>{
      return this.fb.group({
        Name: data.name,
      })
    })
    return this.fb.array(tmpArr);
  }
  

  initialCountries(){
    for (let index = 0; index < this.ListCountries.length; index++) {
      const element = this.ListCountries[index];
      this.myFormArrays.push(this.newCountryArray2(element.Code, element.Name));
      this.ListCountriesSelected.push(element.Code);
    }
    setTimeout(()=>{this.ListCountries = this.ListMainCountries.filter(data => this.ListCountriesSelected.indexOf(data.Code) === -1);},500)
  }

  //Add
  addCountry() {
    //this.getCountries();
    this.ListCountries = this.ListCountries.filter(data => this.ListCountriesSelected.indexOf(data.Code) === -1);
    this.myFormArrays.push(this.newCountryArray());
  }

  //Remove
  removeCountry(i: number) {
    //get actual countryCode Selected
    let countryCode = this.myFormArrays.controls[i].get('CountryName').value;
    if(countryCode){
      this.ListCountriesSelected = this.ListCountriesSelected.filter(data => data != countryCode);
    }
    this.addCountriesAfterRemove(countryCode);
    this.ListCountries = this.ListMainCountries.filter(data => this.ListCountriesSelected.indexOf(data.Code) === -1);
    
    this.myFormArrays.removeAt(i);
  }

  //Copy to clipboard
  copyInputMessage(inputElement) {  
    navigator.clipboard.writeText(inputElement.value).then(() => {
        this.copied = true;
        setTimeout(() => { this.copied = false; },500)
    });
  } 

  //Send data to api

  submit(){
    this.loading = true;
    this.checkAccount();

    if(!this.accountExists){

      this.modalService.showSpinner();
    let payload = this.myForm.value;
    
    payload.Countries = this.ListCountriesSelected;
    console.log("Mostrando values",payload)

    let resultDataCountries = payload.DataCountries.map((data)=>{
      return{
        AfipRetention: data.AfipRetention,
        Alias: payload.Alias+data.CountryName,
        ArbaRetention: data.ArbaRetention,
        CommisionValue: data.CommisionValue,
        CommissionCurrency: data.CommissionCurrency,
        CountryDisplay: data.CountryDisplay,
        CountryName: data.CountryName,
        CurrencyAccount: data.CurrencyAccount,
        LocalTax: data.LocalTax,
        Spread: data.Spread
      }
    })
    delete payload.Alias;
    delete payload.DataCountries;
    payload.DataCountries = resultDataCountries;
    console.log("Mostrando values despues",payload)
    //return;
    this.securityService.createAccount(payload).subscribe(response => {
      setTimeout(() => { this.modalService.hideSpinner() }, 400);
      this.loading = false;
      this._toast.success('Account created succesfully');
      this.myForm.reset();
      this.responseAPI = response[0];
      this.AccountDataTextArea = `Merchant Name: ${response[0].MerchantName}\nIdentification: ${response[0].Identification}\nApi Password: ${response[0].ApiPassword}\nMail: ${response[0].Mail}\nWebPassword: ${response[0].WebPassword}`
      console.log(response);
    }, error =>{
      this.loading = false;
      this._toast.error('Error when intent create account.');
      setTimeout(() => { this.modalService.hideSpinner() }, 400)
      console.log(error);
    })

    }
    setTimeout(() => { this.modalService.hideSpinner() }, 400);
    this.loading = false;
    
  }



}

export class Currency {
  name: string

  constructor(_name: string){
    this.name = _name;
  }
}

export class CountryCurrency {
  Code: string;
  Name: string;
  Currencies: Array<any>

  constructor(_country: any) {
      this.Code = _country.Code || null;
      this.Name = _country.Name || null;
      this.Currencies = _country.Currencies || null;
  }

}