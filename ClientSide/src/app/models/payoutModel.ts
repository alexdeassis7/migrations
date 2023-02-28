import { TypeScriptEmitter } from "@angular/compiler";
import { __core_private_testing_placeholder__ } from "@angular/core/testing";

export class Payout {
    accreditation_date: string;
    balance: string;
    customer_name: string;
    gross_amount: string;
    lot_number: string;
    net_amount: string;
    payout_id: string;
    token_id: string;

    transaction_type: string;
    tax_withholdings: string;
    commissions: string;
    vat: string;
    bank_cost: string;
    bank_cost_vat: string;
    gross_revenue_perception: string;
    tax_debit: string;
    tax_credit: string;
    rounding: string;
    pay_vat: string;
    bank_balance: string;
    status: string;
    idTransactionLot: number


    transaction_list: TransactionList[];


    constructor(_payout: any) {
        this.accreditation_date = _payout.accreditation_date || null;
        this.balance = _payout.balance || null;
        this.customer_name = _payout.customer_name || null;
        this.gross_amount = _payout.gross_amount || null;
        this.lot_number = _payout.lot_number || null;
        this.net_amount = _payout.net_amount || null;
        this.payout_id = _payout.payout_id || null;
        this.token_id = _payout.token_id || null;
        this.transaction_type = _payout.transaction_type || null;
        this.tax_withholdings = _payout.tax_withholdings || null;
        this.commissions = _payout.commissions || null;
        this.vat = _payout.vat || null;
        this.bank_cost = _payout.bank_cost || null;
        this.bank_cost_vat = _payout.bank_cost_vat || null;
        this.gross_revenue_perception = _payout.gross_revenue_perception || null;
        this.tax_debit = _payout.tax_debit || null;
        this.tax_credit = _payout.tax_credit || null;
        this.rounding = _payout.rounding || null;
        this.pay_vat = _payout.pay_vat || null;
        this.bank_balance = _payout.bank_balance || null;
        this.status = _payout.status || null;
        this.idTransactionLot = _payout.idTransactionLot || null;



        this.transaction_list = _payout.transaction_list.length > 0 ? this.typeTr(_payout.transaction_list) : null;

    }

    typeTr(listTransaction: any): TransactionList[] {
        var _list = [];
        listTransaction.forEach(tr => {
            _list.push(new TransactionList(tr));
        });
        return _list;
    }
}

export class TransactionList {
    BankAccountType: string;
    CBU: string;
    ConceptCode: string;
    CurrencyType: string;
    Description: string;
    EntityAccount_id: string;
    EntityIdentificationType: string;
    InternalDescription: string;
    PaymentType: string;
    Recipient: string;
    RecipientAccountNumber: string;
    RecipientCUIT: string;
    Status: string;
    TransactionAcreditationDate: string;
    TransactionLot_id: string;
    Version: string;
    amount: string;
    idStatus: string;
    idTransaction: string;
    transactionRecipientDetail_id: string;
    transactionType_id: string;
    Value: string;
    transactionDetail_id: string;
    CreditTax: string;
    DebitTax: string;
    GrossAmount: string;
    NetAmount: string;
    BankCost: string;
    IVABankCost: string;
    Balance: string;
    Commission: string;
    IVACommission: string;
    IVATotal: string;
    TotalCostRdo: string;
    TransactionDate: string;


    constructor(_payout: any) {
        this.BankAccountType = _payout.BankAccountType || null;
        this.CBU = _payout.CBU || null;
        this.ConceptCode = _payout.ConceptCode || null;
        this.CurrencyType = _payout.CurrencyType || null;
        this.Description = _payout.Description || null;
        this.EntityAccount_id = _payout.EntityAccount_id || null;
        this.EntityIdentificationType = _payout.EntityIdentificationType || null;
        this.InternalDescription = _payout.InternalDescription || null;
        this.PaymentType = _payout.PaymentType || null;
        this.Recipient = _payout.Recipient || null;
        this.RecipientAccountNumber = _payout.RecipientAccountNumber || null;
        this.RecipientCUIT = _payout.RecipientCUIT || null;
        this.Status = _payout.Status || null;
        this.TransactionAcreditationDate = _payout.TransactionAcreditationDate || null;
        this.TransactionLot_id = _payout.TransactionLot_id || null;
        this.Version = _payout.Version || null;
        this.amount = _payout.amount || null;
        this.idStatus = _payout.idStatus || null;
        this.idTransaction = _payout.idTransaction || null;
        this.transactionRecipientDetail_id = _payout.transactionRecipientDetail_id || null;
        this.transactionType_id = _payout.transactionType_id || null;
        this.Value = _payout.Value || null;
        this.transactionDetail_id = _payout.transactionDetail_id || null;
        this.CreditTax = _payout.CreditTax || null;
        this.DebitTax = _payout.DebitTax || null;
        this.GrossAmount = _payout.GrossAmount || null;
        this.NetAmount = _payout.NetAmount || null;
        this.BankCost = _payout.BankCost || null;
        this.IVABankCost = _payout.IVABankCost || null;
        this.Balance = _payout.Balance || null;
        this.Commission = _payout.Commission || null;
        this.IVACommission = _payout.IVACommission || null;
        this.IVATotal = _payout.IVATotal || null;
        this.TotalCostRdo = _payout.TotalCostRdo || null;
        this.TransactionDate = _payout.TransactionDate || null;

    }
}
