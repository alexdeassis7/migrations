using Hangfire;
using Hangfire.SqlServer;
using SharedBusiness.Log;
using System;
using System.Configuration;
using System.Web.Hosting;
using WA_LP.HangFireCustomLogger;

namespace WA_LP.App_Start
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class HangfireBootstrapper : IRegisteredObject
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static readonly HangfireBootstrapper Instance = new HangfireBootstrapper();
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        private readonly object _lockObject = new object();
        private bool _started;

        private BackgroundJobServer _backgroundJobServer;

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string PayoneerArgReportQueue = "PayoneerArgQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string PayoneerColReportQueue = "PayoneerColQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string PayoneerBraReportQueue = "PayoneerBraQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string PayoneerMexReportQueue = "PayoneerMexQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string PayoneerUryReportQueue = "PayoneerUryQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string PayoneerChlReportQueue = "PayoneerChlQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string PayoneerPerReportQueue = "PayoneerPerQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string PayoneerEcuReportQueue = "PayoneerEcuQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string NiumMerchantReportsQueue = "NiumReportsQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string AfipQueue = "AfipQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string GeneralBlceQueue = "GeneralBlceQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string TranLotQueue = "TranLotQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string CurrencyCleanQueue = "CurrencyCleanQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string AmlQueue = "AmlQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string NotificationPushRetryQueue = "NotificationPushRetryQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string PayinTaskQueue = "PayinTaskQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string OnholdTaskQueue = "OnholdTaskQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public const string CustomerAccountBalanceTaskQueue = "CustomerAccountBalanceTaskQueue";
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        private HangfireBootstrapper()
        {
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public void Start()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            LogService.LogInfo("HangFire instance Start");
            try
            {

            lock (_lockObject)
            {
                if (_started) return;
                _started = true;

                HostingEnvironment.RegisterObject(this);

                Hangfire.GlobalConfiguration.Configuration
                .UseLogProvider(new CustomLogProvider())
                .SetDataCompatibilityLevel(CompatibilityLevel.Version_170)
                .UseSimpleAssemblyNameTypeSerializer()
                .UseRecommendedSerializerSettings()
                .UseSqlServerStorage(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString, new SqlServerStorageOptions
                {
                    CommandBatchMaxTimeout = TimeSpan.FromMinutes(5),
                    SlidingInvisibilityTimeout = TimeSpan.FromMinutes(5),
                    QueuePollInterval = TimeSpan.Zero,
                    UseRecommendedIsolationLevel = true,
                    UsePageLocksOnDequeue = true,
                    DisableGlobalLocks = true,
                    PrepareSchemaIfNecessary = true
                });
                // Specify other options here

                var options = new BackgroundJobServerOptions
                {
                    Queues = new[] {
                        PayoneerArgReportQueue.ToLower(),
                        PayoneerColReportQueue.ToLower(),
                        PayoneerBraReportQueue.ToLower(),
                        PayoneerMexReportQueue.ToLower(),
                        AfipQueue.ToLower(),
                        GeneralBlceQueue.ToLower(),
                        TranLotQueue.ToLower(),
                        CurrencyCleanQueue.ToLower(),
                        AmlQueue.ToLower(),
                        PayinTaskQueue.ToLower(),
                        NotificationPushRetryQueue.ToLower(),
                        NiumMerchantReportsQueue.ToLower(),
                        PayoneerChlReportQueue.ToLower(),
                        PayoneerUryReportQueue.ToLower(),
                        OnholdTaskQueue.ToLower(),
                        CustomerAccountBalanceTaskQueue.ToLower(),
                        PayoneerEcuReportQueue.ToLower(),
                        PayoneerPerReportQueue.ToLower()
                    }
                };

                _backgroundJobServer = new BackgroundJobServer(options);
            }
            }catch (Exception ex)
            {
                LogService.LogInfo("HangFireBoostrapper instance Error "+ ex.Message);
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public void Stop()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            LogService.LogInfo("HangFire instance Stop");

            lock (_lockObject)
            {
                if (_backgroundJobServer != null)
                {
                    _backgroundJobServer.Dispose();
                }

                HostingEnvironment.UnregisterObject(this);
            }
        }

        void IRegisteredObject.Stop(bool immediate)
        {
            Stop();
        }
    }
}