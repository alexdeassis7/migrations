using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
using System.Text.RegularExpressions;

namespace SharedModel.ValidationsAttrs.Mexico
{
    /// <summary>
    /// <inheritdoc/> 
    /// </summary>
    public class BeneficiaryAccountNumberAttribute : ValidationAttribute

    {
        Dictionary<int, int> peso = new Dictionary<int, int>() {
            {0, 3 },
            {1, 7 },
            {2, 1 }
        };

        /// <summary>
        /// <inheritdoc/> 
        /// </summary>
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            string membername = validationContext.MemberName;
            try
            {
                if (value == null)
                {
                    return null;
                }
                string clabe = value as string;
                
                object instance = validationContext.ObjectInstance;
                Type type = instance.GetType();
                PropertyInfo bankAccountType = type.GetProperty("bank_account_type");
                object bankAccountTypeValue = bankAccountType.GetValue(instance);

                if (bankAccountType == null || bankAccountTypeValue == null)
                {
                    return null;
                }

                //Validar que el tipo de cuenta sea 'A' Caja de Ahorro ó 'C' Cuenta Corriente
                if (bankAccountTypeValue.ToString() == "A" || bankAccountTypeValue.ToString() == "C")
                {
                    if (type.GetProperty("bank_code").GetValue(instance).ToString() != clabe.Substring(0, 3))
                    {
                        return new ValidationResult(ErrorMessage = "Parameter :: beneficiary_account_number :: invalid format: The account number and the bank code do not match.", new string[] { membername });
                    }

                    Regex expresion = new Regex("^[0-9]{18}$"); //VALIDA QUE SU LONGITUD MAXIMA SEA DE 18 CARACTERES
                    if (!expresion.IsMatch(clabe.ToString()))
                    {
                        return new ValidationResult(ErrorMessage = "Parameter :: beneficiary_account_number :: invalid format: numbers 0 beetwen 9 and length has 18 numeric characters.", new string[] { membername });
                    }
                    // Validar Control de Digito Clabe
                    string realCheckSum = ComputeCheckSum(clabe.Substring(0, 17));
                    string sentCheckSum = clabe.Substring(17, 1);

                    if (realCheckSum == sentCheckSum)
                    {
                        return ValidationResult.Success;
                    }
                }

                //Validar que el tipo de cuenta sea 'D' Tarjeta Débito
                if (bankAccountTypeValue.ToString() == "D")
                {
                    Regex expresion = new Regex("^[0-9]{16}$"); //VALIDA QUE SU LONGITUD MAXIMA SEA DE 16 CARACTERES
                    if (!expresion.IsMatch(clabe.ToString()))
                    {
                        return new ValidationResult(ErrorMessage = "Parameter :: beneficiary_account_number :: invalid format: numbers 0 beetwen 9 and length has 16 numeric characters.", new string[] { membername });
                    }
                }

                //Validar que el tipo de cuenta sea 'P' Cuenta Celular
                if (bankAccountTypeValue.ToString() == "P")
                {
                    Regex expresion = new Regex("^[0-9]{10}$"); //VALIDA QUE SU LONGITUD MAXIMA SEA DE 10 CARACTERES
                    if (!expresion.IsMatch(clabe.ToString()))
                    {
                        return new ValidationResult(ErrorMessage = "Parameter :: beneficiary_account_number :: invalid format: numbers 0 beetwen 9 and length has 10 numeric characters.", new string[] { membername });
                    }
                }

                
            }
            catch(Exception ex)
            {
                return new ValidationResult(ErrorMessage = ex.Message, new string[] { membername });
            }

            return ValidationResult.Success;

            //if (value == null)
            //{
            //    return null;
            //}

            

            //if (bankAccountType == null || bankAccountTypeValue == null)
            //{
            //    return null;
            //}

            

        }

        /// <summary>
        /// <inheritdoc/>
        /// </summary>
        public string ComputeCheckSum(string clabe)

        {
            return Compute(clabe).ToString();
        }

        /// <summary>
        /// <inheritdoc/>
        /// </summary>
        public int Add(int sum, int digit, int i)
        {
            return (digit * peso[i % 3]) % 10;
        }

        /// <summary>
        /// <inheritdoc/> 
        /// </summary>
        public int Compute(string clabe)
        {
            int i = 0;
            int sum = 0;
            foreach (char clabeChar in clabe)
            {
                sum += Add(0, Int16.Parse(clabeChar.ToString()), i);
                i++;
            }
            return (10 - sum % 10) % 10;
        }
    }
}
