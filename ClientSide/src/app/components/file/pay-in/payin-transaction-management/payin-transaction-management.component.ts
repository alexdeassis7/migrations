import { Component, OnInit } from '@angular/core';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { EnumViews } from '../../../services/enumViews';
import { Country } from 'src/app/models/countryModel';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { Payout } from 'src/app/models/payoutModel';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { ModalConfirmComponent } from 'src/app/components/shared/modals/modal-confirm/modal-confirm.component';
import { tick } from '@angular/core/testing';
import { environment } from '../../../../../environments/environment.prod';

@Component({
  selector: 'app-payin-transaction-management',
  templateUrl: './payin-transaction-management.component.html',
  styleUrls: ['./payin-transaction-management.component.css']
})
export class PayinTransactionManagementComponent implements OnInit {

  itemsBreadcrumb: any = ['Home', 'Files Manager', 'Payin', 'Edit Manual TXS InProgress'];
  filteredPayins: any[] = [];
  //set payins provider
  ListProviders: any[] = [];
  ListMerchants: any[] = [];
  ListSubMerchants: any[] = [];
  ListCountries: any[] = [];
  ListProviderFilter: any[] = [];
  ListMerchantFilter: any[] = [];
  ListSubMerchantFilter: any[] = [];
  trSelect: any = null;
  merchantSelect: any = null;
  subMerchantSelect: any = null;
  providerSelect: any = null
  currencySelect: string = "";
  countryCode: string = null;
  filteredPayinsTotal: any;
  checkedPayins: any[] = [];
  checkedPayinsTotal: any;
  downloadStatus: string = null;
  rejectAll: boolean = false;
  modalRef: BsModalRef;
  aproveMessage: string = "Do you want to aprove this transactions?"

  constructor(private LpServices: LpMasterDataService, private clientData: ClientDataShared, private modalServiceLp: ModalServiceLp) { }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.FILE_MANAGER, 'Payin', 'PayinTxsManagement');
    this.getCountries();
    this.getProviders();
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
    this.currencySelect = this.ListCountries.filter(e => e.Code == code)[0].Currency;
    this.ListProviderFilter = this.ListProviders.filter(e => e.countryCode == code);
    this.merchantSelect = null
    this.ListMerchantFilter = this.ListMerchants.filter(e => e.CountryCode == code);
  }

  public get validationFilter(): Boolean {
    return (this.countryCode != null && this.providerSelect != null)
  }

  loadSubmerchantFilter(idEntity: number) {
    this.subMerchantSelect = null;
    this.ListSubMerchantFilter = this.ListSubMerchants.filter(e => e.idEntityUser == idEntity)

  }

  loadCheckboxTransactions(Transaction: any, rejected: boolean) {
    if (rejected) {
      this.checkedPayins.push(Transaction)
    }
    else {
      let index = this.checkedPayins.indexOf(Transaction);
      this.checkedPayins.splice(index, 1);
    }
    this.checkAll();
    this.loadCheckboxTotals();
  }

  loadAllTransactions(rejected: boolean) {
    this.checkedPayins = [];
    if (rejected) {
      this.filteredPayins.forEach(Payout => {
        Payout.Reject = true;
        this.checkedPayins.push(Payout);
      });
    }
    else {
      this.filteredPayins.forEach(Payout => {
        Payout.Reject = false;
      });
    }
    this.loadCheckboxTotals();
  }

  checkAll() {
    this.rejectAll = this.checkedPayins.length == this.filteredPayins.length ? true : false
  }

  loadCheckboxTotals() {
    var total = {
      'Amount': this.checkedPayins.reduce((a, b) => parseFloat(a) + (parseFloat(b['amount']) || 0), 0)
    };
    this.checkedPayinsTotal = total;
  }

  getProviders() {
    this.LpServices.Filters.getProviders('PAYIN').subscribe((data: any) => {
      if (data != null) {
        this.ListProviders = data
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
    })
  }



  filter() {
    this.modalServiceLp.showSpinner();
    this.rejectAll = false;
    this.loadAllTransactions(false);
    this.filteredPayins = [];
    var params = {
      'provider': this.providerSelect,
      'merchant': this.merchantSelect,
      'subMerchant': this.subMerchantSelect
    }
    this.downloadStatus = null;
    this.LpServices.Payin.payinsToManage(params, this.countryCode).subscribe((data: any) => {
      if (data && data.length > 0) {
        this.filteredPayins = data.sort((a, b) => new Date(a.TransactionDate).getTime() - new Date(b.TransactionDate).getTime())
        var total = {
          'Amount': this.filteredPayins.reduce((a, b) => parseFloat(a) + (parseFloat(b['amount']) || 0), 0)
        };
        this.filteredPayinsTotal = total;
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

  changeStatus() {
    this.modalRef = this.modalServiceLp.openModal('CONFIRM', 'Confirm', this.aproveMessage);
    (<ModalConfirmComponent>this.modalRef.content).confirmAction.subscribe(response => {
      if (response == true) {
        this.modalServiceLp.showSpinner();
        var tickets = this.checkedPayins.map((txs) => txs.ticket)
        this.LpServices.Payin.updatePayins(tickets, this.countryCode).subscribe((data: any) => {
          this.downloadStatus = "OK";

          this.checkedPayins.forEach(detail => {
            let indexF = this.filteredPayins.findIndex(x => x.ticket == detail.ticket)
            this.filteredPayins.splice(indexF, 1);
          });
          this.checkedPayins = [];
          this.loadCheckboxTotals();
          setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
        },
          error => {
            setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
            this.downloadStatus = "ERROR";
          });
      }
    }
      , error => {
        this.modalServiceLp.openModal(error.Status, 'Error', error.StatusMessage);
      })
  }
}
