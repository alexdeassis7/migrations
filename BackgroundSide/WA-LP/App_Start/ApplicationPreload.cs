using SharedBusiness.Log;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WA_LP.App_Start
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class ApplicationPreload : System.Web.Hosting.IProcessHostPreloadClient
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public void Preload(string[] parameters)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            LogService.LogInfo("Application Preload");
            HangfireBootstrapper.Instance.Start();
        }
    }
}