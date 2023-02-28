﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAO.DataAccess.Services.Ecuador;
using Newtonsoft.Json;
using SharedMaps.Converters.Services.Ecuador;
using SharedModel.Models.Services.Ecuador;

namespace SharedBusiness.Services.Ecuador
{
    public class BIPayoutEcuador
    {
        static readonly object _locker = new object();
        public List<EcuadorPayoutCreateResponse> LotTransaction(List<EcuadorPayoutCreateRequest> data, string customer, bool TransactionMechanism, string countryCode)
        {
            try
            {
                /* CASTEO REQUEST - LOT */
                var LPMapper = new PayOutMapperEcuador();
                var LotBatch = LPMapper.MapperModels(data);

                /* CONN DAO LOT - LOT */
                Payouts.BIPayOut LPDAO = new Payouts.BIPayOut();
                lock (_locker)
                {
                    LotBatch = LPDAO.CreateLotTransaction(LotBatch, customer, countryCode, TransactionMechanism);
                }

                /* CASTEO LOT - RESPONSE */
                var Response = LPMapper.MapperModels(LotBatch);
                return Response;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public EcuadorPayoutDownloadResponse DownloadLotBatchTransactionToBank(List<string> tickets, bool TransactionMechanism, string providerName)
        {
            var dbPayOut = new DbPayOutEcuador();

            string JSON = JsonConvert.SerializeObject(tickets);

            var result = dbPayOut.DownloadBatchLotTransactionToBank(TransactionMechanism, JSON, providerName);

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

        public EcuadorUploadResponse UploadExcelFromBankItau(List<EcuadorExcelUploadResponse> excelData, int currencyFx, string datetime, bool TransactionMechanism, string countryCode)
        {
            var ResponseModel = new EcuadorUploadResponse();

            var BatchLotDetail = new EcuadorBatchLotDetail();
            var Detail = new EcuadorTransactionDetail();
            var uploadModel = new List<SharedModel.Models.Services.Payouts.Payouts.UploadModel>();

            try
            {

                var DbPayOut = new DbPayOutEcuador();

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

                ResponseModel.TransactionDetail = DbPayOut.UpdateLotBatchTransactionFromBank(currencyFx, TransactionMechanism, uploadModel);

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
