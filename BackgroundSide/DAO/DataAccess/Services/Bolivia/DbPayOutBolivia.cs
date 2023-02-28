using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using DAO.DataAccess.Services.CrossCountry;
using Newtonsoft.Json;
using SharedModel.Models.Services.Bolivia;
using SharedModel.Models.Services.Payouts;
using SharedModelDTO.Models.LotBatch;
using Tools;
using Tools.LocalPayment.Tools;

namespace DAO.DataAccess.Services.Bolivia
{
    public class DbPayOutBolivia
    {
        SqlConnection _conn;
        SqlCommand _cmd;
        SqlParameter _prm;
        SqlDataAdapter _da;
        DataSet _ds;
        DataTable _dt;

        public LotBatchModel CreateLotTransaction(LotBatchModel data, string customer, string countryCode, bool TransactionMechanism)
        {
            var result = new LotBatchModel();

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Operation].[BOL_Payout_Generic_Entity_Operation_Create]", _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@json", SqlDbType.NVarChar, -1) { Value = JsonConvert.SerializeObject(data) };
                _cmd.Parameters.Add(_prm);
                _prm = new SqlParameter("@customer", SqlDbType.NVarChar, 50) { Value = customer };
                _cmd.Parameters.Add(_prm);
                _prm = new SqlParameter("@country_code", SqlDbType.VarChar, 3) { Value = countryCode };
                _cmd.Parameters.Add(_prm);
                if (TransactionMechanism)
                {
                    _prm = new SqlParameter("@TransactionMechanism", SqlDbType.Bit) { Value = TransactionMechanism };
                    _cmd.Parameters.Add(_prm);
                }
                else
                {
                    _prm = new SqlParameter("@TransactionMechanism", SqlDbType.Bit) { Value = false };
                    _cmd.Parameters.Add(_prm);
                }

                _ds = new DataSet();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);
                result = JsonConvert.DeserializeObject<LotBatchModel>(_ds.Tables[0].Rows[0][0].ToString());

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        public BoliviaPayoutDownloadResponse DownloadBatchLotTransactionToBank(bool TransactionMechanism, string JSON, string providerName)
        {

            var result = new BoliviaPayoutDownloadResponse();

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                var sp = "";

                switch (providerName)
                {
                    case "":
                        break;
                }

                _cmd = new SqlCommand(sp, _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JSON };
                _cmd.Parameters.Add(_prm);
                _prm = new SqlParameter("@TransactionMechanism", SqlDbType.Bit) { Value = TransactionMechanism };
                _cmd.Parameters.Add(_prm);

                _ds = new DataSet();
                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables.Count > 0)
                {
                    _dt = _ds.Tables[0];
                    result.Rows = _dt.Rows.Count;

                    result.Lines = new string[_dt.Rows.Count];

                    for (int i = 0; i < _dt.Rows.Count; i++)
                    {
                        result.Lines[i] = _dt.Rows[i][0].ToString();
                    }

                }
                else
                {
                    result.Rows = 0;
                }

                result.Status = "OK";
                result.StatusMessage = "OK";
            }

            catch (Exception ex)
            {
                result.Status = "ERROR";
                result.StatusMessage = ex.Message;
            }

            return result;

        }

        [BankActionDownloadIdentifier("BGBOL")]
        public PayOutBolivia.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBank_BANCO_GANADERO_BOLIVIA(bool TransactionMechanism, string JSON, int internalFiles)
        {
            PayOutBolivia.DownloadLotBatchTransactionToBank.Response result = new PayOutBolivia.DownloadLotBatchTransactionToBank.Response();

            const string storedProcedureName = "[LP_Operation].[BOL_Payout_BANCO_GANADERO_Operation_Download]";

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand(storedProcedureName, _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };

                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JSON };
                _cmd.Parameters.Add(_prm);

                _ds = new DataSet();
                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);

                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables.Count > 0)
                {
                    result.PayoutFiles = new List<PayOutBolivia.DownloadLotBatchTransactionToBank.PayoutFile>();
                    PayOutBolivia.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;
                
                    PayoutFile = new PayOutBolivia.DownloadLotBatchTransactionToBank.PayoutFile
                    {
                        LinesPayouts = new List<string>(),

                        RowsPayouts = _ds.Tables[0].Rows.Count
                    };

                    result.ExcelRows = _ds.Tables[0].Rows.Count;

                    

                    result.DownloadCount = _ds.Tables[0].Rows.Count;

                    ExcelService excelService = new ExcelService();

                    result.ExcelExportByteArray = excelService
                        .ExportToByteArray(_ds, new[] { "Hoja1" }).GetAwaiter().GetResult();
                }
                else
                {
                    result.ExcelRows = 0;
                    result.DownloadCount = 0;
                    result.RowsPreRegister = 0;
                    result.LinesPreRegister = new string[0];
                    result.ExcelExportByteArray = null;
                }

                result.Status = "OK";
                result.StatusMessage = "OK";
            }
            catch (Exception ex)
            {
                result.RowsPreRegister = 0;
                result.Status = "ERROR";
                result.StatusMessage = ex.Message;
            }
            return result;
        }

        public List<BoliviaTransactionDetail> UpdateLotBatchTransactionFromBank(Int64 CurrencyFxClose, bool TransactionMechanism, List<Payouts.UploadModel> uploadModel)
        {
            var Detail = new List<BoliviaTransactionDetail>();

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Operation].[CHL_Payout_ITAU_Bank_Operation_Upload]", _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JsonConvert.SerializeObject(uploadModel) };
                _cmd.Parameters.Add(_prm);
                _prm = new SqlParameter("@CurrencyExchangeClose", SqlDbType.BigInt) { Value = CurrencyFxClose };
                _cmd.Parameters.Add(_prm);
                if (TransactionMechanism == true)
                {
                    _prm = new SqlParameter("@TransactionMechanism", SqlDbType.Bit) { Value = TransactionMechanism };
                    _cmd.Parameters.Add(_prm);
                }
                else
                {
                    _prm = new SqlParameter("@TransactionMechanism", SqlDbType.Bit) { Value = false };
                    _cmd.Parameters.Add(_prm);
                }

                _ds = new DataSet();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                foreach (DataRow row in _ds.Tables[0].Rows)
                {
                    Detail.Add(DataRowHelper.CreateItemFromRow<BoliviaTransactionDetail>(row));
                }

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return Detail;
        }
    }
}
