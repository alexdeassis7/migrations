using System.Collections.Generic;

namespace SharedModel.Models.Services.Paraguay
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class ParaguayUploadResponse
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
        public ParaguayBatchLotDetail BatchLotDetail { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        private List<ParaguayTransactionDetail> _TransactionDetail = new List<ParaguayTransactionDetail>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public List<ParaguayTransactionDetail> TransactionDetail { get { return _TransactionDetail; } set { _TransactionDetail = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

    }
}