export class HistoricalFx {
   
    Merchant:string;
    ProcessDate:string
    Buy:string;
    Base_Buy:string;
    Spot:string;
    Base_Sell: string;
    Sell :string;

    constructor(histFx: HistoricalFx) {
        this.Merchant = histFx.Merchant || null
        this.ProcessDate = histFx.ProcessDate || null;
        this.Buy = histFx.Buy || null;
        this.Base_Buy = histFx.Base_Buy || null;
        this.Spot = histFx.Spot || null;
        this.Base_Sell =  histFx.Base_Sell || null;
        this.Sell  = histFx.Sell || null;

    }
}