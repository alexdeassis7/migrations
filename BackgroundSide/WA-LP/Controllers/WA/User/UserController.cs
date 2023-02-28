using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Collections.Generic;
using System.Web.Http.Cors;
using SharedBusiness.Log;
using System.Web;
using System.Web.Http.Description;
using SharedSecurity.Signature;
using Newtonsoft.Json;

namespace WA_LP.Controllers.WA.User
{
    //[Authorize]
    [RoutePrefix("v2/users")]
    [ApiExplorerSettings(IgnoreApi = true)]


#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class UserController : BaseApiController
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {


        [HttpGet]
        [Route("user")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage UserInfo()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            try
            {
                HttpContent requestContent = Request.Content;
                string data = requestContent.ReadAsStringAsync().Result;


                var re = Request;
                var headers = re.Headers;
                string user = headers.GetValues("customer_id").First();
                // var user = ((string[])Request.Content.Headers.FirstOrDefault(x => x.Key == "user").Value)[0];

                if (user == null)
                {
                    throw new HttpResponseException(HttpStatusCode.BadRequest);
                }


                if (!string.IsNullOrEmpty(user) && user.Length > 0)
                {
                    SharedModel.Models.Security.AccountModel.Login Credential = new SharedModel.Models.Security.AccountModel.Login() { ClientID = user, WebAcces = true };

                    SharedBusiness.User.BlUser BL = new SharedBusiness.User.BlUser();
                    SharedModel.Models.User.User userinfo = BL.GetUserInfo(Credential);

                    return Request.CreateResponse(HttpStatusCode.OK, userinfo);
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
                }


            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());
                return Request.CreateResponse(HttpStatusCode.Unauthorized, ex);
            }


        }

        [HttpGet]
        [Route("ListUsers")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage GetList()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {

            try
            {
                List<SharedModel.Models.User.User> ListUsers = new List<SharedModel.Models.User.User>();
                SharedBusiness.User.BlUser Bl = new SharedBusiness.User.BlUser();

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();

                if (customer != null && customer.Length > 0)
                {
                    ListUsers = Bl.GetListUsers();


                }
                else
                {
                    //return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }

                return Request.CreateResponse(HttpStatusCode.OK, ListUsers);
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());
                return Request.CreateResponse(HttpStatusCode.Unauthorized, ex);
            }
        }

        [HttpGet]
        [Route("ListAccounts")]
        public HttpResponseMessage GetListAccounts()
        {
            try
            {
                List<SharedModel.Models.Account.ListAccountsResponse> ListUsers = new List<SharedModel.Models.Account.ListAccountsResponse>();
                SharedBusiness.User.BlUser Bl = new SharedBusiness.User.BlUser();
                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                if (customer != null && customer.Length > 0)
                {
                    ListUsers = Bl.GetListAccounts();
                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    //return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }
                return Request.CreateResponse(HttpStatusCode.OK, ListUsers);
            }

            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());
                return Request.CreateResponse(HttpStatusCode.BadRequest, ex);
            }

        }

        [HttpPost]
        [Route("CreateUsers")]
        public HttpResponseMessage CreateUsers()

        {
            try
            {
                String dataRequest = "";
                var response = new List<SharedModelDTO.User.UserIntoAccountRequest>();
                SharedBusiness.User.BlUser Bl = new SharedBusiness.User.BlUser();
                HttpContent requestContent = Request.Content;
                dataRequest = requestContent.ReadAsStringAsync().Result;
                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                if (customer != null && customer.Length > 0)
                {
                    SharedModelDTO.User.UserIntoAccountRequest data = JsonConvert.DeserializeObject<SharedModelDTO.User.UserIntoAccountRequest>(dataRequest);
                    response = Bl.CreateUsers(data);
                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }
                return Request.CreateResponse(HttpStatusCode.OK, response);
            }

            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());
                return Request.CreateResponse(HttpStatusCode.BadRequest, ex);
            }

        }

        [HttpPost]
        [Route("CreateAccount")]
        public HttpResponseMessage CreateAccount()
        {
            try
            {
                String dataRequest = "";
                var response = new List<SharedModel.Models.Account.AccountResponse>();
                SharedBusiness.User.BlUser Bl = new SharedBusiness.User.BlUser();
                HttpContent requestContent = Request.Content;
                dataRequest = requestContent.ReadAsStringAsync().Result;
                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                if (customer != null && customer.Length > 0)
                {
                    SharedModel.Models.Account.AccountRequest data = JsonConvert.DeserializeObject<SharedModel.Models.Account.AccountRequest>(dataRequest);
                    response = Bl.CreateAccount(data);
                    if (response == null) {
                        return Request.CreateResponse(HttpStatusCode.BadRequest, "Merchant already exists");
                    }
                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }
                return Request.CreateResponse(HttpStatusCode.OK, response);

            }

            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());
                return Request.CreateResponse(HttpStatusCode.BadRequest, ex);
            }
        }

        [HttpPost]
        [Route("CheckAccountExists")]
        public HttpResponseMessage CheckAccountExists()
        {
            try
            {
                String dataRequest = "";
                var response = false;
                SharedBusiness.User.BlUser Bl = new SharedBusiness.User.BlUser();
                HttpContent requestContent = Request.Content;
                dataRequest = requestContent.ReadAsStringAsync().Result;
                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();
                if (customer != null && customer.Length > 0)
                {
                    SharedModel.Models.Account.CheckAccount data = JsonConvert.DeserializeObject<SharedModel.Models.Account.CheckAccount>(dataRequest);
                    response = Bl.CheckAccount(data);
                }
                else
                {
                    string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                    return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
                }
                return Request.CreateResponse(HttpStatusCode.OK, response);

            }

            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());
                return Request.CreateResponse(HttpStatusCode.Unauthorized, ex);
            }
        }

        

        [HttpGet]
        [Route("ListUsersKeys")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage GetListKeys()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {

            try
            {
                List<SharedModel.Models.User.User> ListUsers = new List<SharedModel.Models.User.User>();
                SharedBusiness.User.BlUser Bl = new SharedBusiness.User.BlUser();

                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();

                if (customer != null && customer.Length > 0)
                {
                    ListUsers = Bl.GetListKeyUsers();
                }
                else
                {
                }

                return Request.CreateResponse(HttpStatusCode.OK, ListUsers);
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());
                return Request.CreateResponse(HttpStatusCode.Unauthorized, ex);
            }
        }

        [HttpPost]
        [Route("CreateUserKeys")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage CreateUserKeys()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {

            try
            {
                HttpContent requestContent = Request.Content;
                string identification = JsonConvert.DeserializeObject<string>(requestContent.ReadAsStringAsync().Result);
                var re = Request;
                var headers = re.Headers;
                string customer = headers.GetValues("customer_id").First();

                var signature = new DigitalHMACSignature();

                if (customer != null && customer.Length > 0)
                {
                    signature.AssignNewKey(identification);
                }
                else
                {
                }

                return Request.CreateResponse(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, HttpContext.Current.User.Identity.Name, SerializeRequest());
                return Request.CreateResponse(HttpStatusCode.Unauthorized, ex);
            }
        }
    }
}

