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
  selector: 'app-payout-transaction-management',
  templateUrl: './payout-transaction-management.component.html',
  styleUrls: ['./payout-transaction-management.component.css']
})
export class PayoutTransactionManagementComponent implements OnInit {

  itemsBreadcrumb: any = ['Home', 'Files Manager', 'PayOut', 'Edit Manual TXS InProgress'];
  filteredPayouts: any[] = [];
  ListProviders: any[] = [];
  ListTransactions: any = [{ name: 'Providers Payment', val: '2' }];
  ListStatus: any = [{name: 'Aprove', val: false},{name: 'Reject', val: true}]
  ListMerchants: any[] = [];
  ListSubMerchants: any[] = [];
  ListCountries: any[] = [];
  ListProviderFilter: any[] = [];
  ListMerchantFilter: any[] = [];
  ListSubMerchantFilter: any[] = [];
  ListStatusCodes: any[] = [];
  ListStatusCodesFilter: any[] = [];
  trSelect: any = null;
  statusSelect: string = null;
  merchantSelect: any = null;
  subMerchantSelect: any = null;
  providerSelect: any = null
  currencySelect:string = "";
  countryCode: string = null;
  statusCode: string = null;
  filteredPayoutsTotal: any;
  checkedPayouts: any[] = [];
  checkedPayoutsTotal: any;
  downloadStatus: string = null;
  rejectAll: boolean = false;
  modalRef: BsModalRef;
  aproveMessage: string = "Do you want to aprove this transactions?"
  rejectMessage: string = "Do you want to reject this transactions?"
  searchInput: string = null;

  constructor( private LpServices: LpMasterDataService, private clientData: ClientDataShared, private modalServiceLp: ModalServiceLp) { }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.FILE_MANAGER, 'PayOut', 'PayOutTxsManagement');
    this.getProviders();
    this.getCountries();
    this.getListClients();
    this.getListSubmerchant();
    this.getInternalStatuses();
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
        //this.loadMifel();
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

  loadMifel(){
    this.countryCode = 'MEX';
    this.trSelect = '2';
    this.loadProviderFilter(this.countryCode);
    this.providerSelect = 'MIFEL';
  }

  loadProviderFilter(code: any) {
    this.providerSelect = null
    this.currencySelect = this.ListCountries.filter(e=> e.Code == code)[0].Currency ;
    this.ListProviderFilter = this.ListProviders.filter(e => e.countryCode == code);
    this.merchantSelect = null
    this.ListMerchantFilter = this.ListMerchants.filter(e => e.CountryCode == code);
    this.subMerchantSelect = null;
    this.statusSelect = null;
  }

  resetprovider() {
    this.statusSelect = null;
    this.statusCode = null;
  }

  public get validationFilter(): Boolean {
    return (this.countryCode != null && this.providerSelect != null && this.trSelect != null)
  }

  loadSubmerchantFilter(idEntity: number) {
    this.subMerchantSelect = null;
    this.ListSubMerchantFilter = this.ListSubMerchants.filter(e => e.idEntityUser == idEntity)
  }

  
  loadStatusCodeFilter(isError: number) {
    this.statusCode = null;
    this.ListStatusCodesFilter = this.ListStatusCodes.filter(e => e.isError == isError && e.providerCode == this.providerSelect && e.countryCode == this.countryCode)
    if (isError == 0)
    {
      this.statusCode = '300'
    }
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

  getInternalStatuses() {
    this.LpServices.Filters.getInternalStatuses().subscribe((data: any) => {
      if (data != null) {
        this.ListStatusCodes = data
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
      'PaymentType': this.trSelect,
      'idMerchant': this.merchantSelect,
      'idSubMerchant' : this.subMerchantSelect,
      'provider': this.providerSelect,
      'merchantId': this.searchInput
    }
    this.downloadStatus = null;
    this.LpServices.Payout.payoutsToManage(params,this.countryCode).subscribe((data : any) =>{
      if (data && data.length > 0)
      {
        this.filteredPayouts = data.sort((a,b) => new Date(a.TransactionDate).getTime() - new Date(b.TransactionDate).getTime())
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

  changeStatus(reject: string)
  {
    this.modalRef = this.modalServiceLp.openModal('CONFIRM', 'Confirm', reject.toString() == 'true' ? this.rejectMessage : this.aproveMessage);
    (<ModalConfirmComponent>this.modalRef.content).confirmAction.subscribe(response => {
      if (response == true) {
        this.modalServiceLp.showSpinner();
        this.LpServices.Payout.updatePayouts(this.checkedPayouts,this.countryCode, this.providerSelect, reject, this.statusCode).subscribe((data : any) =>{
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
