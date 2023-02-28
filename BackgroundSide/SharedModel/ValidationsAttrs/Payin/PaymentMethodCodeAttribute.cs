using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModel.ValidationsAttrs.Payin
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class PaymentMethodCodeAttribute : ValidationAttribute
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            List<string> paymentMethods = GetPaymentCodesList(validationContext);

            string paymentMethodCode = value as string;

            if(paymentMethods.IndexOf(paymentMethodCode) > -1)
            {
                return ValidationResult.Success;
            }

            string membername = validationContext.MemberName;
            return new ValidationResult(ErrorMessage = ErrorMessage, new string[] { membername });
        }

        private List<string> GetPaymentCodesList(ValidationContext validationContext)
        {
            List<string> result = (List<string>)validationContext.Items["paymentMethods"];

            return result;
        }
    }
}
