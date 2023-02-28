export class CardToken {
    token: string;
    payment_method_id: number;
    bin: string;
    last_four_digits: string;
    expiration_month: string;
    expiration_year: string;
    expired: boolean;

    constructor(_cardToken: any) {


        this.token = _cardToken.token || null;
        this.payment_method_id = _cardToken.payment_method_id || null;
        this.bin = _cardToken.bin || null;
        this.last_four_digits = _cardToken.last_four_digits || null;
        this.expiration_month = _cardToken.expiration_month || null;
        this.expiration_year = _cardToken.expiration_year || null;
        this.expired = _cardToken.expired || null;
    }




}