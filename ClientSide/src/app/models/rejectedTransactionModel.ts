
export class RejectedTransaction {


    ProcessDate: string
    ListErrors: ErrorType[]
    TransactionType: string
    PaymentDate: string
    Merchant: string
    MerchantId: string
    SubMerchant: string
    BeneficiaryName: string
    Country: string
    City: string
    Address: string
    Email: string
    Birthdate: string
    BeneficiaryID: string
    CBU: string
    Amount: string
  




    constructor(_trError: any) {
        this.ProcessDate = _trError.ProcessDate
        this.ListErrors = _trError.ListErrorsCliente.map(error => new ErrorType(error))
        this.TransactionType = _trError.TransactionType
        this.PaymentDate = _trError.PaymentDate
        this.Merchant = _trError.Merchant
        this.MerchantId = _trError.MerchantId
        this.SubMerchant = _trError.SubMerchant
        this.BeneficiaryName = _trError.BeneficiaryName
        this.Country = _trError.Country
        this.City = _trError.City
        this.Address = _trError.Address
        this.Email = _trError.Email
        this.Birthdate = _trError.Birthdate
        this.BeneficiaryID = _trError.BeneficiaryID
        this.CBU = _trError.CBU
        this.Amount = _trError.Amount
   

    }

}

export class ErrorType {

    Key: string
    Messages: string[]

    constructor(_error: any) {
        this.Key = _error.Key;
        this.Messages = _error.Messages;


    }

}

