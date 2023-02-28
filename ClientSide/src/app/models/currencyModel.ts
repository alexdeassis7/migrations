export class Currency {
    idCurrencyType:number
    Code: string;
    Name: string;
    NameCode:string;

    constructor(_currency: any) {
        this.Code = _currency.Code || null;
        this.Name = _currency.Name || null;
        this.NameCode= _currency.Name + ' (' + _currency.Code + ')' || null;
        this.idCurrencyType = _currency.idCurrencyType

    }

}
