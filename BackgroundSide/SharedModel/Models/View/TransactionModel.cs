using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SharedModel.Models.View
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class TransactionModel
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Transaction
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [Required(ErrorMessage = "Parameter action_type is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int idTransactionType;
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter action_type is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public String TransactionTypeCode;
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter amount is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public decimal Amount;
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter client is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int idEntityUser;
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter currency is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int idCurrencyType;
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter description is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Description;
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int ValueFX;
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

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string status_message { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Close
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [Required(ErrorMessage = "Parameter :: value :: is required.")]
                [RegularExpression("(^[0-9]{1,4})+\\.+([0-9]{0,6})$", ErrorMessage = "Parameter :: value :: invalid value.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string value { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter :: ListID :: is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public long[] transactions { get; set; }
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
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string status_message { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class TransactionLot 
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string User { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Merchant { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int TotalTransactions { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public decimal TotalAmount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string CurrencyType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public DateTime LotDate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Country { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

        }
    }
}
