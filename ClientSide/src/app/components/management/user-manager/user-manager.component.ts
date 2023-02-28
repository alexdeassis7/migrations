import { Component, OnInit } from '@angular/core';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { BsModalService } from 'ngx-bootstrap/modal';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { AltaUserComponent } from 'src/app/components/management/user-manager/alta-user/alta-user.component';
import{ EnumViews} from 'src/app/components/services/enumViews'
@Component({
  selector: 'app-user-manager',
  templateUrl: './user-manager.component.html',
  styleUrls: ['./user-manager.component.css']
})
export class UserManagerComponent implements OnInit {
ListUsers:any [] = [];
itemsBreadcrumb:any =  ['Home','Tools','Manage Users'];
modalRef?: BsModalRef;

constructor(private securityService: LpSecurityDataService, private clientData: ClientDataShared,private modalService: BsModalService) { }

  ngOnInit() {
    this.getListUsers();
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.TOOLS,'userManager');
  }


  getListUsers() {

    this.securityService.getListUsers().subscribe((users: any) => {
     
     this.ListUsers = users;

    },

      error => {


      });

  }

  openModalAddUser(){

    this.modalRef = this.modalService.show(AltaUserComponent, {  class: 'widthModalTr' });


  }
}
