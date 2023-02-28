using System.Collections.Generic;
using AutoMapper;
using SharedModel.Models.Services.Ecuador;
using SharedModelDTO.Models.LotBatch;

namespace SharedMaps.Converters.Services.Ecuador
{
    public class PayOutMapperEcuador
    {
        public LotBatchModel MapperModels(List<EcuadorPayoutCreateRequest> data)
        {
            var Result = Mapper.Map<LotBatchModel>(data);
            return Result;
        }

        /* PAYOUT ==> POST ==> DTO -> RESPONSE */
        public List<EcuadorPayoutCreateResponse> MapperModels(LotBatchModel data)
        {
            var Result = Mapper.Map<List<EcuadorPayoutCreateResponse>>(data);
            return Result;
        }

        public List<EcuadorPayoutLotBatch> MapperModelsBatch(List<LotBatchModel> data)
        {
            var Result = Mapper.Map<List<EcuadorPayoutLotBatch>>(data);
            return Result;
        }
    }
}