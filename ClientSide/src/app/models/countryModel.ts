import Utils from "../utils";


export class Country {
    idCountry: string    
    Code: string;
    Name: string;
    Currency:string
    NameCode: string;
    FlagIcon: string;
    Description: string
    idEntityUser: number
    idEntityAccount: number
    DescriptionUser: string
    Currencies: Array<any>


    constructor(_country: any) {
        this.idCountry = _country.idCountry || null
        this.Code = _country.Code || null;
        this.Currency = _country.Currency || null
        this.Name = _country.Name.toString().toUpperCase() || null;
        this.NameCode = _country.Name + ' (' + _country.Code + ')' || null;
        this.Description = _country.Description || null
        this.FlagIcon = null
        this.idEntityUser = _country.idEntityUser 
        this.idEntityAccount = _country.idEntityAccount 
        this.DescriptionUser = _country.DescriptionUser,
        this.Currencies = _country.Currencies || null;
    }

    addIcon() {

        this.FlagIcon = Utils.getFlagClass(this.Code)

    }

}
