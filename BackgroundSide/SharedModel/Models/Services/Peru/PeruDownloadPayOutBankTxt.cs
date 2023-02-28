using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace SharedModel.Models.Services.Peru
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class PeruDownloadPayOutBankTxt
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
}
