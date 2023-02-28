import { Component, OnInit } from '@angular/core';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { BsModalService } from 'ngx-bootstrap/modal';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { AltaUserComponent } from 'src/app/components/management/user-manager/alta-user/alta-user.component';
import{ EnumViews} from 'src/app/components/services/enumViews'
import { CreateKeyComponent } from './create-key/create-key.component'

@Component({
  selector: 'app-create-signature-key',
  templateUrl: './create-signature-key.component.html',
  styleUrls: ['./create-signature-key.component.css']
})
export class CreateSignatureKeyComponent implements OnInit {

  constructor(private securityService: LpSecurityDataService, private clientData: ClientDataShared,private modalService: BsModalService) { }
  itemsBreadcrumb:any =  ['Home','Tools','Manage Keys'];
  ListUsers:any [] = [];
  ListKeyUsers: any [] = [];
  modalRef: BsModalRef;
  ngOnInit() {
    this.getListUsers();
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.TOOLS,'keymanager');
  }

  getListUsers() {
    this.securityService.getListKeyUsers().subscribe((users: any) => {
     this.ListUsers = users;
     this.ListKeyUsers = this.ListUsers.filter(x => x.Key != null)
    },
    error => {
    });
  }

  createKey() 
  {
    this.modalRef = this.modalService.show(CreateKeyComponent);
    this.modalRef.content.ListUser = this.ListUsers.filter(x => x.Key == null).map((x) => { x.Merchant = x.Admin + ' - ' + x.UserSiteIdentification; return x; });
    (<CreateKeyComponent>this.modalRef.content).onClose.subscribe(identification => {
      this.securityService.assingUserKey(identification).subscribe( response => {
        this.getListUsers();
      })
    })
  }

  resetKey(identification: string) 
  {
    this.securityService.assingUserKey(identification).subscribe( response => {
      this.getListUsers();
    })
  }

}
