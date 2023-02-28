using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using Newtonsoft.Json;
using SharedModel.Models.Services.Paraguay;
using SharedModel.Models.Services.Payouts;
using SharedModelDTO.Models.LotBatch;
using Tools;
using Tools.LocalPayment.Tools;

namespace DAO.DataAccess.Services.Paraguay
{
    public class DbPayOutParaguay
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

                _cmd = new SqlCommand("[LP_Operation].[PRY_Payout_Generic_Entity_Operation_Create]", _conn)
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
                result = JsonConvert.DeserializeObject<SharedModelDTO.Models.LotBatch.LotBatchModel>(_ds.Tables[0].Rows[0][0].ToString());

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        [BankActionDownloadIdentifier("ITAUPYG")]
        public SharedModel.Models.Services.Paraguay.PayOutParaguay.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBankITAUPYG(bool TransactionMechanism, string JSON)
        {
            SharedModel.Models.Services.Paraguay.PayOutParaguay.DownloadLotBatchTransactionToBank.Response result = new SharedModel.Models.Services.Paraguay.PayOutParaguay.DownloadLotBatchTransactionToBank.Response();

            const string storedProcedureName = "[LP_Operation].[PYG_Payout_ITAUPYG_Bank_Operation_Download]";

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
                    result.PayoutFiles = new List<SharedModel.Models.Services.Paraguay.PayOutParaguay.DownloadLotBatchTransactionToBank.PayoutFile>();
                    SharedModel.Models.Services.Paraguay.PayOutParaguay.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;
                    PayoutFile = new SharedModel.Models.Services.Paraguay.PayOutParaguay.DownloadLotBatchTransactionToBank.PayoutFile
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
                    result.ExcelExportByteArray = null;
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


        public List<SharedModel.Models.Services.Paraguay.PayOutParaguay.UploadTxtFromBank.TransactionDetail> UpdateLotBatchTransactionFromBank(Int64 CurrencyFxClose, bool TransactionMechanism, List<Payouts.UploadModel> uploadModel)
        {
            var Detail = new List<SharedModel.Models.Services.Paraguay.PayOutParaguay.UploadTxtFromBank.TransactionDetail>();

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
                    Detail.Add(DataRowHelper.CreateItemFromRow<SharedModel.Models.Services.Paraguay.PayOutParaguay.UploadTxtFromBank.TransactionDetail>(row));
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