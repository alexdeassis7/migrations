export class TransactionType {
    TG_Code: string
    TG_Country: string
    TG_Desc: string
    TG_Name: string
    TO_Code: string
    TO_Country: string
    TO_Desc: string
    TO_Name: string
    TT_Code: string
    TT_Country: string
    TT_Desc: string
    TT_Name: string
    idTransactionGroup: string
    idTransactionOperation: string
    idTransactionType: string

    constructor(_method: any) {

        this.TG_Code = _method.TG_Code
        this.TG_Country = _method.TG_Country
        this.TG_Desc = _method.TG_Desc
        this.TG_Name = _method.TG_Name
        this.TO_Code = _method.TO_Code
        this.TO_Country = _method.TO_Country
        this.TO_Desc = _method.TO_Desc
        this.TO_Name = _method.TO_Name
        this.TT_Code = _method.TT_Code
        this.TT_Country = _method.TT_Country
        this.TT_Desc = _method.TT_Desc
        this.TT_Name = _method.TT_Name
        this.idTransactionGroup = _method.idTransactionGroup
        this.idTransactionOperation = _method.idTransactionOperation
        this.idTransactionType = _method.idTransactionType


    }

}