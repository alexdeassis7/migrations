export class CurrencyExchange {

    base_currency: string;
    quote_currency: string;
    quote: number;
    date: string;

    constructor(_currency: any) {

        this.base_currency = _currency.base_currency || null;
        this.quote_currency = _currency.quote_currency || null;
        this.quote = _currency.quote || null;
        this.date = _currency.date || null;

    }

}