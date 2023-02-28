using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.Reflection;

namespace SharedModel.ValidationsAttrs.Peru
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class BankAccountAttribute : ValidationAttribute
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Dictionary<string, int> BankAccountsLength = new Dictionary<string, int>() {
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            { "1", 14 }, // BANCO AZTECA DEL PERU, S.A.
            { "2", 15 }, // BANCO BBVA PERU 
            { "3", 10 }, // BANCO CENTRAL DE RESERVA DEL PERU
            { "4", 9 },  // BANCO DE COMERCIO 
            { "5", 7 },  // BANCO DE CREDITO DEL PERU
            { "6", 10 }, // BANCO DE LA NACION
            { "7", 19 }, // BANCO GNB PERU SA
            { "8", 12 }, // BANCO INTERAMERICANO DE FINANZAS
            { "9", 9 },  // BANCO INTERNACIONAL DEL PERU (INTERBANK)
            { "10", 10 }, // BANCO PICHINCHA
            { "11", 9 },  // BANCO SANTANDER PERU S.A.
            { "12", 7 },  // BANK OF CHINA (PERU) S.A.
            { "13", 8 },   // CAMPOSOL
            { "14", 8 },   // CAVALI S.A. I.C.L.V.
            { "15", 8 },   // CETCO S.A.
            { "16", 8 },   // CITIBANK DEL PERU S.A.
            { "17", 8 },   // CORPORACION ANDINA DE FOMENTO
            { "18", 8 },   // CORPORACION FINANCIERA DE DESARROLLO S.A. - COFIDE
            { "19", 8 },   // ENEL GENERACION PERU S.A.A.
            { "20", 8 },   // ICBC PERU BANK
            { "21", 8 },   // JP MORGAN BANCO DE INVERSION
            { "22", 8 }    // SCOTIABANK PERU S.A.A.

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
                case "5": // BPC
                    flag = (bankAccount.Length <= BankAccountsLength[propertyValue.ToString()]);
                break;
                default:
                    if (BankAccountsLength.ContainsKey(propertyValue.ToString())) { 
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
