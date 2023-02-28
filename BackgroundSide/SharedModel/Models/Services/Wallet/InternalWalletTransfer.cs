using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModel.Models.Services.Wallet
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class InternalWalletTransfer
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

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 customer_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter :: amount :: is required.")]
                //[Range(000000001, 100000000, ErrorMessage = "Parameter :: amount :: value out range [000000001 - 100000000].")]
                //[RegularExpression("^[0-9]{9}$", ErrorMessage = "Parameter :: amount :: invalid format, only allow: numbers.")] 
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 transaction_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                [Required(ErrorMessage = "Parameter :: currency :: is required.")]
                [RegularExpression("^[ARS|USD]{3}$", ErrorMessage = "Parameter :: currency :: invalid format, only allow codes: 'ARS' | 'USD'.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string currency { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string credit_tax { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                private string _payout_date { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string payout_date { get { return _payout_date == null || string.IsNullOrEmpty(_payout_date) ? DateTime.Now.ToString("yyyyMMdd") : _payout_date; } set { _payout_date = value; } }
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
                public Int64 transactionLot_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
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
                //[Required(ErrorMessage = "Parameter :: transaction_id :: is required.")]
                [RegularExpression("^[0-9]$", ErrorMessage = "Parameter :: transaction_id :: invalid format, only allow: numbers.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Int64 transaction_id { get; set; }
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

    }
}
