using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModel.Models.Shared
{
    public class CountryModelRequest
    {
        public string CountryName { get; set; }
        public string CountryDisplay { get; set; }
        public string CurrencyAccount { get; set; }
        public string CommisionValue { get; set; }
        public string CommissionCurrency { get; set; }
        public string Spread { get; set; }
        public string AfipRetention { get; set; }
        public string ArbaRetention { get; set; }
        public string LocalTax { get; set; }
        public string Alias { get; set; }
    }
}
