using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Newtonsoft.Json;
using SharedModel.ValidationsAttrs;

namespace SharedModel.Models.Services.Brasil
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class PayOutBrasil
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class LotBatch
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            /// <summary>
            /// [ES|EN][ID Lote|ID PayOut][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public Int64 payout_id { get; set; }
            /// <summary>
            /// [ES|EN][Nombre del Cliente|Customer Name][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string customer_name { get; set; }
            /// <summary>
            /// [ES|EN][Tipo de Transacción|Transaction Type][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string transaction_type { get; set; }
            /// <summary>
            /// [ES|EN][Estado|Status][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string status { get; set; }
            /// <summary>
            /// [ES|EN][Fecha de Proceso|Process Date][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string lot_date { get; set; }
            /// <summary>
            /// [ES|EN][Importe Bruto|Gross Amount][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public Int64 gross_amount { get; set; }
            /// <summary>
            /// [ES|EN][Importe Neto|Net Amount][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public Int64 net_amount { get; set; }
            
#pragma warning disable CS1587 // El comentario XML no está situado en un elemento válido del idioma
/// <summary>
            /// [ES|EN][Saldo|Balance][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            //public Int64 account_balance { get; set; }
            /// <summary>
            /// [ES|EN][Listado de Transacciones|List of Transactions][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            private List<List.Response> pri_transaction_list = new List<List.Response>();
#pragma warning restore CS1587 // El comentario XML no está situado en un elemento válido del idioma
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public List<List.Response> transaction_list { get { return pri_transaction_list; } set { pri_transaction_list = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            //public string error { get; set; }

        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Create
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
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
                public string concept_code { get; set; } = "";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [JsonProperty(Order = 24)]
                [Required(ErrorMessage = "Parameter :: currency :: is required.#REQUIRED")]
                [RegularExpression("^USD$|^BRL$", ErrorMessage = "Parameter :: currency :: invalid format, only allow codes: 'USD' | 'BRL'.#INVALID")]
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
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [JsonProperty(Order = 26)]
                [Required(ErrorMessage = "Parameter :: amount :: is required.#REQUIRED")]
                [Range(100, 100000000, ErrorMessage = "Parameter :: amount :: value out range [100 - 100000000].#INVALID")]
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
                public string submerchant_code { get; set; } = "";
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
                [RegularExpression("^[a-zA-Z0-9\\s][^\r\n]{1,60}$", ErrorMessage = "Parameter :: beneficiary_name :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string beneficiary_name { get; set; } = "";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [JsonProperty(Order = 14)]
                [Required(ErrorMessage = "Parameter :: beneficiary_document_id :: is required.#REQUIRED")]
                [RegularExpression("^(?=(?:.{14}|.{11})$)[0-9]*$", ErrorMessage = "Parameter :: beneficiary_document_id :: invalid length, must be only numbers and 11 or 14 characters length.#INVALID")]
                [ValidationsAttrs.Brasil.BeneficiaryDocumentNumber(ErrorMessage = "Parameter :: beneficiary_document_id :: is invalid")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string beneficiary_document_id { get; set; } = "";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [JsonProperty(Order = 14)]
                [Required(ErrorMessage = "Parameter :: bank_account_type :: is required.#REQUIRED")]
                [StringLength(1, MinimumLength = 1, ErrorMessage = "Parameter :: bank_account_type :: has 1 characters length.#LENGTH")]
                [RegularExpression("^[AC]{1}$", ErrorMessage = "Parameter :: bank_account_type :: invalid format, only characters available: 'C' – checking account, 'A' – savings account.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string bank_account_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [JsonProperty(Order = 16)]
                [Required(ErrorMessage = "Parameter :: bank_code :: is required. #REQUIRED")]
                [StringLength(3, MinimumLength = 3, ErrorMessage = "Parameter :: bank_code :: length must be 3.#LENGTH")]
                [BankCode(ErrorMessage = "Parameter :: bank_code :: is invalid")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string bank_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [JsonProperty(Order = 16)]
                [Required(ErrorMessage = "Parameter :: bank_branch :: is required. #REQUIRED")]
                [RegularExpression("(^\\d{4}[0-9Xx]{1}$)|(^\\d{4}-[0-9Xx]{1}$|(^\\d{4})|(^\\d{3})|(^\\d{1}))", ErrorMessage = "Parameter :: bank_branch :: must be between 1-6 character length characters length.#LENGTH")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string bank_branch { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                 [JsonProperty(Order = 17)]
                [Required(ErrorMessage = "Parameter :: beneficiary_account_number :: is required.#REQUIRED")]
                [RegularExpression("(^\\d{2,12}[0-9Xx]{1}$)|(^\\d{2,12}-[0-9Xx]{1}$)", ErrorMessage = "Parameter :: beneficiary_account_number :: has minimum 3 characters and a maximum of 13 with or without a underscore.#LENGTH")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string beneficiary_account_number { get; set; } = "";
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

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request<T> where T : class
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
            }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response : Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                #region Transaction Information
                [JsonProperty(Order = 0)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 transaction_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [JsonProperty(Order = 1)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 payout_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [JsonProperty(Order = 2)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [JsonProperty(Order = 3)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Ticket { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                #endregion
                [JsonProperty(Order = 27)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 exchange_rate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [JsonProperty(Order = 28)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public long iof_tax { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Update
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {

            }
            //public class Request
            //{
            //    [Required(ErrorMessage = "Parameter :: transaction_id :: is required.")]
            //    [RegularExpression("^[0-9]*$", ErrorMessage = "Parameter :: transaction_id :: invalid format, only allow: numbers.")]
            //    public Int64 transaction_id { get; set; }
            //    [Required(ErrorMessage = "Parameter :: payout_id :: is required.")]
            //    [RegularExpression("^[0-9]*$", ErrorMessage = "Parameter :: payout_id :: invalid format, only allow: numbers.")]
            //    public Int64 payout_id { get; set; }
            //    [Required(ErrorMessage = "Parameter :: beneficiary_cuit :: is required.")]
            //    [StringLength(11, MinimumLength = 11, ErrorMessage = "Parameter :: beneficiary_cuit :: incorrect length, the correct format has 11 characters.")]
            //    [RegularExpression("^(\\b(20|23|24|27|30|33|34)(\\D)?[0-9]{8}(\\D)?[0-9])$", ErrorMessage = "Parameter :: beneficiary_cuit :: invalid format, only allow: numbers.")]
            //    [CUIT(ErrorMessage = "Parameter :: beneficiary_cuit :: invalid CUIT.")]
            //    public string beneficiary_cuit { get; set; }
            //    [Required(ErrorMessage = "Parameter :: beneficiary_name :: is required.")]
            //    [StringLength(60, MinimumLength = 1, ErrorMessage = "Parameter :: beneficiary_name :: has minimun 1 characters and 60 characters maximum. ")]
            //    [RegularExpression("^[a-zA-Z0-9\\s]{1,60}$", ErrorMessage = "Parameter :: beneficiary_name :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
            //    public string beneficiary_name { get; set; }
            //    [Required(ErrorMessage = "Parameter :: bank_account_type :: is required.")]
            //    [StringLength(1, MinimumLength = 1, ErrorMessage = "Parameter :: bank_account_type :: has 1 characters length. ")]
            //    [RegularExpression("^[AC]{1}$", ErrorMessage = "Parameter :: bank_account_type :: invalid format, only characters available: 'C' – checking account, 'A' – savings account.")]
            //    public string bank_account_type { get; set; }
            //    [Required(ErrorMessage = "Parameter :: bank_cbu :: is required.")]
            //    [StringLength(22, MinimumLength = 22, ErrorMessage = "Parameter :: bank_cbu :: has 22 characters length.")]
            //    [RegularExpression("^[0-9]{22}$", ErrorMessage = "Parameter :: bank_cbu :: invalid format, only allow: numbers and length has 22 characters.")]
            //    [CBU(ErrorMessage = "Parameter :: bank_cbu :: invalid CBU.")]
            //    public string bank_cbu { get; set; }
            //    [Required(ErrorMessage = "Parameter :: amount :: is required.")]
            //    [Range(100, 100000000, ErrorMessage = "Parameter :: amount :: value out range [100 - 100000000].")]
            //    [RegularExpression("^[0-9]{3,9}$", ErrorMessage = "Parameter :: amount :: invalid length, must be between 3 and 9 characters.")]
            //    public Int64 amount { get; set; }
            //    [Required(ErrorMessage = "Parameter :: merchant_id :: is required.")]
            //    [StringLength(22, MinimumLength = 0, ErrorMessage = "Parameter :: merchant_id :: has minimun 0 characters and 22 characters maximum.")]
            //    [RegularExpression("^[a-zA-Z0-9\\s]{0,22}$", ErrorMessage = "Parameter :: merchant_id :: invalid format, only allow: letters and spaces.")]
            //    public string merchant_id { get; set; }
            //    [StringLength(4, MinimumLength = 0, ErrorMessage = "Parameter :: concept_code :: has minimum 0 and 4 characters maximum.#LENGTH")]
            //    [JsonProperty(Order = 22)]
            //    public string concept_code { get; set; }
            //    [Required(ErrorMessage = "Parameter :: currency :: is required.")]
            //    [RegularExpression("^[ARS|USD|BRL|EUR|UYU|COP|PYG]{3}$", ErrorMessage = "Parameter :: currency :: invalid format, only allow codes: 'ARS' | 'USD' | 'BRL' | 'EUR' | 'UYU' | 'COP' | 'PYG'.")]
            //    public string currency { get; set; }
            //    [Required(ErrorMessage = "Parameter :: payout_date :: is required.")]
            //    [StringLength(8, MinimumLength = 8, ErrorMessage = "Parameter :: payout_date :: has 8 characters length.")]
            //    [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: payout_date :: invalid value: allow only date format, length 8 characters (YYYMMDD).")]
            //    private string _payout_date { get; set; }
            //    public string payout_date { get { return this._payout_date == null || string.IsNullOrEmpty(this._payout_date) ? DateTime.Now.ToString("yyyyMMdd") : this._payout_date; } set { this._payout_date = value; } }

            //    [EmailAddress(ErrorMessage = "Parameter :: beneficiary_email :: is not a valid mail.")]
            //    public string beneficiary_email { get; set; }

            //    [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ0-9\\s]{1,150}$", ErrorMessage = "Parameter :: beneficiary_address :: invalid format, only allow: letters, numbers and spaces, and length has between 1 and 150 characters.")]
            //    public string beneficiary_address { get; set; }
            //    [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: beneficiary_birth_date :: invalid value: allow only date format, length 8 characters (YYYMMDD).")]
            //    public string beneficiary_birth_date { get; set; }

            //    [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: beneficiary_country :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
            //    public string beneficiary_country { get; set; }

            //    [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: beneficiary_state :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
            //    public string beneficiary_state { get; set; }

            //    [Required(ErrorMessage = "Parameter :: submerchant_code :: is required.")]
            //    [StringLength(60, MinimumLength = 3, ErrorMessage = "Parameter :: submerchant_code :: has minimun 3 characters and 60 characters maximum.")]
            //    [RegularExpression("^[a-zA-Z0-9\\s\\.-_]{3,60}$", ErrorMessage = "Parameter :: submerchant_code :: invalid format, only allow numbers, letters chars [-_.] and spaces, and length should be between 3 and 60 characters.")]
            //    public string submerchant_code { get; set; }

            //    [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: SenderName :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
            //    public string sender_name { get; set; }
            //    [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ0-9\\s]{1,150}$", ErrorMessage = "Parameter :: SenderAddress :: invalid format, only allow: letters and spaces, and length has between 1 and 150 characters.")]
            //    public string sender_address { get; set; }
            //    [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,20}$", ErrorMessage = "Parameter :: SenderState :: invalid format, only allow: letters and spaces, and length has between 1 and 20 characters.")]
            //    public string sender_state { get; set; }
            //    [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,20}$", ErrorMessage = "Parameter :: SenderCountry :: invalid format, only allow: letters and spaces, and length has between 1 and 20 characters.")]
            //    public string sender_country { get; set; }
            //    [RegularExpression("^[a-zA-Z0-9\\s]{0,22}$", ErrorMessage = "Parameter :: SenderTaxid :: invalid format, only allow: letters and spaces, and length has between 1 and 20 characters.")]
            //    public string sender_taxid { get; set; }
            //    [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: sender_birthdate :: invalid value: allow only date format, length 8 characters (YYYMMDD).#INVALID")]
            //    public string sender_birthdate { get; set; }
            //    [EmailAddress(ErrorMessage = "Parameter :: sender_email :: is not a valid mail.#INVALID")]
            //    public string sender_email { get; set; }

            //    private SharedModel.Models.General.ErrorModel.Error errorrow = new General.ErrorModel.Error();
            //    public SharedModel.Models.General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
            //}
            //public class Response : Request
            //{
            //    public string status { get; set; }
            //    public Int32 withholding_tax { get; set; }
            //}

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {

            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Delete
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [RegularExpression("^[0-9]*$", ErrorMessage = "Parameter :: transaction_id :: invalid format, only allow: numbers.")]
                private long? _transaction_id { get; set; }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public long? transaction_id { get { return _transaction_id == null || _transaction_id <= 0 ? -1 : _transaction_id; } set { _transaction_id = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: payout_id :: is required.")]
                [Range(1, Int64.MaxValue, ErrorMessage = "Parameter :: payout_id :: invalid value, must be greater than 0.")]
                [RegularExpression("^[0-9]*$", ErrorMessage = "Parameter :: payout_id :: invalid format, only allow: numbers.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 payout_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                private SharedModel.Models.General.ErrorModel.Error errorrow = new General.ErrorModel.Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public SharedModel.Models.General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response : Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class List
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {

                [RegularExpression("^[0-9]*$", ErrorMessage = "Parameter :: payout_id :: invalid format, only allow: numbers.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 payout_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [RegularExpression("^[0-9]*$", ErrorMessage = "Parameter :: transaction_id :: invalid format, only allow: numbers.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 transaction_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [StringLength(60, MinimumLength = 0, ErrorMessage = "Parameter :: merchant_id :: has minimun 0 characters and 60 characters maximum.#LENGTH")]
                [RegularExpression("^[a-zA-Z0-9\\s\\-]{0,60}$", ErrorMessage = "Parameter :: merchant_id :: invalid format, only allow: letters and spaces.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string merchant_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [StringLength(8, MinimumLength = 8, ErrorMessage = "Parameter :: date_from :: has 8 characters length.")]
                [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: payout_date :: invalid value: allow only date format, length 8 characters (YYYMMDD).")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string date_from { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [StringLength(8, MinimumLength = 8, ErrorMessage = "Parameter :: date_to :: has 8 characters length.")]
                [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: payout_date :: invalid value: allow only date format, length 8 characters (YYYMMDD).")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string date_to { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                private SharedModel.Models.General.ErrorModel.Error errorrow = new General.ErrorModel.Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public SharedModel.Models.General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response //: Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 transaction_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string beneficiary_document_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string beneficiary_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string bank_account_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string bank_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string bank_branch { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public long iof_tax { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string beneficiary_account_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public long amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string transaction_date { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string merchant_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string concept_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string currency { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string status_detail { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 exchange_rate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string submerchant_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string sender_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string sender_address { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string sender_state { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string sender_country { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string sender_taxid { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string sender_birthdate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string sender_email { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string sender_phone_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string beneficiary_phone_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class DownloadLotBatchTransactionToBank
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int PaymentType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string idMerchant { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string idSubMerchant { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string dateTo { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int Rows { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string[] Lines { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string StatusMessage { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string FileBase64 { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int idLotOut { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class ExcelResponse
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public List<ExcelFastcash> transactions { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string StatusMessage { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string FileBase64 { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int idLotOut { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class ExcelFastcash
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string TID { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Payment Date")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string PaymentDate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Bank Number")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string BankNumber { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Bank Branch")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string BankBranch { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Bank Account Number")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string BankAccountNumber { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Bank Account Type")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string BankAccountType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Beneficiary Name")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string BeneficiaryName { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Beneficiary Document")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string BeneficiaryDocument { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Customer Name")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string CustomerName { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Customer Email")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string CustomerEmail { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Customer Document")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string CustomerDocument { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Description("Customer MobilePhone")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string CustomerMobilePhone { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Description { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class ExcelFastcashResponse : ExcelFastcash 
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            { 
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Success { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Message { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class ExcelPluralResponse 
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string ID_LIQDC { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string DT_LIQDC { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string ID_BANCO_DOC { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string NOME_BANCO { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string NUM_AGENCIA_DOC { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string NUM_CC_DOC { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string NOME_PESSOA { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string CPF_CGC_PESSOA { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string VLR { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string OBSERVACAO { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string SITUACAO { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string MOTIVO_DEVOLUCAO { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class UploadTxtFromBank
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string File { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int CurrencyFxClose { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int Rows { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string[] Lines { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string StatusMessage { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string FileBase64 { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public BatchLotDetail BatchLotDetail { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                private List<TransactionDetail> _TransactionDetail = new List<TransactionDetail>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public List<TransactionDetail> TransactionDetail { get { return _TransactionDetail; } set { _TransactionDetail = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class BatchLotDetail
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string InternalStatus { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string InternalStatusDescription { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class TransactionDetail
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Ticket { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public DateTime TransactionDate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public decimal Amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Currency { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 LotNumber { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string LotCode { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Recipient { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string RecipientId { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string RecipientCUIT { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string RecipientCBU { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string RecipientAccountNumber { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public DateTime AcreditationDate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Description { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string InternalDescription { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string ConceptCode { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string BankAccountType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string EntityIdentificationType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string InternalStatus { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string InternalStatusDescription { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string idEntityUser { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string TransactionId { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string StatusCode { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class DownloadPayOutBankTxt
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public enum FileType
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [Description("*H2")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                H2 = 1,
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Description("*P2")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                P2 = 2
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public enum CurrencyType
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [Description("$")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                ARS = 1,
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Description("U$S")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                DOLAR = 2
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public enum PayType
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [Description("Pago de Haberes")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                PAGO_DE_HABERES = 1,
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Description("Pago a Proveedores")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                PAGO_A_PROVEEDORES = 2
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Header
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                /* string part :: from: 1 | to: 3 | length: 3 */
                [Required(ErrorMessage = "Parameter :: file_type :: is required.")]
                [RegularExpression("^[*H2|*P2]{3}$", ErrorMessage = "Parameter :: file_type :: invalid format, only allow: one number: '1' – Payroll payments, '2' – Suppliers payments.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string file_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                ///* string part :: from: 4 | to: 9 | length: 6 */
                [Required(ErrorMessage = "Parameter :: business_code :: is required.")]
                [RegularExpression("^[0-9]{6,6}$", ErrorMessage = "Parameter :: business_code :: invalid format, only allow: numbers, length 6 characters.")]
                public string business_code { get; set; }
                /* string part :: from: 10 | to: 20 | length: 11 */
                [Required(ErrorMessage = "Parameter :: business_cuit :: is required.")]
                [RegularExpression("^[0-9]{11,11}$", ErrorMessage = "Parameter :: business_cuit :: invalid format, only allow: numbers, length 11 digits.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string business_cuit { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                /* string part :: from: 21 | to: 21 | length: 1 */
                [RegularExpression("^[A|C|\\s]{1}$", ErrorMessage = "Parameter :: account_type :: invalid format, only allow 1 letter or 1 space: 'A' ==> Caja de Ahorro | 'C' ==> Cuenta Corriente | ' '.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string account_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                /* string part :: from: 22 | to: 22 | length: 1 */
                [Required(ErrorMessage = "Parameter :: currency_type :: is required.")]
                //[RegularExpression("^[$]{1}$|^[U$S]{3}$", ErrorMessage = "Parameter :: currency_type :: invalid format, only allow: one of two digits: $ | U$S.")]
                [RegularExpression("^[1-2]{1}$", ErrorMessage = "Parameter :: currency_type :: invalid format, only allow: one of two digits: 1: $ | 2: U$S.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string currency_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                ///* string part :: from: 23 | to: 34 | length: 12 */
                private string pri_account_debit { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string account_debit
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    get
                    {
                        string format_str = "000000000000";
                        Regex regex = new Regex("^[0-9]{12,12}$");
                        Match match = regex.Match(pri_account_debit);
                        return string.IsNullOrEmpty(pri_account_debit) || !match.Success ? format_str : pri_account_debit;
                    }
                    set
                    {
                        pri_account_debit = value;
                    }
                }
                ///* string part :: from: 35 | to: 60 | length: 26 */
                private string pri_cbu { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string cbu
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    get
                    {
                        string format_str = "00000000000000000000000000";
                        Regex regex = new Regex("^[0-9]{26,26}$");
                        Match match = regex.Match(pri_account_debit);
                        return string.IsNullOrEmpty(pri_cbu) || !match.Success ? format_str : pri_cbu;
                    }
                    set
                    {
                        pri_cbu = value;
                    }
                }
                ///* string part :: from: 61 | to: 74 | length: 14 */
                [Required(ErrorMessage = "Parameter :: total_amount :: is required.")]
                [RegularExpression("^[0-9]{14,14}$", ErrorMessage = "Parameter :: total_amount :: invalid format, only allow: numbers, length 14 digits.")]
                public string total_amount { get; set; }
                ///* string part :: from: 75 | to: 82 | length: 8 */
                [Required(ErrorMessage = "Parameter :: availability_date :: is required.")]
                [RegularExpression("^((19|20)\\d{2})((0|1)\\d{1})((0|1|2)\\d{1})", ErrorMessage = "Parameter::availability_date :: invalid format, format: AAAAMMDD.")]
                public string availability_date { get; set; }
                /* string part :: from: 83 | to: 150 | length: 68 */
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string filler { get { return "                                                                    "; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                private SharedModel.Models.General.ErrorModel.Error errorrow = new General.ErrorModel.Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public SharedModel.Models.General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string FormatLine()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    return file_type + business_code + business_cuit + account_type + currency_type + account_debit + cbu + total_amount + availability_date + filler;
                }
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Body
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [Required(ErrorMessage = "Parameter :: beneficiary_name :: is required.")]
                [RegularExpression("^[A-Z\\s]{16,16}$", ErrorMessage = "Parameter :: beneficiary_name :: invalid format, only allow: letters and spaces, length 16 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string beneficiary_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: beneficiary_cuit :: is required.")]
                [RegularExpression("^[0-9]{11,11}$", ErrorMessage = "Parameter :: beneficiary_cuit :: invalid format, only allow: numbers, length 11 digits.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string beneficiary_cuit { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: availability_date :: is required.")]
                [RegularExpression("^((19|20)\\d{2})((0|1)\\d{1})((0|1|2)\\d{1})", ErrorMessage = "Parameter::availability_date :: invalid format, format: AAAAMMDD.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string availability_date { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: account_type :: is required.")]
                [RegularExpression("^[C|A]{1}$", ErrorMessage = "Parameter :: account_type :: invalid format, only allow: one letter 'A': Caja de Ahorro | 'C': Cuenta corriente.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string account_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: currency_type :: is required.")]
                [RegularExpression("^[1-2]{1}$", ErrorMessage = "Parameter :: currency_type :: invalid format, only allow: one of two digits: 1: $ | 2: U$S.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string currency_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [RegularExpression("^[0-9]{12}$", ErrorMessage = "Parameter :: account_number :: invalid format, only allow: numbers: length 12 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string account_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [RegularExpression("^[0-9]{26}$", ErrorMessage = "Parameter :: cbu :: invalid format, only allow: numbers: length 26 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string cbu { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: transaction_code :: is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string transaction_code { get { return "32"; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: pay_type :: is required.")]
                [RegularExpression("^[1-2]{1}$", ErrorMessage = "Parameter :: pay_type :: invalid format, only allow: one number: 1: Pago de Haberes | 2: Pago a Proveedores.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string pay_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: amount :: is required.")]
                [RegularExpression("^[0-9]{14}$", ErrorMessage = "Parameter :: amount :: invalid format, only allow: numbers: length 14 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                private string pri_legend { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string legend
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    get
                    {
                        string format_str = "               ";
                        Regex regex = new Regex("^[a-zA-Z0-9\\s]{15}$");
                        Match match = regex.Match(pri_legend == null ? format_str : pri_legend);
                        return string.IsNullOrEmpty(pri_legend) || !match.Success ? format_str : pri_legend;
                    }
                    set
                    {
                        pri_legend = value;
                    }
                }
                private string pri_internal_identifiaction { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string internal_identification
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    get
                    {
                        string format_str = "                      ";
                        Regex regex = new Regex("^[a-zA-Z0-9\\s]{22}$");
                        Match match = regex.Match(pri_internal_identifiaction == null ? format_str : pri_internal_identifiaction);
                        return string.IsNullOrEmpty(pri_internal_identifiaction) || !match.Success ? format_str : pri_internal_identifiaction;
                    }
                    set
                    {

                        pri_internal_identifiaction = value;
                    }
                }
                private string pri_process_date { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string process_date
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    get
                    {
                        string format_str = "        ";
                        Regex regex = new Regex("^((19|20)\\d{2})((0|1)\\d{1})((0|1|2)\\d{1})");
                        Match match = regex.Match(pri_process_date == null ? format_str : pri_process_date);
                        return string.IsNullOrEmpty(pri_process_date) || !match.Success ? format_str : pri_process_date;
                    }
                    set
                    {
                        pri_process_date = value;
                    }
                }
                private string pri_concept_code { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string concept_code
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    get
                    {
                        string format_str = "  ";
                        Regex regex = new Regex("^[01]{2}$|^[02]{2}$|^[03]{2}$|^[04]{2}$|^[05]{2}$|^[06]{2}$|^[07]{2}$|^[08]{2}$|^[09]{2}$|^[10]{2}$|^[11]{2}$|^[12]{2}$|^[\\s\\s]{2}$");
                        Match match = regex.Match(pri_concept_code == null ? format_str : pri_concept_code);
                        return string.IsNullOrEmpty(pri_concept_code) || !match.Success ? format_str : pri_concept_code;
                    }
                    set
                    {
                        pri_concept_code = value;
                    }
                }
                private string pri_payment_to_commerce { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string payment_to_commerce
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    get
                    {
                        string format_str = "  ";
                        Regex regex = new Regex("^[PC]{2}$");
                        Match match = regex.Match(pri_payment_to_commerce == null ? format_str : pri_payment_to_commerce);
                        return string.IsNullOrEmpty(pri_payment_to_commerce) || !match.Success ? format_str : pri_payment_to_commerce;
                    }
                    set
                    {
                        pri_payment_to_commerce = value;
                    }
                }
                internal virtual string filler { get { return "         "; } }
                private SharedModel.Models.General.ErrorModel.Error errorrow = new General.ErrorModel.Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public SharedModel.Models.General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string FormatLine()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    return beneficiary_name + beneficiary_cuit + availability_date + account_type + currency_type + account_number + cbu + transaction_code + pay_type + amount + legend + internal_identification + process_date + concept_code + payment_to_commerce + filler;
                }
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Footer
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string registry_type { get { return "*F"; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: business_code :: is required.")]
                [RegularExpression("^[0-9]{6,6}$", ErrorMessage = "Parameter :: business_code :: invalid format, only allow: numbers, length 6 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string business_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: total_rows :: is required.")]
                [RegularExpression("^[0-9]{7,7}$", ErrorMessage = "Parameter :: total_rows :: invalid format, only allow: numbers, length 7 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string total_rows { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                internal virtual string filler { get { return "                                                                                                                                       "; } }
                private SharedModel.Models.General.ErrorModel.Error errorrow = new General.ErrorModel.Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public SharedModel.Models.General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string FormatLine()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
                    return registry_type + business_code + total_rows + filler;
                }
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class ErrorsCreateLog
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string idTransactionType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string idEntityUser { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string beneficiaryName { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string typeOfId { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string beneficiaryId { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string cbu { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string bankCode { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string accountType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string accountNumber { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string paymentDate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string submerchantCode { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string currency { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string merchantId { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string beneficiaryAddress { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string beneficiaryCity { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string beneficiaryCountry { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string beneficiaryEmail { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string beneficiaryBirthdate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string errors { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class ClientBalance
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string merchant { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string current_balance { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string trx_in_progress_amt { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string trx_in_progress_cnt { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string balance_after_execution { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string trx_received_amt { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string trx_received_cnt { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }
    }
}
