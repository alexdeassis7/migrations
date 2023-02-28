using System;
using System.Configuration;
using System.Diagnostics;
using System.Collections.Specialized;
using System.IO;

using Janus.Arg.MLogger.Base;

namespace Janus.Arg.MLogger.Logger
{
    public class FileLogger : LogBase
    {
        public override void Log(string message, string database_name)
        {
            try
            {
                lock (lockObj)
                {
                    Configuration _CONFIG = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                    ConfigurationSectionGroup _CONFIG_GROUP = _CONFIG.SectionGroups["MLoggerConfig"];
                    var _FILELOGGER_CONFIG = _CONFIG_GROUP.Sections.Get("FileLogger");

                    var _FILELOGGER_CONFIG_PATH = (ConfigurationManager.GetSection(_FILELOGGER_CONFIG.SectionInformation.SectionName) as NameValueCollection)["cfgFileLogger_Path"];

                    if (!Directory.Exists(_FILELOGGER_CONFIG_PATH))
                    {
                        Directory.CreateDirectory(_FILELOGGER_CONFIG_PATH);
                    }

                    string _LOGFILENAME = _FILELOGGER_CONFIG_PATH + "\\" + "MLOGGER_LOG_" + DateTime.Now.ToString("yyyyMMdd") + ".txt";
                    if (!File.Exists(_LOGFILENAME))
                    {
                        using (FileStream fileinfo = new FileStream(_LOGFILENAME, FileMode.Create))
                        {
                            fileinfo.Close();
                            fileinfo.Dispose();
                        }
                    }

                    using (StreamWriter streamWriter = new StreamWriter(_LOGFILENAME, true))
                    {
                        streamWriter.WriteLine(message);
                        streamWriter.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                string strErroMsg = string.Format
                                                 (
                                                    "Janus.Arg.MLogger.Logger.FileLogger :: DbName: {0} :: Message: {1} :: ErrorEX: {2}.",
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
