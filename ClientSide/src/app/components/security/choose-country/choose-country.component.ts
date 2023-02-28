import { Component, OnInit } from '@angular/core';
import { Country } from 'src/app/models/countryModel';
import Utils from 'src/app/utils';
import { Subject, Observable, BehaviorSubject } from 'rxjs';
import {  BsModalRef } from 'ngx-bootstrap/modal';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';

@Component({
  selector: 'app-choose-country',
  templateUrl: './choose-country.component.html',
  styleUrls: ['./choose-country.component.css']
})
export class ChooseCountryComponent implements OnInit {

  ListCountries: Country[] 
  currentCountry: Country = null
  isLogin: boolean = null;
  private currentViewSubject = new BehaviorSubject<any>(0);
  public onClose: Subject<Country>;

  constructor(private bsModalRef: BsModalRef, private clientShared:ClientDataShared) { }
 
  selectedCountry: Country = null;

  ngOnInit() {   
    this.onClose = new Subject();
 
    this.selectedCountry = this.currentCountry == null ?  this.ListCountries[0] : this.currentCountry;
  }

  onConfirm(){
    this.bsModalRef.hide();
    this.onClose.next(this.selectedCountry);
    if(this.isLogin == false && this.clientShared.getIndexCurrentView() == 2){

      this.clientShared.reloadAllDB()
    }
  

  }

// triggerAllDB(){

//   this.clientShared.reloadAllDB()
// }


}
