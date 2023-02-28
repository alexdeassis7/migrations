import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { SpinnerWaitComponent } from 'src/app/components/shared/spinner/spinner.component';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { BsModalService } from 'ngx-bootstrap/modal';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { EnumViews } from '../../../services/enumViews';
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { DatePipe } from '@angular/common'
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { Country } from 'src/app/models/countryModel';
import { environment } from '../../../../../environments/environment.prod';
import { Transaction } from 'src/app/components/model/transaction';
import { BoliviaService } from '../../services/bolivia/bolivia-payout-service';


@Component({
  selector: 'app-payout-sol-bancarias',
  templateUrl: './payout-sol-bancarias.component.html',
  styleUrls: ['./payout-sol-bancarias.component.css']
})
export class PayoutSolBancariasComponent implements OnInit {
  repeatedFlag: boolean = false;
  transactionsRepetead: Transaction[] = [];
  filesUpload: any[] = [];
  files: any;
  res: any = [];
  itemsBreadcrumb: any = ['Home', 'Files Manager', 'PayOut', 'Bank Solutions'];
  action: string;
  stateLoad: boolean = false;
  stateValidation: boolean = false;
  stateUpload: boolean = false;
  modifyInclude: boolean = true;
  modifyExclude: boolean = true;
  finalState: boolean = null;
  hasLotAmountMaxLimit = false;    // define if the provider has a maximum limit by lot 
  maxAmountLimitProvider = 0;  // if provider has a limit of amount by lot 

  fileBase64: any;
  bsModalRef: BsModalRef;
  ListTransactions: any = [{ name: 'Providers Payment', val: '2' }]
  //TODO agregar verdadero provider de Uruguay
  ListProviders: any[] = [];
  ListFx: any = [{ name: 'With Fx', code: 'WITH_COT' }, { name: 'Without Fx', code: 'WITHOUT_COT' }]
  ListMerchants: any[] = []
  ListSubMerchants: any[] = []
  ListCountries: any[] = []
  ListProviderFilter: any[] = []
  ListMerchantFilter: any[] = [];
  ListSubMerchantFilter: any[] = [];
  ListBank: any[] = [];
  ListBankFiltered: any[] = [];
  ListBankInclude: any[] = [];
  ListBankExclude: any[] = [];
  inputElementFile: HTMLInputElement;
  MexOperationsFilter: any[] = [{
    value: 1,
    label: "Received"
  },
  {
    value: 2,
    label: "Approved Accounts"
  },
  {
    value: 3,
    label: "Pending PreRegister Response"
  }]


  dataTxt: string = "";
  dataTxtBenef: string = "";
  dataTxtBrou: string = "";

  downloadStatus: string = null;
  userPermission: string = this.securityService.userPermission;

  listTransactionsUpload: any = [];

  ErrorTrans: number = 0;
  OkTrans: number = 0;
  PendingTrans: number = 0;
  IgnoredTrans: number = 0;
  //Filters
  countryCode: string = null
  dollarPrice: string = "";
  actionSelect: string = "";
  trSelect: any = null;
  merchantSelect: any = null;
  subMerchantSelect: any = null;
  mexOperationType: any = 1;
  mexIncludeDupAmounts: boolean = false;
  txLimit: any = null;
  txMaxAmount: any = null;

  providerSelect: any = null;
  bankIncludeSelect= new Array();
  bankExcludeSelect= new Array();
  currencySelect: string = "";
  amountLimit: string = ""
  downloadDateTo: string = "";
  downloadHour: string = "";
  filteredPayouts: any[] = [];
  bsConfig: Partial<BsDatepickerConfig>;
  filteredPayoutsTotal: any;
  checkedPayouts: any[] = [];
  checkedPayoutsTotal: any;
  rejectAll: boolean = false;
  maxAmountExceeded = false;
  minAmountRequired = false;

  refT: ChangeDetectorRef = null
  constructor(
    private clientData: ClientDataShared,
    private modalService: BsModalService,
    private modalServiceLp: ModalServiceLp,
    private securityService: LpSecurityDataService,
    private LpServices: LpMasterDataService,
    private ref: ChangeDetectorRef,
    public datepipe: DatePipe) { }

  ngOnInit() {
    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY', showWeekNumbers: false, clearBtn: true });
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.FILE_MANAGER, 'PayOut', 'PayOutSolBancarias');
    this.action = 'upload';
    this.refT = this.ref;
    this.getProviders();
    this.getBanks();
    this.getCountries();
    this.getListClients();
    this.getListSubmerchant();
    this.trSelect = this.ListTransactions[0].val;
  }

  //disabledCheckInput: boolean = false;

  handleShowPopOver(amount: any,provider: any, bank: any, accountType: any){
    
    if(amount > 5000000 && provider == 'SEC' && bank != 'Banco Security'){
      return "The amount exceeds the allowed value - 5000000";
    }

    if(accountType && accountType == "P" && provider != 'STPMEX'){
      return "The cellular account type is only downloadable with STP MEXICO"
    }

    if(accountType && accountType == "D" && provider != 'STPMEX'){
      return "The type of debit account is only downloadable with STP MEXICO"
    }
    return "";

    
  }

  handleDisabledCheckInput(amount: any,provider: any, bank: any, accountType: any){
    
    if(amount > 5000000 && provider == 'SEC' && bank != 'Banco Security'){
      return true;
    }

    if(accountType && accountType == "P" && provider != 'STPMEX'){
      return true
    }

    if(accountType && accountType == "D" && provider != 'STPMEX'){
      return true
    }

    return false;

    
  }

  onFileChange(event) {
    if (event.target.files.length > 0) {
      this.filesUpload = event.target.files;
      this.files = event
      this.inputElementFile = <HTMLInputElement>event.srcElement
      this.stateValidation = true;
      this.stateUpload = false;
      this.listTransactionsUpload = [];
      this.ErrorTrans = 0;
      this.OkTrans = 0;
      this.PendingTrans = 0;
      this.IgnoredTrans = 0;
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

  getBanks() {
    this.LpServices.Filters.getBanks().subscribe((data: any) => {
      if (data != null) {
        this.ListBank = data
        //this.ListBankExclude=data
      }
    }, error => {
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType)
    })
  }

  loadTxLimit() {
    this.txLimit = null;
    this.resetAmountLimitValidation();

    if (this.providerSelect) {

      let provider = this.getFilteredProvider();
      this.maxAmountLimitProvider = provider.batchFileTxLimit
      this.txLimit = this.maxAmountLimitProvider;
      
      // TODO: Solve with a better pattern filter rather than if/else (By now, because is only one case we star with if/else)
      this.bankExcludeSelect = new Array();
      this.bankIncludeSelect = new Array();
      
      if (provider.code === 'SEC') {
        this.hasLotAmountMaxLimit = true;
      }

      if (this.countryCode === null)
      {
            this.modifyInclude = true;
            this.modifyExclude = true;
      }
      else
      {
        if (this.providerSelect === 'BCHILE822' || this.providerSelect === 'SANTARCVU') {   
            this.modifyInclude = true;
            this.modifyExclude = true;
        }
        else {
            this.modifyInclude = false;
            this.modifyExclude = false;
        }
      }
      this.ListBankFiltered = this.ListBank.filter(e => e.countryCode == this.countryCode);
      if (this.ListBankFiltered.length > 0) {
          this.ListBankInclude = this.ListBankFiltered[0].bankFullNameCodes;
          this.ListBankExclude = this.ListBankFiltered[0].bankFullNameCodes; 
      }
      if (this.providerSelect === 'BCHILE816') {
        var index= this.ListBankExclude.findIndex(x => x.bankCode == '012' ); 
        this.bankExcludeSelect.push(this.ListBankExclude[index].bankCode);
        this.bankExcludeSelect = [...this.bankExcludeSelect];
        this.ListBankInclude = this.ListBankInclude.filter(x => x.bankCode != '012');
        return;
       }

       this.ListBankFiltered = this.ListBank.filter(e => e.countryCode == this.countryCode);
       if (this.ListBankFiltered.length > 0) {
           this.ListBankInclude = this.ListBankFiltered[0].bankFullNameCodes;
       }

      if (this.providerSelect === 'BCHILE822') {
        var index= this.ListBankInclude.findIndex(x => x.bankCode == '012' ); 
        this.bankIncludeSelect.push(this.ListBankInclude[index].bankCode);
        this.bankIncludeSelect = [...this.bankIncludeSelect];
      }
      if (this.providerSelect === 'SANTAR') { // SANTANDER ARGENTINA
       var index= this.ListBankExclude.findIndex(x => x.bankCode == '00000' ); 
       this.bankExcludeSelect.push(this.ListBankExclude[index].bankCode);
       this.bankExcludeSelect = [...this.bankExcludeSelect];
       this.ListBankInclude = this.ListBankInclude.filter(x => x.bankCode != '00000');
       return;
      }
      if (this.providerSelect === 'SANTARCVU') { // SANTANDER ARGENTINA CVU 
       var index= this.ListBankInclude.findIndex(x => x.bankCode == '00000' ); // WALLETS 
       this.bankIncludeSelect.push(this.ListBankInclude[index].bankCode);
       this.bankIncludeSelect = [...this.bankIncludeSelect];
      }
   }
 }

  getFilteredProvider() {
    let provider = this.ListProviders.filter(x => { return x.code === this.providerSelect && x.countryCode === this.countryCode })[0];
    console.log(provider);
    return provider;
  }

  loadCheckboxTransactions(Transaction: any, rejected: boolean) {
    if (rejected) {
      this.checkedPayouts.push(Transaction)
      if (Transaction.HistoricalyRepetead || Transaction.Repeated) {
        this.repeatedFlag = true;
        this.transactionsRepetead.push(Transaction);
      }
    }
    else {
      let index = this.checkedPayouts.indexOf(Transaction);
      this.checkedPayouts.splice(index, 1);
      if (Transaction.HistoricalyRepetead || Transaction.Repeated) {
        this.transactionsRepetead = this.transactionsRepetead.filter(obj => obj !== Transaction);
        if (this.transactionsRepetead.length == 0) {
          this.repeatedFlag = false;
        }
      }
    }
    this.checkAll();
    this.loadCheckboxTotals();
    this.validateMaxAmount();
  }

  onTextMaxAmountChange(amountValue: number) {
    
    this.minAmountRequired = amountValue < 0;  // In all cases, value must be positive

    if(this.providerSelect && this.maxAmountLimitProvider != undefined)
    {
      if(this.maxAmountLimitProvider > 0) {
        this.maxAmountExceeded = (amountValue > this.maxAmountLimitProvider);
        this.minAmountRequired = amountValue <= 0;
      }
      else {
        this.minAmountRequired = false;
        this.maxAmountExceeded = false;
      }
    }
  }
  
  loadAllTransactions(rejected: boolean) {
    console.log(rejected);
    this.checkedPayouts = [];
    if (rejected) {
      this.filteredPayouts.forEach((Payout:any) => {
        console.log("[Mostrando payouts]", Payout);
        if(!this.handleDisabledCheckInput(Payout.NetAmount,this.providerSelect,Payout.Bank,Payout.AccountType)){
          Payout.Reject = true;
          this.checkedPayouts.push(Payout);
        }
        //Payout.Reject = true;
        //this.checkedPayouts.push(Payout);
        if (Payout.HistoricalyRepetead || Payout.Repeated) {
          this.repeatedFlag = true;
          this.transactionsRepetead.push(Payout);
        }
      });
    }
    else {
      this.filteredPayouts.forEach(Payout => {
        Payout.Reject = false;
        if (Payout.HistoricalyRepetead || Payout.Repeated) {
          this.transactionsRepetead = this.transactionsRepetead.filter(obj => obj !== Payout);
          if (this.transactionsRepetead.length == 0)
            this.repeatedFlag = false;
        }
      });
    }
    
    this.loadCheckboxTotals();
  }

  checkAll() {
    this.rejectAll = this.checkedPayouts.length == this.filteredPayouts.length ? true : false
    //this.rejectAll = true;
  }

  loadCheckboxTotals() {
    var total = {
      'GrossValueClient': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['GrossValueClient']) || 0), 0),
      'LocalTax': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['LocalTax']) || 0), 0),
      'TaxWithholdings': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['TaxWithholdings']) || 0), 0),
      'TaxWithholdingsARBA': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['TaxWithholdingsARBA']) || 0), 0),
      'NetAmount': this.checkedPayouts.reduce((a, b) => parseFloat(a) + (parseFloat(b['NetAmount']) || 0), 0),
    };
    this.checkedPayoutsTotal = total;
  }

  uploadServer() {
    this.modalServiceLp.showSpinner();

    if (this.providerSelect == "BSPVIELLE") {
      var params = {
        "File": null,
        "CurrencyFxClose": this.actionSelect == 'WITH_COT' ? this.formatNumber(this.dollarPrice) : 0
      }

      this.LpServices.Payout.postFilePayOut(params, this.countryCode, this.providerSelect).subscribe((data: any) => {
        var response = JSON.parse(data);

        if (response.Status == "ERROR") {
          this.finalState = false
          this.modalServiceLp.openModal('ERROR', 'Alert', response.Status + ' - ' + response.StatusMessage);
        }
        if (response.Status == "OK") {
          if (this.countryCode == "ARG" && this.providerSelect == "BSPVIELLE") { this.validateUploadARG_Supervielle(response) }
        }

        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      }, error => {
        let _error = error.error;
        this.modalServiceLp.openModal('ERROR', 'API ERROR', _error.Message);
        this.finalState = false

        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      });
    } else {

      var file: File = this.filesUpload[0]
      var myReader: FileReader = new FileReader();
      myReader.onloadend = (e) => {
        if (this.providerSelect == "FASTCASH" || this.providerSelect == "PLURAL" || this.providerSelect == "ITAUCHL" || this.providerSelect == "ITAU") {
          this.fileBase64 = btoa(String.fromCharCode.apply(null, new Uint8Array(<ArrayBuffer>myReader.result)));
        }
        else {
          this.fileBase64 = btoa(unescape(encodeURIComponent(new TextDecoder('utf-8').decode(new Uint8Array(<ArrayBuffer>myReader.result)))));
        }
        var params = {
          "File": this.fileBase64,
          "CurrencyFxClose": this.actionSelect == 'WITH_COT' ? this.formatNumber(this.dollarPrice) : 0
        }

        if (this.countryCode == "MEX") params["FileName"] = this.filesUpload[0].name;

        this.LpServices.Payout.postFilePayOut(params, this.countryCode, this.providerSelect).subscribe((data: any) => {
          var response = JSON.parse(data);

          if (response.Status == "ERROR") {
            this.finalState = false
            this.modalServiceLp.openModal('ERROR', 'Alert', response.Status + ' - ' + response.StatusMessage);
          }
          if (response.Status == "OK") {

            if (this.countryCode == "ARG" && this.providerSelect == "BGALICIA") { this.validateUploadARG_Galicia(response) }
            if (this.countryCode == "ARG" && (this.providerSelect == "BBBVA" || this.providerSelect == "BBBVATP")) { this.validateUploadARG_BBVA(response) }
            if (this.countryCode == "ARG" && this.providerSelect == "SANTAR") { this.validateUploadCOL(response) }
            if (this.countryCode == "COL" || this.countryCode == 'BRA' || this.countryCode == 'CHL') { this.validateUploadCOL(response) }
            if (this.countryCode == "MEX" && this.providerSelect == "SRM") { this.validateUploadCOL(response) }
            if (this.countryCode == "MEX" && this.providerSelect != "SRM") { this.validateUploadMEX(response) }

            this.listTransactionsUpload.sort(function (a, b) {
              return -a.StatusCode.localeCompare(b.StatusCode);
            })
          }

          setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
        }, error => {
          let _error = error.error;
          this.modalServiceLp.openModal('ERROR', 'API ERROR', _error.Message);
          this.finalState = false

          setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
        });
      }
      myReader.readAsArrayBuffer(file);
    }
  }

  validateUploadMEX(response: any) {
    response.TransactionDetail.forEach(lisTr => {
      if (lisTr.StatusCode == 'Received' || lisTr.InternalStatus == 'SUC' || lisTr.StatusCode == 'Executed') {
        this.OkTrans++;
      } else {
        this.ErrorTrans++;
      }
      this.listTransactionsUpload.push(lisTr);
    });

    this.modalServiceLp.openModal('UPLOADED', 'Success', 'File was processed successfully')

    this.stateValidation = true;
    this.stateUpload = true;
    this.finalState = true
  }

  validateUploadARG_Galicia(response: any) {

    response.TransactionDetail.forEach(lisTr => {

      if (lisTr.InternalStatus == 60) {
        this.OkTrans++;
      } else {
        this.ErrorTrans++
      }
      this.listTransactionsUpload.push(lisTr);

    });

    this.modalServiceLp.openModal('UPLOADED', 'Success', response.BatchLotDetail.InternalStatus + ' - ' + response.BatchLotDetail.InternalStatusDescription)
    this.stateValidation = true;
    this.stateUpload = true;
    this.finalState = true


  }

  validateUploadARG_BBVA(response: any) {

    response.TransactionDetail.forEach(lisTr => {

      if (lisTr.InternalStatus == 'I7') {
        this.OkTrans++;
      } else {
        this.ErrorTrans++
      }
      this.listTransactionsUpload.push(lisTr);

    });

    this.modalServiceLp.openModal('UPLOADED', 'Success', response.BatchLotDetail.InternalStatus + ' - ' + response.BatchLotDetail.InternalStatusDescription)
    this.stateValidation = true;
    this.stateUpload = true;
    this.finalState = true


  }


  validateUploadARG_Supervielle(response: any) {

    response.TransactionDetail.forEach(lisTr => {

      if (lisTr.InternalStatus == "OK") {
        this.OkTrans++;
      } else {
        this.ErrorTrans++
      }

      this.listTransactionsUpload.push(lisTr);

    });

    this.modalServiceLp.openModal('UPLOADED', 'Success', 'File was processed successfully')

    this.stateValidation = true;
    this.stateUpload = true;
    this.finalState = true


  }
  validateUploadCOL(response: any) {
    response.TransactionDetail.forEach(lisTr => {


      if (lisTr.InternalStatus == "IGNORED") {
        this.IgnoredTrans++

      }
      else if (lisTr.InternalStatus == "ERROR" || lisTr.StatusCode == "Rejected") {
        this.ErrorTrans++

      }
      else if (lisTr.StatusCode == 'Executed') {

        this.OkTrans++;

      }
      else {

        this.PendingTrans++;
      }
      this.listTransactionsUpload.push(lisTr);
    });

    this.modalServiceLp.openModal('UPLOADED', 'Success', 'File was processed successfully')

    this.stateValidation = true;
    this.stateUpload = true;
    this.finalState = true

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


  validarArchivo() {
    this.bsModalRef = this.modalService.show(SpinnerWaitComponent, Object.assign({}, { class: "modal-dialog-centered", ignoreBackdropClick: true }));

    setTimeout(() => {
      this.stateValidation = true;
      this.bsModalRef.hide();
    }, 1000);

  }

  exportOperationalReport(idLotOut) {
    let tickets = this.checkedPayouts.map(a => a.Ticket);
    let body = {
      FileName: 'OperationalReport',
      Name: "[LP_Operation].[OperationalReport]",
      IsSP: true,
      Parameters: [{ Key: "json", Val: JSON.stringify(tickets) }, { Key: "country_code", Val: this.countryCode }]
    }

    this.LpServices.Export.ExportReport(body).subscribe((data: any) => {
      if (data != null) {

        this.downloadExcel(data, 'OperationalReport_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + this.countryCode + '_' + idLotOut + '.xlsx');
      }
    })
  }

  exportOperationalMerchantReport(idLotOut) {
    let tickets = this.checkedPayouts.map(a => a.Ticket);
    let body = {
      FileName: 'OperationalMerchantReport',
      Name: "[LP_Operation].[OperationalMerchantReport]",
      IsSP: true,
      Parameters: [{ Key: "json", Val: JSON.stringify(tickets) }, { Key: "country_code", Val: this.countryCode }]
    }

    this.LpServices.Export.ExportReport(body).subscribe((data: any) => {
      if (data != null) {

        this.downloadExcel(data, 'OperationalMerchantReport_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + this.countryCode + '_' + idLotOut + '.xlsx');
      }
    })
  }



  getFileTxtInternal() {
    this.modalServiceLp.showSpinner();
    let dateTo = new Date(this.downloadDateTo);

    this.LpServices.Payout.testDownload(this.checkedPayouts, this.countryCode, this.providerSelect, this.downloadHour, 1)
      .subscribe((datos: any) => {
        // DOWNLOAD OPERATIONAL REPORTS
        let idLotOut = 0;
        if (datos.idLotOut) idLotOut = datos.idLotOut;
        this.exportOperationalReport(idLotOut);
        this.exportOperationalMerchantReport(idLotOut);

        if (this.countryCode == 'MEX') {
          if (datos.Status && datos.PayoutFiles.length > 0) {
            this.downloadStatus = "OK";

            let PayoutFilesCount = 1
            datos.PayoutFiles.forEach(file => {
              this.dataTxt = atob(file.FileBase64_Payouts);
              let fileTotal = file.FileTotal;
              let fileRows = file.RowsPayouts;
              this.downloadFile(this.dataTxt, 'PO_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.PreRegisterLot + '_' + PayoutFilesCount + '_' + fileRows + '_' + fileTotal + '_' + idLotOut + '.txt');
              PayoutFilesCount++;
            });

            if (datos.RowsPreRegister > 0) {
              this.dataTxtBenef = atob(datos.FileBase64_PreRegister);
              this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.PreRegisterLot + '_' + datos.RowsPreRegister + '_' + idLotOut + '.txt');
            }
          }
          else if (datos.Status == "OK" && datos.RowsBeneficiaries == 0 && datos.RowsPayouts == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      },
        error => {
          // console.log(error.message) // error path
          this.downloadStatus = "ERROR";
          setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

        })
  }


  getFileTxt() {
    let providerTxLimit = this.getFilteredProvider();
    if (providerTxLimit > 0 && (this.checkedPayouts.length > providerTxLimit)) {
      console.log("Se seleccionaron mas transacciones del limite permitido por el proveedor.")
      return;
    }
    this.modalServiceLp.showSpinner();
    this.LpServices.Payout.testDownload(this.checkedPayouts, this.countryCode, this.providerSelect, this.downloadHour)
      .subscribe((datos: any) => {
        // DOWNLOAD OPERATIONAL REPORTS
        let idLotOut = 0;
        if (datos.idLotOut) idLotOut = datos.idLotOut;
        this.exportOperationalReport(idLotOut);
        this.exportOperationalMerchantReport(idLotOut);

        if (this.countryCode == 'MEX') {
          if (this.providerSelect == 'MIFEL') {
            if (datos.Status && datos.PayoutFiles.length > 0) {
              this.downloadStatus = "OK";

              let PayoutFilesCount = 1
              datos.PayoutFiles.forEach(file => {
                this.dataTxt = atob(file.FileBase64_Payouts);
                let fileTotal = file.FileTotal;
                let fileRows = file.RowsPayouts;
                this.downloadFile(this.dataTxt, 'PO_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.PreRegisterLot + '_' + PayoutFilesCount + '_' + fileRows + '_' + fileTotal + '_' + idLotOut + '.txt');
                PayoutFilesCount++;
              });

              if (datos.RowsPreRegister > 0) {
                this.dataTxtBenef = atob(datos.FileBase64_PreRegister);
                this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.PreRegisterLot + '_' + datos.RowsPreRegister + '_' + idLotOut + '.txt');
              }
            }

          }
          else if (this.providerSelect == 'SABADELL') {
            if (datos.Status && datos.PayoutFiles.length > 0) {
              this.downloadStatus = "OK";

              let PayoutFilesCount = 1
              datos.PayoutFiles.forEach(file => {
                this.dataTxt = atob(file.FileBase64_Payouts);
                let fileTotal = file.FileTotal;
                let fileRows = file.RowsPayouts;
                this.downloadFile(this.dataTxt, new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_000038379_' + ('000' + datos.DownloadCount).slice(-3) + '.csv');
                PayoutFilesCount++;
              });

              if (datos.RowsPreRegister > 0) {
                this.dataTxtBenef = atob(datos.FileBase64_PreRegister);
                this.downloadFile(this.dataTxtBenef, 'B' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + ('000' + datos.DownloadCount).slice(-3) + '.csv');
              }
            }
          }
          else if (this.providerSelect == 'SRM' || this.providerSelect == 'BANORTE') {
            if (datos.Status && datos.PayoutFiles.length > 0) {
              this.downloadStatus = "OK";

              let PayoutFilesCount = 1
              datos.PayoutFiles.forEach(file => {
                this.dataTxt = atob(file.FileBase64_Payouts);
                let fileTotal = file.FileTotal;
                let fileRows = file.RowsPayouts;
                this.downloadFile(this.dataTxt, 'PO_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + PayoutFilesCount + '_' + fileRows + '_' + fileTotal + '_' + idLotOut + '.txt');
                PayoutFilesCount++;
              });

              if (datos.RowsPreRegister > 0) {
                this.dataTxtBenef = atob(datos.FileBase64_PreRegister);
                this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.RowsPreRegister + '_' + idLotOut + '.txt');
              }
            }
          }
          else if (this.providerSelect == 'BBVAMEX') {
            if (datos.Status && datos.PayoutFiles.length > 0) {
              this.downloadStatus = "OK";

              let PayoutFilesCount = 1
              datos.PayoutFiles.forEach(file => {
                this.dataTxt = atob(file.FileBase64_Payouts);
                let fileTotal = file.FileTotal;
                let fileRows = file.RowsPayouts;
                this.downloadFile(this.dataTxt, 'PO_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + PayoutFilesCount + '_' + fileRows + '_' + fileTotal + '_' + idLotOut + '.txt');
                PayoutFilesCount++;
              });

              if (datos.RowsPreRegister > 0) {
                this.dataTxtBenef = atob(datos.FileBase64_PreRegister);
                this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.RowsPreRegister + '_' + idLotOut + '.txt');
              }

              if (datos.RowsPreRegisterSameBank > 0) {
                this.dataTxtBenef = atob(datos.FileBase64_PreRegisterSameBank);
                this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.RowsPreRegisterSameBank + '_' + idLotOut + 'SAME_BANK' + '.txt');
              }

            }
          }
          else if(this.providerSelect == 'PMIMEX') {
            if (datos.Status && datos.ExcelRows > 0) {
              this.downloadStatus = "OK";
              let PayoutFilesCount = 1;
              let fileTotal = 1;
              let fileRows = datos.ExcelRows;
              this.downloadExcel(datos.FileBase64_ExcelFileOut, 'PO_' + this.providerSelect + '_' + idLotOut + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + idLotOut + '.xls');
              PayoutFilesCount++;
            }
          }
          else if (this.providerSelect == 'SCOTMEX') {
            this.DowloadActionForScotiaBankMEX(datos, idLotOut);
          }
          else if (this.providerSelect == 'STPMEX') {
            if (datos.Status && datos.PayoutFiles.length > 0) {
              this.downloadStatus = "OK";

              let PayoutFilesCount = 1
              datos.PayoutFiles.forEach(file => {
                this.dataTxt = atob(file.FileBase64_Payouts);
                let fileTotal = file.FileTotal;
                let fileRows = file.RowsPayouts;
                this.downloadFile(this.dataTxt, 'MEX_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + PayoutFilesCount + '_' + fileRows + '_' + idLotOut + '.txt');
                PayoutFilesCount++;
              });

              if (datos.RowsPreRegister > 0) {
                this.dataTxtBenef = atob(datos.FileBase64_PreRegister);
                this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.RowsPreRegister + '_' + idLotOut + '.txt');
              }

              if (datos.RowsPreRegisterSameBank > 0) {
                this.dataTxtBenef = atob(datos.FileBase64_PreRegisterSameBank);
                this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.RowsPreRegisterSameBank + '_' + idLotOut + 'SAME_BANK' + '.txt');
              }
            }
          }
          else if (this.providerSelect == 'STPMEX') {
            if (datos.Status && datos.PayoutFiles.length > 0) {
              this.downloadStatus = "OK";

              let PayoutFilesCount = 1
              datos.PayoutFiles.forEach(file => {
                this.dataTxt = atob(file.FileBase64_Payouts);
                let fileTotal = file.FileTotal;
                let fileRows = file.RowsPayouts;
                this.downloadFile(this.dataTxt, 'MEX_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + PayoutFilesCount + '_' + fileRows + '_' + idLotOut + '.txt');
                PayoutFilesCount++;
              });

              if (datos.RowsPreRegister > 0) {
                this.dataTxtBenef = atob(datos.FileBase64_PreRegister);
                this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.RowsPreRegister + '_' + idLotOut + '.txt');
              }

              if (datos.RowsPreRegisterSameBank > 0) {
                this.dataTxtBenef = atob(datos.FileBase64_PreRegisterSameBank);
                this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.RowsPreRegisterSameBank + '_' + idLotOut + 'SAME_BANK' + '.txt');
              }
            }
          }
          else if (datos.Status == "OK" && datos.RowsBeneficiaries == 0 && datos.RowsPayouts == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }
        if (this.countryCode == 'PRY') {
          if(this.providerSelect == 'ITAUPYG') {
              if (datos.Status && datos.ExcelRows > 0) {
                this.downloadStatus = "OK";
                let PayoutFilesCount = 1;
                let fileTotal = 1;
                let fileRows = datos.ExcelRows;
                this.downloadExcel(datos.FileBase64_ExcelFileOut, 'PAYOUT_' + this.providerSelect + '_' + idLotOut + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + idLotOut + '.xls');
                PayoutFilesCount++;
              }
           }
        }
        if (this.countryCode == 'COL') {

          if (this.providerSelect == "BCOLOMBIA" || this.providerSelect == "BCOLOMBIA2") {
            if (datos.Status && datos.RowsBeneficiaries > 0 && datos.RowsPayouts > 0) {
              this.downloadStatus = "OK";
              this.dataTxt = atob(datos.FileBase64_Payouts);
              this.dataTxtBenef = atob(datos.FileBase64_Beneficiaries)
              this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.txt');
              this.downloadFile(this.dataTxtBenef, 'BENEF_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.txt');

            }
            else if (datos.Status == "OK" && datos.RowsBeneficiaries == 0 && datos.RowsPayouts == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
          }
          else if (this.providerSelect == "OCCIDENTE") {
            if (datos.Status && datos.RowsPayouts > 0) {
              this.downloadStatus = "OK";
              this.dataTxt = atob(datos.FileBase64_Payouts);
              let fileTotal = datos.FileBase64_Beneficiaries;
              let fileRows = datos.RowsPayouts - 2;
              this.downloadFile(this.dataTxt, 'PO_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + 'T' + fileTotal + '_' + 'Q' + fileRows + '_' + idLotOut + '.txt');

            }
            else if (datos.Status == "OK" && datos.RowsPayouts == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
          }
          else if (this.providerSelect == "ACCIVAL") {
            if (datos.Status && datos.RowsPayouts > 0) {
              this.downloadStatus = "OK";
              this.dataTxt = atob(datos.FileBase64_Payouts);
              let fileRows = datos.RowsPayouts;
              let totalAmount = datos.TotalAmount;
              this.downloadFile(this.dataTxt, 'ACCIONES&VALORES_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + fileRows + '_' + totalAmount + '.prn');

            }
            else if (datos.Status == "OK" && datos.RowsPayouts == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
          }
          else if (this.providerSelect == "SCOTIACOL") {
            if (datos.Status && datos.RowsPayouts > 0) {
              this.downloadStatus = "OK";
              this.dataTxt = atob(datos.FileBase64_Payouts);
              let fileRows = datos.RowsPayouts;
              let totalAmount = datos.TotalAmount;
              this.downloadFile(this.dataTxt, 'SCOTIA_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + fileRows + '_' + totalAmount + '_' + idLotOut + '.xml');

            }
            else if (datos.Status == "OK" && datos.RowsPayouts == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
          }
          else if (this.providerSelect == "FINANDINA") {
            if (datos.Status && datos.RowsPayouts > 0) {
              this.downloadStatus = "OK";
              this.dataTxt = atob(datos.FileBase64_Payouts);
              let fileRows = datos.RowsPayouts;
              let totalAmount = datos.TotalAmount;
              this.downloadFile(this.dataTxt, 'FINANDINA_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + fileRows + '_' + totalAmount + '_' + idLotOut + '.txt');

            }
            else if (datos.Status == "OK" && datos.RowsPayouts == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
          }
          else if (this.providerSelect == "BCSC") {
            if (datos.Status && datos.RowsPayouts > 0) {
              this.downloadStatus = "OK";
              this.dataTxt = atob(datos.FileBase64_Payouts);
              let fileRows = datos.RowsPayouts;
              let totalAmount = datos.TotalAmount;
              this.downloadFile(this.dataTxt, 'BCSC_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + fileRows + '_' + totalAmount + '_' + idLotOut + '.txt');

            }
            else if (datos.Status == "OK" && datos.RowsPayouts == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
          }
          else if (this.providerSelect == "ITAUCOL") {
            if (datos.Status && datos.RowsPayouts > 0) {
              this.downloadStatus = "OK";
              this.dataTxt = atob(datos.FileBase64_Payouts);
              let fileRows = datos.RowsPayouts;
              let totalAmount = datos.TotalAmount;
              this.downloadFile(this.dataTxt, 'ITAU_COL_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + fileRows + '_' + totalAmount + '_' + idLotOut + '.txt');

            }
            else if (datos.Status == "OK" && datos.RowsPayouts == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
          }
          else if (this.providerSelect == "BBVACOL") {
            if (datos.Status && datos.RowsPayouts > 0) {
              this.downloadStatus = "OK";
              this.dataTxt = atob(datos.FileBase64_Payouts);
              let fileRows = datos.RowsPayouts;
              let totalAmount = datos.TotalAmount;
              this.downloadFile(this.dataTxt, 'BBVA_COL_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + fileRows + '_' + totalAmount + '_' + idLotOut + '.txt');

            }
            else if (datos.Status == "OK" && datos.RowsPayouts == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
          }
        }
        if (this.countryCode == 'ARG') {

          if (datos.Status == "OK" && datos.Rows > 0) {
            this.downloadStatus = "OK";
            let ext = ".txt";
            //if(this.providerSelect == "BSPVIELLE") ext = ".enk";
            this.dataTxt = atob(datos.FileBase64);
            if (this.providerSelect != "BSPVIELLE") {
              this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + ext);
            }
          }
          else if (datos.Status == "OK" && datos.Rows == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
          else if (datos.Status == "ERROR") {

            this.modalServiceLp.openModal("ERROR", 'Error', datos.StatusMessage)

          }
        }
        if (this.countryCode == 'BRA') {
          if (this.providerSelect == "FASTCASH") {
            if (datos.Status == "OK" && datos.transactions.length > 0) {
              this.downloadStatus = "OK";
              this.downloadExcel(datos.FileBase64, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.xlsx');
            }
            else if (datos.Status == "OK" && datos.Rows == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
            else if (datos.Status == "ERROR") {

              this.modalServiceLp.openModal("ERROR", 'Error', datos.StatusMessage)

            }
          } else if (this.providerSelect == "PLURAL") {
            var now = new Date();
            now.setSeconds(0, 0);
            var isoNow = new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString();
            var stamp = isoNow.replace(/T|-/g, "").replace(/:00.000Z/, "").replace(/:/, '');
            this.downloadExcel(datos.FileBase64, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + stamp + '_' + idLotOut + '.xlsx');
          }
          else if (this.providerSelect == "BDOBR") {
            if (datos.Status == "OK" && datos.Rows > 0) {
              this.downloadStatus = "OK";
              let ext = ".txt";
              this.dataTxt = atob(datos.FileBase64);
              this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + ext);
            }
            else if (datos.Status == "OK" && datos.Rows == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
            else if (datos.Status == "ERROR") {

              this.modalServiceLp.openModal("ERROR", 'Error', datos.StatusMessage)
            }
          }
          else if (this.providerSelect == "RENDBRTED") {
            if (datos.Status == "OK" && datos.Rows > 0) {
              this.downloadStatus = "OK";
              let ext = ".txt";
              this.dataTxt = atob(datos.FileBase64);
              this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + ext);
            }
            else if (datos.Status == "OK" && datos.Rows == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
            else if (datos.Status == "ERROR") {

              this.modalServiceLp.openModal("ERROR", 'Error', datos.StatusMessage)
            }
          }
          else if (this.providerSelect == "SAFRA") {
            if (datos.Status == "OK" && datos.Rows > 0) {
              this.downloadStatus = "OK";
              let ext = ".txt";
              this.dataTxt = atob(datos.FileBase64);
              this.downloadFile(this.dataTxt, 'SA_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + ext);
            }
            else if (datos.Status == "OK" && datos.Rows == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
            else if (datos.Status == "ERROR") {

              this.modalServiceLp.openModal("ERROR", 'Error', datos.StatusMessage)
            }
          }
          else if (this.providerSelect == "SANTBR") {
            if (datos.Status == "OK" && datos.Rows > 0) {
              this.downloadStatus = "OK";
              let ext = ".txt";
              this.dataTxt = atob(datos.FileBase64);
              this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + ext);
            }
            else if (datos.Status == "OK" && datos.Rows == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
            else if (datos.Status == "ERROR") {

              this.modalServiceLp.openModal("ERROR", 'Error', datos.StatusMessage)
            }
          }
          else if (this.providerSelect == "RENDIMENTO") {
            if (datos.Status == "OK" && datos.Rows > 0) {
              this.downloadStatus = "OK";
              let ext = ".txt";
              this.dataTxt = atob(datos.FileBase64);
              this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + ext);
            }
            else if (datos.Status == "OK" && datos.Rows == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
            else if (datos.Status == "ERROR") {

              this.modalServiceLp.openModal("ERROR", 'Error', datos.StatusMessage)
            }
          }
          else if (this.providerSelect == "ITAUBRPIX") {
            if (datos.Status == "OK" && datos.Rows > 0) {
              this.downloadStatus = "OK";
              let ext = ".txt";
              this.dataTxt = atob(datos.FileBase64);
              this.downloadFile(this.dataTxt, "PIX" + idLotOut + ext);
            }
            else if (datos.Status == "OK" && datos.Rows == 0) {
              this.downloadStatus = "NOTPROCESS";
            }
            else if (datos.Status == "ERROR") {

              this.modalServiceLp.openModal("ERROR", 'Error', datos.StatusMessage)
            }
          }

        }
        if (this.countryCode == 'URY') {

          if (datos.Status && (datos.RowsBrou > 1 || datos.RowsPayouts > 1)) {
            if (datos.RowsPayouts > 1) {
              let qtyPayouts = datos.RowsPayouts - 1
              let totalPayouts = datos.Total_Payouts
              this.dataTxt = atob(datos.FileBase64_Payouts);
              this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_T' + totalPayouts + '_Q' + qtyPayouts + '_' + idLotOut + '.txt');
            }
            if (datos.RowsBrou > 1) {
              let qtyBrou = datos.RowsBrou - 1
              let totalBrou = datos.Total_Brou
              this.dataTxtBrou = atob(datos.FileBase64_PayoutsBrou)
              this.downloadFile(this.dataTxtBrou, 'PAYOUT_BROU_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_T' + totalBrou + '_Q' + qtyBrou + '_' + idLotOut + '.txt');
            }
            this.downloadStatus = "OK";
          }
          else if (datos.Status == "OK" && datos.RowsBrou == 0 && datos.RowsPayouts == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }

        if (this.countryCode == 'CHL') {
          if (datos.Status && datos.Rows > 0) {
            this.downloadStatus = "OK";
            this.dataTxt = atob(datos.FileBase64);
            this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.txt');

          }
          else if (datos.Status == "OK" && datos.Rows == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }

        if (this.countryCode == 'ECU') {
          if (datos.Status && datos.Rows > 0) {
            this.downloadStatus = "OK";
            this.dataTxt = atob(datos.FileBase64);
            this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.txt');
          }
          else if (datos.Status == "OK" && datos.Rows == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }

        if (this.countryCode == 'PER') {
          if (datos.Status && datos.Rows > 0) {
            this.downloadStatus = "OK";
            this.dataTxt = atob(datos.FileBase64);
            this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.txt');
          }
          else if (datos.Status == "OK" && datos.Rows == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }

        if (this.countryCode == 'PRY') {
          if (datos.Status && datos.Rows > 0) {
            this.downloadStatus = "OK";
            this.dataTxt = atob(datos.FileBase64);
            this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.txt');
          }
          else if (datos.Status == "OK" && datos.Rows == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }

        if (this.countryCode == 'BOL') {
          if (datos.Status && datos.DownloadCount > 0) {
            var boliviaService = new BoliviaService();
            boliviaService.ProcessPayout(this.providerSelect, datos, idLotOut);
            this.downloadStatus = "OK";
          }
          else if (datos.Status == "OK" && datos.Rows == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }

        if (this.countryCode == 'PAN') {
          if (datos.Status && datos.Rows > 0) {
            this.downloadStatus = "OK";
            this.dataTxt = atob(datos.FileBase64);
            this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.txt');
          }
          else if (datos.Status == "OK" && datos.Rows == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }

        if (this.countryCode == 'CRI') {
          if (datos.Status && datos.Rows > 0) {
            this.downloadStatus = "OK";
            this.dataTxt = atob(datos.FileBase64);
            this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.txt');
          }
          else if (datos.Status == "OK" && datos.Rows == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }

        if (this.countryCode == 'SLV') {
          if (datos.Status && datos.Rows > 0) {
            this.downloadStatus = "OK";
            this.dataTxt = atob(datos.FileBase64);
            this.downloadFile(this.dataTxt, 'PAYOUT_' + this.countryCode + '_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + idLotOut + '.txt');
          }
          else if (datos.Status == "OK" && datos.Rows == 0) {
            this.downloadStatus = "NOTPROCESS";
          }
        }

        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      },
        error => {
          // console.log(error.message) // error path
          this.downloadStatus = "ERROR";
          setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

        });
  }

  private DowloadActionForScotiaBankMEX(datos: any, idLotOut: number) {
    if (datos.Status && datos.PayoutFiles.length > 0) {
      this.downloadStatus = "OK";

      let PayoutFilesCount = 1;
      datos.PayoutFiles.forEach(file => {
        this.dataTxt = atob(file.FileBase64_Payouts);
        let fileTotal: Number | null = (file.FileTotal == null) ? 1 : file.FileTotal;
        let fileRows = file.RowsPayouts;
        this.downloadFile(this.dataTxt, 'PO_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + PayoutFilesCount + '_' + fileRows + '_' + fileTotal + '_' + idLotOut + '.txt');
        PayoutFilesCount++;
      });

      if (datos.RowsPreRegister > 0) {
        this.dataTxtBenef = atob(datos.FileBase64_PreRegister);
        this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.RowsPreRegister + '_' + idLotOut + '.txt');
      }

      if (datos.RowsPreRegisterSameBank > 0) {
        this.dataTxtBenef = atob(datos.FileBase64_PreRegisterSameBank);
        this.downloadFile(this.dataTxtBenef, 'RE_' + this.providerSelect + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + '_' + datos.RowsPreRegisterSameBank + '_' + idLotOut + 'SAME_BANK' + '.txt');
      }
    }
  }


  filter(mifelInternal = false) {
    this.modalServiceLp.showSpinner();
    this.rejectAll = false;
    this.loadAllTransactions(false);
    this.filteredPayouts = [];
    let dateTo = new Date(this.downloadDateTo);
    var params = {
      'PaymentType': this.trSelect,
      'idMerchant': this.merchantSelect,
      'idSubMerchant': this.subMerchantSelect,
      'amount': this.amountLimit.trim().length > 0 ? this.formatNumber(this.amountLimit) : null,
      'dateTo': this.downloadDateTo ? dateTo : null,
      'txLimit': this.txLimit ? this.txLimit : null,
      'txMaxAmount': this.txMaxAmount ? this.txMaxAmount : null,
      'provider': this.providerSelect ? this.providerSelect : null, //TODO: pasar a méxico,
      'bankIncludes': this.bankIncludeSelect ? this.bankIncludeSelect : null,
      'bankExcludes': this.bankExcludeSelect ? this.bankExcludeSelect : null
    }

    if (this.countryCode == "MEX") {
      if (mifelInternal) {
        params["internalFiles"] = 1;
      }
      params["operationType"] = this.mexOperationType;
      params["includeDuplicateAmounts"] = (this.mexIncludeDupAmounts) ? 1 : 0;
    }

    this.LpServices.Payout.payoutsToDownload(params, this.countryCode, this.downloadHour).subscribe((data: any) => {
      if (data && data.length > 0) {
        this.downloadStatus = null
        this.filteredPayouts = data.sort((a, b) => new Date(a.TransactionDate).getTime() - new Date(b.TransactionDate).getTime())
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

  loadProviderFilter(code: any) {

    this.resetAmountLimitValidation();

    this.providerSelect = null
    this.bankIncludeSelect = new Array();
    this.bankExcludeSelect = new Array();

    this.currencySelect = this.ListCountries.filter(e => e.Code == code)[0].Currency;
    this.txLimit = null;
    this.hasLotAmountMaxLimit = false;
    this.ListProviderFilter = this.ListProviders.filter(e => e.countryCode == code);
    console.log("Mostrando list providers",this.ListProviders)
    if (this.ListProviderFilter.length == 1) {
      this.countryCode = code;
      this.providerSelect = this.ListProviderFilter[0].code;
      this.loadTxLimit();
    }
    this.merchantSelect = null
    this.ListMerchantFilter = this.ListMerchants.filter(e => e.CountryCode == code);
    this.ListBankFiltered = this.ListBank.filter(e => e.countryCode == code);
    if (this.ListBankFiltered.length > 0) {
        this.ListBankInclude = this.ListBankFiltered[0].bankFullNameCodes;
        this.ListBankExclude = this.ListBankFiltered[0].bankFullNameCodes; 
    }
  }


  loadSubmerchantFilter(idEntity: number) {
    this.subMerchantSelect = null;
    this.ListSubMerchantFilter = this.ListSubMerchants.filter(e => e.idEntityUser == idEntity)

  }

  formatNumber(numAmount: string): string {

    var newMonto = numAmount;

    if (numAmount.includes('.')) {

      var aux = newMonto.split('.');

      if (aux[1].length < 6) {
        var emptyNumbers = "";
        for (let x = 0; x < (6 - aux[1].length); x++) {
          emptyNumbers = "0" + emptyNumbers;
        }
        aux[1] = aux[1] + emptyNumbers;
      }
      newMonto = aux.join('');
    }
    else {
      if (newMonto.trim() != "") {
        newMonto = newMonto + "000000";
      }
    }


    return newMonto;
  }
  validateNumber(value: any) {
    if (value != "") {
      var regexNumber = /^\d*\.?\d*$/;
      return regexNumber.test(value);
    }
    else {
      return true;
    }
  }
  downloadFile(content, filename) {
    var a = document.createElement('a');
    var blob = new Blob([content], { 'type': 'text/plain' });
    a.href = window.URL.createObjectURL(blob);
    a.download = filename;
    a.click();
  }

  downloadExcel(content, filename) {
    var a = document.createElement('a');
    a.href = "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64," + content;
    a.download = filename;
    a.click();
  }

  clearFiles() {
    this.stateLoad = false;
    this.stateValidation = false;
    this.stateUpload = false;
    this.filesUpload = [];
    this.ErrorTrans = 0;
    this.OkTrans = 0;
    this.PendingTrans = 0;
    this.IgnoredTrans = 0
    this.listTransactionsUpload = [];
    // if (this.clearUploadView != null) { }
    if (this.inputElementFile != undefined) {
      this.inputElementFile.form.reset();


    }
  }
  clearUploadView() {
    this.countryCode = null
    this.dollarPrice = "";
    this.actionSelect = "";
    this.stateLoad = false;
    this.stateValidation = false;
    this.stateUpload = false;
    this.providerSelect = null
    this.currencySelect = ""
    this.filesUpload = [];
    this.ErrorTrans = 0;
    this.OkTrans = 0;
    this.PendingTrans = 0;
    this.IgnoredTrans = 0
    this.listTransactionsUpload = [];
    if (this.inputElementFile != undefined) {
      this.inputElementFile.form.reset();


    }

  }
  clearDownloadView() {

    this.countryCode = null
    this.trSelect = null;
    this.merchantSelect = null;
    this.subMerchantSelect = null;
    this.providerSelect = null
    this.currencySelect = ""
    this.amountLimit = ""
    this.downloadStatus = null
    this.downloadDateTo = "";
    this.downloadHour = "";
    this.filteredPayouts = [];
    this.bankIncludeSelect = new Array();
    this.bankExcludeSelect = new Array();
  }
  public get validationDownload(): Boolean {
    if (this.countryCode == 'MEX' && this.mexOperationType == 3) {
      return false
    }
    else {
      return this.checkedPayouts.length != 0 && (this.countryCode != null && this.providerSelect != null && this.trSelect != null) &&
        ((this.amountLimit.trim().length > 0 && this.validateNumber(this.amountLimit)) || (this.amountLimit.trim().length == 0))
    }
  }
  public get validationFilter(): Boolean {
    return (this.countryCode != null && this.providerSelect != null && this.trSelect != null) &&
      ((this.amountLimit.trim().length > 0 && !this.maxAmountExceeded && this.validateNumber(this.amountLimit)) || (this.amountLimit.trim().length == 0))
  }
  public get validateUpload(): Boolean {
    return this.countryCode != null && this.providerSelect != null && ((this.actionSelect != "" && this.actionSelect == "WITH_COT" && this.dollarPrice != "" && this.validateNumber(this.dollarPrice)) || (this.actionSelect != "" && this.actionSelect == "WITHOUT_COT"))
  }

  clearDateFilter(date: string) {
    this.downloadDateTo = "";
  }

  filterBankChange(value: any) {
    if (this.providerSelect === 'BCHILE816') {
      return;       
    }
    if (this.providerSelect === 'SANTAR') {
      return;       
    }
    if (value == 'Include') {
      this.bankExcludeSelect = null;
    }
    else {
      this.bankIncludeSelect = null;
    }
    
  }

  onRemoveInclude(event: any) {
    console.log(event, this.providerSelect);

    if (this.providerSelect) {
      if (this.providerSelect === 'BCHILE822' && event.value.bankCode == '012') {
      this.bankIncludeSelect.push(event.value.bankCode);
      this.bankIncludeSelect = [...this.bankIncludeSelect]; 
      }
      if (this.providerSelect === 'SANTARCVU' && event.value.bankCode == '00000') {
        this.bankIncludeSelect.push(event.value.bankCode);
        this.bankIncludeSelect = [...this.bankIncludeSelect]; 
      }
    }
  }

  onRemoveExclude(event: any) {
    console.log(event, this.providerSelect);

    if (this.providerSelect) {
      if (this.providerSelect === 'BCHILE816' && event.value.bankCode == '012') {
        this.bankExcludeSelect.push(event.value.bankCode);
        this.bankExcludeSelect = [...this.bankExcludeSelect]; 
        }
        if (this.providerSelect === 'SANTAR' && event.value.bankCode == '00000') {
          this.bankExcludeSelect.push(event.value.bankCode);
          this.bankExcludeSelect = [...this.bankExcludeSelect]; 
        }
    }
  }

  validateMaxAmount() {
    if (!this.hasLotAmountMaxLimit) {
      return;
    }
    this.maxAmountExceeded = this.checkedPayoutsTotal.NetAmount > this.maxAmountLimitProvider;
  }

  resetAmountLimitValidation() {
    this.hasLotAmountMaxLimit = false;
    this.maxAmountExceeded = false;
    this.minAmountRequired = false;   
  }
}