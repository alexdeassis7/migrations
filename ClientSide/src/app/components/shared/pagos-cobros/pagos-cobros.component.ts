import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-pagos-cobros',
  templateUrl: './pagos-cobros.component.html',
  styleUrls: ['./pagos-cobros.component.css']
})
export class PagosCobrosComponent implements OnInit {

  constructor() { }
  ListTransactions: any = [{ name: 'PayIn', val: '1' }, { name: 'PayOut', val: '2' }]
  listMonedas = [{ idMoneda: 'ARS', symbol: '$', name: 'Peso Argentino' }, { idMoneda: 11, symbol: 'U$S', name: 'Dolar Americano' }, { idMoneda: 12, symbol: '€', name: 'Euro' }]
  monedaSelect: any = this.listMonedas[0];
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
