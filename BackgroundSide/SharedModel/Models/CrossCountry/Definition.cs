using System;

namespace SharedModel.Models.CrossCountry
{
    /// <summary>
    /// A definition for Validation thats helps to validate a given value with (or not) a regular expression and (or not) a Delegate Function
    /// </summary>
    public class Definition
    {
        /// <summary>
        /// Defines the Minimun Length for a given Value
        /// </summary>
        public int MinLength { get; set; }

        /// <summary>
        /// Defines the Maximun Length for a Value
        /// </summary>
        public int MaxLength { get; set; }

        /// <summary>
        /// Defines or Gets if the Definition has a Regular Expression for Test Matching
        /// </summary>
        public bool HasPatternMatching { get; set; }

        /// <summary>
        /// Defines or Gets a Regular Expression (If HasPatternMatching Field is not defined has True, this will not work)
        /// </summary>
        public string RegularExpression { get; set; }

        /// <summary>
        /// A Delegate that will be executed to test the value of the validation parameters given />
        /// </summary>
        public Func<string, bool> CustomFunction { get; set; }
    }
}
