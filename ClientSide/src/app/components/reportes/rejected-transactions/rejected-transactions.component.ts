import { Component, OnInit } from '@angular/core';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service';
import { ModalServiceLp } from '../../services/lp-modal.service';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { EnumViews } from '../../services/enumViews';
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import Utils from 'src/app/utils';
import { RejectedTransaction } from 'src/app/models/rejectedTransactionModel'
import { Merchant } from 'src/app/models/merchantModel';
import { map } from 'rxjs-compat/operator/map';
import { error } from 'protractor';
@Component({
  selector: 'app-rejected-transactions',
  templateUrl: './rejected-transactions.component.html',
  styleUrls: ['./rejected-transactions.component.css']
})
export class RejectedTransactionsComponent implements OnInit {

  ListMerchants: any[];
  ListSubMerchant: any[];
  ListSubmerchantFilter: any[] = [];
  ListMetodos: any[] = []
  ListRejectedReasons: any[] = []
  ListRejectedTransactions: RejectedTransaction[] = []
  ListFieldsValidation: any[] = []
  ListErrorTypes: any[] = []
  ListFieldsValidationFilter:any[] = []
  dateFrom: Date = null;
  dateTo: Date = null;
  merchantSelect: any = null;
  subMerchantSelect: any = null;
  statusExport: boolean = false
  transactionType: any = null;
  amount: string = "";
  merchantIdSelect: string = null
  rejectedReasonSelect: string
  fieldSelect:any = null;
  errorTypeSelect:any = null;

  positionTop: string = "translateY(0px)"
  positionBottom: string = "";
  offset: number = 0;
  pageSize: number = 20;
  bsConfig: Partial<BsDatepickerConfig>;
  paramsFilter: any;
  ListColumns: any = ['Processed Date', 'Transaction Type', 'Merchant', 'ID Merchant', 'SubMerchant', 'Name', 'Country', 'City', 'Address', 'Email', 'Birthdate', 'Beneficiary Id', 'CBU', 'Amount', 'Reason for Rejected']
  itemsBreadcrumb: any = ['Home', 'Reports', 'Rejected Transactions'];
  toggleFitro = false;
  userPermission: string = this.securityService.userPermission;

  constructor(private LpServices: LpMasterDataService,
    private modalServiceLp: ModalServiceLp, private securityService: LpSecurityDataService, private clientData: ClientDataShared, private sanitizer: DomSanitizer) { }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.REPORTS, 'TrRejected');
    this.bsConfig = { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY', showWeekNumbers: false }
    if (this.userPermission != "ADMIN")
      this.loadFields(this.securityService.currentUser.idEntityAccount.toString());
    else
    this.loadFields();
    this.getListErrorTypes();
    this.paramsFilter = {

      "dateFrom": null,
      "dateTo": null,
      "idEntityUser": null,
      "idTransactionType": null,
      "amount": null,
      "merchantId": null,
      "pageSize": this.pageSize,
      "offset": this.offset,

    }
  }

  loadSubmerchantFilter(merchantChange: Merchant) {
    this.subMerchantSelect = null;
    if(this.ListSubMerchant != null && this.ListSubMerchant.length > 0){
      this.ListSubmerchantFilter = this.ListSubMerchant.filter(e => e.idEntityUser == merchantChange.idEntityUser)
    }
    this.fieldSelect = null;
    if(this.ListFieldsValidation != null && this.ListFieldsValidation.length > 0){
      this.ListFieldsValidationFilter = this.ListFieldsValidation.filter(e=>  e.CountryCode == merchantChange.CountryCode )
    }
  }

  getListTransactionsError(params: any, autoScroll: boolean = false) {


    this.LpServices.Reports.getListTransactionsError(this.paramsFilter).subscribe((data: any) => {
      if (autoScroll == false) {

        this.ListRejectedTransactions = [];
      }
      if (data != null) {

        data.forEach(txError => this.ListRejectedTransactions.push(new RejectedTransaction(txError)));

      }
      this.paramsFilter.offset = this.paramsFilter.offset + this.pageSize;

      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

    }, error => {

      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

    })

  }

  getListErrorTypes() {

    this.LpServices.Filters.getListErrorTypes().subscribe((data: any) => {

      this.ListErrorTypes = data;


    })

  }

  filterList() {

    this.modalServiceLp.showSpinner();
    var myDiv = document.getElementById('divContainerTable');
    if (myDiv != null) { myDiv.scrollTop = 0; }
    this.offset = 0;
    this.paramsFilter = {

      "dateFrom": this.dateFrom != null ? this.dateFrom.toISOString().replace(/-|T.*/g, '') : null,
      "dateTo": this.dateTo!= null ? this.dateTo.toISOString().replace(/-|T.*/g, '') : null,
      "idEntityUser": this.merchantSelect.idEntityUser,
      "transactionType": this.transactionType,
      "amount": this.amount != "" ? this.amount : null,
      "idEntitySubmerchant": this.subMerchantSelect,
      "merchantId": this.merchantIdSelect != "" ? this.merchantIdSelect : null,
      "idField": this.fieldSelect,
      "idErrorType"      : this.errorTypeSelect,
      "pageSize": this.pageSize,
      "offset": this.offset,

    }
    this.getListTransactionsError(this.paramsFilter)
  }

  scrollFixedHead($event: Event) {
    let divTabla: HTMLDivElement = <HTMLDivElement>$event.srcElement
    let scrollOffset = divTabla.scrollTop;
    let tabla: HTMLTableElement = <HTMLTableElement>divTabla.children[0]

    let offsetBottom = (tabla.offsetHeight - divTabla.offsetHeight + 15) * -1 + scrollOffset
    this.positionBottom = "translateY(" + offsetBottom + "px)"
    this.positionTop = "translateY(" + scrollOffset + "px)"
  }
  onScrollReport() {
    this.getListTransactionsError(this.paramsFilter, true);
  }
  formatErrors(errors: any) {
    return Utils.mergeError(JSON.parse(errors));
  }
  exportToExcel() {
    this.statusExport = true;
    var _dateTo = new Date();
    let paramsFilter = {

      "dateFrom": this.paramsFilter.dateFrom == null ? null : this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.paramsFilter.dateTo == null ? null : this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "idEntityUser": this.merchantSelect.idEntityUser,
      "transactionType": this.transactionType,
      "amount": this.amount != "" ? this.amount : null,
      "idEntitySubmerchant": this.subMerchantSelect,
      "merchantId": this.merchantIdSelect != "" ? this.merchantIdSelect : null,
      "pageSize": null,
      "offset": 0,

    }
    let body = {
      columnsReport: this.ListColumns,
      TypeReport: 'TRANSACTION_REJECTED',
      requestReport: paramsFilter
    }
    this.LpServices.Export.testExport(body).subscribe((data: any) => {
      if (data != null) {

        let nameFile = 'RejectedTransactions.xlsx';

        this.downloadFile(data, nameFile);
        this.statusExport = false;
      }

    }
      , error => {

      })

  }

  downloadFile(content, filename) {
    var a = document.createElement('a');
    a.href = "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64," + content;
    a.download = filename;
    a.click();
  }

  getHtmlPopover(errors: any): SafeHtml {

    let html: string = ``
    let errorsFormated = Utils.mergeErrorPopover(errors)

    errorsFormated.forEach(error => {
      html = html + error + '<br> <div  class="dropdown-divider" style="border-color: lightgray;"></div>'
    });

    return this.sanitizer.bypassSecurityTrustHtml(html);
  }


  validateNumber(value: any) {
    if (value != "" || value != null) {
      var regexNumber = /^\d*\.?\d*$/;

      return regexNumber.test(value);
    }
    else {
      return true;
    }
  }

  
  public get validateFilterBtn() : boolean {
    
    return (this.dateFrom != null && this.dateTo!=null) && (this.merchantSelect != null)
  }

  loadMerchant() {
    if (this.userPermission != "ADMIN"){
      var currentUser = this.securityService.currentUser
      this.merchantSelect = this.ListMerchants.find(x => x.idEntityUser == currentUser.idEntityUser);
      this.loadSubmerchantFilter(this.merchantSelect);
    }
  }

  loadFields(idUser: string = '0' ) {
    //Get list of clients
    this.LpServices.Filters.getListClients(idUser).subscribe((data: any) => {
      if (data != null) {
        this.ListMerchants = data;

        //Get list of Submerchants
        this.LpServices.Filters.getListSubMerchantUser(this.securityService.currentUser.customer_id).subscribe((_listSubmerchant: any[]) => {
          let auxArray = [];
          _listSubmerchant.forEach(subM => {
            auxArray.push(subM);
          });
          this.ListSubMerchant = auxArray;
          //Get Validations
          this.LpServices.Filters.getListFieldsValidation().subscribe((data: any) => {
            this.ListFieldsValidation = data;

            //If user is Merchant, load his data
            this.loadMerchant();
          },
          error => {
            console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
          })

        },
        errorSubMerchant => {
          console.log(errorSubMerchant.error.ExceptionMessage + ' - ' + errorSubMerchant.error.ExceptionType);
        })
      }

    },
     errorClient => {
      console.log(errorClient.error.ExceptionMessage + ' - ' + errorClient.error.ExceptionType);
    })
  }

}
