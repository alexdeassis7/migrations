using System;
using System.ComponentModel.DataAnnotations;

namespace SharedModelDTO.Models.Transaction.PayWay.PayIn.CashPayment.Distributed.Types
{
    public class PagoFacilModel : BarCodeModel
    {
        [Required(ErrorMessage = "Parameter :: Customer :: is required.")]
        [RegularExpression("^[0-9]{10}$", ErrorMessage = "Parameter :: Customer :: invalid format, only allow: numbers and length: ten digits.")]
        public override string Customer { get; set; }
        public string Currency { get { return "0"; /* DE MOMENTO ES UN UNICO DIGITO, 0 QUE ES EN PESOS. */ } }

        #region Methods::Public
        public override void Create()
        {
            base.Create();
        }
        public override void Update()
        {
            base.Update();
        }
        public override void Delete(Int64 id)
        {
            base.Delete(id);
        }
        public override void List() { }
        #endregion

        #region Methods::Barcode
        public override string CodeBarFormatNumber()
        {
            string CodeNumberWithOutCheckDigit = BusinessCode + FirstExpirationAmount + FirstExpirtationDate + Customer + Currency + SecondExpirationAmount + SecondExpirtationDate;
            string CheckDigit01 = CalculationOfTheVerifierDigit(CodeNumberWithOutCheckDigit);
            string CheckDigit02 = CalculationOfTheVerifierDigit(CodeNumberWithOutCheckDigit + CheckDigit01);

            CheckDigit = CheckDigit01 + CheckDigit02;

            string CodeNumber = CodeNumberWithOutCheckDigit + CheckDigit;

            return CodeNumber;
        }
        #endregion
    }
}
