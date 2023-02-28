import { AfterViewInit, Component, OnInit } from '@angular/core';
import { ToastrService } from 'ngx-toastr';
import { BsModalRef, BsModalService } from 'ngx-bootstrap/modal';
import { AltaUserComponent } from '../../user-manager/alta-user/alta-user.component';
@Component({
  selector: 'app-edit-account',
  templateUrl: './edit-account.component.html',
  styleUrls: ['./edit-account.component.css']
})
export class EditAccountComponent implements OnInit, AfterViewInit {

    public accountData: any;
    itemSelect = "INFORMATION";
    
  constructor(
    public bsModalRef: BsModalRef,
    private _toast : ToastrService,
    private modalService: BsModalService
  ) {
    
    //console.log(this.bsModalRef.content);
  }

    ngOnInit() {
    //this.accountData = this.bsModalRef.content.user
  }

  ngAfterViewInit(): void {
    
    setTimeout(()=>{
      this.accountData = this.bsModalRef.content.user
    },500)
    //console.log(this.bsModalRef.content);
  }

  openModalAddUser(){
    this.bsModalRef = this.modalService.show(AltaUserComponent, {  class: 'modal-lg' });
    const payload = {
      idEntityAccount: this.accountData.idEntityAccount,
      idEntityUser: this.accountData.idEntityUser
    }
    this.bsModalRef.content.userData = payload;
  }

  closeModa(){
    //this.bsModalRef.hide();
    this.modalService.hide(1)
  }

}
