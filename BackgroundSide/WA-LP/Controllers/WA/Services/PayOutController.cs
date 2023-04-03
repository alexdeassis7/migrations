﻿using Newtonsoft.Json;
using SharedBusiness.Exceptions;
using SharedBusiness.Filters;
using SharedBusiness.Log;
using SharedBusiness.Mail;
using SharedBusiness.Services.Bolivia;
using SharedBusiness.Services.Chile;
using SharedBusiness.Services.CostaRica;
using SharedBusiness.Services.CrossCutting;
using SharedBusiness.Services.Ecuador;
using SharedBusiness.Services.ElSalvador;
using SharedBusiness.Services.Mexico;
using SharedBusiness.Services.Panama;
using SharedBusiness.Services.Paraguay;
using SharedBusiness.Services.Peru;
using SharedBusiness.Services.Uruguay;
using SharedMaps.Converters.Services.Bolivia;
using SharedMaps.Converters.Services.CostaRica;
using SharedMaps.Converters.Services.Ecuador;
using SharedMaps.Converters.Services.ElSalvador;
using SharedMaps.Converters.Services.Panama;
using SharedMaps.Converters.Services.Paraguay;
using SharedModel.Models.Beneficiary;
using SharedModel.Models.CrossCountry;
using SharedModel.Models.Filters;
using SharedModel.Models.General;
using SharedModel.Models.Services.Bolivia;
using SharedModel.Models.Services.Bolivia.Validation;
using SharedModel.Models.Services.Chile;
using SharedModel.Models.Services.CostaRica;
using SharedModel.Models.Services.Ecuador;
using SharedModel.Models.Services.ElSalvador;
using SharedModel.Models.Services.Mexico;
using SharedModel.Models.Services.Panama;
using SharedModel.Models.Services.Paraguay;
using SharedModel.Models.Services.Peru;
using SharedModel.Models.Services.Uruguay;
using Swashbuckle.Swagger.Annotations;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Web.Http.Description;
using WA_LP.Cache;
using WA_LP.Infrastructure;
using static SharedModel.Models.Services.Mexico.PayOutMexico;
using static SharedModel.Models.Services.Payouts.Payouts;

namespace WA_LP.Controllers.WA.Services
{
   // [Authorize]
    [RoutePrefix("v3/integration")]
    [ApiExplorerSettings(IgnoreApi = false)]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class PayOutController : BaseApiController
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        /// <summary>
        /// Create
        /// </summary>
        /// <remarks>
        /// </remarks>
        [HttpPost]
        [Route("providers")]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(List<SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Request>))]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(List<SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Response>))]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Request>))]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Response>))]
        [SwaggerResponse(HttpStatusCode.BadRequest, Type = typeof(GeneralErrorModel))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, Type = typeof(GeneralErrorModel))]
        public HttpResponseMessage Payouts()
        {
            String data = "";
            string customer = "";
            string countryCode = "";
            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {
                HttpContent requestContent = Request.Content;
                data = requestContent.ReadAsStringAsync().Result;

                string customerByAdmin = null;
                string countryCodeByAdmin = null;

                LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0},REQUEST HEADERS: {1}, REQUEST DATA {2}", transactionIdLog, Request.Headers.ToString(), data));

                if (data != null && data.Length > 0)
                {
                    var re = Request;
                    var headers = re.Headers;

                    string _customer = string.Empty;
                    string _countryCode = string.Empty;
                    string _provider = string.Empty;

                    if (headers.Contains("provider"))
                        _provider = headers.GetValues("provider").First();

                    if (headers.Contains("customer_id"))
                        _customer = headers.GetValues("customer_id").First();

                    if (headers.Contains("countryCode"))
                        _countryCode = headers.GetValues("countryCode").First();

                    customerByAdmin = headers.Contains("customerByAdmin") ? headers.GetValues("customerByAdmin").First() : null;
                    countryCodeByAdmin = headers.Contains("countryCodeByAdmin") ? headers.GetValues("countryCodeByAdmin").First() : null;

                    bool TransactionMechanism = headers.Contains("TransactionMechanism") == false ? false : Convert.ToBoolean(((string[])headers.GetValues("TransactionMechanism"))[0]) == false ? false : true;

                    customer = _customer;
                    countryCode = _countryCode;

                    if (customerByAdmin != null && countryCodeByAdmin != null)
                    {
                        customer = customerByAdmin;
                        countryCode = countryCodeByAdmin;
                    }

                    if (string.IsNullOrEmpty(customer) || string.IsNullOrEmpty(countryCode))
                    {
                        GeneralErrorModel Error = new GeneralErrorModel()
                        {
                            Code = "400",
                            CodeDescription = "BadRequest",
                            Message = "Bad Parameter Value or Parameters Values."
                        };

                        LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0},Bad Request - No Customer or Country", transactionIdLog));

                        return Request.CreateResponse(HttpStatusCode.BadRequest, Error);
                    }

                    var subMerchantsUsers = new BlFilters().GetListSubMerchantUser();
                    var blackList = new BlFilters().GetBlackLists();

                    List<SharedModel.Models.Database.General.BankCodesModel.BankCodesOrdered> bankCodes = BankValidateCacheService.Get();
                    var validatorData = new Dictionary<object, object>();
                    validatorData.Add("bankCodes", bankCodes);
                    validatorData.Add("countryCode", countryCode);

                    #region Argentina

                    if (countryCode == "ARG")
                    {
                        List<SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Request> lRequest = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Request>>(data);
                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        List<SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Response> lResponse = new List<SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Response>();

                        foreach (SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Request model in lRequest)
                        {
                            model.ErrorRow.Errors = SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && x.CountryCode == countryCode)) && x.Description == model.submerchant_code);
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;


                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name) || string.IsNullOrEmpty(model.sender_address) || string.IsNullOrEmpty(model.sender_country)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }

                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                            //if (model.beneficiary_name != null && model.beneficiary_cuit != null)
                            //{
                            //    if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.bank_cbu.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_cuit.Replace(" ", "").ToLower()))
                            //    {
                            //        model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                            //    }
                            //}
                            //if (model.sender_name != null)
                            //{
                            //    if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                            //    {
                            //        model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                            //    }
                            //}
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();

                            //if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            //{
                            //    model.ToOnHold = true;
                            //    LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0},Duplicate Transaction", transactionIdLog));

                            //}
                        }

                        var ListWhitOutErrors = lRequest.Where(x => x.ErrorRow.HasError == false).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError == true).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            SharedBusiness.Services.Banks.Galicia.BIPayOut BiPO = new SharedBusiness.Services.Banks.Galicia.BIPayOut();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Response>>(a));


                            //if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            //{
                            //    var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                            //    var body = "<font>The following transactions were rejected: </font><br><br>";
                            //    body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                            //    MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED_TraceIdLog:" + transactionIdLog, body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            //}
                        }

                        List<SharedModel.Models.Security.TransactionError.ModelDB> ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        SharedBusiness.Security.BlLog BlLog = new SharedBusiness.Security.BlLog();

                        List<SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Response> ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        List<SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Response> ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            List<string> ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            List<string> onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {
                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                List<ErrorCode> _errors = new List<ErrorCode>();
                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_cuit;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.cbu = e.bank_cbu;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }
                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);
                        }
                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                        //return Request.CreateResponse(HttpStatusCode.OK, lResponse);

                        List<String> ticketsNumbers = new List<String>(); //alex

                        foreach (SharedModel.Models.Services.Banks.Galicia.PayOut.Create.Response transaction in lResponse) //alex
                        {
                            ticketsNumbers.Add(transaction.Ticket); //alex
                        }

                        string jsonTickets = JsonConvert.SerializeObject(ticketsNumbers); //alex 

                        return DownloadPayOutBankTxt(_provider, ticketsNumbers); //alex

                    }

                    #endregion

                    #region Colombia

                    else if (countryCode == "COL")
                    {
                        var aml = new BlFilters().GetAML(countryCode);
                        List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Request> lRequest = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Request>>(data);

                        if (lRequest.Count > 0)
                        {
                            lRequest.Select(c => { c.beneficiary_email = string.IsNullOrEmpty(c.beneficiary_email) ? null : c.beneficiary_email; return c; }).ToList();
                        }

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Response> lResponse = new List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Response>();

                        foreach (SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Request model in lRequest)
                        {
                            model.ErrorRow.Errors = SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name) || string.IsNullOrEmpty(model.sender_address) || string.IsNullOrEmpty(model.sender_country)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                            /*if (model.beneficiary_name != null)
                            {
                                if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.id.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }
                            if (model.sender_name != null)
                            {
                                if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }*/
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0},Duplicate Transaction", transactionIdLog));

                            }
                        }

                        var ListWhitOutErrors = lRequest.Where(x => x.ErrorRow.HasError == false).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError == true).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            SharedBusiness.Services.Colombia.Banks.Bancolombia.BIPayOutColombia BiPO = new SharedBusiness.Services.Colombia.Banks.Bancolombia.BIPayOutColombia();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));

                            List<string> ticketsOnHold = new List<string>();

                           /* foreach (var item in lResponse)
                            {
                                if (aml.Any(x => x.accountNumber.Replace(" ", "").ToLower() == item.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == item.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == item.id.Replace(" ", "").ToLower()))
                                {
                                    //PUT ON HOLD TRANSACTION
                                    ticketsOnHold.Add(item.Ticket);
                                    item.status = "OnHold";
                                }
                            }*/

                            if (ticketsOnHold.Count > 0)
                            {
                                SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                                List<string> onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0},ONHOLD: ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT", transactionIdLog));

                                //SEND EMAIL
                                //var amllisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                                body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                                MailService.SendMail("ONHOLD: ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                            }

                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Response>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED_TraceIdLog:" + transactionIdLog, body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT" || y.Key == "ERROR_AMOUNT_EXCEEDS_SENDER_MAX_LIMIT")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT" || y.Key == "ERROR_AMOUNT_EXCEEDS_SENDER_MAX_LIMIT"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT/ERROR_AMOUNT_EXCEEDS_SENDER_MAX_LIMIT_TraceIdLog:" + transactionIdLog, body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }


                        }
                        List<SharedModel.Models.Security.TransactionError.ModelDB> ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        SharedBusiness.Security.BlLog BlLog = new SharedBusiness.Security.BlLog();

                        List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Response> ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Response> ResponseToOnHold = lResponse.Where(e => e.ErrorRow.HasError == false && e.ToOnHold == true).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            List<string> ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            List<string> onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                List<ErrorCode> _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.typeOfId = e.type_of_id;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }
                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        List<String> ticketsNumbers = new List<String>(); //alex
                    
                        foreach (SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.Create.Response transaction in lResponse) //alex
                        {
                            ticketsNumbers.Add(transaction.Ticket); //alex
                        }

                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                        //return Request.CreateResponse(HttpStatusCode.OK, lResponse);

                        string jsonTickets = JsonConvert.SerializeObject(ticketsNumbers); //alex 

                        return DownloadPayOutBankTxt(_provider, ticketsNumbers); //alex
                    }

                    #endregion

                    #region Uruguay

                    else if (countryCode == "URY")
                    {
                        List<SharedModel.Models.Services.Uruguay.PayOutUruguay.Create.Request> lRequest = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Uruguay.PayOutUruguay.Create.Request>>(data);

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        List<SharedModel.Models.Services.Uruguay.PayOutUruguay.Create.Response> lResponse = new List<SharedModel.Models.Services.Uruguay.PayOutUruguay.Create.Response>();

                        foreach (SharedModel.Models.Services.Uruguay.PayOutUruguay.Create.Request model in lRequest)
                        {
                            model.ErrorRow.Errors = SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name) || string.IsNullOrEmpty(model.sender_address) || string.IsNullOrEmpty(model.sender_country)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                            /*if (model.beneficiary_name != null)
                            {
                                if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }
                            if (model.sender_name != null)
                            {
                                if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }*/
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0},Duplicate Transaction", transactionIdLog));

                            }
                        }

                        var ListWhitOutErrors = lRequest.Where(x => x.ErrorRow.HasError == false).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError == true).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            SharedBusiness.Services.Uruguay.BIPayOutUruguay BiPO = new SharedBusiness.Services.Uruguay.BIPayOutUruguay();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Uruguay.PayOutUruguay.Create.Response>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED_TraceIdLog:" + transactionIdLog, body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                        }

                        List<SharedModel.Models.Security.TransactionError.ModelDB> ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        SharedBusiness.Security.BlLog BlLog = new SharedBusiness.Security.BlLog();

                        List<SharedModel.Models.Services.Uruguay.PayOutUruguay.Create.Response> ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        List<SharedModel.Models.Services.Uruguay.PayOutUruguay.Create.Response> ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            List<string> ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            List<string> onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                List<ErrorCode> _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.typeOfId = e.beneficiary_document_type;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }

                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                        //return Request.CreateResponse(HttpStatusCode.OK, lResponse);
                        List<String> ticketsNumbers = new List<String>(); //alex

                        foreach (SharedModel.Models.Services.Uruguay.PayOutUruguay.Create.Response transaction in lResponse) //alex
                        {
                            ticketsNumbers.Add(transaction.Ticket); //alex
                        }



                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                        //return Request.CreateResponse(HttpStatusCode.OK, lResponse);


                        string jsonTickets = JsonConvert.SerializeObject(ticketsNumbers); //alex 

                        return DownloadPayOutBankTxt(_provider, ticketsNumbers);//alex

                    }

                    #endregion

                    #region Brazil

                    else if (countryCode == "BRA")
                    {
                        List<SharedModel.Models.Services.Brasil.PayOutBrasil.Create.Request> lRequest = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Brasil.PayOutBrasil.Create.Request>>(data);

                        if (lRequest.Count > 0)
                        {
                            lRequest.Select(c => { c.beneficiary_email = string.IsNullOrEmpty(c.beneficiary_email) ? null : c.beneficiary_email; return c; }).ToList();
                        }

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        List<SharedModel.Models.Services.Brasil.PayOutBrasil.Create.Response> lResponse = new List<SharedModel.Models.Services.Brasil.PayOutBrasil.Create.Response>();

                        foreach (SharedModel.Models.Services.Brasil.PayOutBrasil.Create.Request model in lRequest)
                        {
                            model.ErrorRow.Errors = SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name) || string.IsNullOrEmpty(model.sender_address) || string.IsNullOrEmpty(model.sender_country)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }

                            /*
                            if (_customer == "000003100001") //BL rule for  for Efx Capital customer
                            {
                                if (blackList.Any(x => (x.accountNumber.Replace(" ", "").Replace("-", "").Replace("/", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").Replace("-", "").Replace("/", "").ToLower() && x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower()) ||
                                                       (x.accountNumber.Replace(" ", "").Replace("-", "").Replace("/", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").Replace("-", "").Replace("/", "").ToLower() && x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()) ||
                                                       (x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() && x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower())))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                };
                            }
                            if (aml.Any(x => x.isSender == "0" && (x.accountNumber.Replace(" ", "").Replace("-", "").Replace("/", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").Replace("-", "").Replace("/", "").ToLower() || 
                                                                   x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || 
                                                                   x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower())))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_BRA_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT", Messages = new List<string>() { "Beneficiary exceeds transaction limit" }, CodeTypeError = new List<string> { "REJECTED" } });
                            }
                            if (model.sender_name != null && model.beneficiary_name != null)
                            {
                                if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }
                            */

                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            /*if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0}, Duplicate Transaction", transactionIdLog));

                            }*/

                        }

                        var ListWhitOutErrors = lRequest.Where(x => x.ErrorRow.HasError == false).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError == true).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            ListWhitOutErrors = Tools.ValidationHelper.ValidateRequestBrasil(ListWhitOutErrors);
                            SharedBusiness.Services.Brasil.BIPayOutBrasil BiPO = new SharedBusiness.Services.Brasil.BIPayOutBrasil();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));

                            //CALL AML BLACKLIST
                           // var aml = new BlFilters().GetAML(countryCode);
                            List<string> ticketsOnHold = new List<string>();

                            /*foreach (var item in lResponse)
                            {
                                if (aml.Any(x => x.isSender == "0" && (x.accountNumber.Replace(" ", "").Replace("-", "").Replace("/", "").ToLower() == item.beneficiary_account_number.Replace(" ", "").Replace("-", "").Replace("/", "").ToLower() ||
                                                                        x.beneficiaryName.Replace(" ", "").ToLower() == item.beneficiary_name.Replace(" ", "").ToLower() ||
                                                                        x.documentId.Replace(" ", "").ToLower() == item.beneficiary_document_id.Replace(" ", "").ToLower())))
                                {
                                    //PUT ON HOLD TRANSACTION
                                    ticketsOnHold.Add(item.Ticket);
                                    item.status = "OnHold";
                                }
                            }*/

                            if (ticketsOnHold.Count > 0)
                            {
                                SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                                List<string> onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0},ONHOLD: ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT", transactionIdLog));

                                //SEND EMAIL
                                //var amllisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                                body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                                MailService.SendMail("ONHOLD: ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                            }

                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Brasil.PayOutBrasil.Create.Response>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED_TraceIdLog:" + transactionIdLog, body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                        }
                        List<SharedModel.Models.Security.TransactionError.ModelDB> ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        SharedBusiness.Security.BlLog BlLog = new SharedBusiness.Security.BlLog();

                        List<SharedModel.Models.Services.Brasil.PayOutBrasil.Create.Response> ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        List<SharedModel.Models.Services.Brasil.PayOutBrasil.Create.Response> ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            List<string> ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            List<string> onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));

                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                List<ErrorCode> _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.bankBranch = e.bank_branch;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }
                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        List<String> ticketsNumbers = new List<String>(); //alex

                        //transactionModel = lResponse.Transactions;

                        foreach (SharedModel.Models.Services.Brasil.PayOutBrasil.Create.Response transaction in lResponse) //alex
                        {
                            ticketsNumbers.Add(transaction.Ticket); //alex
                        }

                        //SharedModel.Models.Services.Brasil.PayOutBrasil.DownloadLotBatchTransactionToBank.ExcelResponse lotResponseDonwload;
                        //List<TransactionModel> transactionModel;

                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                        //DownloadPayOutBankTxt("SAFRA" );


                        string jsonTickets = JsonConvert.SerializeObject(ticketsNumbers); //alex 
                        //return Request.CreateResponse(HttpStatusCode.OK, lResponse);
                        return DownloadPayOutBankTxt(_provider, ticketsNumbers); //alex
                    }

                    #endregion

                    #region Mexico

                    else if (countryCode == "MEX")
                    {
                        List<SharedModel.Models.Services.Mexico.PayOutMexico.Create.Request> lRequest = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Mexico.PayOutMexico.Create.Request>>(data);

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        List<SharedModel.Models.Services.Mexico.PayOutMexico.Create.Response> lResponse = new List<SharedModel.Models.Services.Mexico.PayOutMexico.Create.Response>();

                        foreach (SharedModel.Models.Services.Mexico.PayOutMexico.Create.Request model in lRequest)
                        {

                            if (model.bank_code == null || model.bank_code == "")
                                model.bank_code = model.beneficiary_account_number != null ? model.beneficiary_account_number.Substring(0, 3) : null;

                            model.ErrorRow.Errors = SharedModel.Models.Shared.ValidationModel.ValidatorModel(model);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                            //if (model.beneficiary_name != null)
                            //{
                            //    if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || (x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower() && x.documentId.Replace(" ", "").ToLower() != "")))
                            //    {
                            //        model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                            //    }
                            //}
                            //if (model.sender_name != null)
                            //{
                            //    if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                            //    {
                            //        model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                            //    }
                            //}
                            //SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            //if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            //{
                            //    model.ToOnHold = true;
                            //    LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0}, Duplicate Transaction", transactionIdLog));

                            //}
                        }

                        var ListWhitOutErrors = lRequest.Where(x => x.ErrorRow.HasError == false).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError == true).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            SharedBusiness.Services.Mexico.BIPayOutMexico BiPO = new SharedBusiness.Services.Mexico.BIPayOutMexico();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Mexico.PayOutMexico.Create.Response>>(a));

                            //if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            //{
                            //    var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                            //    var body = "<font>The following transactions were rejected: </font><br><br>";
                            //    body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                            //    MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED_TraceIdLog:" + transactionIdLog, body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            //}
                        }

                        List<SharedModel.Models.Security.TransactionError.ModelDB> ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        SharedBusiness.Security.BlLog BlLog = new SharedBusiness.Security.BlLog();

                        List<SharedModel.Models.Services.Mexico.PayOutMexico.Create.Response> ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        List<SharedModel.Models.Services.Mexico.PayOutMexico.Create.Response> ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            List<string> ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            List<string> onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                List<ErrorCode> _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }

                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        List<String> ticketsNumbers = new List<String>(); //alex

                        foreach (SharedModel.Models.Services.Mexico.PayOutMexico.Create.Response transaction in lResponse) //alex
                        {
                            ticketsNumbers.Add(transaction.Ticket); //alex
                        }

                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                      
                        string jsonTickets = JsonConvert.SerializeObject(ticketsNumbers); //alex 

                        return DownloadPayOutBankTxt(_provider, ticketsNumbers);//alex

                    }

                    #endregion

                    #region Chile

                    else if (countryCode == "CHL")
                    {
                        List<SharedModel.Models.Services.Chile.PayOutChile.Create.Request> lRequest = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Chile.PayOutChile.Create.Request>>(data);

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        List<SharedModel.Models.Services.Chile.PayOutChile.Create.Response> lResponse = new List<SharedModel.Models.Services.Chile.PayOutChile.Create.Response>();

                        foreach (SharedModel.Models.Services.Chile.PayOutChile.Create.Request model in lRequest)
                        {
                            model.ErrorRow.Errors = SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                           /* if (model.beneficiary_name != null)
                            {
                                if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }
                            if (model.sender_name != null)
                            {
                                if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }*/
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0}, Duplicate Transaction", transactionIdLog));

                            }
                        }

                        var ListWhitOutErrors = lRequest.Where(x => x.ErrorRow.HasError == false).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError == true).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            SharedBusiness.Services.Chile.BIPayOutChile BiPO = new SharedBusiness.Services.Chile.BIPayOutChile();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Chile.PayOutChile.Create.Response>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED_TraceIdLog:" + transactionIdLog, body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                        }

                        List<SharedModel.Models.Security.TransactionError.ModelDB> ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        SharedBusiness.Security.BlLog BlLog = new SharedBusiness.Security.BlLog();

                        List<SharedModel.Models.Services.Chile.PayOutChile.Create.Response> ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        List<SharedModel.Models.Services.Chile.PayOutChile.Create.Response> ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            List<string> ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            List<string> onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                List<ErrorCode> _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.typeOfId = e.beneficiary_document_type;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }

                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        List<String> ticketsNumbers = new List<String>(); //alex
                               
                        foreach (SharedModel.Models.Services.Chile.PayOutChile.Create.Response transaction in lResponse) //alex
                        {
                            ticketsNumbers.Add(transaction.Ticket); //alex
                        }

                        

                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                        //return Request.CreateResponse(HttpStatusCode.OK, lResponse);


                        string jsonTickets = JsonConvert.SerializeObject(ticketsNumbers); //alex 
               
                        return DownloadPayOutBankTxt(_provider, ticketsNumbers);//alex

                    }

                    #endregion

                    #region Ecuador

                    else if (countryCode == "ECU")
                    {
                        var lRequest = JsonConvert.DeserializeObject<List<EcuadorPayoutCreateRequest>>(data);

                        var lResponse = new List<EcuadorPayoutCreateResponse>();

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        foreach (var model in lRequest)
                        {
                            model.ErrorRow.Errors =
                                SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                          /*  if (model.beneficiary_name != null)
                            {
                                if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }
                            if (model.sender_name != null)
                            {
                                if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }*/
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0}, Duplicate Transaction", transactionIdLog));

                            }
                        }

                        var ListWhitOutErrors = lRequest.Where(x => !x.ErrorRow.HasError).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            var BiPO = new BIPayoutEcuador();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<EcuadorPayoutCreateResponse>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED", body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                        }

                        var ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        var BlLog = new SharedBusiness.Security.BlLog();

                        var ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        var ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            var ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            var BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            var onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));

                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                var _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.typeOfId = e.beneficiary_document_type;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }

                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }
                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                       // return Request.CreateResponse(HttpStatusCode.OK, lResponse); alex



                        List<String> ticketsNumbers = new List<String>(); //alex

                        foreach (SharedModel.Models.Services.Ecuador.EcuadorPayoutCreateResponse transaction in lResponse) //alex
                        {
                            ticketsNumbers.Add(transaction.Ticket); //alex
                        }



                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                        //return Request.CreateResponse(HttpStatusCode.OK, lResponse);


                        string jsonTickets = JsonConvert.SerializeObject(ticketsNumbers); //alex 

                        return DownloadPayOutBankTxt(_provider, ticketsNumbers);//alex
                    }

                    #endregion

                    #region Peru

                    else if (countryCode == "PER")
                    {

                        List<SharedModel.Models.Services.Peru.PeruPayoutCreateRequest> lRequest = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Peru.PeruPayoutCreateRequest>>(data);

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        List<SharedModel.Models.Services.Peru.PeruPayoutCreateResponse> lResponse = new List<SharedModel.Models.Services.Peru.PeruPayoutCreateResponse>();

                        foreach (SharedModel.Models.Services.Peru.PeruPayoutCreateRequest model in lRequest)
                        {
                            model.ErrorRow.Errors = SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                            //if (model.beneficiary_name != null && model.sender_name != null && model.beneficiary_document_id != null)
                            //{
                                //if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
                                //{
                                //    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                //}
                                //if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                //{
                                //    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                //}
                            //}
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0}, Duplicate Transaction", transactionIdLog));

                            }
                        }

                        var ListWhitOutErrors = lRequest.Where(x => x.ErrorRow.HasError == false).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError == true).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            SharedBusiness.Services.Peru.BIPayOutPeru BiPO = new SharedBusiness.Services.Peru.BIPayOutPeru();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Peru.PeruPayoutCreateResponse>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED", body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                        }

                        List<SharedModel.Models.Security.TransactionError.ModelDB> ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        SharedBusiness.Security.BlLog BlLog = new SharedBusiness.Security.BlLog();

                        List<SharedModel.Models.Services.Peru.PeruPayoutCreateResponse> ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        List<SharedModel.Models.Services.Peru.PeruPayoutCreateResponse> ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            List<string> ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            List<string> onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                List<ErrorCode> _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.typeOfId = e.beneficiary_document_type;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }

                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        // return Request.CreateResponse(HttpStatusCode.OK, lResponse); alex

                        List<String> ticketsNumbers = new List<String>(); //alex

                        foreach (SharedModel.Models.Services.Peru.PeruPayoutCreateResponse transaction in lResponse) //alex
                        {
                            ticketsNumbers.Add(transaction.Ticket); //alex
                        }

                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                       
                        string jsonTickets = JsonConvert.SerializeObject(ticketsNumbers); //alex 

                        return DownloadPayOutBankTxt(_provider, ticketsNumbers);//alex

                    }

                    #endregion

                    #region Paraguay

                    else if (countryCode == "PRY")
                    {
                        var lRequest = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Paraguay.ParaguayPayoutCreateRequest>>(data);

                        var lResponse = new List<SharedModel.Models.Services.Paraguay.ParaguayPayoutCreateResponse>();

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        foreach (var model in lRequest)
                        {
                            model.ErrorRow.Errors =
                                SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            #region CustomValidationsForParaguay
                            if (model.amount < 0 || model.amount > long.MaxValue)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_AMOUNT_NOT_VALID", Messages = new List<string>() { "Amount is not valid" }, CodeTypeError = new List<string> { "ERROR_AMOUNT_NOT_VALID" } });
                            }
                            if (string.IsNullOrEmpty(model.beneficiary_account_number))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "beneficiary_account_number", Messages = new List<string>() { "Parameter :: beneficiary account number :: is required.#REQUIRED" }, CodeTypeError = new List<string> { "beneficiary_account_number" } });
                                model.beneficiary_account_number = string.Empty;
                            }

                            if (string.IsNullOrEmpty(model.bank_account_type))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "bank_account_type", Messages = new List<string>() { "Parameter :: bank account type :: is required.#REQUIRED" }, CodeTypeError = new List<string> { "bank_account_type" } });
                                model.bank_account_type = string.Empty;
                            }
                            if (string.IsNullOrEmpty(model.beneficiary_name))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "beneficiary_name", Messages = new List<string>() { "Parameter :: beneficiary_name :: is required.#REQUIRED" }, CodeTypeError = new List<string> { "beneficiary_name" } });
                                model.beneficiary_name = string.Empty;
                            }
                            if (string.IsNullOrEmpty(model.beneficiary_document_id))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "beneficiary_document_id", Messages = new List<string>() { "Parameter :: beneficiary_document_id :: is required.#REQUIRED" }, CodeTypeError = new List<string> { "beneficiary_document_id" } });
                                model.beneficiary_document_id = string.Empty;
                            }
                            if (model.beneficiary_document_type == "CI" && model.beneficiary_document_id.Length != 7)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "InvalidDocumentIdLength", Messages = new List<string>() { "Invalid Document Length For CI. Length must be equal to 7" }, CodeTypeError = new List<string> { "InvalidDocumentIdLength" } });
                                model.beneficiary_document_type = string.Empty;
                                model.beneficiary_document_id = string.Empty;
                            }
                            else if (model.beneficiary_document_type == "RUC" && model.beneficiary_document_id.Length != 9)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "InvalidDocumentIdLength", Messages = new List<string>() { "Invalid Document Length For RUC. Length must be equal to 9" }, CodeTypeError = new List<string> { "InvalidDocumentIdLength" } });
                                model.beneficiary_document_type = string.Empty;
                                model.beneficiary_document_id = string.Empty;
                            }
                            if (string.IsNullOrEmpty(model.bank_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "BankCodeNullEmpty", Messages = new List<string>() { "Parameter :: bank code :: is required.#REQUIRED" }, CodeTypeError = new List<string> { "BankCodeNullEmpty" } });
                                model.bank_code = string.Empty;
                            }
                            if (string.IsNullOrEmpty(model.currency))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "CurrencyNullEmpty", Messages = new List<string>() { "Parameter :: currency :: is required.#REQUIRED" }, CodeTypeError = new List<string> { "CurrencyNullEmpty" } });
                                model.currency = string.Empty;
                            }
                            #endregion

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                           /* if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                            }
                            if (model.sender_name != null)
                            {
                                if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }*/
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0}, Duplicate Transaction", transactionIdLog));

                            }

                        }

                        var ListWhitOutErrors = lRequest.Where(x => !x.ErrorRow.HasError).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            var BiPO = new BIPayoutParaguay();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Paraguay.ParaguayPayoutCreateResponse>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED", body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                        }

                        var ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        var BlLog = new SharedBusiness.Security.BlLog();

                        var ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        var ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            var ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            var BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            var onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                var _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                //errorModel.typeOfId = e.beneficiary_document_type;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }

                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        List<String> ticketsNumbers = new List<String>(); //alex

                        foreach (SharedModel.Models.Services.Paraguay.ParaguayPayoutCreateResponse transaction in lResponse) //alex
                        {
                            ticketsNumbers.Add(transaction.Ticket); //alex
                        }


                        LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0}, StatusCode: OK, RESPONSE {1}", transactionIdLog, JsonConvert.SerializeObject(lResponse)));
                        //return Request.CreateResponse(HttpStatusCode.OK, lResponse);


                        string jsonTickets = JsonConvert.SerializeObject(ticketsNumbers); //alex 

                        return DownloadPayOutBankTxt(_provider, ticketsNumbers);//alex


                       // return Request.CreateResponse(HttpStatusCode.OK, lResponse);
                    }

                    #endregion

                    #region Bolivia

                    else if (countryCode == "BOL")
                    {
                        // TODO: Mejorar el pase de parametros
                        return ProcessBoliviaPayout(data, customer, countryCode, customerByAdmin, countryCodeByAdmin, _customer, TransactionMechanism, subMerchantsUsers, blackList, validatorData, _provider);
                    }

                    #endregion

                    #region Panama

                    else if (countryCode == "PAN")
                    {
                        var lRequest = JsonConvert.DeserializeObject<List<PanamaPayoutCreateRequest>>(data);

                        var lResponse = new List<PanamaPayoutCreateResponse>();

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        foreach (var model in lRequest)
                        {
                            model.ErrorRow.Errors =
                                SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                            if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                            }
                            if (model.sender_name != null)
                            {
                                if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0}, Duplicate Transaction", transactionIdLog));

                            }
                        }

                        var ListWhitOutErrors = lRequest.Where(x => !x.ErrorRow.HasError).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            var BiPO = new BIPayoutPanama();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<PanamaPayoutCreateResponse>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED", body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                        }

                        var ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        var BlLog = new SharedBusiness.Security.BlLog();

                        var ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        var ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            var ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            var BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            var onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                var _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.typeOfId = e.beneficiary_document_type;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }

                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        return Request.CreateResponse(HttpStatusCode.OK, lResponse);
                    }

                    #endregion

                    #region CostaRica

                    else if (countryCode == "CRI")
                    {
                        var lRequest = JsonConvert.DeserializeObject<List<CostaRicaPayoutCreateRequest>>(data);

                        var lResponse = new List<CostaRicaPayoutCreateResponse>();

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        foreach (var model in lRequest)
                        {
                            model.ErrorRow.Errors =
                                SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                            if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                            }
                            if (model.sender_name != null)
                            {
                                if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0}, Duplicate Transaction", transactionIdLog));

                            }
                        }

                        var ListWhitOutErrors = lRequest.Where(x => !x.ErrorRow.HasError).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            var BiPO = new BIPayoutCostaRica();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<CostaRicaPayoutCreateResponse>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED", body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                        }

                        var ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        var BlLog = new SharedBusiness.Security.BlLog();

                        var ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());


                        var ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            var ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            var BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            var onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                var _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.typeOfId = e.beneficiary_document_type;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }

                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        return Request.CreateResponse(HttpStatusCode.OK, lResponse);
                    }

                    #endregion

                    #region ElSalvador

                    else if (countryCode == "SLV")
                    {
                        var lRequest = JsonConvert.DeserializeObject<List<ElSalvadorPayoutCreateRequest>>(data);

                        var lResponse = new List<ElSalvadorPayoutCreateResponse>();

                        if (lRequest.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                            throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

                        foreach (var model in lRequest)
                        {
                            model.ErrorRow.Errors =
                                SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                            var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                            var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                            {
                                Identification = model.submerchant_code,
                                IsCorporate = true
                            };
                            subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                            if (subMerchant == null)
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
                            }
                            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
                            }
                            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
                            }
                            if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
                            {
                                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                            }
                            if (model.sender_name != null)
                            {
                                if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
                                {
                                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
                                }
                            }
                            SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            if (BiP.CheckDuplicity(model.amount, model.beneficiary_name, customer, countryCode))
                            {
                                model.ToOnHold = true;
                                LogService.LogInfo(string.Format("TRANSACTIONIDLOG: {0}, Duplicate Transaction", transactionIdLog));

                            }
                        }

                        var ListWhitOutErrors = lRequest.Where(x => !x.ErrorRow.HasError).ToList();
                        var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError).ToList();

                        if (ListWhitOutErrors.Count > 0)
                        {
                            var BiPO = new BIPayoutElSalvador();
                            lResponse.AddRange(BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism, countryCode));
                        }
                        if (ListWhitErrors.Count > 0)
                        {
                            var a = JsonConvert.SerializeObject(ListWhitErrors);
                            lResponse.AddRange(JsonConvert.DeserializeObject<List<ElSalvadorPayoutCreateResponse>>(a));

                            if (ListWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                            {
                                var blacklisted = ListWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                                var body = "<font>The following transactions were rejected: </font><br><br>";
                                body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                                MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED", body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                            }
                        }

                        var ListTxError = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
                        var BlLog = new SharedBusiness.Security.BlLog();

                        var ResponseWithErrors = lResponse.Where(e => e.ErrorRow.HasError == true).ToList();

                        lResponse.ForEach(x => x.authenticate = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
                        lResponse.ForEach(x => x.ToOnHold = lRequest.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());

                        var ResponseToOnHold = lResponse.Where(e => (e.ErrorRow.HasError == false && e.authenticate == true) || e.ToOnHold).ToList();

                        if (ResponseToOnHold.Count > 0)
                        {
                            var ticketsOnHold = ResponseToOnHold.Select(x => x.Ticket).ToList();
                            var BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                            var onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                            lResponse.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");


                            var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                            body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                            MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
                        }

                        if (ResponseWithErrors.Count > 0)
                        {

                            SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                            foreach (var e in ResponseWithErrors)
                            {
                                errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                                var _errors = new List<ErrorCode>();

                                errorModel.idTransactionType = "2";
                                errorModel.idEntityUser = null;
                                errorModel.beneficiaryName = e.beneficiary_name;
                                errorModel.beneficiaryId = e.beneficiary_document_id;
                                errorModel.paymentDate = e.payout_date;
                                errorModel.typeOfId = e.beneficiary_document_type;
                                errorModel.amount = e.amount.ToString();
                                errorModel.accountType = e.bank_account_type;
                                errorModel.submerchantCode = e.submerchant_code;
                                errorModel.currency = e.currency;
                                errorModel.merchantId = e.merchant_id;
                                errorModel.beneficiaryAddress = e.beneficiary_address;
                                errorModel.beneficiaryCity = e.beneficiary_state;
                                errorModel.beneficiaryCountry = e.beneficiary_country;
                                errorModel.beneficiaryEmail = e.beneficiary_email;
                                errorModel.bankCode = e.bank_code;
                                errorModel.accountNumber = e.beneficiary_account_number;
                                errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                                errorModel.beneficiarySenderName = e.sender_name;
                                errorModel.beneficiarySenderAddress = e.sender_address;
                                errorModel.beneficiarySenderCountry = e.sender_country;
                                errorModel.beneficiarySenderState = e.sender_state;
                                errorModel.beneficiarySenderTaxid = e.sender_taxid;
                                errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                                errorModel.beneficiarySenderEmail = e.sender_email;

                                foreach (var error in e.ErrorRow.Errors)
                                {
                                    foreach (var code in error.CodeTypeError)
                                    {
                                        if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                                        {
                                            _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                                        }
                                    }
                                }
                                errorModel.errors = JsonConvert.SerializeObject(_errors);

                                ListTxError.Add(errorModel);
                            }

                            BlLog.InsertTransactionErrors(ListTxError, customer, countryCode, TransactionMechanism);

                        }

                        return Request.CreateResponse(HttpStatusCode.OK, lResponse);
                    }

                    #endregion

                    return Request.CreateResponse(HttpStatusCode.OK);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-Payouts - TRANSACTIONIDLOG: {0} BAD REQUEST", transactionIdLog));

                    return Request.CreateResponse(HttpStatusCode.BadRequest, Error);
                }
            }
            catch (ExceptionLimitPayout ex)
            {
                LogService.LogError(ex, customer, string.Format("PAYOUTController-Payouts - REQUEST {0}, COUNTRY {1}, TRANSACTIONIDLOG {2}", data, countryCode, transactionIdLog));

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "413",
                    CodeDescription = " Array size exceeds the maximum allowed",
                    Message ="The size of the array exceeds the maximum allowed.You can check our limits at: https://docs.v2.localpayment.com/request-a-payment/payout "
                };

                return Request.CreateResponse(HttpStatusCode.RequestEntityTooLarge, Error);
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, customer, string.Format("PAYOUTController-Payouts - REQUEST {0}, COUNTRY {1}, TRANSACTIONIDLOG {2}", data, countryCode, transactionIdLog));

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, Error);
            }
            
        }
        private HttpResponseMessage ProcessBoliviaPayout(string data, string customer, string countryCode, string customerByAdmin, string countryCodeByAdmin, string _customer, bool transactionMechanism, List<Filter.EntitySubMerchant> subMerchantsUsers, List<BlackList> blackList, Dictionary<object, object> validatorData, string _provider)
        {
            var request = JsonConvert.DeserializeObject<List<BoliviaPayoutCreateRequest>>(data);

            var response = new List<BoliviaPayoutCreateResponse>();

            if (request.Count > Convert.ToInt32(ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]))
                throw new ExceptionLimitPayout(string.Format("The max limit of the item in the array transaction is: {0}", ConfigurationManager.AppSettings["LIMIT_PAYOUT_CREATE_API_COUNT"]));

            foreach (var model in request)
            {
                model.ErrorRow.Errors =
                    SharedModel.Models.Shared.ValidationModel.ValidatorModel(model, validatorData);

                var subMerchant = subMerchantsUsers.FirstOrDefault(x => (x.Identification == _customer || ((x.MailAccount == _customer || (x.MailAccount == customerByAdmin && customerByAdmin != null)) && (x.CountryCode == countryCode || (x.CountryCode == countryCodeByAdmin && countryCodeByAdmin != null)))) && x.Description.ToLower() == model.submerchant_code.ToLower());
                var newSubmerchant = new SharedModel.Models.Filters.Filter.EntitySubMerchant
                {
                    Identification = model.submerchant_code,
                    IsCorporate = true
                };
                subMerchant = subMerchant != null ? subMerchant : newSubmerchant;

                ValidateSubMerchantsBolivia(blackList, model, subMerchant);
            }

            var listWhitoutErrors = request.Where(x => !x.ErrorRow.HasError).ToList();
            var listWhitErrors = request.Where(x => x.ErrorRow.HasError).ToList();

            if (listWhitoutErrors.Count > 0)
            {
                var businessPayout = new BIPayoutBolivia();
                response.AddRange(businessPayout.LotTransaction(listWhitoutErrors, customer, transactionMechanism, countryCode));
            }

            if (listWhitErrors.Count > 0)
            {
                var serializedErrors = JsonConvert.SerializeObject(listWhitErrors);
                response.AddRange(JsonConvert.DeserializeObject<List<BoliviaPayoutCreateResponse>>(serializedErrors));

                if (listWhitErrors.Any(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED")))
                {
                    var blacklisted = listWhitErrors.Where(x => x.ErrorRow.Errors.Any(y => y.Key == "ERROR_REJECTED_SENDER_BLACKLISTED" || y.Key == "ERROR_REJECTED_BENEFICIARY_BLACKLISTED"));
                    var body = "<font>The following transactions were rejected: </font><br><br>";
                    body += "<div> " + JsonConvert.SerializeObject(blacklisted) + " </div>";
                    MailService.SendMail("REJECTED: ERROR_REJECTED_BENEFICIARY_BLACKLISTED", body, ConfigurationManager.AppSettings["SupportEmails"].ToString().Split(';'));
                }
            }

            var listTxErrors = new List<SharedModel.Models.Security.TransactionError.ModelDB>();
            var businessLogs = new SharedBusiness.Security.BlLog();
            var responseWithErrors = response.Where(e => e.ErrorRow.HasError == true).ToList();

            response.ForEach(x => x.authenticate = request.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());

            response.ForEach(x => x.authenticate = request.Where(m => m.merchant_id == x.merchant_id).Select(s => s.authenticate).FirstOrDefault());
            response.ForEach(x => x.ToOnHold = request.Where(m => m.merchant_id == x.merchant_id).Select(s => s.ToOnHold).FirstOrDefault());

            var responseToOnHold = response.Where(e => e.ErrorRow.HasError == false && e.authenticate == true).ToList();

            if (responseToOnHold.Count > 0)
            {
                var ticketsOnHold = responseToOnHold.Select(x => x.Ticket).ToList();
                var BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                var onHoldResponse = BiP.HoldTransactions(ticketsOnHold, countryCode);
                response.Where(x => onHoldResponse.Any(a => a == x.Ticket)).ToList().ForEach(x => x.status = "OnHold");

                var body = "<font>The following transactions were put in OnHold: </font><br><br>";
                body += "<div> " + string.Join(",", ticketsOnHold.ToArray()) + " </div>";
                MailService.SendMail("ONHOLD: DUPLICITY OR AUTHENTICATE", body, ConfigurationManager.AppSettings["AmlEmails"].ToString().Split(';'));
            }

            if (responseWithErrors.Count > 0)
            {

                SharedModel.Models.Security.TransactionError.ModelDB errorModel;

                foreach (var e in responseWithErrors)
                {
                    errorModel = new SharedModel.Models.Security.TransactionError.ModelDB();

                    var _errors = new List<ErrorCode>();

                    errorModel.idTransactionType = "2";
                    errorModel.idEntityUser = null;
                    errorModel.beneficiaryName = e.beneficiary_name;
                    errorModel.beneficiaryId = e.beneficiary_document_id;
                    errorModel.paymentDate = e.payout_date;
                    errorModel.typeOfId = e.beneficiary_document_type;
                    errorModel.amount = e.amount.ToString();
                    errorModel.accountType = e.bank_account_type;
                    errorModel.submerchantCode = e.submerchant_code;
                    errorModel.currency = e.currency;
                    errorModel.merchantId = e.merchant_id;
                    errorModel.beneficiaryAddress = e.beneficiary_address;
                    errorModel.beneficiaryCity = e.beneficiary_state;
                    errorModel.beneficiaryCountry = e.beneficiary_country;
                    errorModel.beneficiaryEmail = e.beneficiary_email;
                    errorModel.bankCode = e.bank_code;
                    errorModel.accountNumber = e.beneficiary_account_number;
                    errorModel.beneficiaryBirthdate = e.beneficiary_birth_date;
                    errorModel.beneficiarySenderName = e.sender_name;
                    errorModel.beneficiarySenderAddress = e.sender_address;
                    errorModel.beneficiarySenderCountry = e.sender_country;
                    errorModel.beneficiarySenderState = e.sender_state;
                    errorModel.beneficiarySenderTaxid = e.sender_taxid;
                    errorModel.beneficiarySenderBirthDate = e.sender_birthdate;
                    errorModel.beneficiarySenderEmail = e.sender_email;

                    foreach (var error in e.ErrorRow.Errors)
                    {
                        foreach (var code in error.CodeTypeError)
                        {
                            if (_errors.Where(a => a.Code == code && a.Key == error.Key).ToList().Count == 0)
                            {
                                _errors.Add(new ErrorCode { Key = error.Key, Code = code });
                            }
                        }
                    }

                    errorModel.errors = JsonConvert.SerializeObject(_errors);

                    listTxErrors.Add(errorModel);
                }

                businessLogs.InsertTransactionErrors(listTxErrors, customer, countryCode, transactionMechanism);

            }

            List<String> ticketsNumbers = new List<String>(); //alex

            foreach (SharedModel.Models.Services.Bolivia.BoliviaPayoutCreateResponse transaction in response) //alex
            {
                ticketsNumbers.Add(transaction.Ticket); //alex
            }
            return DownloadPayOutBankTxt(_provider, ticketsNumbers);//alex;
        }

        private static void ValidateSubMerchantsBolivia(List<BlackList> blackList, BoliviaPayoutCreateRequest model, Filter.EntitySubMerchant subMerchant)
        {
            if (model.amount < 0 || model.amount > long.MaxValue)
            {
                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_AMOUNT_NOT_VALID", Messages = new List<string>() { "Amount is not valid" }, CodeTypeError = new List<string> { "ERROR_AMOUNT_NOT_VALID" } });
            }

            if (string.IsNullOrEmpty(model.beneficiary_document_id))
            {
                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "beneficiary_document_id", Messages = new List<string>() { "Parameter :: beneficiary_document_id :: is required.#REQUIRED" }, CodeTypeError = new List<string> { "beneficiary_document_id" } });
                model.beneficiary_document_id = string.Empty;
            }

            if (string.IsNullOrEmpty(model.beneficiary_account_number))
            {
                model.beneficiary_account_number = string.Empty;
            }

            if (string.IsNullOrEmpty(model.beneficiary_name))
            {
                model.beneficiary_name = string.Empty;
            }

            if (subMerchant == null)
            {
                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
            }
            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
            {
                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
            }

            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
            {
                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
            }

            //if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower()
            //    || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower()
            //    || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
            //{
            //    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
            //}

            if (string.IsNullOrEmpty(model.beneficiary_document_id))
            {
                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "beneficiary_document_id", Messages = new List<string>() { "Parameter :: beneficiary_document_id :: is required.#REQUIRED" }, CodeTypeError = new List<string> { "beneficiary_document_id" } });
                model.beneficiary_name = string.Empty;
            }

            // Validacion del Merchant
            if (subMerchant == null)
            {
                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "SubMerchantNotFound", Messages = new List<string>() { "SubMerchant not found" }, CodeTypeError = new List<string> { "SubMerchantNotFound" } });
            }
            else if (!subMerchant.IsCorporate && (string.IsNullOrEmpty(model.sender_name)))
            {
                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "MissingSenderInformation", Messages = new List<string>() { "Missing sender information" }, CodeTypeError = new List<string> { "MissingSenderInformation" } });
            }

            // Validacion de Payout si existe
            if (!string.IsNullOrEmpty(model.concept_code) && !DictionaryService.PayoutConceptExist(model.concept_code))
            {
                model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ConceptCodeNotFound", Messages = new List<string>() { "Concept Code not found" }, CodeTypeError = new List<string> { "ConceptCodeNotFound" } });
            }

            // BlackList
            //if (blackList.Any(x => x.accountNumber.Replace(" ", "").ToLower() == model.beneficiary_account_number.Replace(" ", "").ToLower() || x.beneficiaryName.Replace(" ", "").ToLower() == model.beneficiary_name.Replace(" ", "").ToLower() || x.documentId.Replace(" ", "").ToLower() == model.beneficiary_document_id.Replace(" ", "").ToLower()))
            //{
            //    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_BENEFICIARY_BLACKLISTED", Messages = new List<string>() { "Beneficiary is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
            //}

            // Sender Name
            //if (model.sender_name != null)
            //{
            //    if (blackList.Any(x => x.isSender == "1" && x.beneficiaryName.Replace(" ", "").ToLower() == model.sender_name.Replace(" ", "").ToLower()))
            //    {
            //        model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup { Key = "ERROR_REJECTED_SENDER_BLACKLISTED", Messages = new List<string>() { "Sender is in the blacklist" }, CodeTypeError = new List<string> { "REJECTED" } });
            //    }
            //}


            if (!model.ErrorRow.HasError)
            {
                var boliviaIdentificationValidator = new BoliviaIdentificationValidator();

                var identificationType = BoliviaIdentificationValidator.ConverToIdentificationType(model.beneficiary_document_type);

                if (identificationType == (int)IdentificationType.NotDefined)
                {
                    var error = "Parameter :: beneficiary_document_type :: value provided is an expected valid value, but is not registered internally yet (ERR: EN01)";

                    model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup
                    {
                        Key = "beneficiary_document_type value",
                        Messages = new List<string>() { error },
                        CodeTypeError = new List<string> { "UNEXPECTED" }
                    });
                }
                else
                {
                    var (isValidDocument, errorsValidation) = boliviaIdentificationValidator.IsValidIdentification(identificationType, model.beneficiary_document_id);

                    // Tipo de Identificacion y Numero de Identificacion
                    if (!isValidDocument)
                    {
                        errorsValidation.ForEach(error =>
                        {
                            var (field, errorMessage) = error;
                            model.ErrorRow.Errors.Add(new ErrorModel.ValidationErrorGroup
                            {
                                Key = field,
                                Messages = new List<string>() { errorMessage },
                                CodeTypeError = new List<string> { field }
                            });
                        });
                    }
                }
            }
        }

        /// <summary>
        /// Cancel
        /// </summary>
        [HttpDelete]
        [Route("cancel")]
        [SwaggerResponse(HttpStatusCode.OK)]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Request>))]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Response>))]
        [SwaggerResponse(HttpStatusCode.BadRequest, Type = typeof(GeneralErrorModel))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, Type = typeof(GeneralErrorModel))]
        public async System.Threading.Tasks.Task<HttpResponseMessage> Payout_cancel()
        {
            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;

                LogService.LogInfo(string.Format("PAYOUTController-Payout_cancel - TRANSACTIONIDLOG: {0},REQUEST HEADERS: {1}, REQUEST DATA {2}", transactionIdLog, Request.Headers.ToString(), data));


                if (data != null && data.Length > 0)
                {
                    var re = Request;
                    var headers = re.Headers;
                    string customer = headers.GetValues("customer_id").First();
                    bool TransactionMechanism = Request.Headers.Contains("TransactionMechanism") == false ? false : Convert.ToBoolean(((string[])Request.Headers.GetValues("TransactionMechanism"))[0]) == false ? false : true;

                    List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Request> lRequest = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Request>>(data);

                    List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Response> lResponse = new List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Response>();

                    foreach (SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Request model in lRequest)
                    {
                        model.ErrorRow.Errors = SharedModel.Models.Shared.ValidationModel.ValidatorModel(model);
                    }

                    var ListWhitOutErrors = lRequest.Where(x => x.ErrorRow.HasError == false).ToList();
                    var ListWhitErrors = lRequest.Where(x => x.ErrorRow.HasError == true).ToList();

                    if (ListWhitOutErrors.Count > 0)
                    {
                        SharedBusiness.Services.Banks.Galicia.BIPayOut BiPO = new SharedBusiness.Services.Banks.Galicia.BIPayOut();
                        List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Response> cancelledTxs = BiPO.LotTransaction(ListWhitOutErrors, customer, TransactionMechanism);
                        lResponse.AddRange(cancelledTxs);

                        // CANCEL TXS CALLBACK NOTIFICATION
                        await ClientCallbackService.SendCancelCallback(cancelledTxs, customer);
                    }
                    if (ListWhitErrors.Count > 0)
                    {
                        var a = JsonConvert.SerializeObject(ListWhitErrors);
                        lResponse.AddRange(JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Banks.Galicia.PayOut.Delete.Response>>(a));
                    }

                    LogService.LogInfo(string.Format("PAYOUTController-Payout_cancel - TRANSACTIONIDLOG: {0},REQUEST HEADERS: {1}, REQUEST DATA {2}", transactionIdLog, Request.Headers.ToString(), data));


                    return Request.CreateResponse(HttpStatusCode.OK, lResponse);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-Payout_cancel - TRANSACTIONIDLOG: {0}, ERROR - Bad Parameter Value or Parameters Values.", transactionIdLog));


                    return Request.CreateResponse(HttpStatusCode.BadRequest, Error);
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, string.Format("PAYOUTController-Payout_cancel - TRANSACTIONIDLOG: {0} ", transactionIdLog) + SerializeRequest());
                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, Error);
            }
        }

        [HttpPost]
        [Route("list")]
        [SwaggerResponse(HttpStatusCode.OK)]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(SharedModel.Models.Services.Banks.Galicia.PayOut.List.Request))]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(List<SharedModel.Models.Services.Banks.Galicia.PayOut.LotBatch>))]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(List<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.List.Response>))]
        [SwaggerResponse(HttpStatusCode.BadRequest, Type = typeof(GeneralErrorModel))]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage List_payouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;

                LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + " HEADERS: " + Request.Headers + "DATA: " + data);

                if (data != null && data.Length > 0)
                {
                    var re = Request;
                    var headers = re.Headers;
                    string customer = string.Empty;
                    string countryCode = string.Empty;

                    if (headers.Contains("customer_id"))
                        customer = headers.GetValues("customer_id").First();

                    if (headers.Contains("countryCode"))
                        countryCode = headers.GetValues("countryCode").First();


                    if (customer != null && customer.Length > 0)
                    {

                        SharedModel.Models.Services.Banks.Galicia.PayOut.List.Request lRequest = JsonConvert.DeserializeObject<SharedModel.Models.Services.Banks.Galicia.PayOut.List.Request>(data);
                        var errors = SharedModel.Models.Shared.ValidationModel.ValidatorModel(lRequest);
                        List<SharedModel.Models.Services.Banks.Galicia.PayOut.LotBatch> lResponse = new List<SharedModel.Models.Services.Banks.Galicia.PayOut.LotBatch>();
                        SharedModel.Models.Services.Banks.Galicia.PayOut.List.Response response = new SharedModel.Models.Services.Banks.Galicia.PayOut.List.Response();
                        SharedBusiness.Services.Banks.Galicia.BIPayOut BiPO = new SharedBusiness.Services.Banks.Galicia.BIPayOut();

                        if (lRequest.payout_id == 0 && lRequest.transaction_id == 0 && lRequest.merchant_id == null && (lRequest.date_from == null || lRequest.date_to == null))
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "400",
                                CodeDescription = "BadRequest",
                                Message = "Error - Filter is required."
                            };
                            LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - Filter is required.");
                            return Request.CreateResponse(HttpStatusCode.BadRequest, Error);
                        }

                        if (errors.Count() > 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "400",
                                CodeDescription = "BadRequest",
                                Message = "Bad Parameters Values in "
                            };
                            foreach (var error in errors)
                            {
                                Error.Message += String.Format("{0} ", error.Key);
                            }
                            LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Bad Parameters Values in " + Error.Message);
                            return Request.CreateResponse(HttpStatusCode.BadRequest, Error);
                        }

                        var listLotBachModel = BiPO.ListTransaction(lRequest, customer, countryCode);

                        if (countryCode == "ARG")
                        {
                            SharedMaps.Converters.Services.Banks.Galicia.PayOutMapper LPMapper = new SharedMaps.Converters.Services.Banks.Galicia.PayOutMapper();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - No data found.");

                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "COL")
                        {
                            var LPMapper = new SharedMaps.Converters.Services.Colombia.Banks.Bancolombia.PayOutMapperColombia();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - No data found.");
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "BRA")
                        {
                            var LPMapper = new SharedMaps.Converters.Services.Brasil.PayOutMapperBrasil();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - No data found.");

                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "URY")
                        {
                            var LPMapper = new SharedMaps.Converters.Services.Uruguay.PayOutMapperUruguay();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - No data found.");
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "CHL")
                        {
                            var LPMapper = new SharedMaps.Converters.Services.Chile.PayOutMapperChile();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - No data found.");
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "MEX")
                        {
                            var LPMapper = new SharedMaps.Converters.Services.Mexico.PayOutMapperMexico();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - No data found.");
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "ECU")
                        {
                            var LPMapper = new PayOutMapperEcuador();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - No data found.");
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "PER")
                        {
                            var LPMapper = new SharedMaps.Converters.Services.Peru.PayOutMapperPeru();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "PRY")
                        {
                            var LPMapper = new PayOutMapperParaguay();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "BOL")
                        {
                            var LPMapper = new PayOutMapperParaguay();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "PAN")
                        {
                            var LPMapper = new PayOutMapperPanama();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "CRI")
                        {
                            var LPMapper = new PayOutMapperCostaRica();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else if (countryCode == "SLV")
                        {
                            var LPMapper = new PayOutMapperElSalvador();

                            var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                            if (listResponse == null || listResponse.Count == 0)
                            {
                                GeneralErrorModel Error = new GeneralErrorModel()
                                {
                                    Code = "404",
                                    CodeDescription = "Data not found",
                                    Message = "Error - No data found."
                                };
                                return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                            }
                            else
                                return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                        else
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - No data found.");
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }


                    }
                    else
                    {
                        GeneralErrorModel Error = new GeneralErrorModel()
                        {
                            Code = "400",
                            CodeDescription = "BadRequest",
                            Message = "Bad Parameter Value or Parameters Values."
                        };
                        LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - Bad Parameter Value or Parameters Values.");
                        return Request.CreateResponse(HttpStatusCode.BadRequest, Error);
                    }
                }

                else
                {
                    LogService.LogInfo("PayoutController-ListPayout - TransactionIdLog: " + transactionIdLog + "Error - Bad Parameter Value or Parameters Values.");
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());
                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };
                LogService.LogInfo(string.Format("PAYOUTController-ListPayout - TRANSACTIONIDLOG: {0} - Internal Server Error {1} ", transactionIdLog, JsonConvert.SerializeObject(Error)));

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }

        }
        /// <summary>
        /// Download
        /// </summary>
        [HttpPost]
        [Route("download")]
        //[SwaggerResponse(HttpStatusCode.OK, Type = typeof(SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.DownloadLotBatchTransactionToBank.Response))]
        [SwaggerResponse(HttpStatusCode.BadRequest, Type = typeof(GeneralErrorModel))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, Type = typeof(GeneralErrorModel))]
        [ApiExplorerSettings(IgnoreApi = true)]
        public HttpResponseMessage DownloadPayOutBankTxt(String providerName, List<String> data2)
        {
            string data = JsonConvert.SerializeObject(data2);
            try
            {
                HttpContent requestContent = Request.Content;
                // data = requestContent.ReadAsStringAsync().Result;
                bool TransactionMechanism = Request.Headers.Contains("TransactionMechanism") == false ? false : Convert.ToBoolean(((string[])Request.Headers.GetValues("TransactionMechanism"))[0]) == false ? false : true;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                //string providerName = Request.Headers.GetValues("providerName").First();

                // var hourTo = Request.Headers.GetValues("hourTo").First().Split(':');
                // int internalFiles = Int16.Parse(Request.Headers.GetValues("internalFiles").First().ToString());
                int internalFiles = 1;// Int16.Parse(Request.Headers.GetValues("internalFiles").First().ToString());

                if (string.IsNullOrEmpty(data))
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };

                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }

                //List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> RequestModel = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>>(data);
                List<string> lRequest = new List<string>();
                lRequest = data2;// RequestModel.Select(x => x.Ticket).ToList();
                SharedBusiness.Services.Payouts.BIPayOut BiPayOut =
                    new SharedBusiness.Services.Payouts.BIPayOut();

                switch (countryCode)
                {
                    case "ARG":
                        {
                            SharedModel.Models.Services.Banks.Galicia.PayOut.DownloadLotBatchTransactionToBank.Response ResponseModel = new SharedModel.Models.Services.Banks.Galicia.PayOut.DownloadLotBatchTransactionToBank.Response();
                            SharedBusiness.Services.Banks.Galicia.BIPayOut BiPO = new SharedBusiness.Services.Banks.Galicia.BIPayOut();
                            ResponseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);

                            ResponseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                        }

                    case "COL":
                        {
                            SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.DownloadLotBatchTransactionToBank.Response ResponseModel = new SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.DownloadLotBatchTransactionToBank.Response();
                            SharedBusiness.Services.Colombia.Banks.Bancolombia.BIPayOutColombia BiPO = new SharedBusiness.Services.Colombia.Banks.Bancolombia.BIPayOutColombia();
                            ResponseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);

                            ResponseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                        }

                    case "BRA":
                        {
                            SharedModel.Models.Services.Brasil.PayOutBrasil.DownloadLotBatchTransactionToBank.ExcelResponse ExcelResponseModel = new SharedModel.Models.Services.Brasil.PayOutBrasil.DownloadLotBatchTransactionToBank.ExcelResponse();
                            SharedBusiness.Services.Brasil.BIPayOutBrasil BiPO = new SharedBusiness.Services.Brasil.BIPayOutBrasil();

                            switch (providerName)
                            {
                                case "FASTCASH":
                                case "PLURAL":
                                    {
                                        var reportesPath = HttpContext.Current.Server.MapPath("~/" + "Reports");
                                        ExcelResponseModel = BiPO.DownloadExcelLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName, reportesPath);

                                        if (providerName != "FASTCASH")
                                        {
                                            return Request.CreateResponse(HttpStatusCode.OK, ExcelResponseModel);
                                        }

                                        if (ExcelResponseModel.transactions.Count > 0)
                                        {
                                            ExcelResponseModel.FileBase64 = ExcelFastCash(ExcelResponseModel.transactions, "FastCash");
                                            ExcelResponseModel.idLotOut = BiPayOut.GetLastLotOutNumber();
                                        }

                                        return Request.CreateResponse(HttpStatusCode.OK, ExcelResponseModel);
                                    }
                                default:
                                    {
                                        SharedModel.Models.Services.Brasil.PayOutBrasil.DownloadLotBatchTransactionToBank.Response ResponseModel = new SharedModel.Models.Services.Brasil.PayOutBrasil.DownloadLotBatchTransactionToBank.Response();
                                        ResponseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);

                                        ResponseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                                        return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                                    }
                            }
                        }

                    case "MEX":
                        {
                            var BiPO = new BIPayOutMexico();
                            var responseModel = new PayOutMexico.DownloadLotBatchTransactionToBank.Response();

                            responseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, internalFiles, providerName);

                            responseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, responseModel);
                        }

                    case "URY":
                        {
                            BIPayOutUruguay BiPO = new BIPayOutUruguay();

                            PayOutUruguay.DownloadLotBatchTransactionToBank.Response responseModel = new PayOutUruguay.DownloadLotBatchTransactionToBank.Response();
                            responseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism);

                            responseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, responseModel);
                        }

                    case "CHL":
                        {
                            var BiPO = new BIPayOutChile();

                            PayOutChile.DownloadLotBatchTransactionToBank.Response ResponseModel = new PayOutChile.DownloadLotBatchTransactionToBank.Response();
                            ResponseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);

                            ResponseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                        }

                    case "PER":
                        {
                            var biPayOutPeruService = new BIPayOutPeru();

                            PeruPayoutDownloadLotBatchTransactionToBankResponse ResponseModel = new PeruPayoutDownloadLotBatchTransactionToBankResponse();
                            ResponseModel = biPayOutPeruService.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);

                            ResponseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                        }

                    case "ECU":
                        {
                            var BiPO = new BIPayoutEcuador();
                            var responseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);

                            responseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, responseModel);
                        }

                    case "PRY":
                        {
                            var BiPO = new BIPayoutParaguay();

                            var responseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);

                            responseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, responseModel);
                        }

                    case "BOL":
                        {
                            var BiPO = new BIPayoutBolivia();
                            var responseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, internalFiles, providerName);
                            responseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, responseModel);
                        }

                    case "PAN":
                        {
                            var BiPO = new BIPayoutPanama();
                            var responseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);
                            responseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, responseModel);
                        }

                    case "CRI":
                        {
                            var BiPO = new BIPayoutCostaRica();
                            var responseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);
                            responseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, responseModel);
                        }

                    case "SLV":
                        {
                            var BiPO = new BIPayoutElSalvador();
                            var responseModel = BiPO.DownloadLotBatchTransactionToBank(lRequest, TransactionMechanism, providerName);
                            responseModel.idLotOut = BiPayOut.GetLastLotOutNumber();

                            return Request.CreateResponse(HttpStatusCode.OK, responseModel);
                        }
                }


                return Request.CreateResponse(HttpStatusCode.OK);

            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }
        /// <summary>
        /// Upload
        /// </summary>
        [HttpPost]
        [Route("upload")]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(SharedModel.Models.Services.Banks.Galicia.PayOut.UploadTxtFromBank.Response))]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.UploadTxtFromBank.Response))]
        [SwaggerResponse(HttpStatusCode.BadRequest, Type = typeof(GeneralErrorModel))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, Type = typeof(GeneralErrorModel))]
        [ApiExplorerSettings(IgnoreApi = true)]

        public async System.Threading.Tasks.Task<HttpResponseMessage> UploadPayOutBankTxtAsync()
        {
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                bool TransactionMechanism = Request.Headers.Contains("TransactionMechanism") == false ? false : Convert.ToBoolean(((string[])Request.Headers.GetValues("TransactionMechanism"))[0]) == false ? false : true;
                string datetime = DateTime.Now.ToString("yyyyMMddhhmmss");
                string providerName = Request.Headers.GetValues("providerName").First();

                if (countryCode == "ARG")
                {
                    SharedModel.Models.Services.Banks.Galicia.PayOut.UploadTxtFromBank.Request RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Banks.Galicia.PayOut.UploadTxtFromBank.Request>(data);
                    if (string.IsNullOrEmpty(RequestModel.File) && providerName != "BSPVIELLE")
                        throw new Exception("File is null or empty!");

                    SharedBusiness.Services.Banks.Galicia.BIPayOut BiPO = new SharedBusiness.Services.Banks.Galicia.BIPayOut();
                    SharedModel.Models.Services.Banks.Galicia.PayOut.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Banks.Galicia.PayOut.UploadTxtFromBank.Response();

                    if (providerName == "BGALICIA")
                    {
                        ResponseModel = BiPO.UploadTxtFromGALICIA(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }
                    else if (providerName == "BSPVIELLE")
                    {
                        ResponseModel = BiPO.UploadTxtFromSUPERVIELLE(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }
                    else if (providerName == "BBBVA")
                    {
                        ResponseModel = BiPO.UploadTxtFromBBVA(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }
                    else if (providerName == "BBBVATP")
                    {
                        ResponseModel = BiPO.UploadTxtFromBBVATuPago(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }
                    else if (providerName == "SANTAR")
                    {
                        ResponseModel = BiPO.UploadTxtFromSantander(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }

                    // CALLBACK
                    await ClientCallbackService.CheckAndSendCallback(ResponseModel.TransactionDetail);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(ResponseModel));
                }

                else if (countryCode == "COL")
                {
                    SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.UploadTxtFromBank.Request RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.UploadTxtFromBank.Request>(data);
                    if (string.IsNullOrEmpty(RequestModel.File))
                        throw new Exception("File is null or empty!");

                    SharedBusiness.Services.Colombia.Banks.Bancolombia.BIPayOutColombia BiPO = new SharedBusiness.Services.Colombia.Banks.Bancolombia.BIPayOutColombia();
                    SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Colombia.Banks.Bancolombia.PayOutColombia.UploadTxtFromBank.Response();

                    if (providerName == "BCOLOMBIA")
                    {
                        ResponseModel = BiPO.UploadTxtFromBank(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }
                    else if (providerName == "BCOLOMBIA2")
                    {
                        ResponseModel = BiPO.UploadTxtFromBankBColombiaSas(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }
                    else if (providerName == "OCCIDENTE")
                    {
                        ResponseModel = BiPO.UploadTxtFromBankOccidente(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }

                    // CALLBACK
                    await ClientCallbackService.CheckAndSendCallback(ResponseModel.TransactionDetail);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(ResponseModel));
                }
                else if (countryCode == "BRA")
                {
                    SharedModel.Models.Services.Brasil.PayOutBrasil.UploadTxtFromBank.Request RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Brasil.PayOutBrasil.UploadTxtFromBank.Request>(data);
                    if (string.IsNullOrEmpty(RequestModel.File))
                        throw new Exception("File is null or empty!");

                    SharedBusiness.Services.Brasil.BIPayOutBrasil BiPO = new SharedBusiness.Services.Brasil.BIPayOutBrasil();
                    SharedModel.Models.Services.Brasil.PayOutBrasil.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Brasil.PayOutBrasil.UploadTxtFromBank.Response();

                    if (providerName == "FASTCASH")
                    {
                        var ExcelData = ExcelBase64ToList(RequestModel.File, providerName);
                        var castData = ExcelData.Cast<SharedModel.Models.Services.Brasil.PayOutBrasil.DownloadLotBatchTransactionToBank.ExcelFastcashResponse>().ToList();

                        ResponseModel = BiPO.UploadExcelFromBankFastcash(castData, RequestModel.CurrencyFxClose, datetime, TransactionMechanism, countryCode);
                    }
                    else if (providerName == "PLURAL")
                    {
                        var ExcelData = ExcelBase64ToList(RequestModel.File, providerName);
                        var castData = ExcelData.Cast<SharedModel.Models.Services.Brasil.PayOutBrasil.DownloadLotBatchTransactionToBank.ExcelPluralResponse>().ToList();

                        ResponseModel = BiPO.UploadExcelFromBankPlural(castData, RequestModel.CurrencyFxClose, datetime, TransactionMechanism, countryCode);
                    }
                    else if (providerName == "SAFRA")
                    {
                        ResponseModel = BiPO.UploadTxtFromBankSafra(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }
                    else if (providerName == "BDOBR")
                    {
                        ResponseModel = BiPO.UploadTxtFromBankDoBrasil(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }
                    else if (providerName == "SANTBR")
                    {
                        ResponseModel = BiPO.UploadTxtFromBankSantander(RequestModel, datetime, TransactionMechanism, countryCode, providerName);
                    }

                    // CALLBACK
                    await ClientCallbackService.CheckAndSendCallback(ResponseModel.TransactionDetail);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(ResponseModel));
                }
                else if (countryCode == "MEX")
                {
                    SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Request RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Request>(data);
                    if (string.IsNullOrEmpty(RequestModel.File))
                        throw new Exception("File is null or empty!");

                    SharedBusiness.Services.Mexico.BIPayOutMexico BiPO = new SharedBusiness.Services.Mexico.BIPayOutMexico();
                    SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response();
                    string FileOperation = RequestModel.FileName.Substring(0, 2);

                    if (providerName == "MIFEL")
                    {
                        ResponseModel = BiPO.UploadTxtFromBank(RequestModel, datetime, TransactionMechanism, countryCode);
                    }
                    else if (providerName == "SRM")
                    {
                        ResponseModel = BiPO.UploadTxtFromBankSantander(RequestModel, datetime, TransactionMechanism, countryCode);
                    }

                    //CALLBACK
                    await ClientCallbackService.CheckAndSendCallback(ResponseModel.TransactionDetail);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(ResponseModel));

                }
                else if (countryCode == "CHL")
                {
                    SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.Request RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.Request>(data);
                    if (string.IsNullOrEmpty(RequestModel.File))
                        throw new Exception("File is null or empty!");

                    SharedBusiness.Services.Chile.BIPayOutChile BiPO = new SharedBusiness.Services.Chile.BIPayOutChile();
                    SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.Response();

                    var ExcelData = ExcelBase64ToList(RequestModel.File, providerName);
                    var castData = ExcelData.Cast<SharedModel.Models.Services.Chile.PayOutChile.UploadTxtFromBank.ExcelItauResponse>().ToList();

                    ResponseModel = BiPO.UploadExcelFromBankItau(castData, RequestModel.CurrencyFxClose, datetime, TransactionMechanism, countryCode);

                    // CALLBACK
                    await ClientCallbackService.CheckAndSendCallback(ResponseModel.TransactionDetail);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(ResponseModel));
                }
                else if (countryCode == "PER")
                {
                    SharedModel.Models.Services.Peru.PeruPayoutUploadTxtFromBankRequest RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Peru.PeruPayoutUploadTxtFromBankRequest>(data);
                    if (string.IsNullOrEmpty(RequestModel.File))
                        throw new Exception("File is null or empty!");

                    SharedBusiness.Services.Peru.BIPayOutPeru BiPO = new SharedBusiness.Services.Peru.BIPayOutPeru();
                    SharedModel.Models.Services.Peru.PeruPayoutUploadTxtFromBankResponse ResponseModel = new SharedModel.Models.Services.Peru.PeruPayoutUploadTxtFromBankResponse();

                    var ExcelData = ExcelBase64ToList(RequestModel.File, providerName);
                    var castData = ExcelData.Cast<SharedModel.Models.Services.Peru.PeruPayoutExcelBCPResponse>().ToList();

                    ResponseModel = BiPO.UploadExcelFromBankBCP(castData, RequestModel.CurrencyFxClose, datetime, TransactionMechanism, countryCode);

                    // CALLBACK
                    await ClientCallbackService.CheckAndSendCallback(ResponseModel.TransactionDetail);

                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(ResponseModel));
                }

                return Request.CreateResponse(HttpStatusCode.OK);


            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, Error);
            }
        }


        [HttpPost]
        [Route("list_payouts")]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage ListPayOuts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;

                string countryCode = Request.Headers.GetValues("countryCode").First();
                var hourTo = Request.Headers.GetValues("hourTo").First().Split(':');

                if (!string.IsNullOrEmpty(data))
                {
                    SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Request RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Request>(data);
                    RequestModel.dateTo = RequestModel.dateTo != null ? DateTime.Parse(RequestModel.dateTo).Date.ToString() : null;
                    if (hourTo.Length > 1)
                    {
                        RequestModel.dateTo = Tools.DateUtils.ParseDateHour(RequestModel.dateTo, hourTo);
                    }
                    List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> ResponseModel = new List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.ListTransaction(RequestModel, countryCode);

                    return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };

                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }

        [HttpPost]
        [Route("validate_payouts")]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage ValidatePayouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();

                if (!string.IsNullOrEmpty(data))
                {
                    SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Request RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Request>(data);
                    List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> ResponseModel = new List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.ManageTransaction(RequestModel, countryCode);

                    return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };

                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }

        [HttpPost]
        [Route("received_payouts")]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage ReceivedPayouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();

                if (!string.IsNullOrEmpty(data))
                {
                    SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Request RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Request>(data);
                    List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> ResponseModel = new List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.ReceivedPayouts(RequestModel, countryCode);

                    return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };

                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }

        [HttpPost]
        [Route("update_payouts")]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public async System.Threading.Tasks.Task<HttpResponseMessage> UpdatePayouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                string providerName = Request.Headers.GetValues("providerName").First();
                string statusCode = Request.Headers.GetValues("statusCode").First();

                if (!string.IsNullOrEmpty(data))
                {
                    List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> RequestModel = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>>(data);
                    SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.UpdateTransaction(RequestModel, countryCode, providerName, statusCode);

                    // CALLBACK
                    await ClientCallbackService.CheckAndSendCallback(ResponseModel.TransactionDetail);

                    return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };

                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }

        [HttpPost]
        [Route("cancel_payouts")]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public async Task<HttpResponseMessage> CancelPayouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string transactionIdLog = Guid.NewGuid().ToString();

            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                LogService.LogInfo(string.Format("PAYOUTController-CancelPayouts - TRANSACTIONIDLOG: {0}, HEADER {1} , REQUEST {2}", transactionIdLog, Request.Headers, data));

                if (!string.IsNullOrEmpty(data))
                {
                    List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> RequestModel = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>>(data);
                    SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.CancelTransaction(RequestModel, countryCode);

                    // CANCEL CALLBACK
                    await ClientCallbackService.SendCancelCallback(ResponseModel.TransactionDetail);
                    LogService.LogInfo(string.Format("PAYOUTController-CancelPayouts - TRANSACTIONIDLOG: {0} OK, RESPONSE: {1}", transactionIdLog, JsonConvert.SerializeObject(ResponseModel)));

                    return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-CancelPayouts - TRANSACTIONIDLOG: {0} - Bad Parameter Value or Parameters Values. ", transactionIdLog));

                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };
                LogService.LogInfo(string.Format("PAYOUTController-CancelPayouts - TRANSACTIONIDLOG: {0} - Internal Server Error {1} ", transactionIdLog, JsonConvert.SerializeObject(Error)));

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }

        [HttpPost]
        [Route("get_onhold_payouts")]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Task<HttpResponseMessage> GetOnHoldPayouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                LogService.LogInfo(string.Format("PAYOUTController-GetOnHoldPayouts - TRANSACTIONIDLOG: {0}, HEADER {1} , REQUEST {2}", transactionIdLog, Request.Headers, data));


                if (!string.IsNullOrEmpty(data))
                {
                    ListPayoutsDownload.Request RequestModel = JsonConvert.DeserializeObject<ListPayoutsDownload.Request>(data);
                    List<ListPayoutsDownload.Response> ResponseModel = new List<ListPayoutsDownload.Response>();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.GetOnHoldPayouts(RequestModel, countryCode);

                    LogService.LogInfo(string.Format("PAYOUTController-GetOnHoldPayouts - TRANSACTIONIDLOG: {0}, OK", transactionIdLog));

                    return Task.FromResult(Request.CreateResponse(HttpStatusCode.OK, ResponseModel));
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-GetOnHoldPayouts - TRANSACTIONIDLOG: {0}, ERROR {1} - Bad Parameter Value or Parameters Values.", transactionIdLog, JsonConvert.SerializeObject(Error)));

                    return Task.FromResult(Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error)));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, "PAYOUTController-GetOnHoldPayouts - TRANSACTIONIDLOG: " + transactionIdLog + SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Task.FromResult(Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error)));
            }
        }

        [HttpPost]
        [Route("put_onhold_payouts")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Task<HttpResponseMessage> PutOnHoldPayouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                LogService.LogInfo(string.Format("PAYOUTController-put_onhold_payouts - TRANSACTIONIDLOG: {0}, HEADER {1} , REQUEST {2}", transactionIdLog, Request.Headers, data));

                if (!string.IsNullOrEmpty(data))
                {
                    List<ListPayoutsDownload.Response> RequestModel = JsonConvert.DeserializeObject<List<ListPayoutsDownload.Response>>(data);
                    UploadTxtFromBank.Response ResponseModel = new UploadTxtFromBank.Response();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();

                    List<string> ticketsOnHold = RequestModel.Select(x => x.Ticket).ToList();

                    List<string> onHoldResponse = BiPO.HoldTransactions(ticketsOnHold, countryCode);
                    if (onHoldResponse.Count > 0)
                    {
                        foreach (var transaction in onHoldResponse)
                        {
                            UploadTxtFromBank.TransactionDetail detail = new UploadTxtFromBank.TransactionDetail
                            {
                                Ticket = transaction
                            };
                            ResponseModel.TransactionDetail.Add(detail);
                        }
                        //TODO: Callback
                        ResponseModel.Status = "OK";
                        ResponseModel.StatusMessage = "OK";
                        LogService.LogInfo(string.Format("PAYOUTController-put_onhold_payouts - TRANSACTIONIDLOG: {0}, OK", transactionIdLog));

                    }
                    else
                    {
                        ResponseModel.Status = "ERROR";
                        ResponseModel.StatusMessage = "An error ocurred processing a transaction";
                        LogService.LogInfo(string.Format("PAYOUTController-put_onhold_payouts - TRANSACTIONIDLOG: {0}, An error ocurred processing a transaction", transactionIdLog));

                    }

                    return Task.FromResult(Request.CreateRespon
se(HttpStatusCode.OK, ResponseModel));
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-put_onhold_payouts - TRANSACTIONIDLOG: {0}, Bad Parameter Value or Parameters Values", transactionIdLog));

                    return Task.FromResult(Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error)));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, "PAYOUTController - put_onhold_payout - TRANSACTIONIDLOG: " + transactionIdLog + " " + SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Task.FromResult(Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error)));
            }
        }

        [HttpPost]
        [Route("put_received_payouts")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Task<HttpResponseMessage> PutReceivedPayouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {

                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();

                LogService.LogInfo(string.Format("PAYOUTController-put_received_payout - TRANSACTIONIDLOG: {0}, HEADER {1} , REQUEST {2}", transactionIdLog, Request.Headers, data));

                if (!string.IsNullOrEmpty(data))
                {
                    List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> RequestModel = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>>(data);
                    SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.ReceivedTransaction(RequestModel, countryCode);

                    // TODO: Callback
                    LogService.LogInfo(string.Format("PAYOUTController-put_received_payout - TRANSACTIONIDLOG: {0},  OK ", transactionIdLog));

                    return Task.FromResult(Request.CreateResponse(HttpStatusCode.OK, ResponseModel));
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-put_received_payout - TRANSACTIONIDLOG: {0}, BadRequest", transactionIdLog));
                    return Task.FromResult(Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error)));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, string.Format("PAYOUTController-put_received_payout - TRANSACTIONIDLOG: {0} ", transactionIdLog) + SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Task.FromResult(Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error)));
            }
        }

        [HttpPost]
        [Route("revert_download")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage RevertDownload()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {

            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                LogService.LogInfo(string.Format("PAYOUTController-RevertDownload - TRANSACTIONIDLOG: {0}, HEADER {1} , REQUEST {2}", transactionIdLog, Request.Headers, data));


                if (!string.IsNullOrEmpty(data))
                {
                    List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> RequestModel = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>>(data);
                    List<string> lRequest = new List<string>();
                    lRequest = RequestModel.Select(x => x.Ticket).ToList();

                    SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.RevertDownload(lRequest, countryCode);
                    LogService.LogInfo(string.Format("PAYOUTController-RevertDownload - TRANSACTIONIDLOG: {0}, OK", transactionIdLog));

                    return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-RevertDownload - TRANSACTIONIDLOG: {0}, HEADER {1} , REQUEST {2}", transactionIdLog, Request.Headers, data));

                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, string.Format("PAYOUTController-RevertDownload - TRANSACTIONIDLOG: {0} ", transactionIdLog) + SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }

        [HttpPost]
        [Route("executed_payouts")]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage GetExecutedPayouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                LogService.LogInfo(string.Format("PAYOUTController-executed_payouts - TRANSACTIONIDLOG: {0}, HEADER {1} , REQUEST {2}", transactionIdLog, Request.Headers, data));

                if (!string.IsNullOrEmpty(data))
                {
                    SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Request RequestModel = JsonConvert.DeserializeObject<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Request>(data);
                    List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> ResponseModel = new List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.GetExecutedPayouts(RequestModel, countryCode);
                    LogService.LogInfo(string.Format("PAYOUTController-executed_payouts - TRANSACTIONIDLOG: {0}, OK", transactionIdLog));

                    return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-executed_payouts - TRANSACTIONIDLOG: {0}, BadRequest", transactionIdLog));
                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, string.Format("PAYOUTController-executed_payouts - TRANSACTIONIDLOG: {0} ", transactionIdLog) + SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }

        [HttpPost]
        [Route("return_payouts")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public async System.Threading.Tasks.Task<HttpResponseMessage> ReturnPayouts()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                string providerName = Request.Headers.GetValues("providerName").First();
                string status = Request.Headers.GetValues("status").First();
                LogService.LogInfo(string.Format("PAYOUTController-return_payouts - TRANSACTIONIDLOG: {0}, HEADER {1} , REQUEST {2}", transactionIdLog, Request.Headers, data));


                if (!string.IsNullOrEmpty(data))
                {
                    List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response> RequestModel = JsonConvert.DeserializeObject<List<SharedModel.Models.Services.Payouts.Payouts.ListPayoutsDownload.Response>>(data);
                    SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response ResponseModel = new SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.Response();
                    SharedBusiness.Services.Payouts.BIPayOut BiPO = new SharedBusiness.Services.Payouts.BIPayOut();
                    ResponseModel = BiPO.ReturnTransaction(RequestModel, countryCode, providerName, status);

                    // CALLBACK
                    await ClientCallbackService.CheckAndSendCallback(ResponseModel.TransactionDetail);
                    LogService.LogInfo(string.Format("PAYOUTController-return_payouts - TRANSACTIONIDLOG: {0} , OK", transactionIdLog));

                    return Request.CreateResponse(HttpStatusCode.OK, ResponseModel);
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-return_payouts - TRANSACTIONIDLOG: {0} , BadRequest", transactionIdLog));

                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, string.Format("PAYOUTController-return_payouts - TRANSACTIONIDLOG: {0} ", transactionIdLog) + SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }

        [HttpPost]
        [Route("authenticate")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage AuthorizePO()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string transactionIdLog = Guid.NewGuid().ToString();
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;
                string countryCode = Request.Headers.GetValues("countryCode").First();
                string customer = Request.Headers.GetValues("customer_id").First();



                if (!string.IsNullOrEmpty(data))
                {
                    LogService.LogInfo(string.Format("PAYOUTController-AuthorizePO - TRANSACTIONIDLOG: {0}, HEADER {1} , REQUEST {2}", transactionIdLog, Request.Headers, data));

                    List<string> ticketList = new List<string>();
                    ticketList = JsonConvert.DeserializeObject<List<string>>(data);

                    SharedBusiness.Services.Payouts.BIPayOut BiP = new SharedBusiness.Services.Payouts.BIPayOut();
                    var listLotBachModel = BiP.ChangeTxtToRecieved(ticketList, countryCode, customer);

                    if (countryCode == "ARG")
                    {
                        SharedMaps.Converters.Services.Banks.Galicia.PayOutMapper LPMapper = new SharedMaps.Converters.Services.Banks.Galicia.PayOutMapper();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            LogService.LogInfo(string.Format("PAYOUTController-AuthorizePO - TRANSACTIONIDLOG: {0}, BADREQUEST", transactionIdLog));
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "COL")
                    {
                        var LPMapper = new SharedMaps.Converters.Services.Colombia.Banks.Bancolombia.PayOutMapperColombia();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "BRA")
                    {
                        var LPMapper = new SharedMaps.Converters.Services.Brasil.PayOutMapperBrasil();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "URY")
                    {
                        var LPMapper = new SharedMaps.Converters.Services.Uruguay.PayOutMapperUruguay();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "CHL")
                    {
                        var LPMapper = new SharedMaps.Converters.Services.Chile.PayOutMapperChile();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "MEX")
                    {
                        var LPMapper = new SharedMaps.Converters.Services.Mexico.PayOutMapperMexico();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                        listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "PER")
                    {
                        var LPMapper = new SharedMaps.Converters.Services.Peru.PayOutMapperPeru();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "ECU")
                    {
                        var LPMapper = new PayOutMapperEcuador();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                        listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "PRY")
                    {
                        var LPMapper = new PayOutMapperParaguay();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                        listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "BOL")
                    {
                        var LPMapper = new PayOutMapperBolivia();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                        listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "PAN")
                    {
                        var LPMapper = new PayOutMapperPanama();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                        listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "CRI")
                    {
                        var LPMapper = new PayOutMapperCostaRica();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                        listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else if (countryCode == "SLV")
                    {
                        var LPMapper = new PayOutMapperElSalvador();

                        var listResponse = LPMapper.MapperModelsBatch(listLotBachModel);
                        listResponse = listResponse.OrderBy(x => x.payout_id).ToList();

                        if (listResponse == null || listResponse.Count == 0)
                        {
                            GeneralErrorModel Error = new GeneralErrorModel()
                            {
                                Code = "404",
                                CodeDescription = "Data not found",
                                Message = "Error - No data found."
                            };
                            return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                        }
                        else
                        {
                            listResponse = listResponse.OrderBy(x => x.payout_id).ToList();
                            return Request.CreateResponse(HttpStatusCode.OK, listResponse);
                        }
                    }
                    else
                    {
                        GeneralErrorModel Error = new GeneralErrorModel()
                        {
                            Code = "404",
                            CodeDescription = "Data not found",
                            Message = "Error - No data found."
                        };
                        return Request.CreateResponse(HttpStatusCode.NotFound, Error);
                    }
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("PAYOUTController-AuthorizePO - TRANSACTIONIDLOG: {0}, BADREQUEST_BadParameter", transactionIdLog));
                    return Request.CreateResponse(HttpStatusCode.BadRequest, JsonConvert.SerializeObject(Error));
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, string.Format("PAYOUTController-AuthorizePO - TRANSACTIONIDLOG: {0} ", transactionIdLog) + SerializeRequest());

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, JsonConvert.SerializeObject(Error));
            }
        }
    }
}