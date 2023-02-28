using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UtilityTools = Tools;
using System.Threading.Tasks;

namespace SharedBusiness.Services.Peru
{
    public class BIPayOutPeru
    {
        static readonly object _locker = new object();
        public List<SharedModel.Models.Services.Peru.PeruPayoutCreateResponse> LotTransaction(List<SharedModel.Models.Services.Peru.PeruPayoutCreateRequest> data, string customer, bool TransactionMechanism, string countryCode)
        {
            try
            {
                /* CASTEO REQUEST - LOT */
                SharedMaps.Converters.Services.Peru.PayOutMapperPeru LPMapper = new SharedMaps.Converters.Services.Peru.PayOutMapperPeru();
                SharedModelDTO.Models.LotBatch.LotBatchModel LotBatch = LPMapper.MapperModels(data);

                /* CONN DAO LOT - LOT */
                SharedBusiness.Services.Payouts.BIPayOut LPDAO = new SharedBusiness.Services.Payouts.BIPayOut();
                lock (_locker)
                {
                    LotBatch = LPDAO.CreateLotTransaction(LotBatch, customer, countryCode, TransactionMechanism);
                }

                /* CASTEO LOT - RESPONSE */
                List<SharedModel.Models.Services.Peru.PeruPayoutCreateResponse> Response = LPMapper.MapperModels(LotBatch);
                return Response;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public SharedModel.Models.Services.Peru.PeruPayoutDownloadLotBatchTransactionToBankResponse
            DownloadLotBatchTransactionToBank(List<string> tickets, bool TransactionMechanism, string providerName)
        {
            DAO.DataAccess.Services.Peru.DbPayOutPeru DbPayOut = new DAO.DataAccess.Services.Peru.DbPayOutPeru();
            SharedModel.Models.Services.Peru.PeruPayoutDownloadLotBatchTransactionToBankResponse result =
                new SharedModel.Models.Services.Peru.PeruPayoutDownloadLotBatchTransactionToBankResponse();

            if (providerName == "BCPPER" && tickets.Count >= 1000)
            {
                throw new Exception("Max tickets in a single batch is 999 for BCP");
            }

            string JSON = JsonConvert.SerializeObject(tickets);
            result = DbPayOut.DownloadBatchLotTransactionToBank(TransactionMechanism, JSON, providerName);         
            if (result.Rows > 0)
            {
                byte[] bytes = null;

                using (MemoryStream memory = new MemoryStream())
                {
                    using (StreamWriter writer = new StreamWriter(memory, Encoding.GetEncoding(437)))
                    {
                        for (int i = 0; i < result.Lines.Length; i++)
                        {
                            writer.WriteLine(result.Lines[i]);
                        }

                        writer.Flush();
                        memory.Position = 0;

                        StreamReader sr = new StreamReader(memory);
                        string fullText = sr.ReadToEnd();

                        bytes = Encoding.ASCII.GetBytes(fullText);

                        //bytes = memory.ToArray();
                        result.FileBase64 = Convert.ToBase64String(bytes);

                        result.Lines = null;
                    }
                }
            }
            return result;
        }

        public SharedModel.Models.Services.Peru.PeruPayoutUploadTxtFromBankResponse UploadExcelFromBankBCP(List<SharedModel.Models.Services.Peru.PeruPayoutExcelBCPResponse> excelData, int currencyFx, string datetime, bool TransactionMechanism, string countryCode)
        {
            SharedModel.Models.Services.Peru.PeruPayoutUploadTxtFromBankResponse ResponseModel = new SharedModel.Models.Services.Peru.PeruPayoutUploadTxtFromBankResponse();

            SharedModel.Models.Services.Peru.PeruPayoutBatchLotDetail BatchLotDetail = new SharedModel.Models.Services.Peru.PeruPayoutBatchLotDetail();
            SharedModel.Models.Services.Peru.PeruPayoutTransactionDetail Detail = new SharedModel.Models.Services.Peru.PeruPayoutTransactionDetail();
            List<SharedModel.Models.Services.Payouts.Payouts.UploadModel> uploadModel = new List<SharedModel.Models.Services.Payouts.Payouts.UploadModel>();

            try
            {

                DAO.DataAccess.Services.Peru.DbPayOutPeru DbPayOut = new DAO.DataAccess.Services.Peru.DbPayOutPeru();

                foreach (var transaction in excelData)
                {
                    var trxStatus = transaction.STATUS.ToUpper();
                    if (trxStatus == "PAGADO" || trxStatus == "RECHAZADO")
                    {
                        var status = trxStatus == "PAGADO" ? "EXECUTED" : "REJECTED";
                        var rejectionDetail = transaction.REJECTED_DETAIL.ToUpper();
                        uploadModel.Add(new SharedModel.Models.Services.Payouts.Payouts.UploadModelBCP() { ticket = transaction.TICKET_ID, status = status, rejectDetail = rejectionDetail });
                    }
                }

                ResponseModel.TransactionDetail = DbPayOut.UpdateLotBatchTransactionFromBankBCP(currencyFx, TransactionMechanism, uploadModel);

                ResponseModel.BatchLotDetail = BatchLotDetail;
                if (ResponseModel.TransactionDetail == null)
                {
                    ResponseModel.TransactionDetail.Add(Detail);
                    ResponseModel.Rows = 0;
                }

                ResponseModel.Status = "OK";
                ResponseModel.StatusMessage = "OK";
                ResponseModel.Rows = ResponseModel.TransactionDetail.Count;
            }
            catch (Exception)
            {
                ResponseModel.Status = "ERROR";
                ResponseModel.StatusMessage = "The upload file does not have a valid format";
                ResponseModel.Rows = 0;
            }

            return ResponseModel;
        }

    }
}
