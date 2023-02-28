using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModel.Models.Services.Peru
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public  class PeruPayoutUpdateRequest
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        [Required(ErrorMessage = "Parameter :: transaction_id :: is required.")]
        [RegularExpression("^[0-9]*$", ErrorMessage = "Parameter :: transaction_id :: invalid format, only allow: numbers.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Int64 transaction_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: payout_id :: is required.")]
        [RegularExpression("^[0-9]*$", ErrorMessage = "Parameter :: payout_id :: invalid format, only allow: numbers.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Int64 payout_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: type_of_id :: is required.")]
        [StringLength(1, MinimumLength = 1, ErrorMessage = "Parameter :: type_of_id :: has 1 character length.")]
        [RegularExpression("^[1-5]{1}$", ErrorMessage = "Parameter :: type_of_id :: invalid format, only characters available: '1' - Cédula de ciudadanía '2' - Cédula de extranjería, '3' - NIT, '4' - Tarjeta de identidad, '5' - Pasaporte.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string type_of_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: id :: is required.")]
        [StringLength(15, MinimumLength = 1, ErrorMessage = "Parameter :: id :: has 1 minimum characters length and maximum 15 characters length.")] //ver minimum
        [RegularExpression("^[0-9]{1,15}$", ErrorMessage = "Parameter :: id :: invalid length, must be only numbers and between 1 and 15 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: beneficiary_name :: is required.")]
        [StringLength(60, MinimumLength = 1, ErrorMessage = "Parameter :: beneficiary_name :: has minimun 1 characters and 60 characters maximum. ")]
        [RegularExpression("^[a-zA-Z0-9\\s]{1,60}$", ErrorMessage = "Parameter :: beneficiary_name :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: account_type :: is required.")]
        [StringLength(2, MinimumLength = 2, ErrorMessage = "Parameter :: account_type :: has 2 characters length.")]
        [RegularExpression("^[27|37]{2}$", ErrorMessage = "Parameter :: account_type :: invalid format, only characters available: '27' – checking account, '37' – savings account.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string account_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: bank_code :: is required.")]
        
#pragma warning disable CS1587 // El comentario XML no está situado en un elemento válido del idioma
///*ver*/[RegularExpression("^[1001-1507]{4}$", ErrorMessage = "Parameter :: bank_code :: invalid format, only allow Colombia bank codes.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string bank_code { get; set; }
#pragma warning restore CS1587 // El comentario XML no está situado en un elemento válido del idioma
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: beneficiary_account_number :: is required.")]
        [StringLength(20, MinimumLength = 4, ErrorMessage = "Parameter :: beneficiary_account_number :: has minimum 4 characters and maximum 20 characters length.")]
        //[RegularExpression("^[0-9]$", ErrorMessage = "Parameter :: beneficiary_account_number :: invalid format, only allow: numbers and length has 20 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_account_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: amount :: is required.")]
        [Range(100, 100000000, ErrorMessage = "Parameter :: amount :: value out range [100 - 100000000].")]
        [RegularExpression("^[0-9]{3,9}$", ErrorMessage = "Parameter :: amount :: invalid length, must be between 3 and 9 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Int64 amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: beneficiary_softd :: is required.")]
        [StringLength(15, MinimumLength = 0, ErrorMessage = "Parameter :: beneficiary_softd :: has minimun 0 characters and 15 characters maximum.")]
        [RegularExpression("^[a-zA-Z\\s]{0,15}$", ErrorMessage = "Parameter :: beneficiary_softd :: invalid format, only allow: letters and spaces.")]
        private string _beneficiary_softd { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string beneficiary_softd { get { return string.IsNullOrEmpty(_beneficiary_softd) ? "" : _beneficiary_softd; } set { _beneficiary_softd = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: site_transaction_id :: is required.")]
        [StringLength(22, MinimumLength = 0, ErrorMessage = "Parameter :: site_transaction_id :: has minimun 0 characters and 22 characters maximum.")]
        [RegularExpression("^[a-zA-Z0-9\\s]{0,22}$", ErrorMessage = "Parameter :: site_transaction_id :: invalid format, only allow: letters and spaces.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string site_transaction_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [StringLength(4, MinimumLength = 0, ErrorMessage = "Parameter :: concept_code :: has minimum 0 and 4 characters maximum.#LENGTH")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string concept_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: currency :: is required.")]
        [RegularExpression("^[ARS|USD|BRL|EUR|UYU|COP|PYG]{3}$", ErrorMessage = "Parameter :: currency :: invalid format, only allow codes: 'ARS' | 'USD' | 'BRL' | 'EUR' | 'UYU' | 'COP' | 'PYG'.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string currency { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: payout_date :: is required.")]
        [StringLength(8, MinimumLength = 8, ErrorMessage = "Parameter :: payout_date :: has 8 characters length.")]
        [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: payout_date :: invalid value: allow only date format, length 8 characters (YYYMMDD).")]
        private string _payout_date { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string payout_date { get { return _payout_date == null || string.IsNullOrEmpty(_payout_date) ? DateTime.Now.ToString("yyyyMMdd") : _payout_date; } set { _payout_date = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [EmailAddress(ErrorMessage = "Parameter :: email :: is not a valid mail.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string email { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ0-9\\s]{1,150}$", ErrorMessage = "Parameter :: address :: invalid format, only allow: letters, numbers and spaces, and length has between 1 and 150 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string address { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: birth_date :: invalid value: allow only date format, length 8 characters (YYYMMDD).")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string birth_date { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: country :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string country { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: city :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string city { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ0-9\\s]{1,60}$", ErrorMessage = "Parameter :: annotation :: invalid format, only allow: letters, numbers and spaces, and length has between 1 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string annotation { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Parameter :: subclient_code :: is required.")]
        [StringLength(60, MinimumLength = 3, ErrorMessage = "Parameter :: subclient_code :: has minimun 3 characters and 60 characters maximum.")]
        [RegularExpression("^[a-zA-Z0-9\\s\\.-_]{3,60}$", ErrorMessage = "Parameter :: subclient_code :: invalid format, only allow numbers, letters chars [-_.] and spaces, and length should be between 3 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string subclient_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: SenderName :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ0-9\\s]{1,150}$", ErrorMessage = "Parameter :: sender_address :: invalid format, only allow: letters and spaces, and length has between 1 and 150 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_address { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,20}$", ErrorMessage = "Parameter :: SenderState :: invalid format, only allow: letters and spaces, and length has between 1 and 20 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_state { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,20}$", ErrorMessage = "Parameter :: SenderCountry :: invalid format, only allow: letters and spaces, and length has between 1 and 20 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_country { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_taxid { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: sender_birthdate :: invalid value: allow only date format, length 8 characters (YYYMMDD).")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_birthdate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [EmailAddress(ErrorMessage = "Parameter :: sender_email :: is not a valid e-mail.#INVALID")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string sender_email { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        private SharedModel.Models.General.ErrorModel.Error errorrow = new General.ErrorModel.Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public SharedModel.Models.General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }
}
