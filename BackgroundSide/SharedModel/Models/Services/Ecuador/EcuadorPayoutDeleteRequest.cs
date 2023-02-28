using System;
using System.ComponentModel.DataAnnotations;

namespace SharedModel.Models.Services.Ecuador
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class EcuadorPayoutDeleteRequest
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

        private General.ErrorModel.Error errorrow = new General.ErrorModel.Error();

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }
}