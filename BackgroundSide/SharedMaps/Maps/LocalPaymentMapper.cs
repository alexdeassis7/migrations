using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using AutoMapper;
using SharedMaps.Maps.Services.Bolivia;
using SharedMaps.Maps.Services.CostaRica;
using SharedMaps.Maps.Services.Ecuador;
using SharedMaps.Maps.Services.ElSalvador;
using SharedMaps.Maps.Services.Panama;
using SharedMaps.Maps.Services.Paraguay;

namespace SharedMaps.Maps
{
    public static class LocalPaymentMapper
    {
        public static void InitializeAutoMapper()
        {
            Mapper.Initialize(x =>
            {
                x.AddProfile(new Services.Banks.Galicia.PayOutMapping());
                x.AddProfile(new Services.Wallet.InternalWalletTransferMapping());
                x.AddProfile(new View.DashboardMapping());
                x.AddProfile(new Services.Banks.Bind.DebinMapping());
                x.AddProfile(new Services.Colombia.Banks.Bancolombia.PayOutMappingColombia());
                x.AddProfile(new Services.Brasil.PayOutMappingBrasil());
                x.AddProfile(new Services.Uruguay.PayOutMappingUruguay());
                x.AddProfile(new Services.Chile.PayOutMappingChile());
                x.AddProfile(new Services.Peru.PayOutMappingPeru());
                x.AddProfile(new Services.Mexico.PayOutMappingMexico());
                x.AddProfile(new PayOutMappingEcuador());
                x.AddProfile(new PayOutMappingParaguay());
                x.AddProfile(new PayOutMappingBolivia());
                x.AddProfile(new PayOutMappingPanama());
                x.AddProfile(new PayOutMappingCostaRica());
                x.AddProfile(new PayOutMappingElSalvador());
            });
        }
    }
}
