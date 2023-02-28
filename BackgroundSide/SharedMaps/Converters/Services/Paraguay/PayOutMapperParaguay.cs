using System.Collections.Generic;
using AutoMapper;
using SharedModel.Models.Services.Paraguay;
using SharedModelDTO.Models.LotBatch;

namespace SharedMaps.Converters.Services.Paraguay
{
    public class PayOutMapperParaguay
    {
        public LotBatchModel MapperModels(List<ParaguayPayoutCreateRequest> data)
        {
            var Result = Mapper.Map<LotBatchModel>(data);
            return Result;
        }

        /* PAYOUT ==> POST ==> DTO -> RESPONSE */
        public List<ParaguayPayoutCreateResponse> MapperModels(LotBatchModel data)
        {
            var Result = Mapper.Map<List<ParaguayPayoutCreateResponse>>(data);
            return Result;
        }

        public List<ParaguayPayoutLotBatch> MapperModelsBatch(List<LotBatchModel> data)
        {
            var Result = Mapper.Map<List<ParaguayPayoutLotBatch>>(data);
            return Result;
        }
    }
}