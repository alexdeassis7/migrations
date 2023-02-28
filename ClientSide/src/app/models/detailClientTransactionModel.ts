export class DetailClientTransaction {
    Recipient: string;
    LotNumber: string
    Address: string;
    Birthdate: string;
    Country: string;
    City: string;
    Email: string;
    RecipientCUIT: string;
    CBU: string;
    TransactionDate: string;
    GrossValueClient: string;
    CurrencyType: string;
    CurrencyTypeUsd: string;
    GrossValueClientUsd: string;
    idTransaction: number;
    Ticket:string;
    InternalDescription:string;
    Merchant: string;
    SubMerchantIdentification: string;
    TransactionType: string;
    BankBranch: string;
    RecipientPhoneNumber:string;
    SenderEmail: string;
    SenderPhoneNumber: string;
    BankCode: string;
    Status: string;
    DetailStatus: string;
    ProcessedDate: string;
    // LocalTax: string;
    idLotOut: string;
    LotOutDate : string;
    AlternativeTicket: string;

    //Merchant
    Amount: string; 
    Payable: string;
    FxMerchant: string;
    Pending: string;
    Confirmed: string;
    LocalTax: string;
    Commission: string;



    constructor(_detailClientTr: DetailClientTransaction) {

        this.Recipient = _detailClientTr.Recipient || null
        this.LotNumber = _detailClientTr.LotNumber || null;
        this.Address = _detailClientTr.Address || null
        this.Birthdate = _detailClientTr.Birthdate || null
        this.Country = _detailClientTr.Country || null
        this.City = _detailClientTr.City || null
        this.Email = _detailClientTr.Email || null
        this.RecipientCUIT = _detailClientTr.RecipientCUIT || null
        this.CBU = _detailClientTr.CBU || null
        this.TransactionDate = _detailClientTr.TransactionDate || null
        this.GrossValueClient = _detailClientTr.GrossValueClient || null
        this.CurrencyType = _detailClientTr.CurrencyType || null
        this.CurrencyTypeUsd = _detailClientTr.CurrencyTypeUsd || null
        this.GrossValueClientUsd = _detailClientTr.GrossValueClientUsd || null        
        this.idTransaction = _detailClientTr.idTransaction || null
        this.Ticket =_detailClientTr.Ticket || null
        this.InternalDescription = _detailClientTr.InternalDescription || null
        this.Merchant = _detailClientTr.Merchant || null
        this.SubMerchantIdentification = _detailClientTr.SubMerchantIdentification || null;
        this.TransactionType = _detailClientTr.TransactionType || null
        this.BankBranch = _detailClientTr.BankBranch || null
        this.RecipientPhoneNumber = _detailClientTr.RecipientPhoneNumber || null
        this.SenderEmail = _detailClientTr.SenderEmail || null
        this.SenderPhoneNumber = _detailClientTr.SenderPhoneNumber || null
        this.BankCode = _detailClientTr.BankCode || null
        this.Status = _detailClientTr.Status || null
        this.DetailStatus = _detailClientTr.DetailStatus || null;
        this.ProcessedDate = _detailClientTr.ProcessedDate || null;
        // this.LocalTax = _detailClientTr.LocalTax || null;
        this.idLotOut = _detailClientTr.idLotOut || null;
        this.LotOutDate = _detailClientTr.LotOutDate || null;
        this.AlternativeTicket = _detailClientTr.AlternativeTicket || null;
        //Merchant
        this.Amount = _detailClientTr.Amount || null;
        this.Payable = _detailClientTr.Payable || null;
        this.FxMerchant = _detailClientTr.FxMerchant || null;
        this.Pending = _detailClientTr.Pending || null;
        this.Confirmed = _detailClientTr.Confirmed || null;
        this.LocalTax = _detailClientTr.LocalTax || null;
        this.Commission = _detailClientTr.Commission || null;
    }
}