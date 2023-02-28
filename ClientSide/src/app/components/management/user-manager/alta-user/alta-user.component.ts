import { Component, OnInit, TemplateRef } from '@angular/core';
import { LpConsultDataService } from 'src/app/services/lp-consult-data.service';
import { Currency } from 'src/app/models/currencyModel';
import { Country } from 'src/app/models/countryModel';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service';
//import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { ToastrService } from 'ngx-toastr';



@Component({
  selector: 'app-alta-user',
  templateUrl: './alta-user.component.html',
  styleUrls: ['./alta-user.component.css']
})
export class AltaUserComponent implements OnInit {

  ListMetodos: any[] = [{ name: 'PAGO FACIL', code: 'PAFA' }, { name: 'RAPIPAGO', code: 'RAPA' }, { name: 'BAPRO', code: 'BAPR' }, { name: 'COBROEXPRESS', code: 'COEX' },]
  metodoSelect: any = this.ListMetodos[0].val;
  MethodSelect: any[] = [];
  listCurrency: Currency[] = [];
  listCountries: Country[] = [];
  loading: boolean = false;
  //Formulario
  myForm: FormGroup;
  //Steps
  step: any = 1;
  //
  accountName: any = null;
  //Account Data
  accountData: any = null;

  //public bsModalRef?: BsModalRef

  constructor(
    private servLP: LpConsultDataService,
    private LpServices:LpMasterDataService,
    private securityService: LpSecurityDataService,
    public fb: FormBuilder,
    private modalService : ModalServiceLp,
    //private modalRef : BsModalRef,
    public bsModalRef: BsModalRef,
    private _toast : ToastrService
    )
  {
    this.myForm = this.fb.group({
      WebPassword: ['', [Validators.required]],
      Mail: ['', [Validators.required]],
      idEntityUser: ['', [Validators.required]],
      idEntityAccount: ['', [Validators.required]]
    });
  }

  ngOnInit() {
    this.getListCurrency();
    this.getListCountries();

    setTimeout(()=>{
      this.accountData = this.bsModalRef.content.userData
      this.myForm.controls.idEntityUser.setValue(this.bsModalRef.content.userData.idEntityUser)
        this.myForm.controls.idEntityAccount.setValue(this.bsModalRef.content.userData.idEntityAccount)
    },500)
  }
    
  save(){
    this.loading = true;
      this.modalService.showSpinner();
      //Set values
      
      this.securityService.createUsers(this.myForm.value).subscribe(response => {
        console.log('mostrando response', response);
        this.accountData = null;
        setTimeout(() => { this.modalService.hideSpinner() }, 400)
        this.loading = false;
        this._toast.success("User added succesfully");
        //close modal
        this.closeModal();
      },error => {
        this.loading = false;
        console.log('mostrando error', error);
      })
    
  }

  closeModal(){
    this.bsModalRef.hide();
  }

  getListCurrency() {

    this.LpServices.Filters.getListCurrency().subscribe((_listCurrency: Currency[]) => {
      let auxArray = []
      _listCurrency.forEach(cur => {
        let currency = new Currency(cur);
        auxArray.push(currency);
      });
      this.listCurrency = auxArray;
    
      // this.listCountries = countries;
    },

      error => { })
  }
  getListCountries() {

    this.LpServices.Filters.getListCountries().subscribe((_listCountries: Country[]) => {

      let auxArray = [];
      _listCountries.forEach(country => {

        let _country = new Country(country);
        auxArray.push(_country);

      });

      this.listCountries = auxArray;

    },
      error => {


      })
  }

  passwordGenerator(){
    let numberChars = "0123456789";
    let specialChars = ".%@#/*";
    let upperChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    let lowerChars = "abcdefghijklmnopqrstuvwxyz";
    let randPasswordArray = Array(15);
    const allChars = numberChars + upperChars + lowerChars;

    randPasswordArray[0] = numberChars;
    randPasswordArray[1] = upperChars;
    randPasswordArray[2] = specialChars;
    randPasswordArray[3] = lowerChars;
    randPasswordArray = randPasswordArray.fill(allChars, 3);
    const passGenerated = this.shuffleArray(randPasswordArray.map(function(x) { return x[Math.floor(Math.random() * x.length)] })).join('')
    this.myForm.controls.WebPassword.setValue(passGenerated)
  }

  shuffleArray(array) {
    for (var i = array.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var temp = array[i];
      array[i] = array[j];
      array[j] = temp;
    }
    console.log(array);
    return array;
  }


}
