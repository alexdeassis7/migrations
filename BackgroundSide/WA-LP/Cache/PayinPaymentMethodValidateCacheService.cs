using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WA_LP.Cache
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public static class PayinPaymentMethodValidateCacheService
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        private static List<string> paymentMethodCodes;
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static void Init()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            AddToCache();
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static void AddToCache()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            var Codes = SharedBusiness.Common.Configuration.GetPaymentMethodCodes();
            paymentMethodCodes = Codes;
        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static List<string> Get()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            return paymentMethodCodes;
        }
    }
}