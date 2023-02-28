using Newtonsoft.Json;
using SharedModel.Models.General;
using System;

namespace SharedModel.Models.Services.Bolivia
{
    /// <summary>
    /// BoliviaPayout Response for PayoutCreate Action
    /// </summary>
    public class BoliviaPayoutCreateResponse : BoliviaPayoutCreateRequest
    {
        private ErrorModel.Error errorRow = new General.ErrorModel.Error();

        /// <summary>
        /// Transaction Id
        /// </summary>
        [JsonProperty(Order = 0)]
        public Int64 transaction_id { get; set; }

        /// <summary>
        /// Payout Id
        /// </summary>
        [JsonProperty(Order = 1)]
        public Int64 payout_id { get; set; }

        /// <summary>
        /// Status Id
        /// </summary>
        [JsonProperty(Order = 2)]
        public string status { get; set; }

        /// <summary>
        /// Ticket Number
        /// </summary>
        [JsonProperty(Order = 3)]
        public string Ticket { get; set; }

        /// <summary>
        /// Error Row
        /// </summary>
        [JsonProperty(Order = 27)]
        public Int64 exchange_rate { get; set; }

        /// <summary>
        /// Error Row
        /// </summary>
        [JsonProperty(Order = 31)]
        public new ErrorModel.Error ErrorRow { get => errorRow; set => errorRow = value; }
    }
}