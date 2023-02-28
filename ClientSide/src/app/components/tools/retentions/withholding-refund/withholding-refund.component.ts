import { Component, OnInit } from '@angular/core';
import { LpMasterDataService } from 'src/app/services/lp-master-data.service'
import { ModalServiceLp } from '../../../services/lp-modal.service';
import { RetentionList } from '../../../../models/retentionListModel';

@Component({
  selector: 'withholding-refund',
  templateUrl: './withholding-refund.component.html',
  styleUrls: ['./withholding-refund.component.css']
})
export class WithholdingRefundComponent implements OnInit {

  listMerchants: any = [];
  merchantSelect: any = null;
  ticketNumber: any = null;
  ListOperationRetention: RetentionList[] = [];
  ListColumns: any = ['ID TX','Transaction Date','ProcessedDate',   'Ticket', 'Merchant ID', 'FileName', 'Certificate Number','Retention Type', 'Gross Amount','WithHoldings', 'NetAmount',
   'CUIT', 'Name','CBU','Regime Number', 'Refund'];
  positionTop: string = "translateY(0px)"
  positionBottom: string = "";
  pageSize: number = 100;
  offSet: number = 0;

  constructor(private LpServices: LpMasterDataService, private modalServiceLp: ModalServiceLp) { }

  ngOnInit() {
    this.getListClients();
  }

  getListClients() {
    this.LpServices.Filters.getListClients().subscribe((data: any) => {
      if (data != null) {
        this.listMerchants = data;
      }
    }, error => {

      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    })
  }

  filter(){
    this.modalServiceLp.showSpinner();
    this.ListOperationRetention = [];
    this.offSet = 0;
    this.getRetentions();
  }

  refund(){
    this.modalServiceLp.showSpinner();
    let idList = this.ListOperationRetention.filter(x => !x.Refund && x.IsRefunded == true).map(transaction => transaction.idTransaction).toString();
    let body = {
      "transactionIds" : idList
    }
    this.LpServices.Retentions.refundTransactions(body).subscribe((data: any) =>{
      this.filter()
      this.modalServiceLp.openModal('SUCCESS', 'Exito', 'La operación se ha ejecutado correctamente.')
    },
    error => {
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    });
  }

  refundableTransactions() {
    if (this.ListOperationRetention.length > 0) {
      let idList = this.ListOperationRetention.filter(x => !x.Refund && x.IsRefunded == true).map(transaction => transaction.idTransaction);
      let availableRefunds = idList.length > 0 ? false : true;

      return availableRefunds;
    }
    else {
      return true;
    }
  }

  scrollFixedHead($event: Event) {
    let divTabla: HTMLDivElement = <HTMLDivElement>$event.srcElement
    let scrollOffset = divTabla.scrollTop;
    let tabla: HTMLTableElement = <HTMLTableElement>divTabla.children[0]

    let offsetBottom = (tabla.offsetHeight - divTabla.offsetHeight + 15) * -1 + scrollOffset
    this.positionBottom = "translateY(" + offsetBottom + "px)"
    this.positionTop = "translateY(" + scrollOffset + "px)"
  }

  onScrollReport() {
    this.getRetentions();
  }

  getRetentions() {
    let body = {
      "idEntityAccount": this.merchantSelect ? this.merchantSelect.idEntityUser : null ,
      "ticket": this.ticketNumber,
      "offset": this.offSet,
      "pagesize": this.pageSize
    };
    this.LpServices.Retentions.getListRetention(body).subscribe((data: any) => {
      if (data != null) {
        data.forEach(element => {
          this.ListOperationRetention.push(new RetentionList(element))
        });
        this.offSet = this.offSet + this.pageSize;
        setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      }
    }, error => {
      setTimeout(() => { this.modalServiceLp.hideSpinner() }, 400)
      console.log(error.error.ExceptionMessage + ' - ' + error.error.ExceptionType);
    });
  }

  isRefundAvailable(retention: RetentionList) {
      let disable = retention.Refund ? true : false;
      return disable
  }
}
