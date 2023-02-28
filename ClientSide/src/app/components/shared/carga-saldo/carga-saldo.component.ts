import { Component, OnInit } from '@angular/core';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { BsModalService } from 'ngx-bootstrap/modal';
import { LpConsultDataService } from 'src/app/services/lp-consult-data.service';
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'

@Component({
  selector: 'app-carga-saldo',
  templateUrl: './carga-saldo.component.html',
  styleUrls: ['./carga-saldo.component.css']
})
export class CargaSaldoComponent implements OnInit {


  ListTransactions: any = [{ name: 'PayIn', val: '1' }, { name: 'PayOut', val: '2' }]
  listMonedas = [{ idMoneda: 'ARS', symbol: '$', name: 'Peso Argentino' }, { idMoneda: 11, symbol: 'U$S', name: 'Dolar Americano' }, { idMoneda: 12, symbol: '€', name: 'Euro' }]
  ListClients: any[];
  bsConfig: Partial<BsDatepickerConfig>;
  //
  clientSelectCarga: any = null;
  monedaSelect: any = this.listMonedas[0];
  monto: string = "";
  accionSelect: any = this.ListTransactions[0].val;
  fecha: Date = new Date(Date.now());
  impuestoCredito: string = ""



  constructor(private servLP: LpConsultDataService, private modalServiceLp: ModalServiceLp, public modalRef: BsModalRef) { }

  ngOnInit() {
    //
    this.clientSelectCarga = this.ListClients[0];
    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY',showWeekNumbers: false })
  }

  guardarSaldo() {

    var parametros = {
      customer_id: this.clientSelectCarga.idEntityUser,
      transaction_type: this.accionSelect,
      amount: this.formatNumber(this.monto),
      currency: this.monedaSelect.idMoneda,
      payout_date: this.fecha,
      credit_tax: this.formatNumber(this.impuestoCredito)
    }
    // this.openModalSuc()
    this.servLP.postSaldo(parametros).subscribe((datos: any) => {

      if (datos != null && datos.ErrorRow.HasError == false) {


        // if (datos.status == 'FINA') {
          this.modalRef.hide();
          this.modalServiceLp.openModal('SUCCESS', 'Exito', 'La carga se realizo correctamente.');

        // }

        // this.getListPayout();

      }
      else {
        this.modalRef.hide();
        this.modalServiceLp.openModal('ERROR', 'Operacion erronea', datos.ErrorRow.errors.key.messages)
      }
    },
      error => {
        this.modalRef.hide();
        this.modalServiceLp.openModal('ERROR', 'Operacion erronea', error.error.ExceptionType + ' - ' + error.error.ExceptionMessage)
      })
  }

  formatNumber(numAmount:string):string { 

    
    var newMonto = numAmount;
    if (numAmount.includes(',')) {

      var aux = newMonto.split(',');
      newMonto = aux.join('');
    }
    if (numAmount.includes('.')) {

      var aux = newMonto.split('.');
      newMonto = aux.join('');
    }

    if (!numAmount.includes('.') && !numAmount.includes(',')) {

      newMonto = newMonto + '00';
    }
    if (newMonto.length < 8) {
      var emptyNumbers = "";
      for (let x = 0; x < (8 - newMonto.length); x++) {

        emptyNumbers = "0" + emptyNumbers;

      }
      newMonto = emptyNumbers + newMonto;
    }

    return newMonto;
  }

  get valFormulario(): boolean {
    if (this.monto.trim().length > 0 && this.validateNumber(this.monto) && this.monedaSelect != null 
    && this.accionSelect != null && this.impuestoCredito.trim().length > 0 && this.validateNumber(this.impuestoCredito)) {

      return true;
    }
    else {
      return false;
    }
  }
  validateNumber(value: any) {
    if (value != "") {
      var regexNumber = /^\d*\.?\d*$/;
      return regexNumber.test(value);
    }
    else {
      return true;
    }
  }
}
