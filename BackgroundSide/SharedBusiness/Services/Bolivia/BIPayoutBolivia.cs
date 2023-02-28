using DAO.DataAccess.Services.Bolivia;
using DAO.DataAccess.Services.CrossCountry;
using Newtonsoft.Json;
using SharedMaps.Converters.Services.Bolivia;
using SharedModel.Models.Services.Bolivia;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;

namespace SharedBusiness.Services.Bolivia
{
    public class BIPayoutBolivia
    {
        static readonly object _locker = new object();

        private readonly Dictionary<string, MethodInfo> bankMethodDictionary = new Dictionary<string, MethodInfo>();

        public BIPayoutBolivia()
        {
            var methodCollectionFound = typeof(DbPayOutBolivia).GetMethods()
              .Where(m => m.GetCustomAttributes(typeof(BankActionDownloadIdentifier), false).Length > 0)
              .ToList();

            foreach (var (methodDownloadBank, customAttribute) in from methodDownloadBank in methodCollectionFound
                                                                  let customAttribute = methodDownloadBank.GetCustomAttribute<BankActionDownloadIdentifier>()
                                                                  select (methodDownloadBank, customAttribute))
            {
                bankMethodDictionary.Add(customAttribute.Name, methodDownloadBank);
            }
        }


        public List<BoliviaPayoutCreateResponse> LotTransaction(List<BoliviaPayoutCreateRequest> data, string customer, bool TransactionMechanism, string countryCode)
        {
            try
            {
                /* CASTEO REQUEST - LOT */
                var LPMapper = new PayOutMapperBolivia();
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

        public PayOutBolivia.DownloadLotBatchTransactionToBank.Response DownloadLotBatchTransactionToBank
        (
            List<string> tickets,
            bool TransactionMechanism,
            int internalFiles,
            string providerName
        )
        {
            string serializedTickets = JsonConvert.SerializeObject(tickets);

            // ********************************
            // CASOS CONTEMPLADOS
            // ********************************
            // - BANCO GANADERO (BGBOL)

            PayOutBolivia.DownloadLotBatchTransactionToBank.Response result =
                PerformDownloadBatchLotTransactionToBank(TransactionMechanism, internalFiles, providerName, serializedTickets);

            if (result.PayoutFiles.Count > 0)
            {
                //Payouts Txt
                for (int i = 0; i < result.PayoutFiles.Count; i++)
                {
                    byte[] bytesPayouts = null;

                    using (MemoryStream memory = new MemoryStream())
                    {
                        using (StreamWriter writer = new StreamWriter(memory, Encoding.GetEncoding(437)))
                        {

                            for (int j = 0; j < result.PayoutFiles[i].LinesPayouts.Count; j++)
                            {
                                writer.WriteLine(result.PayoutFiles[i].LinesPayouts[j]);
                            }

                            writer.Flush();
                            memory.Position = 0;
                            bytesPayouts = memory.ToArray();
                            result.PayoutFiles[i].FileBase64_Payouts = Convert.ToBase64String(bytesPayouts);
                            result.PayoutFiles[i].LinesPayouts = null;
                        }

                    }
                }
            }

            if (result.RowsPreRegister > 0)
            {
                //Beneficiaries Txt
                byte[] bytesBeneficiaries = null;
                using (MemoryStream memory = new MemoryStream())
                {
                    using (StreamWriter writer = new StreamWriter(memory, Encoding.GetEncoding(437)))
                    {
                        for (int i = 0; i < result.LinesPreRegister.Length; i++)
                        {
                            writer.WriteLine(result.LinesPreRegister[i]);
                        }

                        writer.Flush();
                        memory.Position = 0;
                        bytesBeneficiaries = memory.ToArray();
                        result.FileBase64_PreRegister = Convert.ToBase64String(bytesBeneficiaries);
                        result.LinesPreRegister = null;
                    }
                }
            }

            if (result.RowsPreRegisterSameBank > 0)
            {
                //Beneficiaries Txt
                byte[] bytesBeneficiaries = null;
                using (MemoryStream memory = new MemoryStream())
                {
                    using (StreamWriter writer = new StreamWriter(memory, Encoding.GetEncoding(437)))
                    {
                        for (int i = 0; i < result.LinesPreRegisterSameBank.Length; i++)
                        {
                            writer.WriteLine(result.LinesPreRegisterSameBank[i]);
                        }

                        writer.Flush();
                        memory.Position = 0;
                        bytesBeneficiaries = memory.ToArray();
                        result.FileBase64_PreRegisterSameBank = Convert.ToBase64String(bytesBeneficiaries);
                        result.LinesPreRegisterSameBank = null;
                    }
                }
            }

            if (result.ExcelRows > 0)
            {
                //Beneficiaries Txt
                byte[] bytesBeneficiaries = result.ExcelExportByteArray;

                using (MemoryStream memory = new MemoryStream())
                {
                    using (StreamWriter writer = new StreamWriter(memory, Encoding.GetEncoding(437)))
                    {
                        writer.Flush();
                        memory.Position = 0;
                        result.FileBase64_ExcelFileOut = Convert.ToBase64String(bytesBeneficiaries);
                        result.LinesPreRegisterSameBank = null;
                        result.FileBase64_PreRegister = null;
                    }
                }
            }

            return result;
        }

        public BoliviaUploadResponse UploadExcelFromBankItau(List<BoliviaExcelUploadResponse> excelData, int currencyFx, string datetime, bool TransactionMechanism, string countryCode)
        {
            var ResponseModel = new BoliviaUploadResponse();

            var BatchLotDetail = new BoliviaBatchLotDetail();
            var Detail = new BoliviaTransactionDetail();
            var uploadModel = new List<SharedModel.Models.Services.Payouts.Payouts.UploadModel>();

            try
            {

                var DbPayOut = new DbPayOutBolivia();

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

        private PayOutBolivia.DownloadLotBatchTransactionToBank.Response PerformDownloadBatchLotTransactionToBank(bool TransactionMechanism, int internalFiles, string providerName, string JSON)
        {
            PayOutBolivia.DownloadLotBatchTransactionToBank.Response result;

            MethodInfo bankPayoutDownloadFunction = bankMethodDictionary[providerName];

            if (bankPayoutDownloadFunction == null)
                throw new NullReferenceException("Method not implemented or not decorated with the attribute of type <BankActionDownloadIdentifier>");

            Type t = typeof(DbPayOutBolivia);

            var obj = Activator.CreateInstance(t, false);

            result = (PayOutBolivia.DownloadLotBatchTransactionToBank.Response)
                bankPayoutDownloadFunction.Invoke(obj, new object[] { TransactionMechanism, JSON, internalFiles });
            return result;
        }
    }
}
