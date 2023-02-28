
export class ListMain {

    Gross                   :number;
    GrossVariation          :number;
    Merchant                :string;
    Ranking                 :number;
    txsQuantity             :number;
    txsQuantityVariation    :number;


    constructor(_listMain: any) {
        this.Gross                     =    _listMain.Gross                           || null
        this.GrossVariation            =    _listMain.GrossVariation                  || null
        this.Merchant                  =    _listMain.Merchant                        || null
        this.Ranking                   =    _listMain.Ranking                         || null
        this.txsQuantity               =    _listMain.txsQuantity                     || null
        this.txsQuantityVariation      =    _listMain.txsQuantityVariation            || null

    }   
}