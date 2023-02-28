using System;
using System.Configuration;
using System.Web;
using Hangfire;
using HangFire.Common.Operations.AutomatedJobs;
using SharedBusiness.Log;
using SharedBusiness.Services.CrossCutting;
using WA_LP.App_Start;
using WA_LP.Cache;

namespace WA_LP
{
    /// <inheritdoc />
    public class WebApiApplication : HttpApplication
    {
        private static readonly object AppStartLock = new object();

        #pragma warning disable CS1591
        protected void Application_Start(object sender, EventArgs e)
        {
            lock (AppStartLock)
            {
                SharedBusiness.Common.Configuration.Init();
                DictionaryService.Init();
                LogInCacheService.Init();
                BankValidateCacheService.Init();
                PayinPaymentMethodValidateCacheService.Init();
                System.Web.Http.GlobalConfiguration.Configure(WebApiConfig.Register);

                // set up hangfire jobs
                HangfireBootstrapper.Instance.Start();
                SetupHangfireJobs();
            }
        }

        protected void Application_End(object sender, EventArgs e) => HangfireBootstrapper.Instance.Stop();

        private void SetupHangfireJobs()
        {
            try { 
                LogService.LogInfo("Setting up HangFire jobs");
                // Starting HangFire Server
                // HangfireAspNet.Use(GetHangfireServers);

                // Adding Payoneer CSV Report Generation job ARG
                // Get cron Expression from config file
                var configParamsNameArg = "PAYONEER_ARG_AUTOMATED_REPORT_";
                var cronExpressionArg = ConfigurationManager.AppSettings[configParamsNameArg + "CRON_EXPRESSION"];
                var jobNamePayoneerArg = "payoneer_automated_report_arg";

                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNamePayoneerArg);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNamePayoneerArg, () => AutomatedReports.GenerateAndUploadMerchantReportCSVarg(configParamsNameArg), cronExpressionArg, TimeZoneInfo.Local, queue: HangfireBootstrapper.PayoneerArgReportQueue.ToLower());

                // Adding Payoneer CSV Report Generation job COL
                // Get cron Expression from config file
                var configParamsNameCol = "PAYONEER_COL_AUTOMATED_REPORT_";
                var cronExpressionCol = ConfigurationManager.AppSettings[configParamsNameCol + "CRON_EXPRESSION"];
                var jobNamePayoneerCol = "payoneer_automated_report_col";
                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNamePayoneerCol);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNamePayoneerCol, () => AutomatedReports.GenerateAndUploadMerchantReportCSVcol(configParamsNameCol), cronExpressionCol, TimeZoneInfo.Local, queue: HangfireBootstrapper.PayoneerColReportQueue.ToLower());

                // Adding Payoneer CSV Report Generation job BRA
                // Get cron Expression from config file
                var configParamsNameBra = "PAYONEER_BRA_AUTOMATED_REPORT_";
                var cronExpressionBra = ConfigurationManager.AppSettings[configParamsNameBra + "CRON_EXPRESSION"];
                var jobNamePayoneerBra = "payoneer_automated_report_bra";
                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNamePayoneerBra);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNamePayoneerBra, () => AutomatedReports.GenerateAndUploadMerchantReportCSVbra(configParamsNameBra), cronExpressionBra, TimeZoneInfo.Local, queue: HangfireBootstrapper.PayoneerBraReportQueue.ToLower());

                // Adding Payoneer CSV Report Generation job MEX
                // Get cron Expression from config file
                var configParamsNameMex = "PAYONEER_MEX_AUTOMATED_REPORT_";
                var cronExpressionMex = ConfigurationManager.AppSettings[configParamsNameMex + "CRON_EXPRESSION"];
                var jobNamePayoneerMex = "payoneer_automated_report_mex";
                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNamePayoneerMex);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNamePayoneerMex, () => AutomatedReports.GenerateAndUploadMerchantReportCSVmex(configParamsNameMex), cronExpressionMex, TimeZoneInfo.Local, queue: HangfireBootstrapper.PayoneerMexReportQueue.ToLower());

                // Adding Payoneer CSV Report Generation job URY
                // Get cron Expression from config file
                var configParamsNameUry = "PAYONEER_URY_AUTOMATED_REPORT_";
                var cronExpressionUry = ConfigurationManager.AppSettings[configParamsNameUry + "CRON_EXPRESSION"];
                var jobNamePayoneerUry = "payoneer_automated_report_ury";
                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNamePayoneerUry);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNamePayoneerUry, () => AutomatedReports.GenerateAndUploadMerchantReportCSVury(configParamsNameUry), cronExpressionUry, TimeZoneInfo.Local, queue: HangfireBootstrapper.PayoneerUryReportQueue.ToLower());

                // Adding Payoneer CSV Report Generation job CHL
                // Get cron Expression from config file
                var configParamsNameChl = "PAYONEER_CHL_AUTOMATED_REPORT_";
                var cronExpressionChl = ConfigurationManager.AppSettings[configParamsNameChl + "CRON_EXPRESSION"];
                var jobNamePayoneerChl = "payoneer_automated_report_chl";
                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNamePayoneerChl);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNamePayoneerChl, () => AutomatedReports.GenerateAndUploadMerchantReportCSVchl(configParamsNameChl), cronExpressionChl, TimeZoneInfo.Local, queue: HangfireBootstrapper.PayoneerChlReportQueue.ToLower());

                // Adding Payoneer CSV Report Generation job PER
                // Get cron Expression from config file
                var configParamsNamePer = "PAYONEER_PER_AUTOMATED_REPORT_";
                var cronExpressionPer = ConfigurationManager.AppSettings[configParamsNamePer + "CRON_EXPRESSION"];
                var jobNamePayoneerPer = "payoneer_automated_report_per";
                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNamePayoneerPer);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNamePayoneerPer, () => AutomatedReports.GenerateAndUploadMerchantReportCSVper(configParamsNamePer), cronExpressionPer, TimeZoneInfo.Local, queue: HangfireBootstrapper.PayoneerPerReportQueue.ToLower());

                // Adding Payoneer CSV Report Generation job Ecu
                // Get cron Expression from config file
                var configParamsNameEcu = "PAYONEER_ECU_AUTOMATED_REPORT_";
                var cronExpressionEcu = ConfigurationManager.AppSettings[configParamsNameEcu + "CRON_EXPRESSION"];
                var jobNamePayoneerEcu = "payoneer_automated_report_ecu";
                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNamePayoneerEcu);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNamePayoneerEcu, () => AutomatedReports.GenerateAndUploadMerchantReportCSVecu(configParamsNameEcu), cronExpressionEcu, TimeZoneInfo.Local, queue: HangfireBootstrapper.PayoneerEcuReportQueue.ToLower());




                // Adding Nium Merchant Report Generation job
                // Get cron Expression from config file
                var niumCronExpression = ConfigurationManager.AppSettings["NIUM_AUTOMATED_REPORT_CRON_EXPRESSION"];
                var jobNameNium = "nium_automated_merchant_reports";
                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNameNium);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNameNium, () => AutomatedReports.GenerateAndUploadNiumMerchantReportsJob(), niumCronExpression, TimeZoneInfo.Local, queue: HangfireBootstrapper.NiumMerchantReportsQueue.ToLower());

                // AFIP Registered Entities UPDATE
                var afipJobName = ConfigurationManager.AppSettings["AFIP_UPDATE_JOB_HF_NAME"];
                var afipJobCronExp = ConfigurationManager.AppSettings["AFIP_UPDATE_JOB_CRON_EXPRESSION"]; // Runs every saturday at 23 PM
                RecurringJob.RemoveIfExists(afipJobName);
                RecurringJob.AddOrUpdate(afipJobName, () => AutomatedProcesses.UpdateAfipRetentionEntitiesAsync(), afipJobCronExp, TimeZoneInfo.Local, queue: HangfireBootstrapper.AfipQueue.ToLower());

                //NOTIFICATION EMAIL SECTION

                //GENERAL BALANCE
                // Get cron Expression from config file
                var cronExpressionGeneralBalance = ConfigurationManager.AppSettings["AUTOMATED_EMAIL_GENERAL_BALANCE_CRON_EXPRESSION"];
                var jobNameGeneralBalance = "email_notificacion_general_balance";
                // To prevent Job being duplicated we first Remove it if it exists.
                RecurringJob.RemoveIfExists(jobNameGeneralBalance);
                // Set up job in HangFire
                RecurringJob.AddOrUpdate(jobNameGeneralBalance, () => AutomatedEmails.GenerateAndSendGeneralBalanceEmail(), cronExpressionGeneralBalance, TimeZoneInfo.Local, queue: HangfireBootstrapper.GeneralBlceQueue.ToLower());

                //TRANSACTION LOT
                var jobNameTransactionLot = "email_notificacion_transaction_lot";
                var cronExpressionTransactionLot = ConfigurationManager.AppSettings["AUTOMATED_EMAIL_TRANSACTION_LOT_CRON_EXPRESSION"]; //Runs every 6 hours
                RecurringJob.RemoveIfExists(jobNameTransactionLot);
                RecurringJob.AddOrUpdate(jobNameTransactionLot, () => AutomatedEmails.SendTransactionLotInfo(), cronExpressionTransactionLot, TimeZoneInfo.Local, queue: HangfireBootstrapper.TranLotQueue.ToLower());

                //CLEANING CURRENCY EXCHANGE
                var jobNameCleanCurrency = "clean_job_currency_exchange";
                var cronExpressionCleanCurrency = ConfigurationManager.AppSettings["AUTOMATED_CLEANING_CURRENCY_EXCHANGE_CRON_EXPRESSION"];
                RecurringJob.RemoveIfExists(jobNameCleanCurrency);
                RecurringJob.AddOrUpdate(jobNameCleanCurrency, () => AutomatedProcesses.CleanCurrencyExchange(), cronExpressionCleanCurrency, TimeZoneInfo.Local, queue: HangfireBootstrapper.CurrencyCleanQueue.ToLower());

                //AML
                var jobNameAML = "email_notificacion_aml";
                var cronExpressionAML = ConfigurationManager.AppSettings["AUTOMATED_EMAIL_AML_CRON_EXPRESSION"];
                RecurringJob.RemoveIfExists(jobNameAML);
                RecurringJob.AddOrUpdate(jobNameAML, () => AutomatedEmails.SendAmlReport(HttpContext.Current.Server.MapPath("~/" + "AML")), cronExpressionAML, TimeZoneInfo.Local, queue: HangfireBootstrapper.AmlQueue.ToLower());

                //JOB NOTIFICATION PUSH RETRY
                var jobNameNotificationPushRetry = "notification_push_retry";
                var cronExpressionNotificationPushRetry = ConfigurationManager.AppSettings["NOTIFICATION_PUSH_RETRY_CRON_EXPRESSION"];
                RecurringJob.RemoveIfExists(jobNameNotificationPushRetry);
                RecurringJob.AddOrUpdate(jobNameNotificationPushRetry, () => AutomatedProcesses.NotificationPushRetry(), cronExpressionNotificationPushRetry, TimeZoneInfo.Local, queue: HangfireBootstrapper.NotificationPushRetryQueue.ToLower());

                //SET PAYIN EXPIRE
                var jobNameSetPayinExpire = "set_payin_expire";
                var cronExpressionSetPayinExpire = ConfigurationManager.AppSettings["PAYIN_JOB_SET_EXPIRATION_CRON_EXPRESSION"];
                RecurringJob.RemoveIfExists(jobNameSetPayinExpire);
                RecurringJob.AddOrUpdate(jobNameSetPayinExpire, () => AutomatedProcesses.SetExpirePayins(), cronExpressionSetPayinExpire, TimeZoneInfo.Local, queue: HangfireBootstrapper.PayinTaskQueue.ToLower());

                //REJECT ONHOLD
                var jobNameRejectOnHold = "reject_onhold";
                var cronExpressionRejectOnHold = ConfigurationManager.AppSettings["ONHOLD_JOB_SET_EXPIRATION_CRON_EXPRESSION"];
                RecurringJob.RemoveIfExists(jobNameRejectOnHold);
                RecurringJob.AddOrUpdate(jobNameRejectOnHold, () => AutomatedProcesses.RejectExpiredOnHold(), cronExpressionRejectOnHold, TimeZoneInfo.Local, queue: HangfireBootstrapper.OnholdTaskQueue.ToLower());

                // ACCOUNT CUSTOMER BALANCE MONTHLY
                var jobNameMonthAccountCustomerBalance = "customeraccountbalance";
                var cronExpressionMonthAccountCustomerBalance = ConfigurationManager.AppSettings["LP_CUSTOMERS_ACCOUNT_BALANCE_AUTOMATED_REPORT_CRON_EXPRESSION"];
                RecurringJob.RemoveIfExists(jobNameMonthAccountCustomerBalance);
                RecurringJob.AddOrUpdate(
                    jobNameMonthAccountCustomerBalance,
                    () => AutomatedProcesses.GenerateAccountCustomerBalanceTask(),
                    cronExpressionMonthAccountCustomerBalance,
                    TimeZoneInfo.Local,
                    queue: HangfireBootstrapper.CustomerAccountBalanceTaskQueue.ToLower()
                    );
            }catch (Exception ex)
            {
                LogService.LogError("Failed in Setting Up Hangfire "+ex.Message);
            }
        }

        protected void Application_BeginRequest()
        {
            if (HttpContext.Current.Request.HttpMethod != "OPTIONS") return;

            HttpContext.Current.Response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
            HttpContext.Current.Response.AddHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, customer_id, api_key, customer_id_to, countryCode");
            HttpContext.Current.Response.AddHeader("Access-Control-Max-Age", "1728000");
            HttpContext.Current.Response.AddHeader("Access-Control-Request-Method", "*");
        }
    }
}
