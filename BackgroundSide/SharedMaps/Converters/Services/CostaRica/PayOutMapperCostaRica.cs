using System.Collections.Generic;
using AutoMapper;
using SharedModel.Models.Services.CostaRica;
using SharedModelDTO.Models.LotBatch;

namespace SharedMaps.Converters.Services.CostaRica
{
    public class PayOutMapperCostaRica
    {
        public LotBatchModel MapperModels(List<CostaRicaPayoutCreateRequest> data)
        {
            var Result = Mapper.Map<LotBatchModel>(data);
            return Result;
        }

        /* PAYOUT ==> POST ==> DTO -> RESPONSE */
        public List<CostaRicaPayoutCreateResponse> MapperModels(LotBatchModel data)
        {
            var Result = Mapper.Map<List<CostaRicaPayoutCreateResponse>>(data);
            return Result;
        }

        public List<CostaRicaPayoutLotBatch> MapperModelsBatch(List<LotBatchModel> data)
        {
            var Result = Mapper.Map<List<CostaRicaPayoutLotBatch>>(data);
            return Result;
        }
    }
}