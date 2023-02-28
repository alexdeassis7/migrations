using System.Web.Http;
using System.Web.Http.Cors;
using SharedSecurity.JWT.Handler;

namespace WA_LP
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public static class WebApiConfig
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static void Register(HttpConfiguration config)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            var cors = new EnableCorsAttribute("*", "*", "*");
            config.EnableCors(cors);
            
            config.MapHttpAttributeRoutes();

            config.MessageHandlers.Add(new TokenValidationHandler());

            config.Routes.MapHttpRoute(
                name: "SecurityApi",
                routeTemplate: "v2/Security/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );

            config.Routes.MapHttpRoute(
                name: "ServicesApi",
                routeTemplate: "v2/Services/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }
    }
}
