import { Component, OnInit } from '@angular/core'
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service'
import { ModalServiceLp } from '../../services/lp-modal.service'
import Utils from 'src/app/utils'
import { EnumViews } from '../../services/enumViews';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
const enabledTransactionTypes = ['AddBalance', 'Conversion', 'AddDebit', 'ReceivedCo']

@Component({
  selector: 'app-create-transaction',
  templateUrl: './create-transaction.component.html',
  styleUrls: ['./create-transaction.component.css']
})
export class CreateTransactionComponent implements OnInit {
  amount: string = ''
  description: string = ''

  itemsBreadcrumb: any = ['Home', 'Tools', 'Create Transaction']

  ListEntitiesUsers: any[]
  ListCurrenciesTypes: any[]
  ListTransactionsTypes: any[]

  selectEntityUser: any
  selectCurrencyType: any
  selectTransactionType: any

  showValueFx: boolean = false
  valueFx: string = '1'

  constructor(private clientData: ClientDataShared, private modalServiceLp: ModalServiceLp, private LpServices: LpMasterDataService) { }

  createTransaction() {
    let amount = this.amount
    let valueFx = this.valueFx

    if (!amount.includes('.')) amount += '.00'
    if (!valueFx.includes('.')) valueFx += '.00'

    let body = {
      Amount: parseFloat(amount).toFixed(2),
      idTransactionType: this.selectTransactionType,
      idEntityUser: this.selectEntityUser,
      idCurrencyType: this.selectCurrencyType,
      Description: this.description,
      TransactionTypeCode: Utils.findTransactionTypeCode(this.ListTransactionsTypes, this.selectTransactionType)
    }

    if (Utils.findTransactionTypeCode(this.ListTransactionsTypes, this.selectTransactionType) === 'Conversion')
      body['ValueFX'] = Math.round(parseFloat(valueFx) * 100)

    // return

    this.LpServices.Transactions.postCreateTransaction(body).subscribe((data: any) => {
      if (data !== null) {
        if (data.status === 'OK') {
          this.modalServiceLp.openModal('SUCCESS', 'Resultado', data.status_message)
          this.cleanFrm();
        } else {
          this.modalServiceLp.openModal('ERROR', 'Operacion erronea', data.status_message)
        }
      } else {
        this.modalServiceLp.openModal('ERROR', 'Error', 'Unknown error')
      }
    }, error => {
      this.modalServiceLp.openModal('ERROR', 'Error', 'Unknown error')
    })
  }

  getListClients() {
    this.LpServices.Filters.getListClients().subscribe((data: any) => {
      if (data != null) {
        this.ListEntitiesUsers = data
        this.selectEntityUser = this.ListEntitiesUsers[0].idEntityUser
        this.selectCurrencyType = this.ListEntitiesUsers[0].CurrencyClient
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
    })
  }

  getListCurrencyType() {
    this.LpServices.Filters.getListCurrency().subscribe((data: any) => {
      if (data != null) {
        this.ListCurrenciesTypes = data
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
    })
  }

  getTransactionType() {
    this.LpServices.Filters.getTransactionTypes().subscribe((data: any) => {
      if (data != null) {
        let filterList = data.filter(item => (item.idTransactionGroup === 10 && item.idTransactionOperation === 6))
        this.ListTransactionsTypes = filterList
        this.selectTransactionType = this.ListTransactionsTypes[0].idTransactionType
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
    })
  }

  handleChangeClient(idEntityUser: number) {
    let user = this.ListEntitiesUsers.find(user => (user.idEntityUser === idEntityUser))
    this.selectCurrencyType = user.CurrencyClient
  }

  handleChangeTransactionType(idTransactionType: number) {
    let code = Utils.findTransactionTypeCode(this.ListTransactionsTypes, idTransactionType)

    switch (code) {
      case 'Conversion':
        this.showValueFx = true
        break

      default:
        this.showValueFx = false
        break
    }
  }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb)
    this.clientData.setCurrentView(EnumViews.TOOLS, 'trCreate');
    this.getListClients()
    this.getListCurrencyType()
    this.getTransactionType()
  }

  validateFieldsSelectedTransactionType(): boolean {
    const transactionTypeCode = Utils.findTransactionTypeCode(this.ListTransactionsTypes, this.selectTransactionType)

    if (!enabledTransactionTypes.includes(transactionTypeCode)) return false

    switch (transactionTypeCode) {
      case 'Conversion':
        return (
          this.valueFx !== '' &&
          this.valueFx !== null &&
          this.validateNumber(this.valueFx)
        )

      default:
        return true
    }
  }

  get validateForm(): boolean {
    return (
      this.amount !== '' &&
      this.validateNumber(this.amount) &&
      this.description.trim().length > 0 &&
      this.selectEntityUser !== null &&
      this.selectEntityUser !== '' &&
      this.selectCurrencyType !== null &&
      this.selectCurrencyType !== '' &&
      this.validateFieldsSelectedTransactionType()
    )
  }

  validateNumber(value: string = '') {
    return Utils.validateAmount(value, 12, 6)
  }

  cleanFrm(): void {

    this.selectTransactionType = this.ListTransactionsTypes[0].idTransactionType;
    this.selectEntityUser = this.ListEntitiesUsers[0].idEntityUser;
    this.selectCurrencyType = this.ListEntitiesUsers[0].CurrencyClient
    this.amount = '';
    this.description = '';

  }
}
