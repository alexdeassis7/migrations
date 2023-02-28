using System;
using System.Configuration;
using System.Diagnostics;
using System.Collections.Specialized;

using Janus.Arg.MLogger.Base;

namespace Janus.Arg.MLogger.Logger
{
    public class EventLogger : LogBase
    {
        public override void Log(string message, string database_name)
        {
            try
            {
                Configuration _CONFIG = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                ConfigurationSectionGroup _CONFIG_GROUP = _CONFIG.SectionGroups["MLoggerConfig"];
                var _EVENTLOGGER_CONFIG = _CONFIG_GROUP.Sections.Get("EventLogger");

                var _EVENTLOGGER_CONFIG_ID = (ConfigurationManager.GetSection(_EVENTLOGGER_CONFIG.SectionInformation.SectionName) as NameValueCollection)["cfgEventLogger_IdEventLog"];

                lock (lockObj)
                {
                    EventLog vEventLog = new EventLog("")
                    {
                        Source = _EVENTLOGGER_CONFIG_ID.ToString()
                    };
                    vEventLog.WriteEntry(message);
                }
            }
            catch (Exception ex)
            {
                string strErroMsg = string.Format
                                                (
                                                    "Janus.Arg.MLogger.Logger.EventLogger :: DbName: {0} :: Message: {1} :: ErrorEX: {2}.",
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
