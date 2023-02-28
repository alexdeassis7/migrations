using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using SharedModel.Models.Shared;

namespace SharedModel.Models.User
{
    /// <summary>
    /// ...
    /// </summary>
    public class User


    {
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string FirstName { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string Admin { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string UserSiteIdentification { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string Identification { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string TypeUser { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string Merchant { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public Int64 idEntityUser { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public Int64 idEntityAccount { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        
        private List<GeographyModel.Country> _pCountryList = new List<GeographyModel.Country>();
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public List<GeographyModel.Country> lCountry { get { return _pCountryList.Count > 0 ? _pCountryList : null ; } set { _pCountryList = value; } }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string ReportEmail { get; set; }
        /// <summary>
        /// ...
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string Key { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string WebPassword { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string Mail { get; set; }
        /// <summary>
        /// ...
        /// </summary>
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public Boolean Active { get; set; }
    }

}