using SharedModel.Models.Services.Banks.Galicia;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using SharedBusiness.Services.Payouts;
using Newtonsoft.Json;
using SharedBusiness.Log;
using SharedBusiness.Mail;
using System.Configuration;
using static SharedModel.Models.Services.Payouts.Payouts;
using System.Threading.Tasks;
using System.Net.Http;
using System.Text;
using SharedSecurity.Signature;

namespace WA_LP.Infrastructure
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class ClientCallbackService
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static List<string> supportEmails = ConfigurationManager.AppSettings["SupportEmails"].Split(';').ToList();
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        // ARG
        internal static async Task CheckAndSendCallback(List<PayOut.UploadTxtFromBank.TransactionDetail> transactionDetail)
        {
            // Get EntityUser and Tx Id
            List<CallbackTransaction> cbTxs = transactionDetail
                .FindAll(x => (x.StatusCode == "Executed" || x.StatusCode == "Rejected" || x.StatusCode == "Returned" || x.StatusCode == "Recalled" || x.StatusCode == "Canceled") && x.InternalStatus != "ERROR" && x.InternalStatus != "IGNORED")
                .Select(x => new CallbackTransaction
                    {
                        idEntityUser = x.idEntityUser,
                        idTransaction = x.TransactionId
                    })
                .ToList();

            // Start process to check notification service
            await ProcessClientsCallback(cbTxs);
        }

        // COL
        internal static async Task CheckAndSendCallback(List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.UploadTxtFromBank.TransactionDetail> transactionDetail)
        {
            // Get EntityUser and Tx Id
            List<CallbackTransaction> cbTxs = transactionDetail
                .FindAll(x => (x.StatusCode == "Executed" || x.StatusCode == "Rejected" || x.StatusCode == "Returned" || x.StatusCode == "Recalled" || x.StatusCode == "Canceled") && x.InternalStatus != "ERROR" && x.InternalStatus != "IGNORED")
                .Select(x => new CallbackTransaction
                {
                    idEntityUser = x.idEntityUser,
                    idTransaction = x.TransactionId
                })
                .ToList();

            // Start process to check notification service
            await ProcessClientsCallback(cbTxs);
        }

        // BRA
        internal static async Task CheckAndSendCallback(List<SharedModel.Models.Services.Brasil.PayOutBrasil.UploadTxtFromBank.TransactionDetail> transactionDetail)
        {
            // Get EntityUser and Tx Id
            List<CallbackTransaction> cbTxs = transactionDetail
                .FindAll(x => (x.StatusCode == "Executed" || x.StatusCode == "Rejected" || x.StatusCode == "Returned" || x.StatusCode == "Recalled" || x.StatusCode == "Canceled") && x.InternalStatus != "ERROR" && x.InternalStatus != "IGNORED")
                .Select(x => new CallbackTransaction
                {
                    idEntityUser = x.idEntityUser,
                    idTransaction = x.TransactionId
                })
                .ToList();

            // Start process to check notification service
            await ProcessClientsCallback(cbTxs);
        }

        // MEX
        internal static async Task CheckAndSendCallback(List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> transactionDetail)
        {
            // Get EntityUser and Tx Id
            List<CallbackTransaction> cbTxs = transactionDetail
                .FindAll(x => (x.StatusCode == "Executed" || x.StatusCode == "Rejected" || x.StatusCode == "Returned" || x.StatusCode == "Recalled" || x.StatusCode == "Canceled") && x.InternalStatus != "ERROR" && x.InternalStatus != "IGNORED")
                .Select(x => new CallbackTransaction
                    {
                        idEntityUser = x.idEntityUser,
                        idTransaction = x.TransactionId
                    })
                .ToList();

            // Start process to check notification service
            await ProcessClientsCallback(cbTxs);
        }

        // CHL
        internal static async Task CheckAndSendCallback(List<SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.TransactionDetail> transactionDetail)
        {
            // Get EntityUser and Tx Id
            List<CallbackTransaction> cbTxs = transactionDetail
                .FindAll(x => (x.StatusCode == "Executed" || x.StatusCode == "Rejected" || x.StatusCode == "Returned" || x.StatusCode == "Recalled" || x.StatusCode == "Canceled") && x.InternalStatus != "ERROR" && x.InternalStatus != "IGNORED")
                .Select(x => new CallbackTransaction
                {
                    idEntityUser = x.idEntityUser,
                    idTransaction = x.TransactionId
                })
                .ToList();

            // Start process to check notification service
            await ProcessClientsCallback(cbTxs);
        }

        // URY
        internal static async Task CheckAndSendCallback(List<SharedModel.Models.Services.Uruguay.PayOutUruguay.UploadTxtFromBank.TransactionDetail> transactionDetail)
        {
            // Get EntityUser and Tx Id
            List<CallbackTransaction> cbTxs = transactionDetail
                .FindAll(x => (x.StatusCode == "Executed" || x.StatusCode == "Rejected" || x.StatusCode == "Returned" || x.StatusCode == "Recalled" || x.StatusCode == "Canceled") && x.InternalStatus != "ERROR" && x.InternalStatus != "IGNORED")
                .Select(x => new CallbackTransaction
                {
                    idEntityUser = x.idEntityUser,
                    idTransaction = x.TransactionId
                })
                .ToList();

            // Start process to check notification service
            await ProcessClientsCallback(cbTxs);
        }

        // PER
        internal static async Task CheckAndSendCallback(List<SharedModel.Models.Services.Peru.PeruPayoutTransactionDetail> transactionDetail)
        {
            // Get EntityUser and Tx Id
            List<CallbackTransaction> cbTxs = transactionDetail
                .FindAll(x => (x.StatusCode == "Executed" || x.StatusCode == "Rejected" || x.StatusCode == "Returned" || x.StatusCode == "Recalled" || x.StatusCode == "Canceled") && x.InternalStatus != "ERROR" && x.InternalStatus != "IGNORED")
                .Select(x => new CallbackTransaction
                {
                    idEntityUser = x.idEntityUser,
                    idTransaction = x.TransactionId
                })
                .ToList();

            // Start process to check notification service
            await ProcessClientsCallback(cbTxs);
        }

        // This method gets executed when cancelling through manual cancel
        internal static async Task SendCancelCallback(List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> transactionDetail)
        {
            // Get EntityUser and Tx Id
            List<CallbackTransaction> cbTxs = transactionDetail
                .FindAll(x => x.StatusCode == "Canceled" && x.InternalStatus != "ERROR")
                .Select(x => new CallbackTransaction
                {
                    idEntityUser = x.idEntityUser,
                    idTransaction = x.TransactionId
                })
                .ToList();

            // Start process to check notification service
            await ProcessClientsCallback(cbTxs);
        }

        // This method gets executed when cancelling through "cancel" API Service
        internal static async Task SendCancelCallback(List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Response> cancelledTxs, string customer)
        {
            // Get callback transactions list model
            List<CallbackTransaction> cbTxs = GetCancelCallbackTransactions(
                cancelledTxs
                    .FindAll(x => x.status == "Canceled") // FIND CANCELLED TXS
                    .ToList()
            );

            // Start process to check notification service
            await ProcessClientsCallback(cbTxs);
        }

        internal static List<CallbackTransaction> GetCancelCallbackTransactions(List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Response> cancelledTxs)
        {
            List<CallbackTransaction> cbTxs = new List<CallbackTransaction>();

            BICallbackService BICs = new BICallbackService();
            foreach (PayOut.Delete.Response tx in cancelledTxs)
            {
                cbTxs.Add(
                    new CallbackTransaction
                    {
                        idEntityUser = BICs.GetEntityUserByTxId(tx.transaction_id),
                        idTransaction = tx.transaction_id.ToString()
                    }
                );
            }

            return cbTxs;
        }

        private static async Task ProcessClientsCallback(List<CallbackTransaction> cbTxs)
        {
            try
            {
                IEnumerable<string> entityUsers = cbTxs.Select(x => x.idEntityUser).Distinct();
                foreach(string idEntityUser in entityUsers)
                {
                    CallbackConfiguration clientConfiguration = GetClientCallbackConfiguration(idEntityUser);
                    if (clientConfiguration != null)
                    {
                        TransactionToNotify transactions = new TransactionToNotify
                        {
                            Transactions = cbTxs.Where(x => x.idEntityUser == idEntityUser).Select(x => x.idTransaction).ToList()
                        };

                        await RetrieveTxDataAndSendAsync(transactions, clientConfiguration);
                    }
                }

            } catch(Exception e)
            {
                LogService.LogError("There was an error sending Callback notification. Exception message: " + e.Message.ToString());
                MailService.SendMail("Callback request error", e.Message.ToString(), supportEmails);
            }
        }

        private static async Task<int> RetrieveTxDataAndSendAsync(TransactionToNotify transactions, CallbackConfiguration clientConfiguration)
        {
            List<string> JsonList = GetTransactionsToNotifyJson(clientConfiguration.countryCode, transactions, clientConfiguration.customer);

            foreach (string JsonString in JsonList)
            {
                await SendCallbackRequest(JsonString, clientConfiguration);
            }

            return 1;
        }

        private static async Task<int> SendCallbackRequest(string body, CallbackConfiguration clientConfiguration)
        {
            string TransactionIdLog = Guid.NewGuid().ToString();
            try
            {
                LogService.LogInfo("ClientCallbackService - SenCallbackRequest - Starting Callback Notification REQUEST. TransactionIdLog: " + TransactionIdLog + " idEntityUser " + clientConfiguration.idEntityUser + ". Data to be sent: " + body);
                HttpClient client = new HttpClient();

                // ADDING HEADER PARAMETERS
                foreach(CallbackParameter callbackParameter in clientConfiguration.parameters)
                {
                    client.DefaultRequestHeaders.Add(callbackParameter.parameterName, callbackParameter.parameterValue);
                }

                if (clientConfiguration.signature == true)
                {
                    client.DefaultRequestHeaders.Add("signature", SignatureHandler.CreateHMACSignature(body,clientConfiguration.customer));
                }
                
                LogService.LogInfo("ClientCallbackService - SenCallbackRequest - Before Callback Notification TransactionIdLog: " + TransactionIdLog + " HEADER " + client.DefaultRequestHeaders + " URLCALLBACK "+ clientConfiguration.notificationUrl + " Data to be sent: " + body);


                var content = new StringContent(body, Encoding.UTF8, "application/json");
                var response = await client.PostAsync(clientConfiguration.notificationUrl, content);

                LogService.LogInfo(string.Format("ClientCallbackService - SenCallbackRequest - TransactionIdLog:{0} After post StatusCode: {1}, URL:{2} ", TransactionIdLog, response.StatusCode.ToString(), clientConfiguration.notificationUrl));
                // REQUEST WAS SUCCESSFULL
                if (response.IsSuccessStatusCode)
                {
                    var responseString = await response.Content.ReadAsStringAsync();

                    LogService.LogInfo("ClientCallbackService - SenCallbackRequest TransactionIdLog: "+ TransactionIdLog + " Notification request response: " + responseString.ToString());
                }
                // REQUEST ERROR
                else
                {
                    LogService.LogInfo("ClientCallbackService - SenCallbackRequest TransactionIdLog: " + TransactionIdLog +" Response was not successful");
                    MailService.SendMail("Callback request error TransactionIdLog: " + TransactionIdLog , response.StatusCode.ToString(), supportEmails);
                }

            }
            catch (Exception e)
            {
                LogService.LogError("ClientCallbackService - SenCallbackRequest TransactionIdLog: "+ TransactionIdLog + " There was an error sending callback request. Exception message: " + e.Message.ToString());
                MailService.SendMail("Callback request error TransactionIdLog: " + TransactionIdLog, e.Message.ToString(), supportEmails);
            }

            return 1;
        }

        private static CallbackConfiguration GetClientCallbackConfiguration(string idEntityUser)
        {
            BICallbackService BICs = new BICallbackService();
            string callbackConf = BICs.GetCallbackConfiguration(idEntityUser);
            if(callbackConf != null) {
                return JsonConvert.DeserializeObject<CallbackConfiguration>(callbackConf);
            }

            return null;
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static List<string> GetTransactionsToNotifyJson(string countryCode, TransactionToNotify transactions, string customer)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            SharedBusiness.Services.Banks.Galicia.BIPayOut BiPO = new SharedBusiness.Services.Banks.Galicia.BIPayOut();

            List<SharedModelDTO.Models.LotBatch.LotBatchModel> PayoutListsToSend = new List<SharedModelDTO.Models.LotBatch.LotBatchModel>();

            PayoutListsToSend = BiPO.ListNotificationTransaction(transactions, customer, countryCode);

            List<string> JsonString = new List<string>();
            var splitValue = Int32.Parse(ConfigurationManager.AppSettings["CALLBACK_LIMIT_REQUEST_ITEMS"]);
            var splitTransactions = PayoutListsToSend.Select((x, i) => new { Group = i / splitValue, Value = x })
             .GroupBy(item => item.Group, g => g.Value)
             .Select(g => g.Where(x => true)).ToList();

            foreach (var listTransactions in splitTransactions)
            {
                var PayoutListToSend = listTransactions.ToList();
                switch (countryCode)
                {
                    case "ARG":
                        SharedMaps.Converters.Services.Banks.Galicia.PayOutMapper LPMapperArg = new SharedMaps.Converters.Services.Banks.Galicia.PayOutMapper();
                        var listResponseArg = LPMapperArg.MapperModelsBatch(PayoutListToSend);
                        if (listResponseArg.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseArg));
                        break;
                    case "COL":
                        SharedMaps.Converters.Services.Colombia.Banks.Bancolombia.PayOutMapperColombia LPMapperCol = new SharedMaps.Converters.Services.Colombia.Banks.Bancolombia.PayOutMapperColombia();
                        var listResponseCol = LPMapperCol.MapperModelsBatch(PayoutListToSend);
                        if (listResponseCol.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseCol));
                        break;
                    case "BRA":
                        SharedMaps.Converters.Services.Brasil.PayOutMapperBrasil LPMapperBra = new SharedMaps.Converters.Services.Brasil.PayOutMapperBrasil();
                        var listResponseBra = LPMapperBra.MapperModelsBatch(PayoutListToSend);
                        if (listResponseBra.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseBra));
                        break;
                    case "MEX":
                        SharedMaps.Converters.Services.Mexico.PayOutMapperMexico LPMapperMex = new SharedMaps.Converters.Services.Mexico.PayOutMapperMexico();
                        var listResponseMex = LPMapperMex.MapperModelsBatch(PayoutListToSend);
                        if (listResponseMex.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseMex));
                        break;
                    case "URY":
                        SharedMaps.Converters.Services.Uruguay.PayOutMapperUruguay LPMapperUry = new SharedMaps.Converters.Services.Uruguay.PayOutMapperUruguay();
                        var listResponseUry = LPMapperUry.MapperModelsBatch(PayoutListToSend);
                        if (listResponseUry.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseUry));
                        break;
                    case "CHL":
                        SharedMaps.Converters.Services.Chile.PayOutMapperChile LPMapperChl = new SharedMaps.Converters.Services.Chile.PayOutMapperChile();
                        var listResponseChl = LPMapperChl.MapperModelsBatch(PayoutListToSend);
                        if (listResponseChl.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseChl));
                        break;
                    case "PER":
                        SharedMaps.Converters.Services.Peru.PayOutMapperPeru LPMapperPer = new SharedMaps.Converters.Services.Peru.PayOutMapperPeru();
                        var listResponsePer = LPMapperPer.MapperModelsBatch(PayoutListToSend);
                        if (listResponsePer.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponsePer));
                        break;
                    case "ECU":
                        SharedMaps.Converters.Services.Ecuador.PayOutMapperEcuador LPMapperEcu = new SharedMaps.Converters.Services.Ecuador.PayOutMapperEcuador();
                        var listResponseEcu = LPMapperEcu.MapperModelsBatch(PayoutListToSend);
                        if (listResponseEcu.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseEcu));
                        break;
                    case "CRI":
                        SharedMaps.Converters.Services.CostaRica.PayOutMapperCostaRica LPMapperCri = new SharedMaps.Converters.Services.CostaRica.PayOutMapperCostaRica();
                        var listResponseCri = LPMapperCri.MapperModelsBatch(PayoutListToSend);
                        if (listResponseCri.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseCri));
                        break;
                    case "SLV":
                        SharedMaps.Converters.Services.CostaRica.PayOutMapperCostaRica LPMapperSlv = new SharedMaps.Converters.Services.CostaRica.PayOutMapperCostaRica();
                        var listResponseSlv = LPMapperSlv.MapperModelsBatch(PayoutListToSend);
                        if (listResponseSlv.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseSlv));
                        break;
                    case "BOL":
                        SharedMaps.Converters.Services.Bolivia.PayOutMapperBolivia LPMapperBol = new SharedMaps.Converters.Services.Bolivia.PayOutMapperBolivia();
                         var listResponseBol = LPMapperBol.MapperModelsBatch(PayoutListToSend);
                        if (listResponseBol.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponseBol));
                        break;
                    case "PRY":
                        SharedMaps.Converters.Services.Paraguay.PayOutMapperParaguay LPMapperPry = new SharedMaps.Converters.Services.Paraguay.PayOutMapperParaguay();
                        var listResponsePry = LPMapperPry.MapperModelsBatch(PayoutListToSend);
                        if (listResponsePry.Count > 0) JsonString.Add(JsonConvert.SerializeObject(listResponsePry));
                        break;
                }
            }

            return JsonString;
        }
    }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class CallbackTransaction
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string idEntityUser { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string idTransaction { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class CallbackConfiguration
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public int idEntityUser { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string notificationUrl { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string customer { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string countryCode { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public List<CallbackParameter> parameters { get; set; } = new List<CallbackParameter>();
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public bool signature { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

    }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class CallbackParameter
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string parameterName { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string parameterValue { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }

}