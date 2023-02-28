import { Country } from "./countryModel";
import Utils from "../utils";

export class Payout {

    static Argentina = class PayoutArgentina {

        beneficiary_name: string = "";
        beneficiary_cuit: string = "";
        bank_account_type: string = "";
        bank_cbu: string = "";
        submerchant_code: string = "";
        amount: number = 0;
        beneficiary_address: string = "";
        annotation: string = "";
        beneficiary_birth_date: string = "";
        beneficiary_state: string = "";
        beneficiary_country: string = "";
        beneficiary_email: string = "";
        currency: string = "";
        payout_date: string = "";
        sender_name: string = "";
        sender_address: string = "";
        sender_state: string = "";
        sender_country: string = "";
        sender_taxid: string = "";
        sender_birthdate: string = "";
        sender_email: string = "";
        merchant_id: string = "";
        // sender_id: string = "";
        // sender_address:string =""

        constructor(_payout_api: any) {
            this.beneficiary_name = _payout_api[0] != null ? _payout_api[0].toString() : ''
            this.beneficiary_cuit = _payout_api[1] != null ? _payout_api[1].toString() : ''
            this.bank_cbu = _payout_api[2] != null ? _payout_api[2].toString() : ''
            this.payout_date = _payout_api[3] != null ? _payout_api[3].toString() : ''
            this.amount = _payout_api[4] != null ? parseInt(_payout_api[4]) : 0
            this.bank_account_type = _payout_api[5] != null ? _payout_api[5].toString() : ''
            this.submerchant_code = _payout_api[6] != null ? _payout_api[6].toString() : ''
            this.currency = _payout_api[7] != null ? _payout_api[7].toString() : ''
            this.merchant_id = _payout_api[8] != null ? _payout_api[8].toString() : ''
            this.beneficiary_address = _payout_api[9] != null ? _payout_api[9].toString() : ''
            this.beneficiary_state = _payout_api[10] != null ? _payout_api[10].toString() : ''
            this.beneficiary_country = _payout_api[11] != null ? _payout_api[11].toString() : ''
            this.beneficiary_email = _payout_api[12] != null ? _payout_api[12].toString() : null
            this.beneficiary_birth_date = _payout_api[13] != null ? _payout_api[13].toString() : '';
            this.sender_name =  _payout_api[6] != null ? _payout_api[6].toString() : null;
            this.sender_taxid =  _payout_api[14] != null ? _payout_api[14].toString() : null;
            this.sender_address =  _payout_api[15] != null ? _payout_api[15].toString() : null;
            this.sender_country =  _payout_api[16] != null ? _payout_api[16].toString() : null;
            this.sender_state =  _payout_api[17] != null ? _payout_api[17].toString() : null;
            this.sender_email =  _payout_api[18] != null ? _payout_api[18].toString() : null;
            this.sender_birthdate =  _payout_api[19] != null ? _payout_api[19].toString() : null;
            // this.sender_id              = _payout_api[14] != null ? _payout_api[14].toString() : '' 
            // this.sender_address         = _payout_api[15] != null ? _payout_api[15].toString() : '' 
            // Proximos datos a partir de index 16
            
        }

    }

    static Colombia = class PayoutColombia {

        type_of_id: string
        id: string
        beneficiary_name: string
        account_type: string
        bank_code: string
        beneficiary_account_number: string
        beneficiary_email: string
        merchant_id: string
        amount: number = 0
        payout_date: string
        currency: string
        beneficiary_address: string
        beneficiary_country: string
        beneficiary_state: string
        telephone_number: string
        fax_number: string
        submerchant_code: string
        sender_name: string = "";
        sender_address: string = "";
        sender_state: string = "";
        sender_country: string = "";
        sender_taxid: string = "";
        sender_birthdate: string = "";
        sender_email: string = "";

        constructor(_payout_api: any) {
            this.type_of_id = _payout_api[0] != null ? _payout_api[0].toString() : ''
            this.id = _payout_api[1] != null ? _payout_api[1].toString() : ''
            this.beneficiary_name = _payout_api[2] != null ? _payout_api[2].toString() : ''
            this.account_type = _payout_api[3] != null ? _payout_api[3].toString() : ''
            this.bank_code = _payout_api[4] != null ? _payout_api[4].toString() : ''
            this.beneficiary_account_number = _payout_api[5] != null ? _payout_api[5].toString() : ''
            this.beneficiary_email = _payout_api[6] != null ? _payout_api[6].toString() : ''
            this.merchant_id = _payout_api[7] != null ? _payout_api[7].toString() : ''
            this.amount = _payout_api[8] != null ? parseInt(_payout_api[8]) : 0
            this.payout_date = _payout_api[9] != null ? _payout_api[9].toString() : ''
            this.currency = _payout_api[10] != null ? _payout_api[10].toString() : ''
            this.beneficiary_address = _payout_api[11] != null ? _payout_api[11].toString() : ''
            this.beneficiary_state = _payout_api[12] != null ? _payout_api[12].toString() : null
            this.beneficiary_country = _payout_api[13] != null ? _payout_api[13].toString() : ''
            this.sender_name =  _payout_api[17] != null ? _payout_api[17].toString() : null;
            this.sender_taxid =  _payout_api[15] != null ? _payout_api[15].toString() : null;
            this.sender_address =  _payout_api[16] != null ? _payout_api[16].toString() : null;
            this.sender_country =  _payout_api[18] != null ? _payout_api[18].toString() : null;
            this.sender_state =  _payout_api[19] != null ? _payout_api[19].toString() : null;
            this.sender_email =  _payout_api[20] != null ? _payout_api[20].toString() : null;
            this.sender_birthdate =  _payout_api[21] != null ? _payout_api[21].toString() : null;
            // this.telephone_number = _payout_api[14] != null ? _payout_api[14].toString() : ''
            // this.fax_number = _payout_api[15] != null ? _payout_api[15].toString() : ''
            this.submerchant_code = _payout_api[14] != null ? _payout_api[14].toString() : ''

        }
    }

    static Brasil = class PayoutBrasil {

        amount: string
        bank_account_type: string
        bank_branch: string
        bank_code: string
        beneficiary_account_number: string
        beneficiary_address: string
        beneficiary_country: string
        beneficiary_document_id: string
        beneficiary_email: string
        beneficiary_name: string
        beneficiary_state: string
        concept_code: string
        currency: string
        merchant_id: string
        payout_date: string
        sender_address: string = ""
        sender_birthdate: string = ""
        sender_country: string = ""
        sender_email: string = ""
        sender_name: string = ""
        sender_state: string = ""
        sender_taxid: string = ""
        submerchant_code: string
        
        constructor(_payout_api: any) {
            this.beneficiary_document_id = _payout_api[0] != null ? _payout_api[0].toString() : ''
            this.beneficiary_name = _payout_api[1] != null ? _payout_api[1].toString() : ''
            this.bank_account_type = _payout_api[2] != null ? _payout_api[2].toString() : ''
            this.bank_code = _payout_api[3] != null ? _payout_api[3].toString() : ''
            this.bank_branch = _payout_api[4] != null ? _payout_api[4].toString() : ''
            this.beneficiary_account_number = _payout_api[5] != null ? _payout_api[5].toString() : ''
            this.beneficiary_email = _payout_api[6] != null ? _payout_api[6].toString() : ''
            this.merchant_id = _payout_api[7] != null ? _payout_api[7].toString() : ''
            this.amount = _payout_api[8] != null ? _payout_api[8].toString() : ''
            this.payout_date = _payout_api[9] != null ? _payout_api[9].toString() : ''
            this.currency = _payout_api[10] != null ? _payout_api[10].toString() : ''
            this.beneficiary_address = _payout_api[11] != null ? _payout_api[11].toString() : ''
            this.beneficiary_state = _payout_api[12] != null ? _payout_api[12].toString() : ''
            this.beneficiary_country = _payout_api[13] != null ? _payout_api[13].toString() : ''
            this.submerchant_code = _payout_api[14] != null ? _payout_api[14].toString() : ''
            this.sender_taxid = _payout_api[15] != null ? _payout_api[15].toString() : ''
            this.sender_address = _payout_api[16] != null ? _payout_api[16].toString() : ''
            this.sender_name = _payout_api[17] != null ? _payout_api[17].toString() : ''
            this.sender_country = _payout_api[18] != null ? _payout_api[18].toString() : ''
            this.sender_state = _payout_api[19] != null ? _payout_api[19].toString() : ''
            this.sender_email = _payout_api[20] != null ? _payout_api[20].toString() : null
            this.sender_birthdate = _payout_api[21] != null ? _payout_api[21].toString() : ''
            this.concept_code = _payout_api[22] != null ? _payout_api[22].toString() : ''
        }


    }


    static Mexico = class PayoutMexico {

      amount: number = 0
      bank_account_type: string
      bank_code: string
      beneficiary_account_number: string
      beneficiary_address: string
      beneficiary_country: string
      beneficiary_document_id: string
      beneficiary_email: string
      beneficiary_name: string
      beneficiary_state: string
      concept_code: string
      currency: string
      merchant_id: string
      payout_date: string
      sender_address: string = ""
      sender_birthdate: string = ""
      sender_country: string = ""
      sender_email: string = ""
      sender_name: string = ""
      sender_state: string = ""
      sender_taxid: string = ""
      submerchant_code: string
      
      constructor(_payout_api: any) {
          this.beneficiary_document_id = _payout_api[0] != null ? _payout_api[0].toString() : ''
          this.beneficiary_name = _payout_api[1] != null ? _payout_api[1].toString() : ''
          this.bank_account_type = _payout_api[2] != null ? _payout_api[2].toString() : ''
          this.bank_code = _payout_api[3] != null ? _payout_api[3].toString() : ''
          this.beneficiary_account_number = _payout_api[4] != null ? _payout_api[4].toString() : ''
          this.beneficiary_email = _payout_api[5] != null ? _payout_api[5].toString() : null
          this.merchant_id = _payout_api[6] != null ? _payout_api[6].toString() : ''
          this.amount = (_payout_api[7] && (_payout_api[7] != null || _payout_api[7] != '')) ? _payout_api[7].toString() : 0
          this.payout_date = _payout_api[8] != null ? _payout_api[8].toString() : ''
          this.currency = _payout_api[9] != null ? _payout_api[9].toString() : ''
          this.beneficiary_address = _payout_api[10] != null ? _payout_api[10].toString() : ''
          this.beneficiary_state = _payout_api[11] != null ? _payout_api[11].toString() : ''
          this.beneficiary_country = _payout_api[12] != null ? _payout_api[12].toString() : ''
          this.submerchant_code = _payout_api[13] != null ? _payout_api[13].toString() : ''
          this.sender_taxid = _payout_api[14] != null ? _payout_api[14].toString() : ''
          this.sender_address = _payout_api[15] != null ? _payout_api[15].toString() : ''
          this.sender_name = _payout_api[16] != null ? _payout_api[16].toString() : ''
          this.sender_country = _payout_api[17] != null ? _payout_api[17].toString() : ''
          this.sender_state = _payout_api[18] != null ? _payout_api[18].toString() : ''
          this.sender_email = _payout_api[19] != null ? _payout_api[19].toString() : null
          this.sender_birthdate = _payout_api[20] != null ? _payout_api[20].toString() : ''
          this.concept_code = _payout_api[21] != null ? _payout_api[21].toString() : ''
      }
  }

    static Uruguay = class PayoutUruguay {

        amount: string
        bank_account_type: string
        bank_code: string
        beneficiary_account_number: string
        beneficiary_address: string
        beneficiary_birth_date: string
        beneficiary_country: string
        beneficiary_document_id: string
        beneficiary_document_type: string
        beneficiary_email: string
        beneficiary_name: string
        beneficiary_state: string
        concept_code: string
        currency: string
        merchant_id: string
        payout_date: string
        sender_address: string = "";
        sender_birthdate: string = "";
        sender_country: string = "";
        sender_email: string = "";
        sender_name: string = "";
        sender_state: string = "";
        sender_taxid: string = "";
        submerchant_code: string

        constructor(_payout_api: any) {
            this.beneficiary_document_type = _payout_api[0] != null ? _payout_api[0].toString() : ''
            this.beneficiary_document_id = _payout_api[1] != null ? _payout_api[1].toString() : ''
            this.beneficiary_name = _payout_api[2] != null ? _payout_api[2].toString() : ''
            this.bank_account_type = _payout_api[3] != null ? _payout_api[3].toString() : ''
            this.bank_code = _payout_api[4] != null ? _payout_api[4].toString() : ''
            this.beneficiary_account_number = _payout_api[5] != null ? _payout_api[5].toString() : ''
            this.beneficiary_email = _payout_api[6] != null ? _payout_api[6].toString() : ''
            this.merchant_id = _payout_api[7] != null ? _payout_api[7].toString() : ''
            this.amount = _payout_api[8] != null ? _payout_api[8].toString() : ''
            this.payout_date = _payout_api[9] != null ? _payout_api[9].toString() : ''
            this.currency = _payout_api[10] != null ? _payout_api[10].toString() : ''
            this.beneficiary_address = _payout_api[11] != null ? _payout_api[11].toString() : ''
            this.beneficiary_state = _payout_api[12] != null ? _payout_api[12].toString() : ''
            this.beneficiary_country = _payout_api[13] != null ? _payout_api[13].toString() : ''
            this.beneficiary_birth_date = _payout_api[14] != null ? _payout_api[14].toString() : ''
            this.submerchant_code = _payout_api[15] != null ? _payout_api[15].toString() : ''
            this.sender_taxid = _payout_api[16] != null ? _payout_api[16].toString() : ''
            this.sender_address = _payout_api[17] != null ? _payout_api[17].toString() : ''
            this.sender_name = _payout_api[18] != null ? _payout_api[18].toString() : ''
            this.sender_country = _payout_api[19] != null ? _payout_api[19].toString() : ''
            this.sender_state = _payout_api[20] != null ? _payout_api[20].toString() : ''
            this.sender_email = _payout_api[21] != null ? _payout_api[21].toString() : null
            this.sender_birthdate = _payout_api[22] != null ? _payout_api[22].toString() : ''
            this.concept_code = _payout_api[23] != null ? _payout_api[23].toString() : ''
        }
    }

    static Chile = class PayoutChile {

        amount: string
        bank_account_type: string
        bank_code: string
        beneficiary_account_number: string
        beneficiary_address: string
        beneficiary_birth_date: string
        beneficiary_country: string
        beneficiary_document_id: string
        beneficiary_document_type: string
        beneficiary_email: string
        beneficiary_name: string
        beneficiary_state: string
        concept_code: string
        currency: string
        merchant_id: string
        payout_date: string
        sender_address: string = "";
        sender_birthdate: string = "";
        sender_country: string = "";
        sender_email: string = "";
        sender_name: string = "";
        sender_state: string = "";
        sender_taxid: string = "";
        submerchant_code: string

        constructor(_payout_api: any) {
            this.beneficiary_document_type = _payout_api[0] != null ? _payout_api[0].toString() : ''
            this.beneficiary_document_id = _payout_api[1] != null ? _payout_api[1].toString() : ''
            this.beneficiary_name = _payout_api[2] != null ? _payout_api[2].toString() : ''
            this.bank_account_type = _payout_api[3] != null ? _payout_api[3].toString() : ''
            this.bank_code = _payout_api[4] != null ? _payout_api[4].toString() : ''
            this.beneficiary_account_number = _payout_api[5] != null ? _payout_api[5].toString() : ''
            this.beneficiary_email = _payout_api[6] != null ? _payout_api[6].toString() : ''
            this.merchant_id = _payout_api[7] != null ? _payout_api[7].toString() : ''
            this.amount = _payout_api[8] != null ? _payout_api[8].toString() : ''
            this.payout_date = _payout_api[9] != null ? _payout_api[9].toString() : ''
            this.currency = _payout_api[10] != null ? _payout_api[10].toString() : ''
            this.beneficiary_address = _payout_api[11] != null ? _payout_api[11].toString() : ''
            this.beneficiary_state = _payout_api[12] != null ? _payout_api[12].toString() : ''
            this.beneficiary_country = _payout_api[13] != null ? _payout_api[13].toString() : ''
            this.submerchant_code = _payout_api[14] != null ? _payout_api[14].toString() : ''
            this.sender_taxid = _payout_api[15] != null ? _payout_api[15].toString() : ''
            this.sender_address = _payout_api[16] != null ? _payout_api[16].toString() : ''
            this.sender_name = _payout_api[17] != null ? _payout_api[17].toString() : ''
            this.sender_country = _payout_api[18] != null ? _payout_api[18].toString() : ''
            this.sender_state = _payout_api[19] != null ? _payout_api[19].toString() : ''
            this.sender_email = _payout_api[20] != null ? _payout_api[20].toString() : null
            this.sender_birthdate = _payout_api[21] != null ? _payout_api[21].toString() : ''
            this.concept_code = _payout_api[22] != null ? _payout_api[22].toString() : ''
        }
    }

    static Ecuador = class PayoutEcuador {

        amount: string
        bank_account_type: string
        bank_code: string
        beneficiary_account_number: string
        beneficiary_address: string
        beneficiary_birth_date: string
        beneficiary_country: string
        beneficiary_document_id: string
        beneficiary_document_type: string
        beneficiary_email: string
        beneficiary_name: string
        beneficiary_state: string
        concept_code: string
        currency: string
        merchant_id: string
        payout_date: string
        sender_address: string = "";
        sender_birthdate: string = "";
        sender_country: string = "";
        sender_email: string = "";
        sender_name: string = "";
        sender_state: string = "";
        sender_taxid: string = "";
        submerchant_code: string

        constructor(_payout_api: any) {
            this.beneficiary_document_type = _payout_api[0] != null ? _payout_api[0].toString() : ''
            this.beneficiary_document_id = _payout_api[1] != null ? _payout_api[1].toString() : ''
            this.beneficiary_name = _payout_api[2] != null ? _payout_api[2].toString() : ''
            this.bank_account_type = _payout_api[3] != null ? _payout_api[3].toString() : ''
            this.bank_code = _payout_api[4] != null ? _payout_api[4].toString() : ''
            this.beneficiary_account_number = _payout_api[5] != null ? _payout_api[5].toString() : ''
            this.beneficiary_email = _payout_api[6] != null ? _payout_api[6].toString() : ''
            this.merchant_id = _payout_api[7] != null ? _payout_api[7].toString() : ''
            this.amount = _payout_api[8] != null ? _payout_api[8].toString() : ''
            this.payout_date = _payout_api[9] != null ? _payout_api[9].toString() : ''
            this.currency = _payout_api[10] != null ? _payout_api[10].toString() : ''
            this.beneficiary_address = _payout_api[11] != null ? _payout_api[11].toString() : ''
            this.beneficiary_state = _payout_api[12] != null ? _payout_api[12].toString() : ''
            this.beneficiary_country = _payout_api[13] != null ? _payout_api[13].toString() : ''
            this.submerchant_code = _payout_api[14] != null ? _payout_api[14].toString() : ''
            this.sender_taxid = _payout_api[15] != null ? _payout_api[15].toString() : ''
            this.sender_address = _payout_api[16] != null ? _payout_api[16].toString() : ''
            this.sender_name = _payout_api[17] != null ? _payout_api[17].toString() : ''
            this.sender_country = _payout_api[18] != null ? _payout_api[18].toString() : ''
            this.sender_state = _payout_api[19] != null ? _payout_api[19].toString() : ''
            this.sender_email = _payout_api[20] != null ? _payout_api[20].toString() : null
            this.sender_birthdate = _payout_api[21] != null ? _payout_api[21].toString() : ''
            this.concept_code = _payout_api[22] != null ? _payout_api[22].toString() : ''
        }
    }

    static Peru = class PayoutPeru {

        amount: string
        bank_account_type: string
        bank_code: string
        beneficiary_account_number: string
        beneficiary_address: string
        beneficiary_birth_date: string
        beneficiary_country: string
        beneficiary_document_id: string
        beneficiary_document_type: string
        beneficiary_email: string
        beneficiary_name: string
        beneficiary_state: string
        concept_code: string
        currency: string
        merchant_id: string
        payout_date: string
        sender_address: string = "";
        sender_birthdate: string = "";
        sender_country: string = "";
        sender_email: string = "";
        sender_name: string = "";
        sender_state: string = "";
        sender_taxid: string = "";
        submerchant_code: string

        constructor(_payout_api: any) {
            this.beneficiary_document_type = _payout_api[0] != null ? _payout_api[0].toString() : ''
            this.beneficiary_document_id = _payout_api[1] != null ? _payout_api[1].toString() : ''
            this.beneficiary_name = _payout_api[2] != null ? _payout_api[2].toString() : ''
            this.bank_account_type = _payout_api[3] != null ? _payout_api[3].toString() : ''
            this.bank_code = _payout_api[4] != null ? _payout_api[4].toString() : ''
            this.beneficiary_account_number = _payout_api[5] != null ? _payout_api[5].toString() : ''
            this.beneficiary_email = _payout_api[6] != null ? _payout_api[6].toString() : ''
            this.merchant_id = _payout_api[7] != null ? _payout_api[7].toString() : ''
            this.amount = _payout_api[8] != null ? _payout_api[8].toString() : ''
            this.payout_date = _payout_api[9] != null ? _payout_api[9].toString() : ''
            this.currency = _payout_api[10] != null ? _payout_api[10].toString() : ''
            this.beneficiary_address = _payout_api[11] != null ? _payout_api[11].toString() : ''
            this.beneficiary_state = _payout_api[12] != null ? _payout_api[12].toString() : ''
            this.beneficiary_country = _payout_api[13] != null ? _payout_api[13].toString() : ''
            this.submerchant_code = _payout_api[14] != null ? _payout_api[14].toString() : ''
            this.sender_taxid = _payout_api[15] != null ? _payout_api[15].toString() : ''
            this.sender_address = _payout_api[16] != null ? _payout_api[16].toString() : ''
            this.sender_name = _payout_api[17] != null ? _payout_api[17].toString() : ''
            this.sender_country = _payout_api[18] != null ? _payout_api[18].toString() : ''
            this.sender_state = _payout_api[19] != null ? _payout_api[19].toString() : ''
            this.sender_email = _payout_api[20] != null ? _payout_api[20].toString() : null
            this.sender_birthdate = _payout_api[21] != null ? _payout_api[21].toString() : ''
            this.concept_code = _payout_api[22] != null ? _payout_api[22].toString() : ''
        }
    }

    static Paraguay = class PayoutParaguay {

        amount: string
        bank_account_type: string
        bank_code: string
        beneficiary_account_number: string
        beneficiary_address: string
        beneficiary_birth_date: string
        beneficiary_country: string
        beneficiary_document_id: string
        beneficiary_document_type: string
        beneficiary_email: string
        beneficiary_name: string
        beneficiary_state: string
        concept_code: string
        currency: string
        merchant_id: string
        payout_date: string
        sender_address: string = "";
        sender_birthdate: string = "";
        sender_country: string = "";
        sender_email: string = "";
        sender_name: string = "";
        sender_state: string = "";
        sender_taxid: string = "";
        submerchant_code: string

        constructor(_payout_api: any) {
            this.beneficiary_document_type = _payout_api[0] != null ? _payout_api[0].toString() : ''
            this.beneficiary_document_id = _payout_api[1] != null ? _payout_api[1].toString() : ''
            this.beneficiary_name = _payout_api[2] != null ? _payout_api[2].toString() : ''
            this.bank_account_type = _payout_api[3] != null ? _payout_api[3].toString() : ''
            this.bank_code = _payout_api[4] != null ? _payout_api[4].toString() : ''
            this.beneficiary_account_number = _payout_api[5] != null ? _payout_api[5].toString() : ''
            this.beneficiary_email = _payout_api[6] != null ? _payout_api[6].toString() : ''
            this.merchant_id = _payout_api[7] != null ? _payout_api[7].toString() : ''
            this.amount = _payout_api[8] != null ? _payout_api[8].toString() : ''
            this.payout_date = _payout_api[9] != null ? _payout_api[9].toString() : ''
            this.currency = _payout_api[10] != null ? _payout_api[10].toString() : ''
            this.beneficiary_address = _payout_api[11] != null ? _payout_api[11].toString() : ''
            this.beneficiary_state = _payout_api[12] != null ? _payout_api[12].toString() : ''
            this.beneficiary_country = _payout_api[13] != null ? _payout_api[13].toString() : ''
            this.submerchant_code = _payout_api[14] != null ? _payout_api[14].toString() : ''
            this.sender_taxid = _payout_api[15] != null ? _payout_api[15].toString() : ''
            this.sender_address = _payout_api[16] != null ? _payout_api[16].toString() : ''
            this.sender_name = _payout_api[17] != null ? _payout_api[17].toString() : ''
            this.sender_country = _payout_api[18] != null ? _payout_api[18].toString() : ''
            this.sender_state = _payout_api[19] != null ? _payout_api[19].toString() : ''
            this.sender_email = _payout_api[20] != null ? _payout_api[20].toString() : null
            this.sender_birthdate = _payout_api[21] != null ? _payout_api[21].toString() : ''
            this.concept_code = _payout_api[22] != null ? _payout_api[22].toString() : ''
        }
    }

    static Bolivia = class PayoutBolivia {

        amount: string
        bank_account_type: string
        bank_code: string
        beneficiary_account_number: string
        beneficiary_address: string
        beneficiary_birth_date: string
        beneficiary_country: string
        beneficiary_document_id: string
        beneficiary_document_type: string
        beneficiary_email: string
        beneficiary_name: string
        beneficiary_state: string
        concept_code: string
        currency: string
        merchant_id: string
        payout_date: string
        sender_address: string = "";
        sender_birthdate: string = "";
        sender_country: string = "";
        sender_email: string = "";
        sender_name: string = "";
        sender_state: string = "";
        sender_taxid: string = "";
        submerchant_code: string

        constructor(_payout_api: any) {
            this.beneficiary_document_type = _payout_api[0] != null ? _payout_api[0].toString() : ''
            this.beneficiary_document_id = _payout_api[1] != null ? _payout_api[1].toString() : ''
            this.beneficiary_name = _payout_api[2] != null ? _payout_api[2].toString() : ''
            this.bank_account_type = _payout_api[3] != null ? _payout_api[3].toString() : ''
            this.bank_code = _payout_api[4] != null ? _payout_api[4].toString() : ''
            this.beneficiary_account_number = _payout_api[5] != null ? _payout_api[5].toString() : ''
            this.beneficiary_email = _payout_api[6] != null ? _payout_api[6].toString() : ''
            this.merchant_id = _payout_api[7] != null ? _payout_api[7].toString() : ''
            this.amount = _payout_api[8] != null ? _payout_api[8].toString() : ''
            this.payout_date = _payout_api[9] != null ? _payout_api[9].toString() : ''
            this.currency = _payout_api[10] != null ? _payout_api[10].toString() : ''
            this.beneficiary_address = _payout_api[11] != null ? _payout_api[11].toString() : ''
            this.beneficiary_state = _payout_api[12] != null ? _payout_api[12].toString() : ''
            this.beneficiary_country = _payout_api[13] != null ? _payout_api[13].toString() : ''
            this.submerchant_code = _payout_api[14] != null ? _payout_api[14].toString() : ''
            this.sender_taxid = _payout_api[15] != null ? _payout_api[15].toString() : ''
            this.sender_address = _payout_api[16] != null ? _payout_api[16].toString() : ''
            this.sender_name = _payout_api[17] != null ? _payout_api[17].toString() : ''
            this.sender_country = _payout_api[18] != null ? _payout_api[18].toString() : ''
            this.sender_state = _payout_api[19] != null ? _payout_api[19].toString() : ''
            this.sender_email = _payout_api[20] != null ? _payout_api[20].toString() : null
            this.sender_birthdate = _payout_api[21] != null ? _payout_api[21].toString() : ''
            this.concept_code = _payout_api[22] != null ? _payout_api[22].toString() : ''
        }
    }

}

export namespace Payout {
    export type Argentina = InstanceType<typeof Payout.Argentina>;
    export type Colombia  = InstanceType<typeof Payout.Colombia>;
    export type Brasil    = InstanceType<typeof Payout.Brasil>;
    export type Uruguay   = InstanceType<typeof Payout.Uruguay>;
    export type Mexico    = InstanceType<typeof Payout.Mexico>;
    export type Chile    = InstanceType<typeof Payout.Chile>;
    export type Ecuador    = InstanceType<typeof Payout.Ecuador>;
    export type Peru    = InstanceType<typeof Payout.Peru>;
    export type Paraguay    = InstanceType<typeof Payout.Paraguay>;
    export type Bolivia    = InstanceType<typeof Payout.Bolivia>;
}
export class PayoutResponseARG {

    beneficiary_name: string;
    beneficiary_cuit: string;
    bank_cbu: string;
    payout_date: string;
    amount: number;
    bank_account_type: string;
    submerchant_code: string;
    currency: string;
    merchant_id: string;
    beneficiary_address: string = "";
    beneficiary_birth_date: string = "";
    beneficiary_state: string = "";
    beneficiary_country: string = "";
    beneficiary_email: string = "";
    sender_name: string = "";
    sender_address: string = "";
    sender_state: string = "";
    sender_country: string = "";
    sender_taxid: string = "";
    sender_birthdate: string = "";
    sender_email: string = "";
    errorComplete: string = ""
    error: ErrorRow;
    ListErrors:ErrorType[]
    //



    constructor(_payout_api_result: any) {
        this.beneficiary_name = _payout_api_result.beneficiary_name || null
        this.beneficiary_cuit = _payout_api_result.beneficiary_cuit || null
        this.bank_cbu = _payout_api_result.bank_cbu || null
        this.amount = _payout_api_result.amount || null
        this.merchant_id = _payout_api_result.merchant_id || null
        this.bank_account_type = _payout_api_result.bank_account_type || null
        this.currency = _payout_api_result.currency || null
        this.submerchant_code = _payout_api_result.submerchant_code || null
        this.beneficiary_address = _payout_api_result.beneficiary_address || null
        this.payout_date = _payout_api_result.payout_date || null
        this.beneficiary_birth_date = _payout_api_result.beneficiary_birth_date || null
        this.beneficiary_state = _payout_api_result.beneficiary_state || null
        this.beneficiary_country = _payout_api_result.beneficiary_country || null
        this.beneficiary_email = _payout_api_result.beneficiary_email || null
        this.sender_name = _payout_api_result.sender_name;
        this.sender_address = _payout_api_result.sender_address;
        this.sender_state = _payout_api_result.sender_state;
        this.sender_country = _payout_api_result.sender_country;
        this.sender_taxid = _payout_api_result.sender_taxid;
        this.sender_birthdate = _payout_api_result.sender_birth_date;
        this.sender_email = _payout_api_result.sender_email;
        this.error = _payout_api_result.ErrorRow;
        this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []

    }
}

export class PayoutResponseCOL {

    type_of_id: string
    id: string
    beneficiary_name: string
    account_type: string
    bank_code: string
    beneficiary_account_number: string
    beneficiary_email: string
    merchant_id: string
    amount: string
    submerchant_code: string
    payout_date: string
    currency: string
    beneficiary_address: string
    beneficiary_country: string
    beneficiary_state: string
    telephone_number: string
    fax_number: string;
    sender_name: string = "";
    sender_address: string = "";
    sender_state: string = "";
    sender_country: string = "";
    sender_taxid: string = "";
    sender_birthdate: string = "";
    sender_email: string = "";
    errorComplete: string = ""
    error: ErrorRow;
    ListErrors:ErrorType[]
    
    constructor(_payout_api_result: any) {
        this.type_of_id = _payout_api_result.type_of_id || null
        this.id = _payout_api_result.id || null
        this.beneficiary_name = _payout_api_result.beneficiary_name || null
        this.account_type = _payout_api_result.account_type || null
        this.bank_code = _payout_api_result.bank_code || null
        this.beneficiary_account_number = _payout_api_result.beneficiary_account_number || null
        this.beneficiary_email = _payout_api_result.beneficiary_email || null
        this.merchant_id = _payout_api_result.merchant_id || null
        this.amount = _payout_api_result.amount || null
        this.submerchant_code = _payout_api_result.submerchant_code || null
        this.payout_date = _payout_api_result.payout_date || null
        this.currency = _payout_api_result.currency || null
        this.beneficiary_address = _payout_api_result.beneficiary_address || null
        this.beneficiary_country = _payout_api_result.beneficiary_country || null
        this.beneficiary_state = _payout_api_result.beneficiary_state || null
        this.telephone_number = _payout_api_result.telephone_number || null
        this.fax_number = _payout_api_result.fax_number || null
        this.sender_name = _payout_api_result.sender_name;
        this.sender_address = _payout_api_result.sender_address;
        this.sender_state = _payout_api_result.sender_state;
        this.sender_country = _payout_api_result.sender_country;
        this.sender_taxid = _payout_api_result.sender_taxid;
        this.sender_birthdate = _payout_api_result.sender_birth_date;
        this.sender_email = _payout_api_result.sender_email;
        this.error      =  _payout_api_result.ErrorRow;
        this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []
        // this.errorComplete = Utils.mergeError(this.error.Errors)

        // this.ListErrors =  JSON.parse(this.error.Errors.Key).map(error => new ErrorType(error))
    }    

}

export class PayoutResponseBRA {

    amount: string
    bank_account_type: string
    bank_branch: string
    bank_code: string
    beneficiary_account_number: string
    beneficiary_address: string
    beneficiary_country: string
    beneficiary_document_id: string
    beneficiary_email: string
    beneficiary_name: string
    beneficiary_state: string
    concept_code: string
    currency: string
    merchant_id: string
    payout_date: string
    sender_address: string = ""
    sender_birthdate: string = ""
    sender_country: string = ""
    sender_email: string = ""
    sender_name: string = ""
    sender_state: string = ""
    sender_taxid: string = ""
    submerchant_code: string
    errorComplete: string = ""
    error: ErrorRow;
    ListErrors:ErrorType[]

    constructor(_payout_api_result: any) {
        this.amount = _payout_api_result.amount || null
        this.bank_account_type = _payout_api_result.bank_account_type || null
        this.bank_branch = _payout_api_result.bank_branch || null
        this.bank_code = _payout_api_result.bank_code || null
        this.beneficiary_account_number = _payout_api_result.beneficiary_account_number || null
        this.beneficiary_address = _payout_api_result.beneficiary_address || null
        this.beneficiary_country = _payout_api_result.beneficiary_country || null
        this.beneficiary_document_id = _payout_api_result.beneficiary_document_id || null
        this.beneficiary_email = _payout_api_result.beneficiary_email || null
        this.beneficiary_name = _payout_api_result.beneficiary_name || null
        this.beneficiary_state = _payout_api_result.beneficiary_state || null
        this.concept_code = _payout_api_result.concept_code || null
        this.currency = _payout_api_result.currency || null
        this.merchant_id = _payout_api_result.merchant_id || null
        this.payout_date = _payout_api_result.payout_date || null
        this.sender_address = _payout_api_result.sender_address || null
        this.sender_birthdate = _payout_api_result.sender_birthdate || null
        this.sender_country = _payout_api_result.sender_country || null
        this.sender_email = _payout_api_result.sender_email || null
        this.sender_name = _payout_api_result.sender_name || null
        this.sender_state = _payout_api_result.sender_state || null
        this.sender_taxid = _payout_api_result.sender_taxid || null
        this.submerchant_code = _payout_api_result.submerchant_code || null
        this.error = _payout_api_result.ErrorRow;
        this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []

    }

    mergeError(listErrors: any) {

        let messages = ""
        // let messageOut = ""
        if (listErrors.length > 0) {

            listErrors.forEach(error => {
                messages += error.Messages
            });
        }
        return messages;

    }

}

export class PayoutResponseMEX {

  amount: string
  bank_account_type: string
  bank_code: string
  beneficiary_account_number: string
  beneficiary_address: string
  beneficiary_country: string
  beneficiary_document_id: string
  beneficiary_email: string
  beneficiary_name: string
  beneficiary_state: string
  concept_code: string
  currency: string
  merchant_id: string
  payout_date: string
  sender_address: string = ""
  sender_birthdate: string = ""
  sender_country: string = ""
  sender_email: string = ""
  sender_name: string = ""
  sender_state: string = ""
  sender_taxid: string = ""
  submerchant_code: string
  errorComplete: string = ""
  error: ErrorRow;
  ListErrors:ErrorType[]

  constructor(_payout_api_result: any) {
      this.amount = _payout_api_result.amount || null
      this.bank_account_type = _payout_api_result.bank_account_type || null
      this.bank_code = _payout_api_result.bank_code || null
      this.beneficiary_account_number = _payout_api_result.beneficiary_account_number || null
      this.beneficiary_address = _payout_api_result.beneficiary_address || null
      this.beneficiary_country = _payout_api_result.beneficiary_country || null
      this.beneficiary_document_id = _payout_api_result.beneficiary_document_id || null
      this.beneficiary_email = _payout_api_result.beneficiary_email || null
      this.beneficiary_name = _payout_api_result.beneficiary_name || null
      this.beneficiary_state = _payout_api_result.beneficiary_state || null
      this.concept_code = _payout_api_result.concept_code || null
      this.currency = _payout_api_result.currency || null
      this.merchant_id = _payout_api_result.merchant_id || null
      this.payout_date = _payout_api_result.payout_date || null
      this.sender_address = _payout_api_result.sender_address || null
      this.sender_birthdate = _payout_api_result.sender_birthdate || null
      this.sender_country = _payout_api_result.sender_country || null
      this.sender_email = _payout_api_result.sender_email || null
      this.sender_name = _payout_api_result.sender_name || null
      this.sender_state = _payout_api_result.sender_state || null
      this.sender_taxid = _payout_api_result.sender_taxid || null
      this.submerchant_code = _payout_api_result.submerchant_code || null
      this.error = _payout_api_result.ErrorRow;
      this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []

  }

  mergeError(listErrors: any) {

      let messages = ""
      // let messageOut = ""
      if (listErrors.length > 0) {

          listErrors.forEach(error => {
              messages += error.Messages
          });
      }
      return messages;

  }

}

export class PayoutResponseURY {

    amount: string
    bank_account_type: string
    bank_code: string
    beneficiary_account_number: string
    beneficiary_address: string
    beneficiary_birth_date: string
    beneficiary_country: string
    beneficiary_document_id: string
    beneficiary_document_type: string
    beneficiary_email: string
    beneficiary_name: string
    beneficiary_state: string
    concept_code: string
    currency: string
    merchant_id: string
    payout_date: string
    sender_address: string = "";
    sender_birthdate: string = "";
    sender_country: string = "";
    sender_email: string = "";
    sender_name: string = "";
    sender_state: string = "";
    sender_taxid: string = "";
    submerchant_code: string
    error: ErrorRow;
    ListErrors:ErrorType[]
    constructor(_payout_api_result: any) {
        this.amount = _payout_api_result.amount || null
        this.bank_account_type = _payout_api_result.bank_account_type || null
        this.bank_code = _payout_api_result.bank_code || null
        this.beneficiary_account_number = _payout_api_result.beneficiary_account_number || null
        this.beneficiary_address = _payout_api_result.beneficiary_address || null
        this.beneficiary_birth_date = _payout_api_result.beneficiary_birth_date || null
        this.beneficiary_country = _payout_api_result.beneficiary_country || null
        this.beneficiary_document_id = _payout_api_result.beneficiary_document_id || null
        this.beneficiary_document_type = _payout_api_result.beneficiary_document_type || null
        this.beneficiary_email = _payout_api_result.beneficiary_email || null
        this.beneficiary_name = _payout_api_result.beneficiary_name || null
        this.beneficiary_state = _payout_api_result.beneficiary_state || null
        this.concept_code = _payout_api_result.concept_code || null
        this.currency = _payout_api_result.currency || null
        this.merchant_id = _payout_api_result.merchant_id || null
        this.payout_date = _payout_api_result.payout_date || null
        this.sender_address = _payout_api_result.sender_address || null
        this.sender_birthdate = _payout_api_result.sender_birthdate || null
        this.sender_country = _payout_api_result.sender_country || null
        this.sender_email = _payout_api_result.sender_email || null
        this.sender_name = _payout_api_result.sender_name || null
        this.sender_state = _payout_api_result.sender_state || null
        this.sender_taxid = _payout_api_result.sender_taxid || null
        this.submerchant_code = _payout_api_result.submerchant_code || null
        this.error = _payout_api_result.ErrorRow;
        this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []

    }

    mergeError(listErrors: any) {

        let messages = ""
        // let messageOut = ""
        if (listErrors.length > 0) {

            listErrors.forEach(error => {
                messages += error.Messages
            });
        }
        return messages;

    }

}

export class PayoutResponseCHL {

    amount: string
    bank_account_type: string
    bank_code: string
    beneficiary_account_number: string
    beneficiary_address: string
    beneficiary_birth_date: string
    beneficiary_country: string
    beneficiary_document_id: string
    beneficiary_document_type: string
    beneficiary_email: string
    beneficiary_name: string
    beneficiary_state: string
    concept_code: string
    currency: string
    merchant_id: string
    payout_date: string
    sender_address: string = "";
    sender_birthdate: string = "";
    sender_country: string = "";
    sender_email: string = "";
    sender_name: string = "";
    sender_state: string = "";
    sender_taxid: string = "";
    submerchant_code: string
    error: ErrorRow;
    ListErrors:ErrorType[]
    constructor(_payout_api_result: any) {
        this.amount = _payout_api_result.amount || null
        this.bank_account_type = _payout_api_result.bank_account_type || null
        this.bank_code = _payout_api_result.bank_code || null
        this.beneficiary_account_number = _payout_api_result.beneficiary_account_number || null
        this.beneficiary_address = _payout_api_result.beneficiary_address || null
        this.beneficiary_birth_date = _payout_api_result.beneficiary_birth_date || null
        this.beneficiary_country = _payout_api_result.beneficiary_country || null
        this.beneficiary_document_id = _payout_api_result.beneficiary_document_id || null
        this.beneficiary_document_type = _payout_api_result.beneficiary_document_type || null
        this.beneficiary_email = _payout_api_result.beneficiary_email || null
        this.beneficiary_name = _payout_api_result.beneficiary_name || null
        this.beneficiary_state = _payout_api_result.beneficiary_state || null
        this.concept_code = _payout_api_result.concept_code || null
        this.currency = _payout_api_result.currency || null
        this.merchant_id = _payout_api_result.merchant_id || null
        this.payout_date = _payout_api_result.payout_date || null
        this.sender_address = _payout_api_result.sender_address || null
        this.sender_birthdate = _payout_api_result.sender_birthdate || null
        this.sender_country = _payout_api_result.sender_country || null
        this.sender_email = _payout_api_result.sender_email || null
        this.sender_name = _payout_api_result.sender_name || null
        this.sender_state = _payout_api_result.sender_state || null
        this.sender_taxid = _payout_api_result.sender_taxid || null
        this.submerchant_code = _payout_api_result.submerchant_code || null
        this.error = _payout_api_result.ErrorRow;
        this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []

    }

    mergeError(listErrors: any) {

        let messages = ""
        // let messageOut = ""
        if (listErrors.length > 0) {

            listErrors.forEach(error => {
                messages += error.Messages
            });
        }
        return messages;

    }

}

export class PayoutResponseECU {

    amount: string
    bank_account_type: string
    bank_code: string
    beneficiary_account_number: string
    beneficiary_address: string
    beneficiary_birth_date: string
    beneficiary_country: string
    beneficiary_document_id: string
    beneficiary_document_type: string
    beneficiary_email: string
    beneficiary_name: string
    beneficiary_state: string
    concept_code: string
    currency: string
    merchant_id: string
    payout_date: string
    sender_address: string = "";
    sender_birthdate: string = "";
    sender_country: string = "";
    sender_email: string = "";
    sender_name: string = "";
    sender_state: string = "";
    sender_taxid: string = "";
    submerchant_code: string
    error: ErrorRow;
    ListErrors:ErrorType[]
    constructor(_payout_api_result: any) {
        this.amount = _payout_api_result.amount || null
        this.bank_account_type = _payout_api_result.bank_account_type || null
        this.bank_code = _payout_api_result.bank_code || null
        this.beneficiary_account_number = _payout_api_result.beneficiary_account_number || null
        this.beneficiary_address = _payout_api_result.beneficiary_address || null
        this.beneficiary_birth_date = _payout_api_result.beneficiary_birth_date || null
        this.beneficiary_country = _payout_api_result.beneficiary_country || null
        this.beneficiary_document_id = _payout_api_result.beneficiary_document_id || null
        this.beneficiary_document_type = _payout_api_result.beneficiary_document_type || null
        this.beneficiary_email = _payout_api_result.beneficiary_email || null
        this.beneficiary_name = _payout_api_result.beneficiary_name || null
        this.beneficiary_state = _payout_api_result.beneficiary_state || null
        this.concept_code = _payout_api_result.concept_code || null
        this.currency = _payout_api_result.currency || null
        this.merchant_id = _payout_api_result.merchant_id || null
        this.payout_date = _payout_api_result.payout_date || null
        this.sender_address = _payout_api_result.sender_address || null
        this.sender_birthdate = _payout_api_result.sender_birthdate || null
        this.sender_country = _payout_api_result.sender_country || null
        this.sender_email = _payout_api_result.sender_email || null
        this.sender_name = _payout_api_result.sender_name || null
        this.sender_state = _payout_api_result.sender_state || null
        this.sender_taxid = _payout_api_result.sender_taxid || null
        this.submerchant_code = _payout_api_result.submerchant_code || null
        this.error = _payout_api_result.ErrorRow;
        this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []

    }

    mergeError(listErrors: any) {

        let messages = ""
        // let messageOut = ""
        if (listErrors.length > 0) {

            listErrors.forEach(error => {
                messages += error.Messages
            });
        }
        return messages;

    }

}

export class PayoutResponsePER {

    amount: string
    bank_account_type: string
    bank_code: string
    beneficiary_account_number: string
    beneficiary_address: string
    beneficiary_birth_date: string
    beneficiary_country: string
    beneficiary_document_id: string
    beneficiary_document_type: string
    beneficiary_email: string
    beneficiary_name: string
    beneficiary_state: string
    concept_code: string
    currency: string
    merchant_id: string
    payout_date: string
    sender_address: string = "";
    sender_birthdate: string = "";
    sender_country: string = "";
    sender_email: string = "";
    sender_name: string = "";
    sender_state: string = "";
    sender_taxid: string = "";
    submerchant_code: string
    error: ErrorRow;
    ListErrors:ErrorType[]
    constructor(_payout_api_result: any) {
        this.amount = _payout_api_result.amount || null
        this.bank_account_type = _payout_api_result.bank_account_type || null
        this.bank_code = _payout_api_result.bank_code || null
        this.beneficiary_account_number = _payout_api_result.beneficiary_account_number || null
        this.beneficiary_address = _payout_api_result.beneficiary_address || null
        this.beneficiary_birth_date = _payout_api_result.beneficiary_birth_date || null
        this.beneficiary_country = _payout_api_result.beneficiary_country || null
        this.beneficiary_document_id = _payout_api_result.beneficiary_document_id || null
        this.beneficiary_document_type = _payout_api_result.beneficiary_document_type || null
        this.beneficiary_email = _payout_api_result.beneficiary_email || null
        this.beneficiary_name = _payout_api_result.beneficiary_name || null
        this.beneficiary_state = _payout_api_result.beneficiary_state || null
        this.concept_code = _payout_api_result.concept_code || null
        this.currency = _payout_api_result.currency || null
        this.merchant_id = _payout_api_result.merchant_id || null
        this.payout_date = _payout_api_result.payout_date || null
        this.sender_address = _payout_api_result.sender_address || null
        this.sender_birthdate = _payout_api_result.sender_birthdate || null
        this.sender_country = _payout_api_result.sender_country || null
        this.sender_email = _payout_api_result.sender_email || null
        this.sender_name = _payout_api_result.sender_name || null
        this.sender_state = _payout_api_result.sender_state || null
        this.sender_taxid = _payout_api_result.sender_taxid || null
        this.submerchant_code = _payout_api_result.submerchant_code || null
        this.error = _payout_api_result.ErrorRow;
        this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []

    }

    mergeError(listErrors: any) {

        let messages = ""
        // let messageOut = ""
        if (listErrors.length > 0) {

            listErrors.forEach(error => {
                messages += error.Messages
            });
        }
        return messages;

    }

}

export class PayoutResponsePRY {

    amount: string
    bank_account_type: string
    bank_code: string
    beneficiary_account_number: string
    beneficiary_address: string
    beneficiary_birth_date: string
    beneficiary_country: string
    beneficiary_document_id: string
    beneficiary_document_type: string
    beneficiary_email: string
    beneficiary_name: string
    beneficiary_state: string
    concept_code: string
    currency: string
    merchant_id: string
    payout_date: string
    sender_address: string = "";
    sender_birthdate: string = "";
    sender_country: string = "";
    sender_email: string = "";
    sender_name: string = "";
    sender_state: string = "";
    sender_taxid: string = "";
    submerchant_code: string
    error: ErrorRow;
    ListErrors:ErrorType[]
    constructor(_payout_api_result: any) {
        this.amount = _payout_api_result.amount || null
        this.bank_account_type = _payout_api_result.bank_account_type || null
        this.bank_code = _payout_api_result.bank_code || null
        this.beneficiary_account_number = _payout_api_result.beneficiary_account_number || null
        this.beneficiary_address = _payout_api_result.beneficiary_address || null
        this.beneficiary_birth_date = _payout_api_result.beneficiary_birth_date || null
        this.beneficiary_country = _payout_api_result.beneficiary_country || null
        this.beneficiary_document_id = _payout_api_result.beneficiary_document_id || null
        this.beneficiary_document_type = _payout_api_result.beneficiary_document_type || null
        this.beneficiary_email = _payout_api_result.beneficiary_email || null
        this.beneficiary_name = _payout_api_result.beneficiary_name || null
        this.beneficiary_state = _payout_api_result.beneficiary_state || null
        this.concept_code = _payout_api_result.concept_code || null
        this.currency = _payout_api_result.currency || null
        this.merchant_id = _payout_api_result.merchant_id || null
        this.payout_date = _payout_api_result.payout_date || null
        this.sender_address = _payout_api_result.sender_address || null
        this.sender_birthdate = _payout_api_result.sender_birthdate || null
        this.sender_country = _payout_api_result.sender_country || null
        this.sender_email = _payout_api_result.sender_email || null
        this.sender_name = _payout_api_result.sender_name || null
        this.sender_state = _payout_api_result.sender_state || null
        this.sender_taxid = _payout_api_result.sender_taxid || null
        this.submerchant_code = _payout_api_result.submerchant_code || null
        this.error = _payout_api_result.ErrorRow;
        this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []

    }

    mergeError(listErrors: any) {

        let messages = ""
        // let messageOut = ""
        if (listErrors.length > 0) {

            listErrors.forEach(error => {
                messages += error.Messages
            });
        }
        return messages;

    }

}

export class PayoutResponseBOL {

    amount: string
    bank_account_type: string
    bank_code: string
    beneficiary_account_number: string
    beneficiary_address: string
    beneficiary_birth_date: string
    beneficiary_country: string
    beneficiary_document_id: string
    beneficiary_document_type: string
    beneficiary_email: string
    beneficiary_name: string
    beneficiary_state: string
    concept_code: string
    currency: string
    merchant_id: string
    payout_date: string
    sender_address: string = "";
    sender_birthdate: string = "";
    sender_country: string = "";
    sender_email: string = "";
    sender_name: string = "";
    sender_state: string = "";
    sender_taxid: string = "";
    submerchant_code: string
    error: ErrorRow;
    ListErrors:ErrorType[]
    constructor(_payout_api_result: any) {
        this.amount = _payout_api_result.amount || null
        this.bank_account_type = _payout_api_result.bank_account_type || null
        this.bank_code = _payout_api_result.bank_code || null
        this.beneficiary_account_number = _payout_api_result.beneficiary_account_number || null
        this.beneficiary_address = _payout_api_result.beneficiary_address || null
        this.beneficiary_birth_date = _payout_api_result.beneficiary_birth_date || null
        this.beneficiary_country = _payout_api_result.beneficiary_country || null
        this.beneficiary_document_id = _payout_api_result.beneficiary_document_id || null
        this.beneficiary_document_type = _payout_api_result.beneficiary_document_type || null
        this.beneficiary_email = _payout_api_result.beneficiary_email || null
        this.beneficiary_name = _payout_api_result.beneficiary_name || null
        this.beneficiary_state = _payout_api_result.beneficiary_state || null
        this.concept_code = _payout_api_result.concept_code || null
        this.currency = _payout_api_result.currency || null
        this.merchant_id = _payout_api_result.merchant_id || null
        this.payout_date = _payout_api_result.payout_date || null
        this.sender_address = _payout_api_result.sender_address || null
        this.sender_birthdate = _payout_api_result.sender_birthdate || null
        this.sender_country = _payout_api_result.sender_country || null
        this.sender_email = _payout_api_result.sender_email || null
        this.sender_name = _payout_api_result.sender_name || null
        this.sender_state = _payout_api_result.sender_state || null
        this.sender_taxid = _payout_api_result.sender_taxid || null
        this.submerchant_code = _payout_api_result.submerchant_code || null
        this.error = _payout_api_result.ErrorRow;
        this.ListErrors = this.error.HasError ?  _payout_api_result.ErrorRow.Errors.map(error => new ErrorType(error)) : []

    }

    mergeError(listErrors: any) {

        let messages = ""
        // let messageOut = ""
        if (listErrors.length > 0) {

            listErrors.forEach(error => {
                messages += error.Messages
            });
        }
        return messages;

    }

}

export class ErrorRow {

    HasError: Boolean;
    Errors: Errors;

    constructor(_ErrorRow: any) {
        this.HasError = _ErrorRow.HasError
        this.Errors = _ErrorRow.Errors
    }

}

export class Errors {

    Key: Array<string>;
    Messages: Array<string>;

    constructor(_Errors: any) {
        this.Key = _Errors.Key
        this.Messages = _Errors.Messages
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