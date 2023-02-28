﻿using SharedModel.Models.General;
using Swashbuckle.Swagger.Annotations;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Cors;
using System.Web.Http.Description;

namespace WA_LP.Controllers.WA.Services
{
    [Authorize]
    [RoutePrefix("v2")]
    [ApiExplorerSettings(IgnoreApi = false)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class BalanceController : BaseApiController
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        [HttpGet]
        [Route("getBalance")]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(List<SharedModel.Models.Services.Banks.Galicia.PayOut.ClientBalance>))]
        [SwaggerResponse(HttpStatusCode.BadRequest, Type = typeof(GeneralErrorModel))]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public HttpResponseMessage GetClientBalance()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            var re = Request;
            var headers = re.Headers;
            string customer = headers.GetValues("customer_id").First();
            //string countryCode = headers.GetValues("countryCode").First();
            List<SharedModel.Models.Services.Banks.Galicia.PayOut.ClientBalance> lResponse = new List<SharedModel.Models.Services.Banks.Galicia.PayOut.ClientBalance>();

            if (customer != null && customer.Length > 0)
            {
                SharedBusiness.Services.Banks.Galicia.BIPayOut BiPO = new SharedBusiness.Services.Banks.Galicia.BIPayOut();
                lResponse = BiPO.ClientBalance(customer);

                return Request.CreateResponse(HttpStatusCode.OK, lResponse);
            }
            else
            {
                string resultError = "{\"Code\":400,\"CodeDescription\":\"BadRequest\",\"Message\":\"Bad Parameter Value or Parameters Values.\" }";
                return Request.CreateResponse(HttpStatusCode.BadRequest, resultError);
            }
        }
    }
}