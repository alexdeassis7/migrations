export class Payout{
    token_id:string;
    beneficiary_cuit:string;
    beneficiary_name:string;
    bank_account_type:string;
    bank_cbu:string;
    amount:number;
    beneficiary_softd:string;
    site_transaction_id:string;
    concept_code:number;
    currency:string;
    payment_type:string;
    payout_date:string;
    //
    accreditation_date:string;
    balance:string;
    customer_name:string;
    gross_amount:string;
    net_amount:string;
    payout_id:string;
    transaction_type:string;
    transaction_list: any;    

    constructor(_payout:any){
        
        this.token_id = _payout.token_id || null;
        this.beneficiary_cuit =_payout.beneficiary_cuit || "";
        this.beneficiary_name= _payout.beneficiary_name || "";
        this.bank_account_type= _payout.bank_account_type || "";
        this.bank_cbu = _payout.bank_cbu || "";
        this.amount=_payout.amount || null;
        this.beneficiary_softd=_payout.beneficiary_softd || null;
        this.site_transaction_id=_payout.site_transaction_id || null;
        this.concept_code=_payout.concept_code || null;
        this.currency = _payout.currency || null;
        this.payment_type = _payout.payment_type || null;
        this.payout_date = _payout.payout_date || null;
        //
        this.accreditation_date = _payout.accreditation_date || null
        this.balance = _payout.balance || ""
        this.customer_name = _payout.customer_name || "";
        this.gross_amount = _payout.gross_amount || null;
        this.net_amount = _payout.net_amount || null
        this.payout_id = _payout.payout_id || null;
        this.transaction_type = _payout.transaction_type || null;
        this.transaction_list = _payout.transaction_list || [];
    }
}

