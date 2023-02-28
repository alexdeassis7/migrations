export interface Transaction {
    LotNumber: string;
    Ticket: string;
    TransactionDate: string;
    idEntityUser?: any;
    LastName: string;
    SubMerchantIdentification: string;
    GrossValueClient: string;
    TaxWithholdings: string;
    TaxWithholdingsARBA: string;
    LocalTax: string;
    NetAmount: string;
    Repeated: boolean;
    HistoricalyRepetead: boolean;
    InternalDescription: string;
    PreRegisterLot?: any;
    PreRegisterApproved: boolean;
    BeneficiaryName?: any;
    AccountNumber?: any;
    TicketAlternative?: any;
    LotOut?: any;
    Bank: string;
}