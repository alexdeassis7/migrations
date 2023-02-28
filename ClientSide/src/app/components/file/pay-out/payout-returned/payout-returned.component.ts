import { Component, OnInit } from '@angular/core';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { EnumViews } from '../../../services/enumViews';
import { Country } from 'src/app/models/countryModel';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { Payout } from 'src/app/models/payoutModel';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { ModalConfirmComponent } from 'src/app/components/shared/modals/modal-confirm/modal-confirm.component';
import { environment } from '../../../../../environments/environment.prod';

@Component({
  selector: 'app-payout-returned',
  templateUrl: './payout-returned.component.html',
  styleUrls: ['./payout-returned.component.css']
})
export class PayoutReturnedComponent implements OnInit {

  itemsBreadcrumb: any = ['Home', 'Files Manager', 'PayOut', 'Edit Manual TXS Returned'];
  ListStatus: any[] = [{name: 'Returned'},{name: 'Recalled'}];
  filteredPayouts: any[] = [];
  ListProviders: any[] = [];
  ListMerchants: any[] = [];
  ListSubMerchants: any[] = [];
  ListCountries: any[] = [];
  ListProviderFilter: any[] = [];
  ListMerchantFilter: any[] = [];
  ListSubMerchantFilter: any[] = [];
  merchantSelect: any = null;
  subMerchantSelect: any = null;
  statusSelect: any = null;
  providerSelect: any = null
  currencySelect:string = "";
  countryCode: string = null;
  filteredPayoutsTotal: any;
  checkedPayouts: any[] = [];
  checkedPayoutsTotal: any;
  downloadStatus: string = null;
  rejectAll: boolean = false;
  modalRef: BsModalRef;
  searchInput: string = null;
  ModalMessage: string = "Do you want to change the status of selected transactions?"

  constructor( private LpServices: LpMasterDataService, private clientData: ClientDataShared, private modalServiceLp: ModalServiceLp) { }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.FILE_MANAGER, 'PayOut', 'PayOutReturned');
    this.getProviders();
    this.getCountries();
    this.getListClients();
    this.getListSubmerchant();
  }

  getCountries() {
    environment.Countries.map((item) => {
      let country = new Country({
        Code: item.Code,
        Name: item.Name,
        Currency: item.Currency,
        FlagIcon: item.FlagIcon,
        NameCode: item.NameCode,
        Description: item.Description
      })
      country.addIcon()
      this.ListCountries.push(country)
    });
  }

  getListClients() {
    this.LpServices.Filters.getListClients().subscribe((data: any) => {
      if (data != null) {
        this.ListMerchants = data;
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }

  getListSubmerchant() {
    this.LpServices.Filters.getListSubMerchantUser().subscribe((data: any) => {
      if (data != null) {
        this.ListSubMerchants = data;
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }

  loadProviderFilter(code: any) {
    this.providerSelect = null
    this.currencySelect = this.ListCountries.filter(e=> e.Code == code)[0].Currency ;
    this.ListProviderFilter = this.ListProviders.filter(e => e.countryCode == code);
    this.merchantSelect = null
    this.ListMerchantFilter = this.ListMerchants.filter(e => e.CountryCode == code);
    this.subMerchantSelect = null;
  }

  public get validationFilter(): Boolean {
    return (this.countryCode != null && this.providerSelect != null)
  }

  loadSubmerchantFilter(idEntity: number) {
    this.subMerchantSelect = null;
    this.ListSubMerchantFilter = this.ListSubMerchants.filter(e => e.idEntityUser == idEntity)
  }

  getProviders() {
    this.LpServices.Filters.getProviders('PODEPO').subscribe((data: any) => {
      if (data != null) {
        this.ListProviders = data
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
    })
  }

  loadCheckboxTransactions(Transaction: any, rejected: boolean) 
  {
    if (rejected){
      this.checkedPayouts.push(Transaction)
    }
    else 
    {
      let index = this.checkedPayouts.indexOf(Transaction);
      this.checkedPayouts.splice(index,1);
    }
    this.checkAll();
    this.loadCheckboxTotals();
  }

  loadAllTransactions(rejected: boolean){
    this.checkedPayouts = [];
    if (rejected){
      this.filteredPayouts.forEach(Payout => {
        Payout.Reject = true;
        this.checkedPayouts.push(Payout);
      });
    }
    else {
      this.filteredPayouts.forEach(Payout => {
        Payout.Reject = false;
      });
    }
    this.loadCheckboxTotals();
  }

  checkAll()
  {
    this.rejectAll = this.checkedPayouts.length == this.filteredPayouts.length ? true : false
  }

  loadCheckboxTotals()
  {
    var total = {
      'GrossValueClient': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['GrossValueClient']) || 0), 0),
      'LocalTax': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['LocalTax']) || 0), 0),
      'TaxWithholdings': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['TaxWithholdings']) || 0), 0),
      'TaxWithholdingsARBA': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['TaxWithholdingsARBA']) || 0), 0),
      'NetAmount': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['NetAmount']) || 0), 0),
    };
    this.checkedPayoutsTotal = total;
  }



  filter(){
    this.modalServiceLp.showSpinner();
    this.rejectAll = false;
    this.loadAllTransactions(false);
    this.filteredPayouts = [];
    var params = {
      'idMerchant': this.merchantSelect,
      'idSubMerchant' : this.subMerchantSelect,
      'provider': this.providerSelect,
      'merchantId': this.searchInput
    }
    this.downloadStatus = null;
    this.LpServices.Payout.getExecutedListPayout(params,this.countryCode).subscribe((data : any) =>{
      if (data && data.length > 0)
      {
        this.filteredPayouts = data.sort((a,b) => new Date(b.TransactionDate).getTime() - new Date(a.TransactionDate).getTime())
        var total = {
          'GrossValueClient': this.filteredPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['GrossValueClient']) || 0), 0),
          'LocalTax': this.filteredPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['LocalTax']) || 0), 0),
          'TaxWithholdings': this.filteredPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['TaxWithholdings']) || 0), 0),
          'TaxWithholdingsARBA': this.filteredPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['TaxWithholdingsARBA']) || 0), 0),
          'NetAmount': this.filteredPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['NetAmount']) || 0), 0),
        };
        this.filteredPayoutsTotal = total;
      }
      else {
        this.downloadStatus = "NOTPROCESS";
      }
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    },
    error => {
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      this.downloadStatus = "ERROR";

    });
  }

  changeStatus(update: string)
  {
    this.modalRef = this.modalServiceLp.openModal('CONFIRM', 'Confirm', update.toString() == 'true' ? this.ModalMessage : '');
    (<ModalConfirmComponent>this.modalRef.content).confirmAction.subscribe(response => {
      if (response == true) {
        this.modalServiceLp.showSpinner();
        this.LpServices.Payout.ReturnPayout(this.checkedPayouts,this.countryCode, this.providerSelect, this.statusSelect).subscribe((data : any) =>{
        if (data.TransactionDetail.length > 0)
        {
          if (data.Status == "OK")
          this.downloadStatus = "OK";
          else
          this.downloadStatus = "MIXED";

          data.TransactionDetail.forEach(detail => {
            let index = this.checkedPayouts.findIndex(x => x.Ticket == detail.Ticket)
            let indexF = this.filteredPayouts.findIndex(x => x.Ticket == detail.Ticket)
            this.checkedPayouts.splice(index,1);
            this.filteredPayouts.splice(indexF,1);
          });
          this.loadCheckboxTotals();
        }
        else {
          this.downloadStatus = "ERROR";
        }
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      },
      error => {
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
        this.downloadStatus = "ERROR";
      });
      }
    }
    ,error => {
      this.modalServiceLp.openModal(error.Status, 'Error', error.StatusMessage);
    })
  }
}