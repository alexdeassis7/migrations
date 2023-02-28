namespace Janus.Arg.MLogger.Base
{
    public enum LogType
    {
        ERROR,
        INFO,
        WARNING,
        SUCCES
    }

    public enum LogTarget
    {
        File,
        Database,
        EventLog
    }

    public abstract class LogBase
    {
        protected readonly object lockObj = new object();
        public abstract void Log(string message, string database_name);
    }
}
