using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModel.Models.Account
{
    public class AccountResponse
    {
        public string MerchantName { get; set; }
        public string SubMerchantName { get; set; }
        public string ApiPassword { get; set; }
        public string WebPassword { get; set; }
        public string Identification { get; set; }
        public string Mail { get; set; }
    }
}
