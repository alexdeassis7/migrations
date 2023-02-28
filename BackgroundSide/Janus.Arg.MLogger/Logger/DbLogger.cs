using System;
using System.Configuration;
using System.Diagnostics;
using System.Collections.Specialized;
using System.Data;
using System.Data.SqlClient;

using Janus.Arg.MLogger.Base;

namespace Janus.Arg.MLogger.Logger
{
    public class DBLogger : LogBase
    {
        string connectionString = string.Empty;
        SqlConnection _conn;
        SqlCommand _cmd;
        SqlParameter _prm;
        public override void Log(string message, string database_name)
        {
            try
            {
                Configuration _CONFIG = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                ConfigurationSectionGroup _CONFIG_GROUP = _CONFIG.SectionGroups["MLoggerConfig"];
                var _DBLOGGER_CONFIG = _CONFIG_GROUP.Sections.Get("DbLogger");

                var _DBLOGGER_CONFIG_CONN = (ConfigurationManager.GetSection(_DBLOGGER_CONFIG.SectionInformation.SectionName) as NameValueCollection)["cfgDbLogger_DbConnName"];

                lock (lockObj)
                {
                    _conn = new SqlConnection(ConfigurationManager.ConnectionStrings[_DBLOGGER_CONFIG_CONN].ConnectionString);

                    _conn.Open();
                    _conn.ChangeDatabase(database_name);

                    _cmd = new SqlCommand("[LP_Log].[FillSystemLog]", _conn)
                    {
                        CommandType = CommandType.StoredProcedure
                    };
                    _prm = new SqlParameter("@Message", SqlDbType.VarChar) { Value = message };
                    _cmd.Parameters.Add(_prm);
                    
                    _cmd.ExecuteNonQuery();
                    _conn.Close();

                    if (_conn.State == ConnectionState.Open)
                        _conn.Close();
                }
            }
            catch (Exception ex)
            {
                string strErroMsg = string.Format
                                                (
                                                    "Janus.Arg.MLogger.Logger.DBLogger :: DbName: {0} :: Message: {1} :: ErrorEX: {2}.",
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
