import { __core_private_testing_placeholder__ } from '@angular/core/testing';

export class OperationRetention {

    idTransaction: string
    TransactionDate: string
    ProcessedDate: string
    Ticket: string
    MerchantId: string
    FileName: string
    CertificateNumber: string
    GrossAmount: string
    TaxWithholdings: string
    NetAmount: string
    GrossUSD: string;
    RecipientCUIT: string
    Recipient: string
    Merchant: string
    Description: string
    IdTransaction: string
    CurrencyType: string
    WithholdingArba : string
    Retention:string
    CBU : string
    NroRegimen: string




    constructor(_operRet: any) {
        this.idTransaction = _operRet.idTransaction || null
        this.TransactionDate = _operRet.TransactionDate || null
        this.ProcessedDate = _operRet.ProcessedDate || null
        this.Merchant = _operRet.Merchant || null
        this.Description = _operRet.Description || null
        this.IdTransaction = _operRet.IdTransaction || null
        this.Ticket = _operRet.Ticket || null
        this.MerchantId = _operRet.MerchantId || null
        this.FileName = _operRet.FileName || null
        this.CertificateNumber = _operRet.CertificateNumber || null
        this.GrossAmount = _operRet.GrossAmount || null
        this.TaxWithholdings = _operRet.TaxWithholdings || null
        this.WithholdingArba = _operRet.WithholdingArba || null
        this.Retention = _operRet.Retention || null
        this.NetAmount = _operRet.NetAmount || null
        this.GrossUSD = _operRet.GrossUSD || null
        this.RecipientCUIT = _operRet.RecipientCUIT || null
        this.Recipient = _operRet.Recipient || null
        this.CurrencyType = _operRet.CurrencyType || null
        this.CBU = _operRet.CBU || null
        this.NroRegimen = _operRet.NroRegimen || null
    }

}
