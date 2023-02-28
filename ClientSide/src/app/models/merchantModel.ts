export class Merchant {

    CountryCode: string
    CurrencyClient: number
    FirstName: string
    Identification: string
    UserSiteIdentification:string
    idEntityUser: number


    constructor(_merchant: any) {

        this.CountryCode         = _merchant.CountryCode        
        this.CurrencyClient = _merchant.CurrencyClient
        this.FirstName = _merchant.FirstName
        this.Identification = _merchant.Identification
        this.UserSiteIdentification = _merchant.UserSiteIdentification
        this.idEntityUser = _merchant.idEntityUser

    }


}