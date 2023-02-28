import { Component, OnInit } from '@angular/core';
import { BsModalService } from 'ngx-bootstrap/modal';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { ClientDataShared } from '../../services/lp-client-data.service';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { AddAccountComponent } from './add-account/add-account.component';
import { EditAccountComponent } from './edit-account/edit-account.component';


@Component({
  selector: 'app-list-account',
  templateUrl: './list-account.component.html',
  styleUrls: ['./list-account.component.css']
})
export class ListAccountComponent implements OnInit {

  ListAccounts:any [] = [];
  itemsBreadcrumb:any =  ['Home','Tools','Manage Users'];
  modalRef?: BsModalRef;

  constructor(
    private securityService: LpSecurityDataService,
    private clientData: ClientDataShared,
    private modalService: BsModalService
    ){
      
    }

  ngOnInit() {
    this.getListAccounts();
  }

  getListAccounts() {
    this.securityService.getListAccounts().subscribe((response: any) => {
     this.ListAccounts = response;
     console.log("mostrando respose", response);
    },
    error => {
      console.log(error);
      });

  }

  openModalAddAccount(){
    this.modalRef = this.modalService.show(AddAccountComponent, {  class: 'w-80' });
  }

  openModalEditAccount(account){
    this.modalRef = this.modalService.show(EditAccountComponent, {  class: 'modal-lg' });
    this.modalRef.content.user = account;
  }

}
