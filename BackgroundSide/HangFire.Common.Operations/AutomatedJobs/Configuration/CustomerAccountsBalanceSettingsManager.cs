using HangFire.Common.Operations.AutomatedJobs.Models.Configuration;
using System.Collections.Generic;

using System;
using System.Configuration;
using System.Linq;

namespace HangFire.Common.Operations.AutomatedJobs.Configuration
{
    /// <summary>
    /// Configuration Manager for Customer Account Balance Settings
    /// </summary>
    public static class CustomerAccountsBalanceSettingsManager
    {
        /// <summary>
        /// Get settings values related to CustomerBalance Settings
        /// </summary>
        /// <returns>returns a <see cref="CustomersAccountBalanceSetting"/> object filled with configuration settings</returns>
        /// <exception cref="ConfigurationErrorsException">If Configuration is not properly configured on Web.Config</exception>
        internal static CustomersAccountBalanceSetting GetCustomerAccountBalanceSetting()
        {
            var fileReportFolder =
                ConfigurationManager.AppSettings["LP_CUSTOMERS_ACCOUNT_BALANCE_AUTOMATED_REPORT_FILE_GEN_FOLDER"]
                ?? throw new ConfigurationErrorsException(
                    "[\"LP_CUSTOMERS_ACCOUNT_BALANCE_AUTOMATED_REPORT_FILE_GEN_FOLDER\"] is not defined in AppSettings");

            var cronExpression =
                ConfigurationManager.AppSettings["LP_CUSTOMERS_ACCOUNT_BALANCE_AUTOMATED_REPORT_CRON_EXPRESSION"]
                ?? throw new ConfigurationErrorsException(
                    "[\"LP_CUSTOMERS_ACCOUNT_BALANCE_AUTOMATED_REPORT_CRON_EXPRESSION\"] is not defined in AppSettings");

            var sendReportToEmail =
                ConfigurationManager.AppSettings["LP_CUSTOMERS_ACCOUNT_BALANCE_AUTOMATED_REPORT_SEND_TO"] ??
                throw new ConfigurationErrorsException(
                    "[\"LP_CUSTOMERS_ACCOUNT_BALANCE_AUTOMATED_REPORT_SEND_TO\"] is not defined in AppSettings");

            return new CustomersAccountBalanceSetting
            {
                CronJobExpression = cronExpression,
                FolderReportPath = fileReportFolder,
                ReportToEmailAddresses = sendReportToEmail
            };
        }

        /// <summary>
        /// Extension Method to get a list of email address
        /// </summary>
        /// <param name="accountBalanceSetting"></param>
        /// <returns>Return a List of String with email address</returns>
        public static List<string> GetEmailListToSendReport(this CustomersAccountBalanceSetting accountBalanceSetting)
        {
            return accountBalanceSetting.ReportToEmailAddresses
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .ToList();
        }
    }
}