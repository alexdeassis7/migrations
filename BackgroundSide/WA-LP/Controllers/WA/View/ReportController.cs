using Newtonsoft.Json;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using SharedModel.Models.View;
using System.Web.Http.Cors;
using System.Collections.Generic;
using WA_LP.Controllers.Export;
using SharedModel.Models.Security;
using System.Web.Http.Description;
using Newtonsoft.Json.Linq;
using System;
using SharedBusiness.Mail;
using System.Configuration;

namespace WA_LP.Controllers.WA.View
{
    [Authorize]
    [RoutePrefix("v2/report")]

    [ApiExplorerSettings(IgnoreApi = true)]


#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class ReportController : BaseApiController
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        [HttpPost]
        [Route("list_merchant_balance")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_merchant_balance()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                string countryCode = headers.GetValues("countryCode").First();

                if (customer != null && customer.Length > 0 && countryCode != null && countryCode.Length >= 3)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();

                    Dashboard.List.Response response = new Dashboard.List.Response();

                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.ListMerchantBalance(lRequest, customer, countryCode);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }

        [HttpPost]
        [Route("list_merchant_proyected_balance")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_merchant_proyected_balance()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                string countryCode = headers.GetValues("countryCode").First();

                if (customer != null && customer.Length > 0 && countryCode != null && countryCode.Length >= 3)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();

                    Dashboard.List.Response response = new Dashboard.List.Response();

                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.ListMerchantProyectedBalance(lRequest, customer, countryCode);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }

        [HttpPost]
        [Route("activity_report")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_activity_report()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                string countryCode = headers.GetValues("countryCode").First();

                if (customer != null && customer.Length > 0 && countryCode != null && countryCode.Length >= 3)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();

                    Dashboard.List.Response response = new Dashboard.List.Response();

                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.ListActivityReport(lRequest, customer, countryCode);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }

        [HttpPost]
        [Route("account_transaction")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage Account_transaction()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                string countryCode = headers.GetValues("countryCode").First();

                if (customer != null && customer.Length > 0 && countryCode != null && countryCode.Length >= 3)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();

                    Dashboard.List.Response response = new Dashboard.List.Response();

                    //SharedModel.Models.Services.Banks.Galicia.PayOut.LotBatch LotBatch = new SharedModel.Models.Services.Banks.Galicia.PayOut.LotBatch();

                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.AccountTransaction(lRequest, customer, countryCode);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }

        [HttpPost]
        [Route("list_transaction")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_transaction()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                string countryCode = headers.GetValues("countryCode").First();

                if (customer != null && customer.Length > 0 && countryCode != null && countryCode.Length >= 3)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();

                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.ListTransaction(lRequest, customer, countryCode);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }
        [HttpPost]
        [Route("list_transaction_detail_colombia")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_Transaction_Detail_Colombia()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            return null;
        }
        [HttpPost]
        [Route("list_transaction_client_details")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_transaction_client_details()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();

                if (customer != null && customer.Length > 0)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();



                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.ListTransactionClientDetails(lRequest, customer);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }

        [HttpPost]
        [Route("list_historical_fx")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_Historical_Fx()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();

                if (customer != null && customer.Length > 0)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();



                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.ListHistoricalFx(lRequest, customer);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }

        [HttpPost]
        [Route("list_operation_retention")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_Operation_Retention()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();

                if (customer != null && customer.Length > 0)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();



                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.ListOperationRetention(lRequest, customer);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }

        [HttpPost]
        [Route("list_operation_retention_monthly")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_Operation_RetentionMonthly()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();

                if (customer != null && customer.Length > 0)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();



                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.ListOperationRetentionMonthly(lRequest, customer);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }

        }

        [HttpPost]
        [Route("downloadExcelAfipRetention")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage DownloadExcelAfipRetention()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();

                if (customer != null && customer.Length > 0)
                {
                    ExportController _ExpController = new ExportController();

                    _ExpController.exportToExcel();
                    
                    //Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    //Report.List.Response lResponse = new Report.List.Response();



                    //SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    //lResponse = BiReport.ListOperationRetentionMonthly(lRequest, customer);

                    //return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));
                    return new HttpResponseMessage();
                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }

        }

        [HttpPost]
        [Route("list_merchant_report")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_Merchant_Report()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();

                if (customer != null && customer.Length > 0)
                {


                    Report.List.Request lRequest = JsonConvert.DeserializeObject<Report.List.Request>(data);
                    Report.List.Response lResponse = new Report.List.Response();

                    Dashboard.List.Response response = new Dashboard.List.Response();

                    //SharedModel.Models.Services.Banks.Galicia.PayOut.LotBatch LotBatch = new SharedModel.Models.Services.Banks.Galicia.PayOut.LotBatch();

                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.List_Merchant_Report(lRequest, customer);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.TransactionList));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }

        [HttpPost]
        [Route("list_rejected_transaction")]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage ListTransactionsError()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {

            //try
            //{
       
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;

            if (data != null && data.Length > 0)
            {
                string countryCode = Request.Headers.GetValues("countryCode").First();
                string customer = Request.Headers.GetValues("customer_id").First();

                if (customer != null && customer.Length > 0 && countryCode != null && countryCode.Length >= 3)
                {

                    SharedModel.Models.View.Report.List.Request lRequest = JsonConvert.DeserializeObject<  SharedModel.Models.View.Report.List.Request > (data);
                    SharedModel.Models.View.Report.List.Response Response = new SharedModel.Models.View.Report.List.Response();
                    List<SharedModel.Models.Security.TransactionError.List.Model> dataExportRejectedTransactions = new List<SharedModel.Models.Security.TransactionError.List.Model>();

                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    Response = BiReport.ListTransactionsError(lRequest, customer);
                    dataExportRejectedTransactions = JsonConvert.DeserializeObject<List<SharedModel.Models.Security.TransactionError.List.Model>>(Response.TransactionList);

                    return Request.CreateResponse(HttpStatusCode.OK, dataExportRejectedTransactions);

                }
                else
                {

                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
            //}
            //catch (Exception ex)
            //{

            //    throw;
            //}

        }


        [HttpPost]
        [Route("admin_email_notification")]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage EmailNotification()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            //GET TRANSACTION LOTS
            List<TransactionModel.TransactionLot.Response> ListTransactionLot = new List<TransactionModel.TransactionLot.Response>();
            SharedBusiness.View.BlTransaction BiTransaction = new SharedBusiness.View.BlTransaction();
            ListTransactionLot = BiTransaction.GetTransactionLots(data);

            foreach (var transactionLot in ListTransactionLot)
            {
                //CREATE MAIL
                var messageBody = Tools.MailHelper.CreateTransactionLotMailBody(transactionLot);

                //SEND EMAIL
                var AdminEmails = ConfigurationManager.AppSettings["AUTOMATED_EMAIL_ADMIN_EMAIL"].ToString().Split(';');
                var subject = String.Format(ConfigurationManager.AppSettings["AUTOMATED_EMAIL_MANUAL_TRANSACTION_LOT_SUBJECT"].ToString(), transactionLot.Merchant, transactionLot.LotDate.ToString("dd/MM/yyyy HH:ss"), transactionLot.TotalTransactions, String.Format("{0} {1}", transactionLot.CurrencyType, Math.Round(transactionLot.TotalAmount, 2)));
                MailService.SendMail(subject, messageBody, AdminEmails);
            }

            return Request.CreateResponse(HttpStatusCode.OK, "");
        }



        [HttpPost]
        [Route("list_clients_config")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage list_clients_config()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            HttpContent requestContent = Request.Content;
            string data = requestContent.ReadAsStringAsync().Result;
            if (data != null && data.Length > 0)
            {

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                //string countryCode = headers.GetValues("countryCode").First();

                if (customer != null && customer.Length > 0)
                {


                    Report.UserConfig.Request lRequest = JsonConvert.DeserializeObject<Report.UserConfig.Request>(data);
                    Report.UserConfig.Response lResponse = new Report.UserConfig.Response();

                    Dashboard.List.Response response = new Dashboard.List.Response();

                    SharedBusiness.View.BIReport BiReport = new SharedBusiness.View.BIReport();

                    lResponse = BiReport.ListUserConfig(lRequest.ClientName);
                    return Request.CreateResponse(HttpStatusCode.OK, lResponse);
                   // return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(lResponse.UsersApi));

                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }

    }
}
