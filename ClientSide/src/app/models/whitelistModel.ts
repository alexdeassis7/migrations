export class Whitelist {
    idWhitelist:number 
    idEntityIdentificationType:number
    Code: string;
    IdentificationNumber: string
    FirstName: string;
    LastName: string;
    Details: DetailWhitelist[]


    constructor(_whitelist: any) {
        this.idWhitelist = _whitelist.idWhitelist || null
        this.idEntityIdentificationType = _whitelist.idEntityIdentificationType || null
        this.Code = _whitelist.Code || null;
        this.IdentificationNumber = _whitelist.IdentificationNumber || null
        this.LastName = _whitelist.LastName || null
        this.FirstName = _whitelist.FirstName || null;
        this.Details = _whitelist.Details ? this.initDetails(_whitelist.Details) : []

    }

    initDetails(data:any){
        let list = []
        data.forEach(det => {
            list.push(new DetailWhitelist(det));
        });
        return list;
    }
}

export class DetailWhitelist {
    idWhiteListRetentionType:number
    idMerchant:number
    Merchant: string
    idEntitySubMerchant:string
    SubMerchant: string
    idRetentionType: number
    TypeRetention: string
    Country: string  
    Active:boolean
    ListSubmerchantFilter: any
    isRepeat:boolean = false

    
    constructor(_whitelist: any) {
        this.idWhiteListRetentionType = _whitelist.idWhiteListRetentionType || -1
        this.Merchant = _whitelist.Merchant || null;
        this.SubMerchant = _whitelist.SubMerchant || null
        this.TypeRetention = _whitelist.TypeRetention || null
        this.Country = _whitelist.Country || null;
        this.idMerchant = _whitelist.idMerchant || null;
        this.idEntitySubMerchant = _whitelist.idEntitySubMerchant ? _whitelist.idEntitySubMerchant.toString() : null;
        this.idRetentionType = _whitelist.idRetentionType || null;
        this.Active = _whitelist.Active || false
        this.ListSubmerchantFilter = _whitelist.ListSubmerchantFilter || [];
        this.isRepeat = _whitelist.isRepeat || false
    }

    
}

export class DetailWhitelistInsert {
    idMerchant:number
    idEntitySubMerchant:string   
    idRetentionType: number
    ListSubmerchantFilter: any


    constructor(_whitelist: any) {

        this.idMerchant = _whitelist.idMerchant || null;
        this.idEntitySubMerchant = _whitelist.idEntitySubMerchant || null;
        this.idRetentionType = _whitelist.idRetentionType || null;
        this.ListSubmerchantFilter = _whitelist.ListSubmerchantFilter || [];

    }
}