using SharedModel.Models.CrossCountry;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace SharedModel.Models.Services.Bolivia.Validation
{
    /// <summary>
    /// Predefined class Validator for Identification Numbers Type for Bolivia Country
    /// </summary>
    public class BoliviaIdentificationValidator
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Dictionary<IdentificationType, Definition> Definitions { get; private set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        /// <summary>
        /// Constructor of BoliviaIdentificationValidator
        /// </summary>
        public BoliviaIdentificationValidator() => InitializeDefinitions();

        private void InitializeDefinitions()
        {
            Definitions = new Dictionary<IdentificationType, Definition>
            {
                { IdentificationType.PASS, new Definition { MinLength = 7, MaxLength = 7, HasPatternMatching = false } },
                { IdentificationType.NIT, new Definition { MinLength = 9, MaxLength = 12, HasPatternMatching = false } },
                // E mayuscula, y 7 numeros  (Total 8 caracteres de largo) ENNNNNNN
                { IdentificationType.CE, new Definition { MinLength = 8, MaxLength = 8, HasPatternMatching = true, RegularExpression = @"^E\d{7}$" } },
                { IdentificationType.CI,  new Definition { MinLength = 7, MaxLength = 10, HasPatternMatching= false,  CustomFunction = (value) => IsValidCIIdentificationNumber(value) }}
            };
        }

        /// <summary>
        /// Validates if the Identification Number is a valid value for the related identificationType
        /// </summary>
        /// <param name="identificationType"></param>
        /// <param name="identification_id"></param>
        /// <returns></returns>
        /// <exception cref="ArgumentException"></exception>
        /// <exception cref="Exception"></exception>
        public (bool, List<(string, string)>) IsValidIdentification(int identificationType, string identification_id)
        {
            var errorValidations = new List<(string, string)>();

            ValidateInputIdentification(identificationType, identification_id);

            var idTypeEnum = (IdentificationType)identificationType;

            // Obtains a listed of well defined previous registered Definitions
            var definition = Definitions[idTypeEnum];

            // if none definition found, then throw exception
            if (definition.Equals(IdentificationType.NotDefined))
                throw new Exception("Identification Type is not valid");

            // Evaluates if the property HasPatternMatching has a valid regular expression if it's TRUE, otherwise, this will be ignored
            if (definition.HasPatternMatching && string.IsNullOrWhiteSpace(definition.RegularExpression))
                throw new Exception("Regular expression value is required when the property HasPatternMatching is true");

            // If has pattern matching
            if (definition.HasPatternMatching)
            {
                var isValid = Regex.IsMatch(identification_id, definition.RegularExpression);

                if (!isValid)
                    errorValidations.Add(("beneficiary_document_id", "has invalid value or format"));

                if (definition.CustomFunction == null)
                    return (errorValidations.Count == 0, errorValidations);
            }
            else // otherwise continue with manual
            {
                // Checking for minimun Length and Max Length
                if (identification_id.Length < definition.MinLength)
                    errorValidations.Add(("beneficiary_document_id", $"value length is lower than {definition.MinLength}"));

                if (identification_id.Length > definition.MaxLength)
                    errorValidations.Add(("beneficiary_document_id", $"value length is greater than {definition.MinLength}"));
            }

            if (definition.CustomFunction != null && !definition.CustomFunction.Invoke(identification_id))
                errorValidations.Add(("beneficiary_document_id", $"Has Invalid Value ending (Valid Are CH|LP|CB|OR|PT|TJ|SC|BE|PD)"));

            return (errorValidations.Count == 0, errorValidations);
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static int ConverToIdentificationType(string documentId)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            if (string.IsNullOrWhiteSpace(documentId))
                throw new ArgumentNullException(message: "Invalid Document Type", paramName: nameof(documentId));

            // convert documentId string to int casting enumeration
            Enum.TryParse(documentId, true, out IdentificationType identificationType);

            // ERR: EN01   (Ey Dev! it is Important!)
            // [WARNING]  ERR: EN01 (This is an internal error not for public documentation, but private)
            // Means that the value is not added inside the enumeration and because that, the default value is returned ( NotDefined = 0)
            // SOLUTION: If apply, add the enumeration inside the Enum class with the expected Value
            // TODO: Add this documentation in some place for internal documentation for the rest of the team

            return (int)identificationType;
        }

        private static void ValidateInputIdentification(int identificationType, string identification_id)
        {
            if (identificationType <= 0)
                throw new ArgumentException($"Parameter {nameof(identificationType)} cannot be null or contain whitespace", paramName: nameof(identificationType));

            if (identificationType > Convert.ToInt64(Enum.GetValues(typeof(IdentificationType)).Cast<object>().Max()))
                throw new ArgumentException($"Parameter {nameof(identificationType)} given value is not valid (Valid types are: {string.Join(", ", Enum.GetNames(typeof(IdentificationType)))})", paramName: nameof(identificationType));

            if (string.IsNullOrWhiteSpace(identification_id))
                throw new ArgumentException($"Parameter {nameof(identification_id)} cannot be null or contain whitespace", paramName: nameof(identification_id));
        }

        private static bool IsValidCIIdentificationNumber(string identification_id)
        {
            if (string.IsNullOrWhiteSpace(identification_id))
                throw new ArgumentException($"Parameter {nameof(identification_id)} cannot be null or contain whitespace", paramName: nameof(identification_id));

            switch (identification_id.Length)
            {
                case 7:
                    return Regex.IsMatch(identification_id, @"^\d{7}");
                case 9://  Este caso seria 1234567AB o AB1234567
                case 10:// Este caso seria 1234567 AB o AB 1234567  (con espacios)
                    return
                        Regex.IsMatch(identification_id, @"^\d{7}\s?[A-Z]{2}$|^[A-Z]{2}\s?\d{7}$") &&
                        Regex.IsMatch(identification_id, "(CH|LP|CB|OR|PT|TJ|SC|BE|PD)");
                default:
                    return false;
            }
        }
    }
}
