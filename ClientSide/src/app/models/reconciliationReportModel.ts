import { __core_private_testing_placeholder__ } from '@angular/core/testing';

export class ReconciliationReport {


    providerName: string
    ccy: string
    date: string
    accountNumber: string
    bic: string
    trxType: string
    description: string
    payoneerId: string
    internalId: string
    debit: string
    credit: string
    availableBalance: string

    constructor(_reconciliationRep: any) {
        this.providerName = _reconciliationRep.providerName || null
        this.ccy = _reconciliationRep.ccy || null
        this.date = _reconciliationRep.date || null
        this.accountNumber = _reconciliationRep.accountNumber || null
        this.bic = _reconciliationRep.bic || null
        this.trxType = _reconciliationRep.trxType || null
        this.description = _reconciliationRep.description || null
        this.payoneerId = _reconciliationRep.payoneerId || null
        this.internalId = _reconciliationRep.internalId || null
        this.debit = _reconciliationRep.debit || null
        this.credit = _reconciliationRep.credit || null
        this.availableBalance = _reconciliationRep.availableBalance || null
    }

}