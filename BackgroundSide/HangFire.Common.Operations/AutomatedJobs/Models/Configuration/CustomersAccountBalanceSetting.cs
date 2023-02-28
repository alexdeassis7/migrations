﻿namespace HangFire.Common.Operations.AutomatedJobs.Models.Configuration
{
    /// <summary>
    /// Customer Account Balance Monthly Job Setting
    /// </summary>
    public class CustomersAccountBalanceSetting
    {
        /// <summary>
        /// Cron expression that defines how often and when the job will be triggered
        /// </summary>
        public string CronJobExpression { get; set; }

        /// <summary>
        /// Folder where the generated by the report will be located
        /// </summary>
        public string FolderReportPath { get; set; }

        /// <summary>
        /// String comma separated email address where the report will be send
        /// </summary>
        public string ReportToEmailAddresses { get; set; }
    }
}
