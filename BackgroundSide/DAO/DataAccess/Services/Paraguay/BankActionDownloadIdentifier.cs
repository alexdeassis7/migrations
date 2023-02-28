using System;

namespace DAO.DataAccess.Services.Paraguay
{
    /// <summary>
    /// Attribute to Define an Identifier to a specific Bank
    /// </summary>
    public class BankActionDownloadIdentifier : Attribute
    {
        /// <summary>
        /// Bank Code
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Default constructor
        /// </summary>
        /// <param name="name"></param>
        public BankActionDownloadIdentifier(string name)
        {
            Name = name;
        }
    }
}
