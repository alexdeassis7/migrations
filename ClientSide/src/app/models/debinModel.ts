export class Debin{
    type:string;
    from:From;
    details:Detail;
    transaction_id:any[];
    status:string;
    status_description:string;
    start_date: string;
    end_date:string;
    charge:Charge;
}

export class From {
    bank_id:string;
    account_id:string;
}
export class Detail{
    preauthorized:boolean;
    seller_cuit:string;
    seller_alias:string;
    seller_CBU:string;
    buyer_cuit:string;
    buyer_alias:string;
    buyer_CBU:string;
}
export class Charge {
    summary:string;
    value:any;

}