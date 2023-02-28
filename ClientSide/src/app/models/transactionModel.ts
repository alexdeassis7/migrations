export class TransactionReport {
    //Datos
    TransactionDate:string//
    ProcessedDate: string
    CollectionDate: string//
    PaymentDate: string
    idTransaction: string
    Provider: string
    PayMethod:string
    TransactionOperation: string
    Mechanism: string
    LotNumber: string
    InternalClient_id: string
    Status: string
    DetailStatus: string
    Pay: string
    Cashed: string
    Merchant: string
    Identification: string;
    GrossValue: string
    SettlementNumber: string
    SettlementDate: string
    IdTransaction: string
    PDF: string
    Recipient: string
    RecipientCUIT: string
    SubMerchantAddress: string
    RecipientAccountNumber: string
    GrossAmount: string
    LotOutId: string
    LotOutDate: string

    //Merchant
    Amount: string
    Withholding: string
    WithholdingArba:string;
    Payable: string
    FxMerchant: string
    Pending: string
    ConfirmedUsd: string
    ConfirmedArs: string
    Confirmed:string
    Com: string
    NetCom: string
    TotCom: string
    TaxCountry: string
    AccountArs: string
    AccountUsd: string
    //Admin
    ProviderCost: string
    VatCostProv: string
    TotalCostProv: string
    PercIIBB: string
    PercVat: string
    PercProfit: string
    PercOthers: string
    Sircreb: string
    TaxDebit: string
    TaxCredit: string
    RdoOperative: string
    VatToPay: string
    FxLP: string
    RdoFx: string
    // Currency
    CurrencyCom: string
    CurrencyAmount:string
    CurrencyLocal:string
    CurrencyFxLP:string
    CurrencyPending:string
    CurrencyConfirmed: string
    CurrencyRdoFx:string
    CurrencyFxMER:string
    Ticket:string
    Cash_VAT_Prov: string
    Commission_Prov: string
    Commission_With_Cash_Prov: string
    Commission_With_VAT_Prov: string
    Commission_Merchant: string
    VAT_Merchant: string
    Commission_whit_vat_Merchant: string
    SubMerchantIdentification: string;
    GrossValueClient: string
    TaxWithholdings: string

    Commission_Vat_Prov: string
    Profit_Perception_prov: string
    Vat_Perception_prov: string
    Gross_Revenue_Perception_CABA_Prov: string
    Gross_Revenue_Perception_BSAS_Prov: string
    Gross_Revenue_Perception_OTHER_Prov: string

    NetPendingAmount_Prov: string
    NetInTermAmount_Prov: string
    NetPendingAmount_Merchant: string
    NetInTermAmount_Merchant: string
    NetPendingAmount_Merchant_USD: string
    NetInTermAmount_Merchant_USD: string
    RevenueOp: string
    RevenuePendingOp: string
    RevenueInTermOp: string
    FxRate: string
    ExRateAmountSale: string
    FxRevenue: string
    tax_debit: string;
    tax_credit: string;
    Bank_Cost: string
    Bank_Cost_VAT: string
    TotalCostRdo: string
    AccountWhitoutCommission:string
    PendingAtLPFx : string
    constructor(_payIn: any) {

        // Datos
        this.ProcessedDate = _payIn.ProcessedDate || null
        this.CollectionDate = _payIn.CollectionDate || null;
        this.TransactionDate = _payIn.TransactionDate || null
        this.PaymentDate = _payIn.PaymentDate || null
        this.idTransaction = _payIn.idTransaction || null;
        this.Provider = _payIn.Provider || null;
        this.PayMethod = _payIn.PayMethod || ""
        this.TransactionOperation = _payIn.TransactionOperation || null;
        this.Mechanism = _payIn.Mechanism || null;
        this.LotNumber = _payIn.LotNumber || null
        this.InternalClient_id = _payIn.InternalClient_id || null
        this.Status = _payIn.Status || null;
        this.DetailStatus = _payIn.DetailStatus || null;
        this.Pay = _payIn.Pay;
        this.Cashed = _payIn.Cashed;
        this.Merchant = _payIn.Merchant || null;
        this.Identification = _payIn.Identification || null;
        this.GrossValue = _payIn.GrossValue || null;
        this.Ticket = _payIn.Ticket || null;
        this.LotOutId = _payIn.LotOutId || null;
        this.LotOutDate = _payIn.LotOutDate || null;
        // Certificates
        this.SettlementNumber = _payIn.SettlementNumber || null;
        this.SettlementDate = _payIn.SettlementDate || null;
        this.IdTransaction = _payIn.IdTransaction || null;
        this.PDF = _payIn.PDF || null;
        this.Recipient = _payIn.Recipient || null;
        this.RecipientCUIT = _payIn.RecipientCUIT || null;
        this.SubMerchantAddress = _payIn.SubMerchantAddress || null;
        this.RecipientAccountNumber = _payIn.RecipientAccountNumber || null;
        this.GrossAmount = _payIn.GrossAmount || null;

        // Merchant
        this.Amount = _payIn.Amount || null;
        this.Withholding = _payIn.Withholding || null
        this.WithholdingArba = _payIn.WithholdingArba || null
        this.Payable = _payIn.Payable || null;
        this.FxMerchant = _payIn.FxMerchant || null;        
        this.Pending = _payIn.Pending || null;
        this.ConfirmedUsd = _payIn.ConfirmedUsd || null;
        this.ConfirmedArs = _payIn.ConfirmedArs || null;
        this.Confirmed = _payIn.Confirmed || null;
        this.Com = _payIn.Com || null
        this.NetCom = _payIn.NetCom || null;
        this.TotCom = _payIn.TotCom || null;
        this.TaxCountry = _payIn.TaxCountry || null;
        this.AccountArs = _payIn.AccountArs || null;
        this.AccountUsd = _payIn.AccountUsd || null;
        this.CurrencyCom = _payIn.CurrencyCom || null;
        this.SubMerchantIdentification = _payIn.SubMerchantIdentification || null;
        // Admin
        this.ProviderCost = _payIn.ProviderCost || null;
        this.VatCostProv = _payIn.VatCostProv || null;
        this.TotalCostProv = _payIn.TotalCostProv || null
        this.PercIIBB = _payIn.PercIIBB || null;
        this.PercVat = _payIn.PercVat || null;
        this.PercProfit = _payIn.PercProfit || null
        this.PercOthers = _payIn.PercOthers || null;
        this.Sircreb = _payIn.Sircreb || null;
        this.TaxDebit = _payIn.TaxDebit || null
        this.TaxCredit = _payIn.TaxCredit || null;
        this.RdoOperative = _payIn.RdoOperative || null;
        this.VatToPay = _payIn.VatToPay || null
        this.FxLP = _payIn.FxLP || null;
        this.RdoFx = _payIn.RdoFx || null
        //Currency
        this.CurrencyCom = _payIn.CurrencyCom || ''
        this.CurrencyAmount = _payIn.CurrencyAmount || ''
        this.CurrencyLocal =_payIn.CurrencyLocal || ''
        this.CurrencyFxLP = _payIn.CurrencyFxLP || ''
        this.CurrencyPending = _payIn.CurrencyPending || ''
        this.CurrencyConfirmed = _payIn.CurrencyConfirmed || ''
        this.CurrencyRdoFx    =    _payIn.CurrencyRdoFx || ''
        this.CurrencyFxMER      =   _payIn.CurrencyFxMER    || ''


        this.Commission_Prov = _payIn.Commission_Prov || null;
        this.Commission_With_Cash_Prov = _payIn.Commission_With_Cash_Prov || null;
        this.Commission_With_VAT_Prov = _payIn.Commission_With_VAT_Prov || null;
        this.Commission_whit_vat_Merchant = _payIn.Commission_whit_vat_Merchant || null;
        this.Commission_Merchant = _payIn.Commission_Merchant || null;
        this.VAT_Merchant = _payIn.VAT_Merchant || null;
        this.GrossValueClient = _payIn.GrossValueClient || null
        this.TaxWithholdings = _payIn.TaxWithholdings != null && isNaN(_payIn.TaxWithholdings) == false ? _payIn.TaxWithholdings : null

        this.Commission_Vat_Prov = _payIn.Commission_Vat_Prov || null
        this.Profit_Perception_prov = _payIn.Profit_Perception_prov || null
        this.Vat_Perception_prov = _payIn.Vat_Perception_prov || null
        this.Gross_Revenue_Perception_CABA_Prov = _payIn.Gross_Revenue_Perception_CABA_Prov || null
        this.Gross_Revenue_Perception_BSAS_Prov = _payIn.Gross_Revenue_Perception_BSAS_Prov || null
        this.Gross_Revenue_Perception_OTHER_Prov = _payIn.Gross_Revenue_Perception_OTHER_Prov || null
        this.Sircreb = _payIn.Sircreb || null
        this.NetPendingAmount_Prov = _payIn.NetPendingAmount_Prov || null
        this.NetInTermAmount_Prov = _payIn.NetInTermAmount_Prov || null
        this.NetPendingAmount_Merchant = _payIn.NetPendingAmount_Merchant || null
        this.NetInTermAmount_Merchant = _payIn.NetInTermAmount_Merchant || null

        this.NetPendingAmount_Merchant_USD = _payIn.NetPendingAmount_Merchant_USD || null;
        this.NetInTermAmount_Merchant_USD = _payIn.NetInTermAmount_Merchant_USD || null
        this.RevenueOp = _payIn.RevenueOp || null
        this.RevenuePendingOp = _payIn.RevenuePendingOp || null
        this.RevenueInTermOp = _payIn.RevenueInTermOp || null
        this.FxRate = _payIn.FxRate || null
        this.ExRateAmountSale = _payIn.ExRateAmountSale || null
        this.FxRevenue = _payIn.FxRevenue || null
        this.tax_debit = _payIn.tax_debit || null
        this.tax_credit = _payIn.tax_credit || null
        this.Bank_Cost = _payIn.Bank_Cost || null
        this.Bank_Cost_VAT = _payIn.Bank_Cost_VAT || null
        this.TotalCostRdo = _payIn.TotalCostRdo || null
        this.AccountWhitoutCommission = _payIn.AccountWhitoutCommission || null
        this.PendingAtLPFx = _payIn.PendingAtLPFx || null

    }
}




