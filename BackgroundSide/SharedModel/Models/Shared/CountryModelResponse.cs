using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModel.Models.Shared
{
    public class CountryModelResponse
    {
        public int idEntityApiCredential { get; set; }
        public int idCountry { get; set; }
        public string Code { get; set; }
        public string Name { get; set; }
    }
}
