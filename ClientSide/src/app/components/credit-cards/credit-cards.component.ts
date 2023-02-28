import { Component, OnInit } from '@angular/core';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import Utils from 'src/app/utils'
import { EnumViews } from 'src/app/components/services/enumViews';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';

const enabledTransactionTypes = ['AddBalance', 'Conversion', 'AddDebit']

@Component({
  selector: 'app-credit-cards',
  templateUrl: './credit-cards.component.html',
  styleUrls: ['./credit-cards.component.css']
})
export class CreditCardsComponent implements OnInit {

  itemsBreadcrumb: any = ['Home', 'Tool', 'Test Credits Cards Tool']
  
  //card data
  ListCreditCards: any[]
  ListCurrenciesTypes: any[]
  cardNumber: string = ''
  securityCode: string = ''
  itemsMonth: any = ['01','02','03','04','05','06','07','08','09','10','11','12']
  itemsYear: any = ['19','20','21','22','23','24','25']
  cardHolderName: string = ''
  birthday: Date = new Date(Date.now());
  doorNumber: string = ''
  ListIdentificationTypes: any []
  idNumber: string = ''
  bin: string = ''
  bsConfig: Partial<BsDatepickerConfig>;

  //payment data
  amount: any
  installments: any = ['1','2','3','4','5','6','7','8','9','10','11','12']
  description: string = ''


  //calculations
  partial: any = null
  taxes: any = null
  total: any = null
  perInsta: any = null



  // ListTransactionsTypes: any[]
  
  

  selectInstallments: any = 1
  selectCreditCard: any  = 1
  selectIdentificationType: any = 1
  selectCurrencyType: any = "ARS"
  //selectTransactionType: any  
  selectExpirationMonth: any = null 
  selectExpirationYear: any = null




  showValueFx: boolean = false
  valueFx: string = '1'

  constructor(private clientData: ClientDataShared, private modalServiceLp: ModalServiceLp, private LpServices: LpMasterDataService) { }

  confirmPayment() {
    let amount = this.amount
    if (!amount.includes('.')) amount += '00'  

    var decimals = this.amount.substring(this.amount.length - 3, this.amount.length);
    var decimals2 = this.amount.substring(this.amount.length - 2, this.amount.length);

    if(amount.includes('.')) amount = amount - decimals + decimals2

    


    

    let body = {
      identification: "20347389683",
      cardData:
      {
        card_number: this.cardNumber,
        card_expiration_month: this.selectExpirationMonth,
        card_expiration_year: this.selectExpirationYear,
        security_code: this.securityCode,
        card_holder_name: this.cardHolderName,
        card_holder_birthday: this.birthday,
        card_holder_door_number: this.doorNumber,
        card_holder_identification: 
        {
          type: this.selectIdentificationType,
          number: this.idNumber,
        },
        fraud_detection: 
        {
          device_unique_identifier: "12345"
        }
      },
        paymentData: 
        {
          site_transaction_id: "1258955bb",
          token: "",
          payment_method_id: "1",
          bin: this.cardNumber.substring(0,6),
          amount: amount, //si no tiene coma, agrego dos ceros. Si tiene coma, sacarla
          currency: this.selectCurrencyType,
          installments: this.selectInstallments,
          description: this.description,
          payment_type: "single",
          sub_payments: []
        }
      }
    

    this.LpServices.CreditCards.postConfirmPayment(body).subscribe((data: any) => {
      if (data !== null) {
        if (data.ErrorRow.HasError === false) {
          this.modalServiceLp.openModal('SUCCESS', 'Transaction Status: ' + data.status , 'Ticket: ' + data.status_details.ticket + ' Site transaction ID: ' + data.site_transaction_id)
          this.cleanFrm();
        } else {
          this.modalServiceLp.openModal('ERROR', 'Operacion erronea', 'ver mensaje de error')
        }
      } else {
        this.modalServiceLp.openModal('ERROR', 'Error', 'Unknown error')
      }
    }, error => {
      this.modalServiceLp.openModal('ERROR', 'Error', 'Unknown error')
    })
  }

  get CalculateTaxes(){
    if(this.amount == 0 || this.amount == null)
    {
      return 0
    }
    else
    {
      this.taxes = parseFloat(this.amount) * ( (this.selectInstallments - 1 ) * 0.07 )
      return parseFloat(this.taxes)
    }
  }

  get CalculateTotal(){
    if(this.amount == 0 || this.amount == null)
    {
      return 0
    }
    else
    {
      this.total = parseFloat(this.amount) + this.taxes 
      return this.total
    }
  }
     

  get CalculateInstallments(){
    if(this.amount == 0 || this.amount == null)
    {
      return
    }
    else
    {
      return '$ ' + this.total / this.selectInstallments + ' per Installment'
    }
  }



  getListCreditCards() {
      //this.ListCreditCards = ['Visa', 'Mastercard', 'American Express']
        this.ListCreditCards = [ 
                                  {
                                      "idCard": 1,
                                      "Card": "Visa"
                                  },
                                  {
                                      "idCard": 2,
                                      "Card": "MasterCard",
                                  },
                                  {
                                    "idCard": 3,
                                    "Card": "Diners",
                                  },
                                  {
                                    "idCard": 4,
                                    "Card": "AMEX",
                                  },
                                  {
                                    "idCard": 5,
                                    "Card": "CABAL",
                                  }
                                ]
  }

  getListIdentificationTypes() {
      this.ListIdentificationTypes = [ 
                                  {
                                      "idType": 1,
                                      "Type": "DNI"
                                  },
                                  {
                                      "idType": 2,
                                      "Type": "LE",
                                  },
                                  {
                                    "idType": 3,
                                    "Type": "CUIT",
                                  }
                                    ]
}


getListCurrencyType() {
  this.ListCurrenciesTypes = [ 
                                {
                                  "Code": 2350,
                                  "Name": "ARS"
                                }
                             ]
}
  

  // getListCurrencyType() {
  //   this.LpServices.Filters.getListCurrency().subscribe((data: any) => {
  //     if (data != null) {
  //       this.ListCurrenciesTypes = data
  //     }
  //   }, error => {
  //     console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
  //   })
  // }

  // getTransactionType() {
  //   this.LpServices.Filters.getTransactionTypes().subscribe((data: any) => {
  //     if (data != null) {
  //       let filterList = data.filter(item => (item.idTransactionGroup === 10 && item.idTransactionOperation === 6))
  //       this.ListTransactionsTypes = filterList
  //       this.selectTransactionType = this.ListTransactionsTypes[0].idTransactionType
  //     }
  //   }, error => {
  //     console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
  //   })
  // }



  // handleChangeTransactionType(idTransactionType: number) {
  //   let code = Utils.findTransactionTypeCode(this.ListTransactionsTypes, idTransactionType)

  //   switch (code) {
  //     case 'Conversion':
  //       this.showValueFx = true
  //       break

  //     default:
  //       this.showValueFx = false
  //       break
  //   }
  // }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb)
    this.clientData.setCurrentView(EnumViews.TOOLS, 'trCreate');
    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY' });
    this.getListCreditCards()
    this.getListCurrencyType()
    //this.getTransactionType()
    this.getListIdentificationTypes()
  }

  // validateFieldsSelectedTransactionType(): boolean {
  //   const transactionTypeCode = Utils.findTransactionTypeCode(this.ListTransactionsTypes, this.selectTransactionType)

  //   if (!enabledTransactionTypes.includes(transactionTypeCode)) return false

  //   switch (transactionTypeCode) {
  //     case 'Conversion':
  //       return (
  //         this.valueFx !== '' &&
  //         this.valueFx !== null &&
  //         this.validateNumber(this.valueFx)
  //       )

  //     default:
  //       return true
  //   }
  // }

  get validateForm(): boolean {
    return (
      this.selectCreditCard !== null &&
      this.selectCreditCard !== '' &&
      this.selectCurrencyType !== null &&
      this.selectCurrencyType !== '' &&
      this.cardNumber !== '' &&
      this.securityCode !== '' &&
      this.selectExpirationMonth !== null &&
      this.selectExpirationMonth !== '' &&
      this.selectExpirationYear !== null &&
      this.selectExpirationYear !== '' &&
      this.cardHolderName !== '' &&
      this.selectIdentificationType !== null &&
      this.selectIdentificationType !== '' &&
      this.idNumber !== '' &&
      this.amount !== null &&
      this.installments !== null &&
      this.installments !== '' &&
      this.description.trim().length > 0 

      // this.validateNumber(this.amount) &&
      // this.validateNumber(this.cardNumber) 
      //this.validateCardLength(this.cardNumber)   
      // this.validateFieldsSelectedTransactionType()
    )
  }


  validateNumber(value: any) {
    if (value != null) {
      var regexNumber = /^\d*\.?\d*$/;
      return regexNumber.test(value);
    }
    else 
      return true;
  }


  validateCardLength(value: string = '') {
    // return true
    return Utils.validateAmount(value, 22, 0)
  }

  cleanFrm(): void {

    //this.selectTransactionType = this.ListTransactionsTypes[0].idTransactionType;
    
    //card data
    this.selectCreditCard = this.ListCreditCards[0];
    this.selectCurrencyType = this.ListCurrenciesTypes[0];
    this.cardNumber = '' ;
    this.securityCode = '' ;
    this.selectExpirationMonth = this.itemsMonth[0];
    this.selectExpirationYear = this.itemsYear[0];
    this.cardHolderName = '' ;
    this.birthday = null;
    this.doorNumber = '';
    this.selectIdentificationType = this.ListIdentificationTypes[0];
    this.idNumber = '' ;
    //payment data
    this.amount = null;
    this.selectInstallments = this.installments[0];
    this.description = '';
  }

}
