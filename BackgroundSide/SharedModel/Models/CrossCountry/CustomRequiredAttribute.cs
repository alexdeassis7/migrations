using System;
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace SharedModel.Models.CrossCountry
{
    /// <summary>
    ///  Validates a Required Field checking (optionally) the value against a Regular Expression  and (optionally also) minimun and max length
    /// </summary>
    [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property, AllowMultiple = false, Inherited = true)]
    public class CustomRequiredAttribute : ValidationAttribute
    {
        private readonly int min;
        private readonly int max;
        private readonly string regularExpression;
        private readonly string regularExpressionError;
        private readonly bool hasRegularExpression;

        /// <summary>
        /// Validate if the field has a minimun and maximun length, with a regular expression and a custom message for the error
        /// </summary>
        /// <param name="minLength">minimun length allowed</param>
        /// <param name="maxLength">max length allowed</param>
        /// <param name="regularExpression">A Valid Regular Expression to check if the value matches or not</param>
        /// <param name="errorMessageForRegularExpression">A well defined message to show during the validation process</param>
        public CustomRequiredAttribute(int minLength, int maxLength, string regularExpression, string errorMessageForRegularExpression)
        {
            min = minLength;
            max = maxLength;
            this.regularExpression = regularExpression;
            regularExpressionError = errorMessageForRegularExpression;
            hasRegularExpression = true;
        }

        /// <summary>
        /// Validate if the field has a minimun and maximun length (Does not check for Regular Expression)
        /// </summary>
        /// <param name="minLength">minimun length allowed</param>
        /// <param name="maxLength">max length allowed</param>
        public CustomRequiredAttribute(int minLength, int maxLength)
        {
            min = minLength;
            max = maxLength;
        }

        /// <summary>
        /// Validate if the field value matches with the regular expression value and a custom message for the error
        /// </summary>
        /// <param name="regularExpression">A Valid Regular Expression to check if the value matches or not</param>
        /// <param name="errorMessageForRegularExpression">A well defined message to show during the validation process</param>
        public CustomRequiredAttribute(string regularExpression, string errorMessageForRegularExpression)
        {
            this.regularExpression = regularExpression;
            regularExpressionError = errorMessageForRegularExpression;
            hasRegularExpression = true;
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public override bool RequiresValidationContext => true;
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        /// <inheritdoc/>
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            string membername = validationContext == null ? "not_defined" : validationContext.MemberName;

            try
            {
                string account_number = (string)value;

                // Validation for requires
                if (account_number == null || string.IsNullOrWhiteSpace(account_number))
                {
                    return new ValidationResult(ErrorMessage = $"Parameter::{membername}:: is required.#REQUIRED", new string[] { membername });
                }

                // If not min and max length is required, then continue and do not validate
                if (min > 0 && max > 0)
                {
                    // Validation for Min and Max Length
                    if (account_number.Length < min || account_number.Length > max)
                        return new ValidationResult(ErrorMessage = $"Parameter :: {membername} :: invalid format, it is only allowed: numbers and the length must be from {min} to {max} characters.#INVALID", new string[] { membername });
                }

                if (hasRegularExpression)
                {
                    // SafeGuard for Regular Expression
                    if (string.IsNullOrEmpty(regularExpression))
                        return new ValidationResult(ErrorMessage = "Regular Expression value is required#INTERNAL", new string[] { membername });
                }

                // SafeGuard for Regular Expression Error
                if (!string.IsNullOrEmpty(regularExpression) && string.IsNullOrWhiteSpace(regularExpressionError))
                    return new ValidationResult(ErrorMessage = "Regular Expression ERROR value is required#INTERNAL", new string[] { membername });

                if (!string.IsNullOrEmpty(regularExpression) && !string.IsNullOrWhiteSpace(regularExpressionError))
                { // Validation with Regular Expression
                    var isMatch = Regex.IsMatch(account_number, regularExpression);

                    // if doesn't match with the regular expresion.....
                    if (!isMatch)
                        return new ValidationResult(ErrorMessage = regularExpressionError, new string[] { membername });
                }
            }
            catch (Exception ex)
            {
                // TODO: Improve with Better Logging Service
                return new ValidationResult(ErrorMessage = regularExpressionError + ex.Message, new string[] { membername });
            }

            // Happy path!
            return ValidationResult.Success;
        }
    }
}
