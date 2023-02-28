using System.Web.Http.Filters;

namespace WA_LP
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class AddCustomHeaderFilter : ActionFilterAttribute
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public override void OnActionExecuted(HttpActionExecutedContext actionExecutedContext)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            actionExecutedContext.Response.Headers.Add("customHeader", "custom value date time");
        }
    }
}