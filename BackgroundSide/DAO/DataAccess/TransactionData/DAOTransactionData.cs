using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAO.DataAccess.TransactionData
{
    public class DAOTransactionData
    {
        SqlCommand _cmd;
        SqlParameter _prm;
        SqlDataAdapter _da;
        DataSet _ds;

        public object getAuditLogs(string dateTo, string dateFrom, int quantity, string dataToSearch)
        {
            object result;

            try
            {
                using (SqlConnection _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString))
                {
                    if (_conn.State == ConnectionState.Open)
                        _conn.Close();

                    _cmd = new SqlCommand("[LP_Filter].[AuditLogs]", _conn)
                    {
                        CommandType = CommandType.StoredProcedure,
                        CommandTimeout = 0
                    };
                    _prm = new SqlParameter("@dateFrom", SqlDbType.VarChar, 50) { Value = dateFrom.ToString() };
                    _cmd.Parameters.Add(_prm);
                    _prm = new SqlParameter("@dateTo", SqlDbType.VarChar, 50) { Value = dateTo.ToString() };
                    _cmd.Parameters.Add(_prm);
                    _prm = new SqlParameter("@quantity", SqlDbType.Int) { Value = quantity };
                    _cmd.Parameters.Add(_prm);
                    _prm = new SqlParameter("@dataToSearch", SqlDbType.VarChar) { Value = dataToSearch };
                    _cmd.Parameters.Add(_prm);
                    _ds = new DataSet();
                    _da = new SqlDataAdapter(_cmd);
                    _da.Fill(_ds);
                    result = JsonConvert.DeserializeObject<List<SharedModelDTO.Models.AuditLogs.AuditLogsDTO>>(dataSetToJSON(_ds));
                    if (_conn.State == ConnectionState.Open)
                        _conn.Close();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;


        }

        public static string dataSetToJSON(DataSet ds)
        {
            ArrayList root = new ArrayList();
            List<Dictionary<string, object>> table;
            Dictionary<string, object> data;

            foreach (DataTable dt in ds.Tables)
            {
                table = new List<Dictionary<string, object>>();
                foreach (DataRow dr in dt.Rows)
                {
                    data = new Dictionary<string, object>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        data.Add(col.ColumnName, dr[col]);
                    }
                    table.Add(data);
                }
                root.Add(table);
            }
            string json = JsonConvert.SerializeObject(root[0]);
            return json;
        }
    }
}
