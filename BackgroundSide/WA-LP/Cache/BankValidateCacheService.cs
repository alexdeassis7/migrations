using SharedModel.Models.Database.Security;
using SharedModel.Models.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using static SharedModel.Models.Database.General.BankCodesModel;

namespace WA_LP.Cache
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public static class BankValidateCacheService
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        private static List<BankCodesOrdered> bankCodes;
        private static List<BankCodesFullNameOrdered> bankFullNameOrdered; 
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
            var Codes =  SharedBusiness.Common.Configuration.GetBankCodes();
            bankCodes = Codes.GroupBy(x => x.countryCode, x => x.bankCode,(key,g) => new BankCodesOrdered{ countryCode = key, bankCodes = g.ToList()}).ToList();


            var Codes2 = Codes
                   .GroupBy(c => c.countryCode)
                   .Select(g => g.First())
                   .OrderBy(ord => ord.countryCode)
                   .ToList();
            bankFullNameOrdered = new List<BankCodesFullNameOrdered>();
            foreach (var item in Codes2)
            {
                BankCodesFullNameOrdered bankord = new BankCodesFullNameOrdered
                {
                    countryCode = item.countryCode,
                    bankFullNameCodes = Codes.Where(x => x.countryCode.Equals(item.countryCode)).ToList()
                };
                bankFullNameOrdered.Add(bankord);
            }

            //bankFullNameOrdered = Codes.GroupBy(x => x.countryCode, x => x.bankCode, (key, g) => new BankCodesFullNameOrdered { countryCode = key, bankFullNameCodes = g.ToList() }).ToList();

        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static List<BankCodesOrdered> Get()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            return bankCodes;
        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static List<BankCodesFullNameOrdered> GetFullNamed()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            return bankFullNameOrdered;
        }

    }
}