using CacheManager.Core;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;

namespace WA_LP.Cache
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public static class CacheService
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        const string TokenCacheExpiration = "TokenCacheExpiration";

        private static ICacheManager<object> manager;
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static void Init()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            int tokenCacheExpirationTime = int.Parse(ConfigurationManager.AppSettings[TokenCacheExpiration]); 
            manager = CacheFactory.Build<object>(p => p.WithSystemRuntimeCacheHandle().WithExpiration(ExpirationMode.Absolute, TimeSpan.FromMinutes(tokenCacheExpirationTime)));
        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static void Add(string key, object value)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            manager.AddOrUpdate(key, value, _=> value);
        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static object Get(string key)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            return manager.Get(key);
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static object Remove(string key)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            return manager.Remove(key);
        }

    }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class CacheValue
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string Key { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public object Value { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }
}