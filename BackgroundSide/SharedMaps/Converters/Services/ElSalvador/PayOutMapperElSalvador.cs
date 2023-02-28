using System.Collections.Generic;
using AutoMapper;
using SharedModel.Models.Services.ElSalvador;
using SharedModelDTO.Models.LotBatch;

namespace SharedMaps.Converters.Services.ElSalvador
{
    public class PayOutMapperElSalvador
    {
        public LotBatchModel MapperModels(List<ElSalvadorPayoutCreateRequest> data)
        {
            var Result = Mapper.Map<LotBatchModel>(data);
            return Result;
        }

        /* PAYOUT ==> POST ==> DTO -> RESPONSE */
        public List<ElSalvadorPayoutCreateResponse> MapperModels(LotBatchModel data)
        {
            var Result = Mapper.Map<List<ElSalvadorPayoutCreateResponse>>(data);
            return Result;
        }

        public List<ElSalvadorPayoutLotBatch> MapperModelsBatch(List<LotBatchModel> data)
        {
            var Result = Mapper.Map<List<ElSalvadorPayoutLotBatch>>(data);
            return Result;
        }
    }
}