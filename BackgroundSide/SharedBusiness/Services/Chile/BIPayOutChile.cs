using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UtilityTools = Tools;
using System.Threading.Tasks;
using DAO.DataAccess.Services.Chile;
using SharedModel.Models.Services.Chile;
using DAO.DataAccess.Services;

namespace SharedBusiness.Services.Chile
{
    public class BIPayOutChile
    {
        static readonly object _locker = new object();
        public List<SharedModel.Models.Services.Chile.PayOutChile.Create.Response> LotTransaction(List<SharedModel.Models.Services.Chile.PayOutChile.Create.Request> data, string customer, bool TransactionMechanism, string countryCode)
        {
            try
            {
                /* CASTEO REQUEST - LOT */
                SharedMaps.Converters.Services.Chile.PayOutMapperChile LPMapper = new SharedMaps.Converters.Services.Chile.PayOutMapperChile();
                SharedModelDTO.Models.LotBatch.LotBatchModel LotBatch = LPMapper.MapperModels(data);

                /* CONN DAO LOT - LOT */
                SharedBusiness.Services.Payouts.BIPayOut LPDAO = new SharedBusiness.Services.Payouts.BIPayOut();
                lock (_locker)
                {
                    LotBatch = LPDAO.CreateLotTransaction(LotBatch, customer, countryCode, TransactionMechanism);
                }

                /* CASTEO LOT - RESPONSE */
                List<SharedModel.Models.Services.Chile.PayOutChile.Create.Response> Response = LPMapper.MapperModels(LotBatch);
                return Response;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public PayOutChile.DownloadLotBatchTransactionToBank.Response DownloadLotBatchTransactionToBank
            (List<string> tickets, bool TransactionMechanism, string providerName)
        {
            var dbPayoutService = new DbPayOutChile();
            var result = new PayOutChile.DownloadLotBatchTransactionToBank.Response();

            string JSON = JsonConvert.SerializeObject(tickets);

            var dbPayOut = new DbPayOut();

            switch (providerName)
            {
                case "BCHILE816":
                    result = dbPayOut.DownloadBatchLotTransactionToBankBCHILE816(TransactionMechanism, JSON);
                    break;
                case "BCHILE822":
                    result = dbPayOut.DownloadBatchLotTransactionToBankBCHILE822(TransactionMechanism, JSON);
                    break;
                case "ITAUCHL":
                    result = dbPayoutService.DownloadBatchLotTransactionToItau(TransactionMechanism, JSON);
                    break;
                case "SEC":
                    result = dbPayoutService.DownloadBatchLotTransactionToBankBancoSecurity(JSON);
                    break;
            }
            
            if (result.Rows > 0)
            {
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
                        byte[] bytes = Encoding.ASCII.GetBytes(fullText);
                        result.FileBase64 = Convert.ToBase64String(bytes);
                        result.Lines = null;
                    }
                }
            }
            return result;
        }

        public SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.Response UploadExcelFromBankItau(List<SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.ExcelItauResponse> excelData, int currencyFx, string datetime, bool TransactionMechanism, string countryCode)
        {
            SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.Response();

            SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.BatchLotDetail BatchLotDetail = new SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.BatchLotDetail();
            SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.TransactionDetail Detail = new SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.TransactionDetail();
            List<SharedModel.Models.Services.Payouts.Payouts.UploadModel> uploadModel = new List<SharedModel.Models.Services.Payouts.Payouts.UploadModel>();

            try
            {

                DAO.DataAccess.Services.Chile.DbPayOutChile DbPayOut = new DAO.DataAccess.Services.Chile.DbPayOutChile();

                foreach (var transaction in excelData)
                {
                    var trxStatus = transaction.STATUS.ToUpper();
                    if (trxStatus == "PAGADO" || trxStatus == "RECHAZADO")
                    {
                        var status = trxStatus == "PAGADO" ? "EXECUTED" : "REJECTED";
                        var rejectionDetail = transaction.REJECTED_DETAIL.ToUpper();
                        uploadModel.Add(new SharedModel.Models.Services.Payouts.Payouts.UploadModelItau() { ticket = transaction.TICKET_ID, status = status, rejectDetail = rejectionDetail });
                    }
                }

                ResponseModel.TransactionDetail = DbPayOut.UpdateLotBatchTransactionFromBankItau(currencyFx, TransactionMechanism, uploadModel);

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
