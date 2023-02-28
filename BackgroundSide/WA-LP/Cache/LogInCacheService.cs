using SharedModel.Models.Database.Security;
using SharedModel.Models.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WA_LP.Cache
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public static class LogInCacheService
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static void Init()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            CacheService.Init();
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static void AddToCache(Authentication.Account account)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            CacheService.Add(account.Login.ClientID + account.Login.Password, account);
        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static Authentication.Account Get(string key)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
           var client = CacheService.Get(key);
            if (client != null)
                return (Authentication.Account)client;
            else
                return null;
        }

    }
}