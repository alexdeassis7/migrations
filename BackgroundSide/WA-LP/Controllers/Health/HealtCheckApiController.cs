using SharedBusiness.Tools;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Description;

namespace WA_LP.Controllers.Health
{
    [RoutePrefix("v2")]
    [ApiExplorerSettings(IgnoreApi = true)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class HealtCheckApiController : ApiController
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        const string HealthCheckKey = "HealthCheck_Code";
        [Route("healthcheck")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public bool Get([FromUri] string code)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            if (code == ConfigurationManager.AppSettings[HealthCheckKey])
            {
                return new MonitorService().HealtCheckDb();
            }
            else
                throw new Exception("Invalid Code");
        }
    }
}