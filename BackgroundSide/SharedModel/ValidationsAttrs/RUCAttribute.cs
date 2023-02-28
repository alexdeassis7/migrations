using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Reflection;
using System.Text.RegularExpressions;

namespace SharedModel.ValidationsAttrs
{
    class RUCAttribute : ValidationAttribute
    {
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
          

            
                string document = value as string;
                string membername = validationContext.MemberName;
            try
            {
                object instance = validationContext.ObjectInstance;
                Type type = instance.GetType();
                PropertyInfo property = type.GetProperty("beneficiary_document_type");
                object propertyValue = property.GetValue(instance);

                if(propertyValue == null)
                {
                    return new ValidationResult(ErrorMessage = "Parameter::beneficiary_document_id :: invalid.#INVALID", new string[] { membername });
                }

                if ((propertyValue.ToString() == "LE" || propertyValue.ToString() == "DNI"))
                {
                    Regex expresion = new Regex("^[0-9]{8}$"); //VALIDA QUE SEA NUMERICO Y QUE TENGA UN MAXIMO DE 8 CARACTERES
                    if (!expresion.IsMatch(document.ToString()))
                    {
                        return new ValidationResult(ErrorMessage = "Parameter :: beneficiary_document_id :: invalid format: only allow numbers and length has 8 characters.#INVALID", new string[] { membername });
                    }
                }
            
                if ((propertyValue.ToString() == "RUC"))
                {
                    Regex expresion = new Regex("^[0-9]{11}$"); //VALIDA QUE SEA NUMERICO Y QUE TENGA UN MAXIMO DE 11 CARACTERES
                    if (!expresion.IsMatch(document.ToString()))
                    {
                        return new ValidationResult(ErrorMessage = "Parameter :: beneficiary_document_id :: invalid format: only allow numbers and length has 11 characters.#INVALID", new string[] { membername });
                    }
                }
            
                if ((propertyValue.ToString() == "CE" || propertyValue.ToString() == "PASS"))
                {
                    Regex expresion = new Regex("^[0-9A-Za-z]{4,12}$"); //VALIDA QUE SEA ALFA NUMERICO Y QUE TENGA UN MAXIMO ENTRE 4 Y 12 CARACTERES
                    if (!expresion.IsMatch(document.ToString()))
                    {
                        return new ValidationResult(ErrorMessage = "Parameter :: beneficiary_document_id :: invalid format: only allow alphanumeric and length has between 4 and 12 characters.#INVALID", new string[] { membername });
                    }
                }

                  return ValidationResult.Success;
            }
            catch (Exception)
            {

               return new ValidationResult(ErrorMessage = "Parameter :: beneficiary_document_id :: invalid.#INVALID", new string[] { membername });
            }
        }

    }
}
