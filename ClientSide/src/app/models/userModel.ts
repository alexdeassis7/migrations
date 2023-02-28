import { Country } from "./countryModel";

export class User {

    customer_id: string;
    Token: string;
    UserSiteIdentification: string;
    Permisos: string;
    Merchant: string;
    TypeUser: string;
    idEntityUser: number;
    idEntityAccount: number;
    Country: Country;

    constructor(_user: any) {
        this.customer_id = _user.customer_id || null;
        this.Token = _user.Token || null;
        this.UserSiteIdentification = _user.UserSiteIdentification || null;
        this.Permisos = _user.Permisos || null;
        this.Merchant = _user.Merchant || null;
        this.idEntityUser = _user.idEntityUser;
        this.idEntityAccount = _user.idEntityAccount;
        this.Country = _user.lCountry || null

    }

}
