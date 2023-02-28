using System;
using System.ComponentModel.DataAnnotations;

namespace SharedModel.Models.Services.Panama
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class PanamaPayoutListRequest
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
        [RegularExpression("^[a-zA-Z0-9\\s\\-]{0,60}$", ErrorMessage = "Parameter :: merchant_id :: invalid format, only allow: letters and spaces and char - .#INVALID")]
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
}