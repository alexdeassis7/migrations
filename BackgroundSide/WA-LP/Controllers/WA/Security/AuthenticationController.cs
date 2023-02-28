using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using SharedSecurity.JWT.Token;
using SharedModel.Models.Security;
using SharedModel.Models.Database.Security;

using System.Web.Http.Cors;
using SharedBusiness.Log;
using System.Web;
using System.Web.Http.Description;
using Swashbuckle.Swagger.Annotations;
using static WA_LP.SwaggerConfig.Consumes;
using WA_LP.Cache;
using static SharedModel.Models.Database.Security.Authentication;
using SharedBusiness.Mail;
using System.Collections.Generic;

namespace WA_LP.Controllers.WA.Security
{
    [AllowAnonymous]
    [RoutePrefix("v2")]
    [ApiExplorerSettings(IgnoreApi = false)]

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class AuthenticationController : BaseApiController
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        SharedBusiness.Security.BlSecurity BL = new SharedBusiness.Security.BlSecurity();

        /// <summary>
        /// Tokens
        /// </summary>
        [HttpPost]
        [Route("tokens")]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(Token))]
        [SwaggerResponse(HttpStatusCode.BadRequest)]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Type = typeof(Authentication.Account))]
        [SwaggerResponse(HttpStatusCode.InternalServerError)]
        [SwaggerConsumes("application/json")]
        //[SwaggerRequestExample(typeof(DeliveryOptionsSearchModel), typeof(DeliveryOptionsSearchModelExample))]
        public HttpResponseMessage Token()
        {
            string CustomerID = "";
            string ApiKey = "";
            string otpLogin = "";
            string TransactionIdLog = Guid.NewGuid().ToString();
            try
            {
                CustomerID = ((string[])Request.Headers.FirstOrDefault(x => x.Key == "customer_id").Value)[0];
                ApiKey = ((string[])Request.Headers.FirstOrDefault(x => x.Key == "api_key").Value)[0];
                bool isWebRequest=false;
                LogService.LogInfo("AuthenticationController - TransactionIdLog:" + TransactionIdLog + " CUSTOMER:" + CustomerID + " trying to get a token with key " + ApiKey);

                if (Request.Headers.Contains("app") && !string.IsNullOrWhiteSpace(Request.Headers.Select(x => x.Key == "app").ToString()))
                {
                    LogService.LogInfo("AuthenticationController - TransactionIdLog:" + TransactionIdLog + "ENTRO EN IF Previo App and otpLogin");

                    isWebRequest = Request.Headers.FirstOrDefault(x => x.Key == "app").Value.First().ToLower() == "true";
                    if (Request.Headers.Contains("otplogin") && !string.IsNullOrWhiteSpace(Request.Headers.Select(x => x.Key == "otplogin").ToString()))
                    {
                        otpLogin = Request.Headers.FirstOrDefault(x => x.Key == "otplogin").Value.First();
                        otpLogin = string.IsNullOrEmpty(otpLogin) ? "-2":otpLogin ;
                    }
                    LogService.LogInfo("AuthenticationController - TransactionIdLog:" + TransactionIdLog + "RECIBIDO App:" + isWebRequest + " otpLogin " + otpLogin);

                }
                else
                {
                    LogService.LogInfo("AuthenticationController - TransactionIdLog:" + TransactionIdLog + "NO ENTRO EN IF Previo App and otpLogin");

                }
                LogService.LogInfo("AuthenticationController - TransactionIdLog:" + TransactionIdLog + "LUEGO DEL IF ");


                if (CustomerID == null || ApiKey == null)
                    throw new HttpResponseException(HttpStatusCode.BadRequest);

                if (!string.IsNullOrEmpty(CustomerID) && CustomerID.Length > 0 && !string.IsNullOrEmpty(ApiKey) && ApiKey.Length > 0)
                {
                    AccountModel.Login Credential = new AccountModel.Login() { ClientID = CustomerID, Password = ApiKey, WebAcces = isWebRequest };

                    var accountCached = (!isWebRequest)?LogInCacheService.Get(CustomerID + ApiKey):null;

                    Authentication.Account Account = null;

                    if (accountCached == null)
                    {
                        Account = BL.GetAuthentication(Credential);

                        if (Account.ValidationResult.ValidationStatus == true)
                        {
                            Account.Login.Password = ApiKey;
                            if (Convert.ToBoolean(isWebRequest))
                            {
                                string otpLoginCache= (CacheService.Get(CustomerID + ApiKey) != null) ? CacheService.Get(CustomerID + ApiKey).ToString() : "-1";

                                if (!string.IsNullOrEmpty(otpLogin) && otpLogin != otpLoginCache)
                                {
                                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "OTP Not Valid");
                                }
                                
                                SharedBusiness.User.BlUser BLUser = new SharedBusiness.User.BlUser();
                                SharedModel.Models.User.User userinfo = BLUser.GetUserInfo(Credential);
                                TokenWeb Token = new TokenWeb
                                {
                                    customer_id = Account.Login.ClientID,
                                    token_id = TokenGenerator.GenerateTokenWebJwt(Account.Login.ClientID, Account.SecretKey, userinfo)
                                };
                                CacheService.Remove(Account.Login + Account.SecretKey);
                                LogService.LogInfo(string.Format("AuthenticationController - TransactionIdLog: {0} Client {1} the token {2} was obtained from DB", TransactionIdLog,CustomerID, Token.token_id));
                                return Request.CreateResponse(HttpStatusCode.OK, Token);
                            }
                            else
                            {
                                Token Token = new Token
                                {
                                    token_id = TokenGenerator.GenerateTokenJwt(Credential.ClientID, Account.SecretKey)
                                };
                                //BL.PutLoginToken(Account.Login.ClientID, Account.Login.WebAcces, Token.token_id);
                                LogInCacheService.AddToCache(new TokenAccount
                                {
                                    Login = Account.Login,
                                    SecretKey = Account.SecretKey,
                                    Token = Token
                                });
                                LogService.LogInfo(string.Format("AuthenticationController - TransactionIdLog: {0} Client {1} the token {2} was obtained from DB", TransactionIdLog, CustomerID, Token.token_id));
                                return Request.CreateResponse(HttpStatusCode.OK, Token);
                            }
                        }
                        else
                        {
                            LogService.LogInfo("AuthenticationController - UNAUTHORIZED LOGIN TransactionIdLog: " + TransactionIdLog + " CUSTOMER:" + CustomerID + " trying to get a token with key " + ApiKey);
                            return Request.CreateResponse(HttpStatusCode.Unauthorized, Account);
                        }
                    }
                    else
                    {

                        var tokenAccount = (TokenAccount)accountCached;
                        if (Convert.ToBoolean(isWebRequest))
                        {
                            LogService.LogInfo(string.Format("AuthenticationController - TransactionIdLog: {0} Client {1} the token {2} was obtained from Cache", TransactionIdLog,CustomerID, tokenAccount.TokenWeb));
                            return Request.CreateResponse(HttpStatusCode.OK, tokenAccount.TokenWeb);
                        }
                        else
                        {
                            LogService.LogInfo(string.Format("AuthenticationController - TransactionIdLog: {0} Client {1} the token {2} was obtained from Cache", TransactionIdLog, CustomerID, tokenAccount.Token));
                            return Request.CreateResponse(HttpStatusCode.OK, tokenAccount.Token);
                        }

                    }
                }
                else
                {
                    LogService.LogInfo("AuthenticationController - UNAUTHORIZED LOGIN TransactionIdLog:" + TransactionIdLog + " CUSTOMER:" + CustomerID + " trying to get a token with key " + ApiKey);
                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
                }
            }
            catch (Exception ex)
            {
                LogService.LogError("AuthenticationController - ERROR LOGIN TransactionIdLog: " + TransactionIdLog + ex.Message, CustomerID);
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message, ex.StackTrace);
            }
        }


        [HttpPost]
        [Route("firstfactor")]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(Token))]
        [SwaggerResponse(HttpStatusCode.BadRequest)]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Type = typeof(Authentication.Account))]
        [SwaggerResponse(HttpStatusCode.InternalServerError)]
        [SwaggerConsumes("application/json")]
        
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage FirstFactor()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string CustomerID = "";
            string ApiKey = "";
            string TransactionIdLog = Guid.NewGuid().ToString();
            try
            {
                CustomerID = ((string[])Request.Headers.FirstOrDefault(x => x.Key == "customer_id").Value)[0];
                ApiKey = ((string[])Request.Headers.FirstOrDefault(x => x.Key == "api_key").Value)[0];
                string App = "false";
                LogService.LogInfo("AuthenticationController - TransactionIdLog:" + TransactionIdLog + " CUSTOMER:" + CustomerID + " trying to get a token with key " + ApiKey);

                if (!((Request.Headers.FirstOrDefault(x => x.Key == "app").Value) == null))
                {
                    App = ((string[])Request.Headers.FirstOrDefault(x => x.Key == "app").Value)[0];
                }

                if (CustomerID == null || ApiKey == null)
                    throw new HttpResponseException(HttpStatusCode.BadRequest);

                if (!string.IsNullOrEmpty(CustomerID) && CustomerID.Length > 0 && !string.IsNullOrEmpty(ApiKey) && ApiKey.Length > 0)
                {
                    AccountModel.Login Credential = new AccountModel.Login() { ClientID = CustomerID, Password = ApiKey, WebAcces = Convert.ToBoolean(App) };
                    Authentication.Account Account = null;

                    
                    Account = BL.GetAuthentication(Credential);

                    if (Account.ValidationResult.ValidationStatus == true)
                    {   
                        Account.Login.Password = ApiKey;
                        
                        SharedBusiness.User.BlUser BLUser = new SharedBusiness.User.BlUser();
                        SharedModel.Models.User.User userinfo = BLUser.GetUserInfo(Credential);
                        List<string> email = new List<string>();
                        email.Add(CustomerID);
                        Random rnd = new Random();
                        int otpvalue= rnd.Next(100000, 999999);//returns random integers < 10
                        CacheService.Add(CustomerID + ApiKey, otpvalue);
                        MailService.SendMail("OTP LP V2",String.Format("OTP LP: {0}",otpvalue),email);
                        LogService.LogInfo(string.Format("AuthenticationController - TransactionIdLog: {0} Client {1} the firstFactor {2}", TransactionIdLog, CustomerID, otpvalue));
                        return Request.CreateResponse(HttpStatusCode.OK, true);
                        
                    }
                    else
                    {
                        LogService.LogInfo("AuthenticationController - UNAUTHORIZED LOGIN TransactionIdLog: " + TransactionIdLog + " CUSTOMER:" + CustomerID + " trying to get a token with key " + ApiKey);
                        return Request.CreateResponse(HttpStatusCode.Unauthorized, Account);
                    }
                }
                else
                {
                    LogService.LogInfo("AuthenticationController - UNAUTHORIZED LOGIN TransactionIdLog:" + TransactionIdLog + " CUSTOMER:" + CustomerID + " trying to get a token with key " + ApiKey);
                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
                }
            }
            catch (Exception ex)
            {
                LogService.LogError("AuthenticationController - ERROR LOGIN TransactionIdLog: " + TransactionIdLog + ex.Message, CustomerID);
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }


        /// <summary>
        /// Login
        /// </summary>
        [HttpPost]
        [Route("login")]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(AccountModel.Login))]
        [SwaggerResponse(HttpStatusCode.BadRequest)]
        [SwaggerResponse(HttpStatusCode.Unauthorized)]
        [SwaggerResponse(HttpStatusCode.InternalServerError)]
        [ApiExplorerSettings(IgnoreApi = true)]

        public HttpResponseMessage Login()
        {
            try
            {
                var user = ((string[])Request.Content.Headers.FirstOrDefault(x => x.Key == "userNameLP").Value)[0];
                var pass = ((string[])Request.Content.Headers.FirstOrDefault(x => x.Key == "userPassLP").Value)[0];

                if (user == null || pass == null)
                {
                    throw new HttpResponseException(HttpStatusCode.BadRequest);
                }

                if (!string.IsNullOrEmpty(user) && user.Length > 0 && !string.IsNullOrEmpty(pass) && pass.Length > 0)
                {
                    AccountModel.Login login = new AccountModel.Login() { ClientID = user, Password = pass };
                    return Request.CreateResponse(HttpStatusCode.OK, login);
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex.Message);
                return Request.CreateResponse(HttpStatusCode.Unauthorized, ex.Message);
            }
        }

        [HttpPost]
        [Route("RefreshToken")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage RefreshToken()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            try
            {
                string CustomerID = ((string[])Request.Headers.FirstOrDefault(x => x.Key == "customer_id").Value)[0];

                if (CustomerID == null)
                    throw new HttpResponseException(HttpStatusCode.BadRequest);

                if (!string.IsNullOrEmpty(CustomerID) && CustomerID.Length > 0)
                {
                    Authentication.Account Account = BL.GetAuthentication(CustomerID);

                    if (Account.ValidationResult.ValidationStatus == true)
                    {
                        SharedModel.Models.Security.AccountModel.Login Credential = new SharedModel.Models.Security.AccountModel.Login() { ClientID = CustomerID, WebAcces = true };
                        SharedBusiness.User.BlUser BLUser = new SharedBusiness.User.BlUser();
                        SharedModel.Models.User.User userinfo = BLUser.GetUserInfo(Credential);
                        TokenWeb Token = new TokenWeb
                        {
                            customer_id = CustomerID,
                            token_id = TokenGenerator.GenerateTokenWebJwt(CustomerID, Account.SecretKey, userinfo)
                        };
                        BL.PutLoginToken(CustomerID, true, Token.token_id);
                        return Request.CreateResponse(HttpStatusCode.OK, Token);
                    }
                    else
                    {
                        return Request.CreateResponse(HttpStatusCode.Unauthorized, Account);
                    }
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
                }

            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex);
            }
        }


        [HttpPost]
        [Route("getOTPValue")]
        [SwaggerResponse(HttpStatusCode.BadRequest)]
        [SwaggerResponse(HttpStatusCode.Unauthorized, Type = typeof(Authentication.Account))]
        [SwaggerResponse(HttpStatusCode.InternalServerError)]
        [SwaggerConsumes("application/json")]
      
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage GetOTPValue()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            string CustomerID = "";
            string ApiKey = "";
            string TransactionIdLog = Guid.NewGuid().ToString();
            try
            {
                CustomerID = ((string[])Request.Headers.FirstOrDefault(x => x.Key == "customer_id").Value)[0];
                ApiKey = ((string[])Request.Headers.FirstOrDefault(x => x.Key == "api_key").Value)[0];
                LogService.LogInfo("AuthenticationController GetOTPValue - TransactionIdLog:" + TransactionIdLog + " CUSTOMER:" + CustomerID + " trying to get a otpValue with key " + ApiKey);

                
                if (CustomerID == null || ApiKey == null)
                    throw new HttpResponseException(HttpStatusCode.BadRequest);

                if (!string.IsNullOrEmpty(CustomerID) && CustomerID.Length > 0 && !string.IsNullOrEmpty(ApiKey) && ApiKey.Length > 0)
                {
                   
                        var otpValue=  (CacheService.Get(CustomerID + ApiKey)!=null)? CacheService.Get(CustomerID + ApiKey).ToString():string.Empty;
                        return Request.CreateResponse(HttpStatusCode.OK, otpValue);
                   
                }
                else
                {
                    LogService.LogInfo("AuthenticationController - UNAUTHORIZED LOGIN TransactionIdLog:" + TransactionIdLog + " CUSTOMER:" + CustomerID + " trying to get a token with key " + ApiKey);
                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
                }
            }
            catch (Exception ex)
            {
                LogService.LogError("AuthenticationController - ERROR LOGIN TransactionIdLog: " + TransactionIdLog + ex.Message, CustomerID);
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }
    }
}
