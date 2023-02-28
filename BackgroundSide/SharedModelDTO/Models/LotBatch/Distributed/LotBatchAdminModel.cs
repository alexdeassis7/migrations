using System;

namespace SharedModelDTO.Models.LotBatch.Distributed
{
    public class LotBatchAdminModel : LotBatchModel
    {
        #region Properties::Public
#pragma warning disable CS0108 // El miembro oculta el miembro heredado. Falta una contraseña nueva
        public string CustomerName { get; set; }
#pragma warning restore CS0108 // El miembro oculta el miembro heredado. Falta una contraseña nueva
        public string Commissions { get; set; }
        public string Vat { get; set; }
        public string BankCost { get; set; }
        public string BankCostVat { get; set; }
        public string GrossRevenuePerception { get; set; }
        public string TaxDebit { get; set; }
        public string TaxCredit { get; set; }
        public string Rounding { get; set; }
        public string PayVat { get; set; }
        public string BankBalance { get; set; }
#pragma warning disable CS0108 // El miembro oculta el miembro heredado. Falta una contraseña nueva
        public string TransactionType { get; set; }
#pragma warning restore CS0108 // El miembro oculta el miembro heredado. Falta una contraseña nueva

#pragma warning disable CS0108 // El miembro oculta el miembro heredado. Falta una contraseña nueva
        public string Status { get; set; }
#pragma warning restore CS0108 // El miembro oculta el miembro heredado. Falta una contraseña nueva
        #endregion

        #region Methods::Public
        public override void Create() { }
        public override void Update() { }
        public override void Delete(Int64 id) { }
        public override void List() { }
        #endregion
    }
}
