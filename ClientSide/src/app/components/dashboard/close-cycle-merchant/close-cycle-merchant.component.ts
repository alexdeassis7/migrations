import { Component, OnInit } from '@angular/core';
// import { MerchantCycle } from 'src/app/models/merchantCycle';

@Component({
  selector: 'app-close-cycle-merchant',
  templateUrl: './close-cycle-merchant.component.html',
  styleUrls: ['./close-cycle-merchant.component.css']
})
export class CloseCycleMerchantComponent implements OnInit {

  // merchantCycle: MerchantCycle
  merchantCycle:any;
  isDollar: boolean = false;
  constructor() { }

  ngOnInit() {
 
  }

  public get usdCalculate() : string {
   let total = (parseFloat(this.merchantCycle.ars) / parseFloat(this.merchantCycle.exchange));
    return  isNaN(total) ? '' : total.toFixed(2).toString()
  }

  changeDollar(event:any){


  }

}
