using Serilog;
using Serilog.Core;
using SharedBusiness.Mail;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;

namespace SharedBusiness.Log
{
    public static class LogService
    {
        //private readonly
        private static Logger log;
        private static List<string> supportEmails;
        public static void Configure()
        {
            var loggerConfiguration = new LoggerConfiguration().WriteTo.MSSqlServer(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString, schemaName: "LP_Log", tableName: "AuditLog", autoCreateSqlTable: true);
            //var loggerConfiguration = new LoggerConfiguration().ReadFrom.AppSettings();
            //loggerConfiguration.WriteTo.MSSqlServer(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString, schemaName: "LP_Log", tableName: "AuditLog", autoCreateSqlTable: true);
            //.Async(x => x.MSSqlServer(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString, "AudittLog",autoCreateSqlTable: true));
            log = loggerConfiguration.CreateLogger();
            supportEmails = ConfigurationManager.AppSettings["SupportEmails"].Split(';').ToList();
        }
        public static void LogError(Exception e, string customerId = "", string request = "")
        {
            try
            {
                log.Error(string.Format("CLIENT: {0}, REQUEST: {1}, ERROR:{2}", customerId, request, e.Message));
                MailService.SendMail(string.Format("Error - Cliente:{0}", customerId), string.Format("REQUEST: {0} ,ERROR: {1}", request , e.Message), supportEmails);
            }
            catch { }
        }
        public static void LogInfo(string val)
        {
            try
            {
               log.Information(val);
            }
            catch { }
        }
        public static void LogError(string val, string customerId = "")
        {
            try
            {
                log.Error(val);
                MailService.SendMail(string.Format("Error - Cliente:{0}", customerId), string.Format("Error: {0}", val), supportEmails);
            }
            catch { }
        }

        public static async Task LogErrorAsync(Exception e, string customerId, string request = "")
        {
            log.Error(string.Format("CLIENT: {0}, REQUEST: {1}, ERROR:{2}", customerId, request, e.Message));

            await Task.Run(() => {
                try
                {
                    MailService.SendMail(string.Format("Error - Cliente:{0}", customerId), string.Format("REQUEST: {0} ,ERROR: {1}", request, e.Message), supportEmails);
                }
                catch
                { }
            });

        }
    }
}
