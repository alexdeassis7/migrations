export class Payout_Up_Resp {
    AcreditationDate            : string;
    BankAccountType             : string;
    Amount                      : number;
    ConceptCode                 : string;
    Currency                    : string;
    Description                 : string;
    EntityIdentificationType    : string;
    InternalDescription         : string;
    InternalStatus              : string;
    InternalStatusDescription   : string;
    LotCode                     : string;
    LotNumber                   : number;
    Recipient                   : string;
    RecipientAccountNumber      : string;
    RecipientCBU                : string;
    RecipientCUIT               : string;
    Ticket                      : string;
    TransactionDate             : string;

    constructor(_Payout_Up_Resp: Payout_Up_Resp) {
        this.AcreditationDate           =   _Payout_Up_Resp.AcreditationDate            || null
        this.Amount                     =   _Payout_Up_Resp.Amount                      || null   
        this.BankAccountType            =   _Payout_Up_Resp.BankAccountType             || null   
        this.ConceptCode                =   _Payout_Up_Resp.ConceptCode                 || null
        this.Currency                   =   _Payout_Up_Resp.Currency                    || null
        this.Description                =   _Payout_Up_Resp.Description                 || null
        this.EntityIdentificationType   =   _Payout_Up_Resp.EntityIdentificationType    || null
        this.InternalDescription        =   _Payout_Up_Resp.InternalDescription         || null
        this.InternalStatus             =   _Payout_Up_Resp.InternalStatus              || null
        this.InternalStatusDescription  =   _Payout_Up_Resp.InternalStatusDescription   || null
        this.LotCode                    =   _Payout_Up_Resp.LotCode                     || null
        this.LotNumber                  =   _Payout_Up_Resp.LotNumber                   || null
        this.Recipient                  =   _Payout_Up_Resp.Recipient                   || null
        this.RecipientAccountNumber     =   _Payout_Up_Resp.RecipientAccountNumber      || null
        this.RecipientCBU               =   _Payout_Up_Resp.RecipientCBU                || null
        this.RecipientCUIT              =   _Payout_Up_Resp.RecipientCUIT               || null
        this.Ticket                     =   _Payout_Up_Resp.Ticket                      || null
        this.TransactionDate            =   _Payout_Up_Resp.TransactionDate             || null
    }   
}