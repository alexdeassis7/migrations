import { Component, OnInit } from '@angular/core';
import { BsModalRef } from 'ngx-bootstrap/modal';
@Component({
  selector: 'app-whitelist-detail',
  templateUrl: './whitelist-detail.component.html',
  styleUrls: ['./whitelist-detail.component.css']
})
export class WhitelistDetailComponent implements OnInit {
  ListDetailRetention:any[] = [];
  IdentificationNumber : string
  nameComplete: string 

  constructor( public bsModalRef: BsModalRef) { }

  ngOnInit() {
  }

  closeDetail(){

    this.bsModalRef.hide();
  }


}
