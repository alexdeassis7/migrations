using SharedBusiness.Log;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http.Filters;
using WA_LP.Serializer.Extensions;
namespace WA_LP.Filters
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class CustomExceptionFilterAttribute : ExceptionFilterAttribute
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        //Resolve logservice y logear
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public override Task OnExceptionAsync(HttpActionExecutedContext actionExecutedContext, System.Threading.CancellationToken cancellationToken)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            var customerId = HttpContext.Current.User.Identity.Name;
            return LogService.LogErrorAsync(actionExecutedContext.Exception, customerId, actionExecutedContext.Request.SerializeRequest());
            /*
           return await new Task(()=> {
               logService.LogError(actionExecutedContext.Exception);
           });*/
        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public override void OnException(HttpActionExecutedContext actionExecutedContext)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            var customerId = HttpContext.Current.User.Identity.Name;
            LogService.LogError(actionExecutedContext.Exception, customerId, actionExecutedContext.Request.SerializeRequest());
        }
    }
}