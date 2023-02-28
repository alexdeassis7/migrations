using System.Collections.Generic;

namespace SharedModel.Models.Services.ElSalvador
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class ElSalvadorUploadResponse
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
        public ElSalvadorBatchLotDetail BatchLotDetail { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        private List<ElSalvadorTransactionDetail> _TransactionDetail = new List<ElSalvadorTransactionDetail>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public List<ElSalvadorTransactionDetail> TransactionDetail { get { return _TransactionDetail; } set { _TransactionDetail = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

    }
}