using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SharedModel.Models.Services.CashPayments
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class CashPaymentModel
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Create
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [Required(ErrorMessage = "Parameter :: invoice :: is required.")]
                [RegularExpression("^[a-zA-Z0-9.-_\\s]{12,12}$", ErrorMessage = "Parameter :: invoice :: invalid format: allow only numbers, length 12 digits.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string invoice { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: payment_method :: is required.")]
                [RegularExpression("^(RAPA)$|^(PAFA)$|^(BAPR)|^(COEX)$", ErrorMessage = "Parameter :: payment_method :: invalid value: [RAPA: RapiPago | PAFA: PagoFacil | BAPR: Bapro | COEX: CobroExpress].")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string payment_method { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: additional_info :: is required.")]
                [RegularExpression("^[a-zA-Z0-9.-_\\s]{1,30}$", ErrorMessage = "Parameter :: additional_info :: invalid value: alphanumeric [a-zA-Z0-9.-_ ], lenggth between 1 - 30 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string additional_info { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: first_expiration_amount :: is required.")]
                //[Range(00000100, 99999999, ErrorMessage = "Parameter :: first_expiration_amount :: invalid value: allow only numbers, length 8 characters (6e + 2d) and range between 00000100 and 99999999.")]
                [StringLength(8, MinimumLength = 8, ErrorMessage = "Parameter :: first_expiration_amount :: invalid value: allow only numbers, length 8 characters (6e + 2d) and range between 00000100 and 99999999.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string first_expiration_amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: first_expirtation_date :: is required.")]
                [RegularExpression("([12]\\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01]))", ErrorMessage = "Parameter :: first_expirtation_date :: invalid value: allow only date format, length 8 characters (YYYMMDD).")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string first_expirtation_date { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: currency :: is required.")]
                //[RegularExpression("^(ARS)$", ErrorMessage = "Parameter :: currency :: invalid value: value must be: ARS.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string currency { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: surcharge :: is required.")]
                [Range(0000000, 99999999, ErrorMessage = "Parameter :: surcharge :: invalid value: allow only numbers, length 8 characters (6e + 2d) and range between 00000100 and 99999999, if payment_method in [RAPA | PAFA | COEX] the length must be: 6 digits (4e + 2d).")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string surcharge { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: days_to_second_exp_date :: is required.")]
                [RegularExpression("^[0-3]{1}$", ErrorMessage = "Parameter :: currency :: invalid value: value must be: 1 digit between 1 and 3.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string days_to_second_exp_date { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: identification :: is required.")]
                [RegularExpression("^(\\b(20|23|24|27|30|33|34)(\\D)?[0-9]{8}(\\D)?[0-9])$", ErrorMessage = "Parameter :: identification :: invalid value.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string identification { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter :: name :: is required.")]
                [StringLength(16, MinimumLength = 1, ErrorMessage = "Parameter :: name :: has minimun 1 characters and 16 characters maximum. ")]
                [RegularExpression("^[a-zA-Z\\s]{1,16}$", ErrorMessage = "Parameter :: name :: invalid format, only allow: letters and spaces, and length has between 1 and 16 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter :: mail :: is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string mail { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                //[Required(ErrorMessage = "Parameter :: first_name :: is required.")]
                //[RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: first_name :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
                //public string first_name { get; set; }

                //[Required(ErrorMessage = "Parameter :: last_name :: is required.")]
                //[RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: last_name :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
                //public string last_name { get; set; }

                [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ0-9\\s]{1,60}$", ErrorMessage = "Parameter :: address :: invalid format, only allow: letters, numbers and spaces, and length has between 1 and 60 characters.")]
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
                public string bar_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string transaction_id {  get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string bar_code_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string bar_code_url { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Upload
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string TransactionType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string File { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string FileName { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class ReadFile
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string Status { get; set; } /* OK | ERROR */
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string StatusMessage { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int QtyTransactionRead { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int QtyTransactionProcess { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int QtyTransactionDismiss { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            private List<TransactionResult> _TrProcessDetail = new List<TransactionResult>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public List<TransactionResult> TrProcessDetail { get { return _TrProcessDetail; } set { _TrProcessDetail = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            private List<TransactionResult> _TrDismissDetail = new List<TransactionResult>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public List<TransactionResult> TrDismissDetail { get { return _TrDismissDetail; } set { _TrDismissDetail = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class TransactionResult
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string Ticket { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string BarCodeNumber { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public double Amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }
    }
}
