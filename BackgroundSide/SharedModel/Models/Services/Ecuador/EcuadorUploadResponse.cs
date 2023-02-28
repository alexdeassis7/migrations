using System.Collections.Generic;

namespace SharedModel.Models.Services.Ecuador
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class EcuadorUploadResponse
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
        public EcuadorBatchLotDetail BatchLotDetail { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        private List<EcuadorTransactionDetail> _TransactionDetail = new List<EcuadorTransactionDetail>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public List<EcuadorTransactionDetail> TransactionDetail { get { return _TransactionDetail; } set { _TransactionDetail = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

    }
}