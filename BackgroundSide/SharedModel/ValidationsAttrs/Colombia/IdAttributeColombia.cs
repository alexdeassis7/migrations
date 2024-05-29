using System;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
using System.Text.RegularExpressions;

namespace SharedModel.ValidationsAttrs
{
    class IdAttributeColombia : ValidationAttribute
    {
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            string document = value as string;
            string membername = validationContext.MemberName;
            try
            {
                object instance = validationContext.ObjectInstance;
                Type type = instance.GetType();
                PropertyInfo typeOfId = type.GetProperty("type_of_id");
                object typeOfIdValue = typeOfId.GetValue(instance);

                if (typeOfIdValue == null)
                {//si el tipo de dni el nulo lanzamos exception
                    return new ValidationResult(ErrorMessage = "Parameter::type_of_id :: invalid.#INVALID", new string[] { membername });
                }

                //segun el tipo de documento es la validacion que se aplica 
                switch (typeOfIdValue.ToString())
                {
                    case "1": // '1' - Cédula de ciudadanía 
                        if (long.Parse(document) <= 9999)
                        {//si el numero de documento es menor a 9999 se rechaza el payout 
                            return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid format: only allow numbers and length has 6 or 10 characters.#INVALID", new string[] { membername });
                        }
                        Regex expresion = new Regex("^[0-9]{6,10}$"); //VALIDA QUE SEA NUMERICO Y QUE TENGA entre 6 y 10 numeros
                        if (!expresion.IsMatch(document))
                        {
                            return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid format: only allow numbers and length has 6 or 10 characters.#INVALID", new string[] { membername });
                        }
                        break;
                    case "2": //'2' - Cédula de extranjería
                        if (long.Parse(document) <= 9999)
                        {//si el numero de documento es menor a 9999 se rechaza el payout 
                            return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid format: only allow numbers and length has 6 or 7 characters.#INVALID", new string[] { membername });
                        }
                        Regex expresion2 = new Regex("^[0-9]{6,7}$"); //VALIDA QUE SEA NUMERICO Y QUE TENGA 6 numeros
                        if (!expresion2.IsMatch(document))
                        {
                            return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid format: only allow numbers and length has 6 or 7 characters.#INVALID", new string[] { membername });
                        }
                        break;
                    case "3": // '3' - NIT
                        if (long.Parse(document) <= 9999)
                        {//si el numero de documento es menor a 9999 se rechaza el payout 
                            return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid format: only allow numbers and length has between 10 characters.#INVALID", new string[] { membername });
                        }
                        Regex expresion3 = new Regex("^(?:\\d{3}\\.\\d{3}\\.\\d{3}-\\d|\\d{10}|\\d{6}\\.\\d{4}|\\d{9}\\-\\d{1})$"); // SE VALIDAN 4 TIPOS DE FORMATO
                        //FORMATO 1 -> NNNNNNNNNN
                        //FORMATO 2 -> NNNNNNNNN-N
                        //FORMATO 3 -> NNN.NNN.NNN-N
                        //FORMATO 4 -> NNNNNN.NNNN
                        if (!expresion3.IsMatch(document))
                        {
                            return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid format: only allow numbers and length has between 10 characters.#INVALID", new string[] { membername });
                        }
                        break;
                    case "4": //'4' - Tarjeta de identidad
                        if (long.Parse(document) <= 9999)
                        {//si el numero de documento es menor a 9999 se rechaza el payout 
                            return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid format: only allow numbers and length has between 10 characters.#INVALID", new string[] { membername });
                        }
                        Regex expresion4 = new Regex("^[0-9]{10}$"); //VALIDA QUE SEA NUMERICO Y QUE TENGA 10 numeros
                        if (!expresion4.IsMatch(document))
                        {
                            return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid format: only allow numbers and length has between 10 characters.#INVALID", new string[] { membername });
                        }
                        break;
                    case "5": //'5' - Pasaporte
                        Regex expresion5 = new Regex("^[A-Za-z0-9-]{5,12}$"); //VALIDA QUE SEA Alfa NUMERICO Y QUE TENGA UN MAXIMO ENTRE 5 Y 12 numeros
                        if (!expresion5.IsMatch(document))
                        {
                            return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid format: only allow numbers and length has between 5 and 12 characters.#INVALID", new string[] { membername });
                        }
                        break;
                    default:
                        return new ValidationResult(ErrorMessage = ErrorMessage = "Parameter :: type_of_id :: invalid value, only characters available: '1' - Cédula de ciudadanía '2' - Cédula de extranjería, '3' - NIT, '4' - Tarjeta de identidad, '5' - Pasaporte.#INVALID", new string[] { membername });
                }
                return ValidationResult.Success;
            }
            catch (Exception)
            {
                return new ValidationResult(ErrorMessage = "Parameter :: id :: invalid.#INVALID", new string[] { membername });
            }
        }

    }
}
