using SharedModel.Models.Shared;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModel.Models.Account
{
    public class AccountRequest
    {
        public string MerchantName { get; set; }
        public string SubMerchantName { get; set; }
        public string ApiPassword { get; set; }
        public string WebPassword { get; set; }
        public string Identification { get; set; }
        public string Mail { get; set; }
        public string FxPeriod { get; set; }
        public List<string> Countries { get; set; }
        public List<CountryModelRequest> DataCountries { get; set; }
    }
}
