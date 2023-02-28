import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ClientDataShared } from '../../services/lp-client-data.service';
import { ModalServiceLp } from '../../services/lp-modal.service';
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { LpReportService } from 'src/app/services/lp-report.service';
@Component({
  selector: 'app-client-data',
  templateUrl: './client-data.component.html',
  styleUrls: ['./client-data.component.css']
})
export class ClientDataComponent implements OnInit {
  toggleFitro: Boolean;
  myForm: FormGroup;
  locale = 'es';
  itemSelect = "UserApi";
  itemsBreadcrumb: any = ['Home', 'Tools', 'Client Data'];
  bsConfig: Partial<BsDatepickerConfig>;
   //Response Data
   responseData : any = null;
   UserApi : any = [];
   UsersWeb : any = [];
   AccountConfigList : any = [];
   //Selected Record 
   selectedRecord : any = null;
   //Copied state
   copied = false;
  constructor(
    public fb: FormBuilder,
    private clientData: ClientDataShared,
    private modalService : ModalServiceLp,
    private reportService : LpReportService,

  ) { 
    this.myForm = this.fb.group({
      clientName: ['', [Validators.required,Validators.minLength(4),Validators.maxLength(60)]],
    });
  }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
  }

  handleChangeSelectItem(item){
    this.itemSelect = item;
  }

  copyInputMessage(inputElement) {  
    navigator.clipboard.writeText(inputElement.value).then(() => {
        this.copied = true;
        setTimeout(() => { this.copied = false; },500)
    });
  } 

  search(){
    this.UserApi = [];
    this.UsersWeb = [];
    this.AccountConfigList = [];
    this.modalService.showSpinner();
    const params = {
        "clientName" : this.myForm.getRawValue().clientName,
    }
    this.reportService.getListClientsConfig(params).subscribe((response:any) => {
      setTimeout(()=>{this.modalService.hideSpinner();},400)
      this.UserApi = response.UserApi != '' ? JSON.stringify(response.UserApi,undefined, 4) : [];
      this.UsersWeb = response.UsersWeb.length > 0 ? JSON.stringify(response.UsersWeb,undefined, 4): [];
      this.AccountConfigList = response.UsersWeb.length > 0 ? JSON.stringify(response.AccountConfigList, undefined, 4) : [] ;
      }, error => {
      setTimeout(()=>{this.modalService.hideSpinner();},400)
      }), completed => {
      setTimeout(()=>{this.modalService.hideSpinner();},400)
    }
  }

  selectRecord(data:any){
    if(data && Object.keys(data).length > 0){
      this.selectedRecord = JSON.stringify(data);
    }else{
      this.selectedRecord = data;
    }
    
    }
}
