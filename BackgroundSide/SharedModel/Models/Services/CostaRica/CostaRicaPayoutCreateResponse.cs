using System;
using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;

namespace SharedModel.Models.Services.CostaRica
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class CostaRicaPayoutCreateResponse : CostaRicaPayoutCreateRequest
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        [JsonProperty(Order = 0)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Int64 transaction_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 1)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Int64 payout_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 2)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 3)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string Ticket { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        [JsonProperty(Order = 27)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Int64 exchange_rate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        private SharedModel.Models.General.ErrorModel.Error errorrow = new General.ErrorModel.Error();
        [JsonProperty(Order = 31)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS0108 // El miembro oculta el miembro heredado. Falta una contraseña nueva
        public SharedModel.Models.General.ErrorModel.Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS0108 // El miembro oculta el miembro heredado. Falta una contraseña nueva
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }
}