using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

using DAO.DataAccess.Services;

using Hangfire;

using HangFire.Common.Operations.AutomatedJobs.Configuration;
using HangFire.Common.Operations.AutomatedJobs.Models;

using SharedBusiness.Log;
using SharedBusiness.Mail;
using SharedBusiness.Payin;
using SharedBusiness.Services.Payouts;

using Tools;
using Tools.LocalPayment.Tools;

namespace HangFire.Common.Operations.AutomatedJobs
{
    public static class AutomatedProcesses
    {
        [Queue("afipqueue")]
        public static async Task UpdateAfipRetentionEntitiesAsync()
        {
            var afipFolder = "";
            string processStatus;
            var supportEmails = ConfigurationManager.AppSettings["SupportEmails"].Split(';').ToList();
            const string tableName = "LP_Retentions_ARG.RegisteredEntities";
            
            try
            {
                LogService.LogInfo("Initializing AFIP entities update");
                var afipUrl = ConfigurationManager.AppSettings["AFIP_UPDATE_JOB_DOWNLOAD_URL"];

                // creating instance of AFIP Helper
                var afipHelper = new AfipPadronHelper();

                // Get last saturday date
                var lastSaturday = DateTime.Now;
                while (lastSaturday.DayOfWeek != DayOfWeek.Saturday)
                    lastSaturday = lastSaturday.AddDays(-1);
                // date format
                var date = lastSaturday.ToString("yyyyMMdd");
                afipFolder = Path.Combine(ConfigurationManager.AppSettings["AFIP_UPDATE_JOB_ZIP_IMPORT_FOLDER"], date);
                var fileName = Path.Combine(afipFolder, date + ".zip");


                if (!Directory.Exists(afipFolder))
                    Directory.CreateDirectory(afipFolder);

                if (File.Exists(fileName))
                {
                    return;
                }

                using (var client = new WebClient())
                {
                    await client.DownloadFileTaskAsync(afipUrl, fileName);
                }

                // folder to extract zip content
                var extractFolderPath = Path.Combine(afipFolder, "extracted");

                // extract downloaded zip
                ZipFile.ExtractToDirectory(fileName, extractFolderPath);
                var extractedFilePath = Directory.GetFiles(extractFolderPath, "*.*", SearchOption.AllDirectories)[0];

                // get extracted file modification date
                var fileDate = new FileInfo(extractedFilePath).LastWriteTime;

                LogService.LogInfo("Downloaded File Creation Time: " + fileDate);

                DataTable padronRows;
                using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString))
                {
                    connection.Open();
                    // get last update date from Table
                    var entityRecordCmd = new SqlCommand(
                        $"SELECT TOP 1 FORMAT(OP_InsDateTime, 'yyyyMMdd') AS insert_date FROM {tableName}", connection);

                    using (var reader = entityRecordCmd.ExecuteReader())
                    {
                        int compare;

                        if (reader.Read())
                        {
                            if (reader["insert_date"] != DBNull.Value)
                            {
                                var lastInsertDate = reader["insert_date"].ToString();
                                var lastInsertDateTime = DateTime.ParseExact(lastInsertDate, "yyyyMMdd", CultureInfo.InvariantCulture);
                                compare = DateTime.Compare(fileDate, lastInsertDateTime);
                            }
                            else
                            {
                                compare = 1;
                            }
                        }
                        else
                        {
                            compare = 1;
                        }

                        if (compare > 0)
                        {
                            padronRows = afipHelper.GenerateRows(extractedFilePath);
                        }
                        else
                        {
                            processStatus = "Downloaded file was not updated. File date:" + fileDate.ToShortDateString();
                            LogService.LogInfo(processStatus);
                            MailService.SendMail("AFIP - Proceso de actualizacion realizado", processStatus, supportEmails);
                            Directory.Delete(afipFolder, true);

                            return;
                        }
                    }

                    if (padronRows.Rows.Count == 0) throw new Exception();

                    // truncate table
                    var truncateTable = $"truncate table {tableName}";
                    var command = new SqlCommand(truncateTable, connection);
                    command.ExecuteNonQuery();

                    // bulk insert
                    using (var bulkCopy = new SqlBulkCopy(connection))
                    {
                        bulkCopy.DestinationTableName = tableName;
                        bulkCopy.ColumnMappings.Add("ProcessDate", "ProcessDate");
                        bulkCopy.ColumnMappings.Add("CUIT", "CUIT");
                        bulkCopy.ColumnMappings.Add("Alias", "Alias");
                        bulkCopy.ColumnMappings.Add("IncomeTax", "IncomeTax");
                        bulkCopy.ColumnMappings.Add("VatTax", "VatTax");
                        bulkCopy.ColumnMappings.Add("MonoTax", "MonoTax");
                        bulkCopy.ColumnMappings.Add("SocialMember", "SocialMember");
                        bulkCopy.ColumnMappings.Add("Employer", "Employer");
                        bulkCopy.ColumnMappings.Add("MonoTaxActivity", "MonoTaxActivity");
                        bulkCopy.ColumnMappings.Add("Active", "Active");

                        bulkCopy.BulkCopyTimeout = 0;
                        bulkCopy.WriteToServer(padronRows);
                    }
                    connection.Close();
                }

                // deleting folder with downloaded and extracted files
                Directory.Delete(afipFolder, true);

                processStatus = "AFIP entities updated successfully on date " + date + ". Inserted rows count: " + padronRows.Rows.Count;
                LogService.LogInfo(processStatus);
                MailService.SendMail("AFIP - Proceso de actualizacion realizado", processStatus, supportEmails);
            }
            catch (Exception e)
            {
                if (!string.IsNullOrWhiteSpace(afipFolder) && Directory.Exists(afipFolder))
                {
                    Directory.Delete(afipFolder, true);
                }
                processStatus = "There has been an error when updating AFIP registered entities: " + e.Message;
                LogService.LogError(processStatus);
                MailService.SendMail("AFIP - Proceso de actualizacion ERROR", processStatus, supportEmails);
            }

        }
        [Queue("currencycleanqueue")]
        [AutomaticRetry(Attempts = 0)]
        public static void CleanCurrencyExchange()
        {
            try
            {
                LogService.LogInfo("Starting Currency Exchange cleaning process");

                var biCurrencyExchange = new SharedBusiness.View.BICurrencyExchange();
                biCurrencyExchange.CleanCurrencyExchange();

                var process = "Currency Exchange cleaned successfully on date " + DateTime.Now.ToString("yyyyMMdd");
                LogService.LogInfo(process);
            }
            catch (Exception ex)
            {
                LogService.LogError("There was an error in Automated Currency Exchange Clean. Exception message: " + ex);
            }
        }

        [Queue("notificationpushretryqueue")]
        [AutomaticRetry(Attempts = 0)]
        public static void NotificationPushRetry()
        {
            try
            {
                LogService.LogInfo("Starting NotificationPushRetry");

                var payoneerTransactions = new TransactionNotifyModel().GetColombiaTransactionDetails(int.Parse(ConfigurationManager.AppSettings["PAYONEER_NOTIFICATION_COL_ENTITY_ID"]));

                Task.Run(async () =>
                {
                    if (payoneerTransactions.Any())
                    {
                        await MerchantNotificationService.RetrieveAndSendTransactionsCOL(payoneerTransactions.ToList());
                        await MerchantNotificationService.SetNotificationPushSent(payoneerTransactions.Select(x => int.Parse(x.TransactionId)));
                    }

                    var process = "NotificationPushRetry successfully:(" + payoneerTransactions.Count() + ") on date " + DateTime.Now.ToString("yyyyMMdd");
                    LogService.LogInfo(process);

                });
            }
            catch (Exception ex)
            {
                LogService.LogError("There was an error in Automated NotificationPushRetry. Exception message: " + ex);

            }
        }

        [Queue("payintaskqueue")]
        [AutomaticRetry(Attempts = 2)]
        public static void SetExpirePayins()
        {
            try
            {
                LogService.LogInfo("Job Started - Set Expire Payin process");

                new PayinService().SetExpires();

                var process = "Job Finished - Set Expire Payin process on date " + DateTime.Now.ToString("yyyyMMdd");

                LogService.LogInfo(process);
            }
            catch (Exception ex)
            {
                LogService.LogError("There was an error while expiring payin. Exception message: " + ex);
            }
        }

        [Queue("onholdtaskqueue")]
        [AutomaticRetry(Attempts = 2)]
        public static void RejectExpiredOnHold()
        {
            try
            {
                LogService.LogInfo("Job Started - Reject Expired Onhold process");

                new BIPayOut().RejectExpiredOnHold();

                var process = "Job Finished - Reject Expired Onhold process on date " + DateTime.Now.ToString("yyyyMMdd");

                LogService.LogInfo(process);
            }
            catch (Exception ex)
            {
                LogService.LogError("There was an error while rejecting onhold transactions. Exception message: " + ex);
            }
        }

        [AutomaticRetry(Attempts = 0)]
        [Queue("customeraccountbalancetaskqueue")]
        public static void GenerateAccountCustomerBalanceTask()
        {
            // Preparing and Getting configuration from Web.Config (If not exist, throw ConfigurationErrorsException)
            var accountBalanceSetting = CustomerAccountsBalanceSettingsManager.GetCustomerAccountBalanceSetting();

            const int lastMonth = 12;
            var currentMonthNumber = DateTime.Now.Month;
            var monthName = (DateTimeFormatInfo.CurrentInfo.GetMonthName(currentMonthNumber));
            var reportDateToString = $"{currentMonthNumber:D2}-{DateTime.Now.Year}";

            try
            {
                LogService.LogInfo($"Job Started - Customer Account Balance for Month {monthName}");

                // getting service
                var service = new DbCustomerAccountBalanceService();

                // Getting Data from Service
                var accountCustomerBalance = service.GetAccountBalance(
                    new DateTime(DateTime.Now.Year, currentMonthNumber, 01),
                    new DateTime(DateTime.Now.Year, lastMonth, 31));

                // Elaborate the Excel Data using Extension
                var dataSet = accountCustomerBalance.Items.ToDataSet();

                // Preparing Excel
                var excelService = new ExcelService();

                var reportName = $"Corte mensual pasivo {reportDateToString}";
                var fileName = $"{reportName}.xls";
                var fullFilePath = Path.Combine(accountBalanceSetting.FolderReportPath, fileName);

                excelService.Export(dataSet, accountBalanceSetting.FolderReportPath, fileName);

                // prepare the email
                const string processStatus = "Report generated correctly";

                // getting the Email List 
                var emailAddressToReport = accountBalanceSetting.GetEmailListToSendReport();

                var subject = $"cortes mensuales pasivo {reportDateToString}";
                var emailContent = $"{reportName} {processStatus}";

                // sending the email
                MailService.SendMail(subject, emailContent, emailAddressToReport, new[] { fullFilePath });

                var process = $"Job Finished - Customer Account Balance for month {monthName} on date " + DateTime.Now.ToString("yyyyMMdd");

                LogService.LogInfo(process);
            }
            catch (Exception ex)
            {
                LogService.LogError("There was an error while Customer Account Balance Generation process. Exception message: " + ex);
                throw;
            }
        }
    }
}
