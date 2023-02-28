using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Reflection;

namespace SharedModel.ValidationsAttrs.Uruguay
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class BankAccountAttribute : ValidationAttribute
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Dictionary<string, int> BankAccountsLength = new Dictionary<string, int>() {
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            { "1001", 14 }, // BROU
            { "1091", 10 }, // Hipotecario
            { "1205", 10 }, // Citibank
            { "1110", 9 },  // Bandes 
            { "1113", 7 },  // ITAU
            { "1128", 10 }, // Scotiabank
            { "1137", 19 }, // Santander
            { "1246", 12 }, // Nacion
            { "1153", 9 },  // BBVA
            { "1157", 10 }, // HSBC
            { "1162", 9 },  // Heritage
            { "1361", 7 },  // BAPRO
            { "7905", 8 }   // FORTEX
        };
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string bankAccount = value as string;

            bool flag = false;
            object instance = validationContext.ObjectInstance;
            Type type = instance.GetType();
            PropertyInfo property = type.GetProperty("bank_code");
            object propertyValue = property.GetValue(instance) == null ? "" : property.GetValue(instance);

            switch (propertyValue)
            {
                case "1153": // BBVA
                    flag = (bankAccount.Length <= BankAccountsLength[propertyValue.ToString()]);
                    break;
                case "1137": // Santander
                    flag = (bankAccount.Length <= BankAccountsLength[propertyValue.ToString()]);
                    break;
                default:
                    if (BankAccountsLength.ContainsKey(propertyValue.ToString()))
                    {
                        flag = (bankAccount.Length == BankAccountsLength[propertyValue.ToString()]);
                    }
                    break;
            }

            if (flag)
            {
                return ValidationResult.Success;
            }

            string membername = validationContext.MemberName;
            return new ValidationResult(ErrorMessage = ErrorMessage, new string[] { membername });
        }
    }
}
