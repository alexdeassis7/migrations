using System.Collections.Generic;
using AutoMapper;
using SharedModel.Models.Services.Panama;
using SharedModelDTO.Models.LotBatch;

namespace SharedMaps.Converters.Services.Panama
{
    public class PayOutMapperPanama
    {
        public LotBatchModel MapperModels(List<PanamaPayoutCreateRequest> data)
        {
            var Result = Mapper.Map<LotBatchModel>(data);
            return Result;
        }

        /* PAYOUT ==> POST ==> DTO -> RESPONSE */
        public List<PanamaPayoutCreateResponse> MapperModels(LotBatchModel data)
        {
            var Result = Mapper.Map<List<PanamaPayoutCreateResponse>>(data);
            return Result;
        }

        public List<PanamaPayoutLotBatch> MapperModelsBatch(List<LotBatchModel> data)
        {
            var Result = Mapper.Map<List<PanamaPayoutLotBatch>>(data);
            return Result;
        }
    }
}