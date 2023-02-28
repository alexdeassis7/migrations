export class RetentionList {
    idTransaction: number; 
    TransactionDate: string; 
    ProcessedDate: string; 
    Ticket: string; 
    MerchantId: string; 
    FileName: string; 
    CertificateNumber: string; 
    Retention: string;   
    GrossAmount: number; 
    TaxWithholdings: number; 
    NetAmount: number; 
    RecipientCUIT: string; 
    Recipient: string; 
    CBU: string; 
    NroRegimen: string;
    Refund: string;
    IsRefunded: boolean;

    constructor(_listRetention: any) 
    {
        this.idTransaction = _listRetention.idTransaction
        this.TransactionDate = _listRetention.TransactionDate
        this.ProcessedDate = _listRetention.ProcessedDate
        this.Ticket = _listRetention.Ticket
        this.MerchantId = _listRetention.MerchantId
        this.FileName = _listRetention.FileName
        this.CertificateNumber = _listRetention.CertificateNumber
        this.Retention = _listRetention.Retention
        this.GrossAmount = _listRetention.GrossAmount
        this.TaxWithholdings = _listRetention.TaxWithholdings
        this.NetAmount = _listRetention.NetAmount
        this.RecipientCUIT = _listRetention.RecipientCUIT
        this.Recipient = _listRetention.Recipient
        this.CBU = _listRetention.CBU
        this.NroRegimen = _listRetention.NroRegimen
        this.Refund = _listRetention.Refund
        this.IsRefunded = _listRetention.Refund ? true : false
    }
}