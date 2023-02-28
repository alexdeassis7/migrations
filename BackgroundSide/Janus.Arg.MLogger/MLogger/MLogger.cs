using System;
using System.Configuration;
using System.Diagnostics;
using System.Collections.Specialized;

using Janus.Arg.MLogger.Base;
using Janus.Arg.MLogger.Helper;

namespace Janus.Arg.MLogger.MLogger
{
    public static class MLogger
    {
        public static void Log(LogTarget target, LogType type, string message, string database_name)
        {
            try
            {
                string strLogType = string.Empty;
                string message_complete = string.Empty;
                string datetime_process = DateTime.Now.ToString();

                switch (type)
                {
                    case LogType.ERROR:
                        strLogType = "ERROR";
                        break;
                    case LogType.INFO:
                        strLogType = "INFO";
                        break;
                    case LogType.SUCCES:
                        strLogType = "SUCCESS";
                        break;
                    case LogType.WARNING:
                        strLogType = "WARNING";
                        break;
                }

                message_complete = string.Format("{0} :: DateTime: {1} :: Message: {2}.", strLogType, datetime_process, message);

                LogHelper.Log(target, message_complete, database_name);
                System.Threading.Thread.Sleep(500);
            }
            catch (Exception ex)
            {
                string strErroMsg = string.Format("Janus.Arg.MLogger.MLogger.MLogger :: {0}.", ex.ToString());

                EventLog vEventLog = new EventLog("")
                {
                    Source = ConfigurationManager.AppSettings["cfgDefaultEventID"].ToString()
                };
                vEventLog.WriteEntry(strErroMsg);
            }            
        }

        public static bool CheckConfiguration()
        {
            try
            {
                bool _flagCfgFileLogger = false;
                bool _flagCfgDbLogger = false;
                bool _flagCfgEventLogger = false;

                Configuration _CONFIG = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                ConfigurationSectionGroup _CONFIG_GROUP = _CONFIG.SectionGroups["MLoggerConfig"];

                if (_CONFIG_GROUP != null)
                {
                }
                else
                {
                    throw new Exception("No existen configuraciones: MLoggerConfig!");                    
                }

                /* Section: FileLogger */
                var _FILELOGGER_CONFIG = _CONFIG_GROUP.Sections.Get("FileLogger");
                var _FILELOGGER_CONFIG_PATH = (ConfigurationManager.GetSection(_FILELOGGER_CONFIG.SectionInformation.SectionName) as NameValueCollection)["cfgFileLogger_Path"];

                if (_FILELOGGER_CONFIG != null)
                {
                    if (_FILELOGGER_CONFIG_PATH != null)
                    {
                        _flagCfgFileLogger = true;
                    }
                    else
                    {
                        throw new Exception("No existen configuraciones: _FILELOGGER_CONFIG_PATH!");
                    }
                }
                else
                {
                    _flagCfgFileLogger = false;
                }

                /* Section: DbLogger */
                var _DBLOGGER_CONFIG = _CONFIG_GROUP.Sections.Get("DbLogger");
                var _DBLOGGER_CONFIG_CONN = (ConfigurationManager.GetSection(_DBLOGGER_CONFIG.SectionInformation.SectionName) as NameValueCollection)["cfgDbLogger_DbConnName"];

                if (_DBLOGGER_CONFIG != null)
                {
                    if (_DBLOGGER_CONFIG_CONN != null)
                    {
                        _flagCfgDbLogger = true;
                    }
                    else
                    {
                        throw new Exception("No existen configuraciones: _DBLOGGER_CONFIG_CONN!");
                    }
                }
                else
                {
                    _flagCfgDbLogger = false;
                }

                /* Section: EventLogger */
                var _EVENTLOGGER_CONFIG = _CONFIG_GROUP.Sections.Get("EventLogger");
                var _EVENTLOGGER_CONFIG_CONN = (ConfigurationManager.GetSection(_EVENTLOGGER_CONFIG.SectionInformation.SectionName) as NameValueCollection)["cfgEventLogger_IdEventLog"];

                if (_EVENTLOGGER_CONFIG != null)
                {
                    if (_EVENTLOGGER_CONFIG_CONN != null)
                    {
                        _flagCfgEventLogger = true;
                    }
                    else
                    {
                        throw new Exception("No existen configuraciones: _EVENTLOGGER_CONFIG_CONN!");
                    }
                }
                else
                {
                    _flagCfgEventLogger = false;
                }

                if (_flagCfgFileLogger == false && _flagCfgDbLogger == false && _flagCfgEventLogger == false)
                {
                    return false;
                }
                else
                {
                    return true;
                }               
            }
            catch (Exception)
            {
                return false;
            }
        }

        public static bool CheckConfiguration(LogTarget target)
        {
            try
            {
                bool _flagCfgConfigGroup = false;

                Configuration _CONFIG = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                ConfigurationSectionGroup _CONFIG_GROUP = _CONFIG.SectionGroups["MLoggerConfig"];

                if (_CONFIG_GROUP != null)
                {
                    _flagCfgConfigGroup = true;
                }
                else
                {
                    _flagCfgConfigGroup = false;
                }

                switch (target)
                {
                    case LogTarget.File:
                        /* Section: FileLogger */
                        var _FILELOGGER_CONFIG = _CONFIG_GROUP.Sections.Get("FileLogger");
                        var _FILELOGGER_CONFIG_PATH = (ConfigurationManager.GetSection(_FILELOGGER_CONFIG.SectionInformation.SectionName) as NameValueCollection)["cfgFileLogger_Path"];

                        if (_FILELOGGER_CONFIG != null)
                        {
                            if (_FILELOGGER_CONFIG_PATH != null)
                            {
                                if (_flagCfgConfigGroup)
                                {
                                    return true;
                                }
                                else
                                {
                                    return false;
                                }
                            }
                            else
                            {
                                return false;
                            }
                        }
                        else
                        {
                            return false;
                        }
                    case LogTarget.Database:
                        /* Section: DbLogger */
                        var _DBLOGGER_CONFIG = _CONFIG_GROUP.Sections.Get("DbLogger");
                        var _DBLOGGER_CONFIG_CONN = (ConfigurationManager.GetSection(_DBLOGGER_CONFIG.SectionInformation.SectionName) as NameValueCollection)["cfgDbLogger_DbConnName"];

                        if (_DBLOGGER_CONFIG != null)
                        {
                            if (_DBLOGGER_CONFIG_CONN != null)
                            {
                                if (_flagCfgConfigGroup)
                                {
                                    return true;
                                }
                                else
                                {
                                    return false;
                                }
                            }
                            else
                            {
                                return false;
                            }
                        }
                        else
                        {
                            return false;
                        }
                    case LogTarget.EventLog:
                        /* Section: EventLogger */
                        var _EVENTLOGGER_CONFIG = _CONFIG_GROUP.Sections.Get("EventLogger");
                        var _EVENTLOGGER_CONFIG_CONN = (ConfigurationManager.GetSection(_EVENTLOGGER_CONFIG.SectionInformation.SectionName) as NameValueCollection)["cfgEventLogger_IdEventLog"];

                        if (_EVENTLOGGER_CONFIG != null)
                        {
                            if (_EVENTLOGGER_CONFIG_CONN != null)
                            {
                                if (_flagCfgConfigGroup)
                                {
                                    return true;
                                }
                                else
                                {
                                    return false;
                                }
                            }
                            else
                            {
                                return false;
                            }
                        }
                        else
                        {
                            return false;
                        }
                }

                return false;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
