
import { Component, OnInit, Input, EventEmitter, Output, ChangeDetectorRef } from '@angular/core';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
import { BsDatepickerConfig } from 'ngx-bootstrap/datepicker';
import { TransactionReport } from 'src/app/models/transactionModel';
import { EnumViews } from '../../services/enumViews';
import { saveAs } from 'file-saver'
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from 'src/app/components/services/lp-modal.service'

@Component({
  selector: 'app-certificates',
  templateUrl: './certificates.component.html',
  styleUrls: ['./certificates.component.css']
})
export class CertificatesComponent implements OnInit {

  @Output() backToDashboard = new EventEmitter();

  locale = 'es';

  itemsBreadcrumb: any = ['Home', 'Tools', 'Certificates'];

  ListTransactionsToDownload: any[] = [];
  ListPayOuts: any[] = [];
  modalRef: BsModalRef;
  bsConfig: Partial<BsDatepickerConfig>;
  listColumns: string[] = [];
  userPermission: string = this.securityService.userPermission;

  //Filtros
  dateFrom: Date = new Date(Date.now());
  dateTo: Date = new Date(Date.now());
  merchantSelect: any = null;
  ListMerchants: any = ['Payoneer Internal', 'Payoneer withdrawals'];
  merchantId: string = null;

  //filtros modal carga
  clientSelectCarga: any = null;

  offset: number = 0;
  pageSize: number = 15;
  positionTop: string = "translateY(0px)"
  paramsFilter: any = {};
  positionBottom: string = ""
  toggleFitro: boolean = true;

  constructor(private clientData: ClientDataShared, private securityService: LpSecurityDataService, private LpServices: LpMasterDataService, private modalServiceLp: ModalServiceLp) { }

  ngOnInit() {
    this.clientData.refreshItemsBreadCrumb(this.itemsBreadcrumb);
    this.clientData.setCurrentView(EnumViews.TOOLS, 'Certificates');

    this.paramsFilter = { "idEntityAccount": null, "cycle": null, "id_status": null, "idTransactioOper": null, "pageSize": this.pageSize, "offset": this.offset }
    
    this.bsConfig = Object.assign({}, { containerClass: 'theme-default', dateInputFormat: 'DD/MM/YYYY' ,showWeekNumbers: false});

    this.listColumns = ['Number', 'Date', 'Name', 'Document Number', 'Address', 'Account Number', 'Amount'];
  }

  filterReport() {
    var myDiv = document.getElementById('divContainerTable');
    if(myDiv != null){ myDiv.scrollTop = 0;  }
    
    this.modalServiceLp.showSpinner();
    this.offset = 0;

    var paramsArr = [{Key: "merchantId", Val: this.merchantSelect},{Key: "dateFrom", Val: this.dateFrom },{Key: "dateTo", Val: this.dateTo }];

    this.getListReport();

  }

  onScrollReport() {
   
    this.getListReport(true);
  }

  downloadZip(){
    this.LpServices.Retentions.downloadCertificates(this.ListTransactionsToDownload).subscribe((data: any) =>{
      var b64Data = data.file_bytes_compressed;
      var contentType = "application/octet-stream";
      var sliceSize = 512;
      var byteCharacters = atob(b64Data);
      var byteArrays = [];
      for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        var slice = byteCharacters.slice(offset, offset + sliceSize);
        var byteNumbers = new Array(slice.length);
        for (var i = 0; i < slice.length; i++) {
          byteNumbers[i] = slice.charCodeAt(i);
        }
        var byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
      }
      var blob = new Blob(byteArrays, { type: contentType });
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      saveAs(blob, data.file_name_zip);
    },
    error => {
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      console.log(error.error.Status + ' - ' + error.error.StatusMessage)
    });
  }
  
  getListReport(autoScroll: boolean = false) {
    this.modalServiceLp.showSpinner();

    this.paramsFilter = {
      "dateFrom": this.dateFrom.toISOString().replace(/-|T.*/g, ''),
      "dateTo": this.dateTo.toISOString().replace(/-|T.*/g, ''),
      "merchantId": this.merchantSelect
    }

    this.LpServices.Filters.getListSettlement(this.paramsFilter).subscribe((data: any) => {
      if (autoScroll == false) {

        this.ListPayOuts = [];
        this.ListTransactionsToDownload = [];
      }
      if (data != null) {
        data.forEach(_pay => {
          var payout = new TransactionReport(_pay);
          var date = new Date(payout.SettlementDate);
          payout.SettlementDate = ("0" + date.getDate()).slice(-2) +'/' + ("0" + (date.getMonth() + 1)).slice(-2)+ '/' + date.getFullYear() + ' ' + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
          this.ListPayOuts.push(payout)
        });

        this.ListPayOuts.forEach((item) => {
          this.ListTransactionsToDownload.push(item.IdTransaction);
        });
      
        this.paramsFilter.offset = this.paramsFilter.offset + this.pageSize;

      }

      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
    }, error => {

      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)

    })
  }
  backDashboard() {

    this.backToDashboard.emit();

  }
}
