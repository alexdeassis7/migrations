import { Component, OnInit } from '@angular/core';
import {  BsModalRef } from 'ngx-bootstrap/modal';
import { Subject } from 'rxjs';
@Component({
  selector: 'app-modal-confirm',
  templateUrl: './modal-confirm.component.html',
  styleUrls: ['./modal-confirm.component.css']
})
export class ModalConfirmComponent implements OnInit {

  title:string;
  message:string;
  public confirmAction: Subject<boolean>;

  constructor(public bsModalRef: BsModalRef ) { 

    this.confirmAction = new Subject();

   }

  ngOnInit() {
  }
  confirm(){
    this.confirmAction.next(true);
    this.bsModalRef.hide()
  }
  cancel(){

    this.confirmAction.next(false);
    this.bsModalRef.hide()
  }
}
