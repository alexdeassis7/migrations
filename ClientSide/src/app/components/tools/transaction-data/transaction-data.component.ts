import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators} from '@angular/forms';
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { LpTransactionService } from 'src/app/services/lp-transaction.service';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'
@Component({
  selector: 'app-transaction-data',
  templateUrl: './transaction-data.component.html',
  styleUrls: ['./transaction-data.component.css']
})
export class TransactionDataComponent implements OnInit {

  myForm: FormGroup;
  locale = 'es';

  itemsBreadcrumb: any = ['Home', 'Tools', 'TransactionData'];

  bsConfig: Partial<BsDatepickerConfig>;
  actualDate: Date = new Date();
  defaultDate: Date = new Date();
  //Filtros
  //dateFrom: Date = new Date(new Date().setDate(this.defaultDate.getDate() - 1)); 
  //dateTo: Date = new Date();

  minDate = new Date(new Date().setDate(this.defaultDate.getDate() - 30));
  maxDate = new Date(new Date().setDate(this.defaultDate.getDate()));

  minDate2 = new Date(new Date().setDate(new Date().getDate()));
  maxDate2 = new Date(new Date().setDate(this.defaultDate.getDate() + 1 ));
  quantity: Number = 10;
  dataToSearch: String = "4366183229946873";
  ListMerchants: any = ['Payoneer Internal', 'Payoneer withdrawals'];
  merchantId: string = null;
//Regex Patterns
  quantityPattern = "^(10|11|12|13|14|15|16|17|18|19|20){1}$";

  //Response Data
  responseData : any = [];
  //Selected Data
  selectedAuditLog : any = null;
  offset: number = 0;
  pageSize: number = 15;
  positionTop: string = "translateY(0px)"
  paramsFilter: any = {};
  positionBottom: string = ""
  toggleFitro: boolean = true;
  constructor
  (
    public fb: FormBuilder,
    private clientData: ClientDataShared,
    private transactionService: LpTransactionService,
    private modalService : ModalServiceLp
  ) 
  {

    this.myForm = this.fb.group({
      dateFrom: [new Date(new Date().setDate(this.defaultDate.getDate() - 1)), [Validators.required]],
      dateTo: [new Date(), [Validators.required]],
      quantity: [10, [Validators.required,Validators.pattern(this.quantityPattern)]],
      dataToSearch: ['', [Validators.required,Validators.minLength(3),Validators.maxLength(100)]],
    });
  }

  ngOnInit() {
    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY' ,showWeekNumbers: false});
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
  }


  search(){
    this.selectAuditLog(null);
    this.modalService.showSpinner();
    const params = 
      {
        "dateFrom" : new Date(this.myForm.getRawValue().dateFrom).getFullYear()+'-'+(new Date(this.myForm.getRawValue().dateFrom).getMonth()+1)+'-'+new Date(this.myForm.getRawValue().dateFrom).getDate()+" 00:00:00",
        "dateTo" : new Date(this.myForm.getRawValue().dateTo).getFullYear()+'-'+(new Date(this.myForm.getRawValue().dateTo).getMonth()+1)+'-'+new Date(this.myForm.getRawValue().dateTo).getDate()+" 23:59:59",
        "quantity" : this.myForm.getRawValue().quantity,
        "dataToSearch" : this.myForm.getRawValue().dataToSearch
        
    }
    this.transactionService.getAuditLogs(params).subscribe(response => {
      setTimeout(()=>{this.modalService.hideSpinner();},400)
      
      this.responseData = response;
      console.log(response)
    }, error => {
      setTimeout(()=>{this.modalService.hideSpinner();},400)
      console.log("error", error)
    }), completed => {
      console.log("completed", completed)
      setTimeout(()=>{this.modalService.hideSpinner();},400)
    }

  }

  selectAuditLog(data:any){
  this.selectedAuditLog = data;
  }

}