using Newtonsoft.Json;
using SharedBusiness.Log;
using SharedModel.Models.General;
using Swashbuckle.Swagger.Annotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;
namespace WA_LP.Controllers.WA.TransactionData
{
    [Authorize]
    [RoutePrefix("v2/transactions")]
    [ApiExplorerSettings(IgnoreApi = false)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class TransactionDataController : BaseApiController
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        /// <summary>
        /// Create
        /// </summary>
        /// <remarks>
        /// </remarks>
        [HttpPost]
        [Route("auditLogs")]
        [SwaggerResponse(HttpStatusCode.BadRequest, Type = typeof(GeneralErrorModel))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, Type = typeof(GeneralErrorModel))]
        public HttpResponseMessage GetAuditLogs()
        {
            String data = "";
            string transactionIdLog = Guid.NewGuid().ToString();

            try
            {
                HttpContent requestContent = Request.Content;
                data = requestContent.ReadAsStringAsync().Result;
                if (data != null)
                {
                    object response;
                    SharedModel.Models.TransactionData.TransactionDataModel transactionData = JsonConvert.DeserializeObject<SharedModel.Models.TransactionData.TransactionDataModel>(data);
                    SharedBusiness.TransactionData.AuditLogs TData = new SharedBusiness.TransactionData.AuditLogs();
                    response = TData.getAuditLogs(transactionData.DateTo, transactionData.DateFrom, transactionData.Quantity, transactionData.DataToSearch);
                    string result1 = JsonConvert.SerializeObject(response);
                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.DeserializeObject(result1));
                }
                else
                {
                    GeneralErrorModel Error = new GeneralErrorModel()
                    {
                        Code = "400",
                        CodeDescription = "BadRequest",
                        Message = "Bad Parameter Value or Parameters Values."
                    };
                    LogService.LogInfo(string.Format("TRANSACTIONDATAController-GetAuditLogs - TRANSACTIONIDLOG: {0} BAD REQUEST", transactionIdLog));

                    return Request.CreateResponse(HttpStatusCode.BadRequest, Error);
                }
            }
            catch (Exception ex)
            {
                LogService.LogError(ex, "", string.Format("TRANSACTIONDATAController-GetAuditLogs - REQUEST {0}, TRANSACTIONIDLOG {1}", data, transactionIdLog));

                GeneralErrorModel Error = new GeneralErrorModel()
                {
                    Code = "500",
                    CodeDescription = "InternalServerError",
                    Message = ex.Message.ToString()
                };

                return Request.CreateResponse(HttpStatusCode.InternalServerError, Error);
            }

        }
    }
}