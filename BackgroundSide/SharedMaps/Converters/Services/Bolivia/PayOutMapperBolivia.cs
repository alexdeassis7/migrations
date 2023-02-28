using System.Collections.Generic;
using AutoMapper;
using SharedModel.Models.Services.Bolivia;
using SharedModelDTO.Models.LotBatch;

namespace SharedMaps.Converters.Services.Bolivia
{
    public class PayOutMapperBolivia
    {
        public LotBatchModel MapperModels(List<BoliviaPayoutCreateRequest> data)
        {
            var Result = Mapper.Map<LotBatchModel>(data);
            return Result;
        }

        /* PAYOUT ==> POST ==> DTO -> RESPONSE */
        public List<BoliviaPayoutCreateResponse> MapperModels(LotBatchModel data)
        {
            var Result = Mapper.Map<List<BoliviaPayoutCreateResponse>>(data);
            return Result;
        }

        public List<BoliviaPayoutLotBatch> MapperModelsBatch(List<LotBatchModel> data)
        {
            var Result = Mapper.Map<List<BoliviaPayoutLotBatch>>(data);
            return Result;
        }
    }
}