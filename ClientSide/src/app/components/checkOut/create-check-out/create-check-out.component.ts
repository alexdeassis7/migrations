import { Component, OnInit } from '@angular/core';
import { BsDatepickerModule, BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { LpConsultDataService } from 'src/app/services/lp-consult-data.service';
import { ModalServiceLp } from '../../services/lp-modal.service';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { User } from 'src/app/models/userModel';
import { Country } from 'src/app/models/countryModel';
// import * as moment from 'moment'
// import moment from 'moment-timezone';
import * as moment from 'moment-timezone'
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'

// import { pdfkit } from 'pdfkit'
import * as pdfMake from 'pdfmake/build/pdfmake.js';
import * as pdfFonts from 'pdfmake/build/vfs_fonts.js';

pdfMake.vfs = pdfFonts.pdfMake.vfs;

@Component({
  selector: 'app-create-check-out',
  templateUrl: './create-check-out.component.html',
  styleUrls: ['./create-check-out.component.css']
})
export class CreateCheckOutComponent implements OnInit {

  fecha: Date = new Date(Date.now());
  minDate: Date = new Date(Date.now());
  birthdate?: Date =null;
  monto: string = "";
  titulo: string = "";
  check: string = "";
  methodSelect: string = "";
  cuitCuil: string;
  nombreApellido: string;
  email: string = "";
  firstName: string = ""
  lastName: string = ""
  countrySelect: string = ""
  city: string = ""
  address: string = ""
  // birthdate:string=""
  annotation: string = ""
  birtEnabled: boolean = true
  userPermission: string = this.securityService.userPermission;
  userMerchant: User = this.securityService.UserLogued;
  bsConfig: Partial<BsDatepickerConfig>;
  imageLogo: any;
  image: any;
  statusCheckout: boolean = false;
  dataBase64: string = "";
  itemsBreadcrumb: any = ['Home', 'Tools', 'CheckOut'];
  ListClients: any = [];
  listCountries: any = [];
  clientSelectCarga: any = null;
  regexCuit = /^(\\b(20|23|24|27|30|33|34)(\\D)?[0-9]{8}(\\D)?[0-9])$/
  regexEmail = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  validateEmail: boolean = false;
  test: any;
  constructor(private modalServiceLp: ModalServiceLp,  private clientData: ClientDataShared, private securityService: LpSecurityDataService,private LpServices: LpMasterDataService) { }

  ngOnInit() {

    this.bsConfig = {containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY', showWeekNumbers: false};
    this.fecha = new Date(Date.now());
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(4, 'checkOut');
    this.getListClients();
    this.getListCountries();
 

  }

  get valFormulario(): boolean {
    if ((this.monto.trim().length > 0 && this.validateNumber(this.monto)) && this.titulo.trim().length > 0 && this.methodSelect != "" && this.firstName.trim().length > 0 && this.lastName.trim().length > 0
      && this.cuitCuil.trim().length > 0 && this.validateEmail == false) {
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

  valEmail(mail: string) {
    if (mail != "") {

      return this.validateEmail = !this.regexEmail.test(mail);
    }
    else {
      return this.validateEmail = false;
    }
  }

  clearBirthDate(e) {
    if (e.target.checked == false) {

      this.birthdate = null;
      
    }

  }
  CreateCheckOut() {

    // moment.defaultFormat(this.fecha)
    let fecha = this.fecha.toISOString().replace(/-|T.*/g, '');
    let birth_date = this.birthdate != null ? this.birthdate.toISOString().replace(/-|T.*/g, '') : null
   
    var parametros = {
      invoice: "000000000009",
      payment_method: this.methodSelect, //this.check,
      additional_info: this.titulo,
      first_expiration_amount: this.formatNumber(this.monto),
      first_expirtation_date: fecha,
      currency: "ARS",
      surcharge: this.methodSelect == 'RAPA' || this.methodSelect == 'PAFA' || this.methodSelect == 'COEX' ? '000100' : '00000100',
      days_to_second_exp_date: 3,
      identification: this.cuitCuil,
      address: this.address == "" ? null : this.address,
      birth_date: birth_date,
      country: this.countrySelect == "" ? null : this.countrySelect,
      city: this.city == "" ? null : this.city,
      annotation: this.annotation == "" ? null : this.annotation,
      mail: this.email,
      name: this.firstName+ ' '+ this.lastName
    }

    // this.openModalSuc()
    let idCliente = this.userPermission == 'ADMIN' ? this.clientSelectCarga.Identification : this.userMerchant.customer_id;
    this.LpServices.Payin.postCheckOut(parametros, idCliente).subscribe((datos: any) => {
      var fechaPDF = + fecha[6] + fecha[7] + '/' + fecha[4] + fecha[5] + '/' + (fecha[0] + fecha[1] + fecha[2] + fecha[3])
      if (datos != null && datos.ErrorRow.HasError == false) {
        this.image = 'data:image/png;base64,' + datos.bar_code;

        //
        // var xhr = new XMLHttpRequest();
        // xhr.onload = () => {
        //   var reader = new FileReader();
        //   reader.onloadend = (e) => {
        //     this.imageLogo =    reader.result;



        //   }
        //   reader.readAsDataURL(xhr.response);
        // };
        // xhr.open('GET', 'LPlogo.png');
        // xhr.responseType = 'blob';
        // xhr.send();

        //
        let docDefinition = {

          content: [

            {
              columns: [
                {
                  // auto-sized columns have their widths based on their content
                  width: 'auto',
                  text: 'Descripcion:  ',
                  fontSize: 12,
                  bold: true,
                  margin: [15, 2]
                },
                {
                  // star-sized columns fill the remaining space
                  // if there's more than one star-column, available width is divided equally
                  width: 'auto',
                  text: this.titulo,
                  fontSize: 10,
                  margin: [2, 3]
                },
                {
                  // fixed width
                  width: 'auto',
                  text: 'Monto:  ',
                  fontSize: 12,
                  bold: true,
                  margin: [15, 2]
                },
                {
                  // % width
                  width: 'auto',
                  text: '$' + this.monto,
                  fontSize: 10,
                  margin: [2, 3]
                }
                ,
                {
                  // fixed width
                  width: 'auto',
                  text: 'Fecha:  ',
                  fontSize: 12,
                  bold: true,
                  margin: [15, 2]
                },
                {
                  // % width
                  width: 'auto',
                  text: fechaPDF,
                  fontSize: 10,
                  margin: [2, 3]
                }
              ],
              // optional space between columns
              columnGap: 10
            },
            {
              image: 'codeBar'
            }

          ],
          images: {

            codeBar: this.image
          },


        }
        this.generatePDF(docDefinition, datos.payment_method)


      }
      else {
        // this.modalRef.hide();
        var err = "";
        datos.ErrorRow.Errors.forEach(error => {
          err = err + error.Key + ' - ' + error.Messages + ' ** '

        });
        this.modalServiceLp.openModal('ERROR', 'Operacion erronea', err);
      }
    },
      error => {
        // this.modalRef.hide();
        this.modalServiceLp.openModal('ERROR', 'Operacion erronea', error.error.ExceptionType + ' - ' + error.error.ExceptionMessage);
      })

  }
  getListClients() {
    this.LpServices.Filters.getListClients().subscribe((data: any) => {
      if (data != null) {
        this.ListClients = data;
        // this.clientSelect = this.ListClients[0]
        this.clientSelectCarga = this.ListClients[0];


      }

    }, error => {

      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }

  getListCountries() {

    this.LpServices.Filters.getListCountries().subscribe((_listCountries: Country[]) => {

      let auxArray = [];
      _listCountries.forEach(country => {

        let _country = new Country(country);
        auxArray.push(_country);

      });

      this.listCountries = auxArray;
    },
      error => {

      })
  }
  formatNumber(numAmount: string): string {


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

  generatePDF(docDefinition, method) {
    pdfMake.createPdf(docDefinition).getDataUrl((pdf) => {

      var a = document.createElement('a');
      // var blob = new Blob([content], { 'type': 'application/pdf' });
      // open(pdf, 'newwin');
      a.href = pdf;
      a.download = 'barcode_' + method + '.pdf';
      a.click();
    }


    )

  }
  downloadFile(content, filename) {
    var a = document.createElement('a');
    var blob = new Blob([content], { 'type': 'application/pdf' });
    a.href = window.URL.createObjectURL(blob);
    a.download = filename;
    a.click();
  }

}
