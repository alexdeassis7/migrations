﻿using Newtonsoft.Json;
using SharedModel.ValidationsAttrs;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModel.Models.Services.Peru
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class PeruPayoutCreateRequest
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        #region Transaction Detail
        [JsonProperty(Order = 21)]
        [Required(ErrorMessage = "Parameter :: merchant_id :: is required.#REQUIRED")]
        [StringLength(60, MinimumLength = 0, ErrorMessage = "Parameter :: merchant_id :: has minimun 0 characters and 60 characters maximum.#LENGTH")]
        [RegularExpression("^[a-zA-Z0-9\\s\\-]{0,60}$", ErrorMessage = "Parameter :: merchant_id :: invalid format, only allow: letters and spaces.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string merchant_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [StringLength(4, MinimumLength = 0, ErrorMessage = "Parameter :: concept_code :: has minimum 0 and 4 characters maximum.#LENGTH")]
        [JsonProperty(Order = 22)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string concept_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 24)]
        [Required(ErrorMessage = "Parameter :: currency :: is required.#REQUIRED")]
        [RegularExpression("^USD$|^PEN$", ErrorMessage = "Parameter :: currency :: invalid format, only allow codes: 'USD' | 'CLP'.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string currency { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [StringLength(8, MinimumLength = 8, ErrorMessage = "Parameter :: payout_date :: has 8 characters length.#LENGTH")]
        [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: payout_date :: invalid value: allow only date format, length 8 characters (YYYMMDD).#INVALID")]

        private string _payout_date { get; set; }
        [JsonProperty(Order = 25)]
        [ExpiredDate(ErrorMessage = "Parameter :: payout_date :: invalid date: it must be greater than actual date.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string payout_date { get { return _payout_date == null || string.IsNullOrEmpty(_payout_date) ? DateTime.Now.ToString("yyyyMMdd") : _payout_date; } set { _payout_date = value; } }

        [JsonProperty(Order = 26)]
        [Required(ErrorMessage = "Parameter :: amount :: is required.#REQUIRED")]
        [Range(100, 42000000, ErrorMessage = "Parameter :: amount :: value out range [100 - 42000000].#INVALID")]
        [RegularExpression("^[0-9]{3,9}$", ErrorMessage = "Parameter :: amount :: invalid length, must be between 3 and 9 characters.#LENGTH")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Int64 amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        #endregion

        #region Sender Information
        [JsonProperty(Order = 4)]
        [Required(ErrorMessage = "Parameter :: submerchant_code :: is required.#REQUIRED")]
        [StringLength(60, MinimumLength = 3, ErrorMessage = "Parameter :: submerchant_code :: has minimun 3 characters and 60 characters maximum.#LENGTH")]
        [RegularExpression("^[a-zA-Z0-9\\s\\-_]{3,60}$", ErrorMessage = "Parameter :: submerchant_code :: invalid format, only allow numbers, letters chars [-_.] and spaces, and length should be between 3 and 60 characters.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string submerchant_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 5)]
        [RegularExpression("^[a-zA-Z0-9\\s]{0,50}$", ErrorMessage = "Parameter :: sender_taxid :: invalid format, only allow: letters and spaces, and length has between 1 and 50 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_taxid { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 6)]
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: sender_name :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 7)]
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ0-9\\s]{1,300}$", ErrorMessage = "Parameter :: sender_address :: invalid format, only allow: letters and spaces, and length has between 1 and 300 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_address { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 8)]
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,20}$", ErrorMessage = "Parameter :: sender_state :: invalid format, only allow: letters and spaces, and length has between 1 and 20 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_state { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 9)]
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,20}$", ErrorMessage = "Parameter :: sender_country :: invalid format, only allow: letters and spaces, and length has between 1 and 20 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_country { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 10)]
        [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: sender_birthdate :: invalid value: allow only date format, length 8 characters (YYYMMDD).#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_birthdate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 11)]
        [EmailAddress(ErrorMessage = "Parameter :: sender_email :: is not a valid mail.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_email { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [JsonProperty(Order = 11)]
        [Phone(ErrorMessage = "Parameter :: sender_phone_number :: is not a valid phone number.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_phone_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [JsonProperty(Order = 11)]
        [RegularExpression("^[A-Za-z0-9-]{1,10}$", ErrorMessage = "Parameter :: sender_zip_code :: invalid value: allow only: letters, numbers and hyphen.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_zip_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        #endregion

        #region Beneficiario
        [JsonProperty(Order = 12)]
        [Required(ErrorMessage = "Parameter :: beneficiary_name :: is required.#REQUIRED")]
        [StringLength(60, MinimumLength = 1, ErrorMessage = "Parameter :: beneficiary_name :: has minimun 1 characters and 60 characters maximum.#LENGTH")]
        [RegularExpression("^([A-Za-z0-9\\u00C0-\\u00D6\\u00D8-\\u00f6\\u00f8-\\u00ff\\s][^\r\n]{1,60})$", ErrorMessage = "Parameter :: beneficiary_name :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: beneficiary_document_type :: is required.#REQUIRED")]
        [RegularExpression("(DNI|CE|LE|RUC|PASS)$", ErrorMessage = "Parameter :: beneficiary_document_type :: invalid format, only allow codes: 'DNI' 'CE' 'RUC' 'PASS' .#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_document_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: beneficiary_document_id :: is required.#REQUIRED")]
        [RUC]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_document_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: bank_code :: is required.#REQUIRED")]
        [BankCode(ErrorMessage = "Parameter :: bank_code :: invalid value .#INVALID")]
        [StringLength(3, ErrorMessage = "Parameter :: bank_code :: has 3 characters length.#LENGTH")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string bank_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [JsonProperty(Order = 14)]
        [Required(ErrorMessage = "Parameter :: bank_account_type :: is required.#REQUIRED")]
        [StringLength(1, MinimumLength = 1, ErrorMessage = "Parameter :: bank_account_type :: has 1 characters length.#LENGTH")]
        [RegularExpression("^[ACM]{1}$", ErrorMessage = "Parameter :: bank_account_type :: invalid format, only characters available: 'C' – checking account, 'A' – savings account, 'M' - master account")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string bank_account_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [JsonProperty(Order = 15)]
        [Required(ErrorMessage = "Parameter :: beneficiary_account_number :: is required.#REQUIRED")]
        [StringLength(20, ErrorMessage = "Parameter :: beneficiary_account_number :: invalid format. length must be 20")]
        [RegularExpression("^[0-9]{20}$", ErrorMessage = "Parameter :: beneficiary_account_number :: invalid format, only allow: numbers and length has 20 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_account_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [JsonProperty(Order = 16)]
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ0-9\\s]{1,300}$", ErrorMessage = "Parameter :: beneficiary_address :: invalid format, only allow: letters, numbers and spaces, and length has between 1 and 300 characters.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_address { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 17)]
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: beneficiary_state :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_state { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 18)]
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: beneficiary_country :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_country { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 19)]
        [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: beneficiary_birth_date :: invalid value: allow only date format, length 8 characters (YYYMMDD).#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_birth_date { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 20)]
        [EmailAddress(ErrorMessage = "Parameter :: beneficiary_email :: is not a valid mail.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_email { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [JsonProperty(Order = 20)]
        [Phone(ErrorMessage = "Parameter :: beneficiary_phone_number :: is not a valid phone number.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_phone_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [JsonProperty(Order = 20)]
        [RegularExpression("^[A-Za-z0-9-]{1,10}$", ErrorMessage = "Parameter :: beneficiary_zip_code :: invalid value: allow only: letters, numbers and hyphen.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_zip_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        #endregion
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public bool authenticate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonIgnore]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public bool ToOnHold { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        private SharedModel.Models.General.ErrorModel.Error errorrow = new General.ErrorModel.Error();
        [JsonProperty(Order = 31)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public SharedModel.Models.General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }
}
