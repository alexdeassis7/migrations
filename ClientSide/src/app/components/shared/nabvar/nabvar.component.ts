import { Component, OnInit, EventEmitter, Output, HostListener, HostBinding, Input } from '@angular/core';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { User } from 'src/app/models/userModel';
import { BsModalService } from 'ngx-bootstrap/modal';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { Country } from 'src/app/models/countryModel';
import { ChooseCountryComponent } from '../../security/choose-country/choose-country.component';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-nabvar',
  templateUrl: './nabvar.component.html',
  styleUrls: ['./nabvar.component.css']
})
export class NabvarComponent implements OnInit {
  UserLogued: User;
  modalRef: BsModalRef;
  subModalCountry: Subscription;
  constructor(
    private clientData: ClientDataShared,
    private securityService: LpSecurityDataService,
    private router: Router,

    // private modalServiceLp: ModalServiceLp,
    private modalService: BsModalService, ) {

  }

  @Output() toggle: EventEmitter<null> = new EventEmitter();

  @Input() isOpen = false;
  @Input() noHome = true;

  toggleTrigger() {
    this.toggle.emit();
  }

  ngOnInit() {
    this.UserLogued = this.securityService.currentUser;

  }
  changeCountry() {

    let initialState = {
      ListCountries: this.securityService.getCountriesAvailables,
      currentCountry: this.UserLogued.Country,
      isLogin: false
    }

    this.modalRef = this.modalService.show(ChooseCountryComponent, { initialState });

    (<ChooseCountryComponent>this.modalRef.content).onClose.subscribe(countrySelect => {

      this.securityService.UserLogued.Country = countrySelect;
      this.securityService.UserLogued.idEntityUser = countrySelect.idEntityUser
      this.securityService.UserLogued.UserSiteIdentification = countrySelect.DescriptionUser
      localStorage.removeItem('Country');
      localStorage.setItem("Country", JSON.stringify(countrySelect));
      
      this.router.navigate(['/Home/Dashboard']);
    })
  }
  logout() {
    this.clientData.inicializeBreadCrumb();
    this.securityService.closeSession();
  }

}
