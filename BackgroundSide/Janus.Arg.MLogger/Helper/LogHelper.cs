using System;
using System.Configuration;
using System.Diagnostics;

using Janus.Arg.MLogger.Base;
using Janus.Arg.MLogger.Logger;

namespace Janus.Arg.MLogger.Helper
{
    public static class LogHelper
    {
        private static LogBase logger = null;
        public static void Log(LogTarget target, string message, string database_name)
        {
            try
            {
                switch (target)
                {
                    case LogTarget.File:
                        logger = new FileLogger();
                        logger.Log(message, database_name);
                        break;
                    case LogTarget.Database:
                        logger = new DBLogger();
                        logger.Log(message, database_name);
                        break;
                    case LogTarget.EventLog:
                        logger = new EventLogger();
                        logger.Log(message, database_name);
                        break;
                    default:
                        return;
                }
            }
            catch (Exception ex)
            {
                string strErroMsg = string.Format
                                                (
                                                    "Janus.Arg.MLogger.Helper.LogHelper ::  Target: {0} :: DbName: {1} :: Message: {2} :: ErrorEX: {3}.",
                                                    target.ToString(),
                                                    database_name,
                                                    message,
                                                    ex.ToString()
                                                );

                EventLog vEventLog = new EventLog("")
                {
                    Source = ConfigurationManager.AppSettings["cfgDefaultEventID"].ToString()
                };
                vEventLog.WriteEntry(strErroMsg);
            }
            
        }
    }
}
