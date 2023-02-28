import { Component, OnInit } from '@angular/core';
import {  BsModalRef } from 'ngx-bootstrap/modal';

@Component({
  selector: 'app-edit-values',
  templateUrl: './edit-values.component.html',
  styleUrls: ['./edit-values.component.css']
})
export class EditValuesComponent implements OnInit {

  constructor(public modalRef:BsModalRef) { }
  ListTransactions: any = [{ name: 'PayIn', val: '1' }, { name: 'PayOut', val: '2' }]
  ListMeses: any[] = [{ name: 'ENERO', val: '1' }, { name: 'FEBRERO', val: '2' }, { name: 'MARZO', val: '3' }, { name: 'ABRIL', val: '4' }, { name: 'MAYO', val: '5' },
  { name: 'JUNIO', val: '6' }, { name: 'JULIO', val: '7' }, { name: 'AGOSTO', val: '8' }, { name: 'SEPTIEMBRE', val: '9' }, { name: 'OCTUBRE', val: '10' },
  { name: 'NOVIEMBRE', val: '11' }, { name: 'DICIEMBRE', val: '12' }]
  ListSemanas:any[] = [{ name: 'Semana 1', val: '1' }, { name: 'Semana 2', val: '2' }, { name: 'Semana 3', val: '3' }, { name: 'Semana 4', val: '4' }]
  transactionSelect:string;
  byRangeLot:boolean = false;
  byRangeTr:boolean = false;
  ngOnInit() {
  }

}
