import { Component, OnInit } from '@angular/core';
import {  BsModalRef } from 'ngx-bootstrap/modal';
@Component({
  selector: 'app-modal-uploaded',
  templateUrl: './modal-uploaded.component.html',
  styleUrls: ['./modal-uploaded.component.css']
})
export class ModalUploadedComponent implements OnInit {

  title:string;
  message:string;
  constructor(public bsModalRef: BsModalRef) { }

  ngOnInit() {
  }

}
