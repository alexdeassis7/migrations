using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;

namespace WA_LP.Serializer.Extensions
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public static class RequestExtension
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static string SerializeRequest(this HttpRequestMessage request)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            try
            {
                var strBuilder = new StringBuilder();
                var header = JsonConvert.SerializeObject(request.Headers, Formatting.None, new JsonSerializerSettings
                {
                    ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
                    ContractResolver = new IgnoreErrorPropertiesResolver()
                });
                strBuilder.Append(header);

                var body = request.Content.ReadAsStringAsync().Result;
                strBuilder.Append(body);

                return strBuilder.ToString();
            }
            catch
            {
                return string.Empty;
            }
        }
    }
}