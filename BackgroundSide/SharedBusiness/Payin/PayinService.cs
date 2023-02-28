using Newtonsoft.Json;
using SharedBusiness.Log;
using SharedBusiness.Payin.DTO;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedBusiness.Payin
{
    public class PayinService
    {
        const string CONNECTION_STRING_DB = "connDbLocalPayment";

        public void SetExpires()
        {
            try
            {
                using (var _conn = new SqlConnection(ConfigurationManager.ConnectionStrings[CONNECTION_STRING_DB].ConnectionString))
                {
                    _conn.Open();

                    var _cmd = new SqlCommand("[LP_Operation].[Payin_Set_Expired]", _conn)
                    {
                        CommandType = CommandType.StoredProcedure
                    };

                    _cmd.ExecuteNonQuery();
                }
            }
            catch (Exception e)
            {
                LogService.LogError(e);
                throw;
            }
        }
        public void SetExecuted(TicketsToChangeStatusDto ticketsDto)
        {
            try
            {
                using (var _conn = new SqlConnection(ConfigurationManager.ConnectionStrings[CONNECTION_STRING_DB].ConnectionString))
                {
                    _conn.Open();

                    var _cmd = new SqlCommand("[LP_Operation].[PayIn_Generic_Entity_Operation_Executed]", _conn)
                    {
                        CommandType = CommandType.StoredProcedure
                    };

                    var _prm = new SqlParameter("@json", SqlDbType.NVarChar, -1) { Value = JsonConvert.SerializeObject(ticketsDto) };
                    _cmd.Parameters.Add(_prm);

                    _cmd.ExecuteNonQuery();
                }
            }
            catch (Exception e)
            {
                LogService.LogError(e);
                throw;
            }
        }
    }
}
