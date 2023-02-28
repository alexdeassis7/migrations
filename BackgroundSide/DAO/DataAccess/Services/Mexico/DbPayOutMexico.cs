using DAO.DataAccess.Services.CrossCountry;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using Tools;
using Tools.LocalPayment.Tools;

namespace DAO.DataAccess.Services.Mexico
{
    public class DbPayOutMexico
    {
        SqlConnection _conn;
        SqlCommand _cmd;
        SqlParameter _prm;
        SqlDataAdapter _da;
        DataSet _ds;
        DataTable _dt;
        const int DeadlockErrorCode = 1205;
        public SharedModelDTO.Models.LotBatch.LotBatchModel CreateLotTransaction(SharedModelDTO.Models.LotBatch.LotBatchModel data, string customer, string countryCode, bool TransactionMechanism, int retries = 0)
        {
            SharedModelDTO.Models.LotBatch.LotBatchModel result = new SharedModelDTO.Models.LotBatch.LotBatchModel();

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Operation].[MEX_Payout_Generic_Entity_Operation_Create]", _conn)
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
                result = JsonConvert.DeserializeObject<SharedModelDTO.Models.LotBatch.LotBatchModel>(_ds.Tables[0].Rows[0][0].ToString());

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
            }
            catch (SqlException sqlex)
            {
                // Deadlock 
                if (sqlex.Number == DeadlockErrorCode && retries <= int.Parse(ConfigurationManager.AppSettings["Deadlock_MaxRetriesCount"]))
                {
                    System.Threading.Thread.Sleep(int.Parse(ConfigurationManager.AppSettings["Deadlock_DelayForRetryInMS"]));
                    result = CreateLotTransaction(data, customer, countryCode, TransactionMechanism, retries + 1);
                }
                else
                    throw;
            }
            return result;
        }

        [BankActionDownloadIdentifier("MIFEL")]
        public SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBank(bool TransactionMechanism, string JSON, int internalFiles)
        {

            SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response result = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response();
            string MifelDownloadSp = "[LP_Operation].[MEX_Payout_MIFEL_Bank_Operation_Download]";

            if (internalFiles > 0)
            {
                MifelDownloadSp = "[LP_Operation].[MEX_Payout_MIFEL_Bank_Operation_Download_Internal]";
            }
            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand(MifelDownloadSp, _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JSON };
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
                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables.Count > 0)
                {
                    result.PayoutFiles = new List<SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile>();
                    SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;
                    PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile
                    {
                        LinesPayouts = new List<string>()
                    };
                    result.PreRegisterLot = _ds.Tables[0].Rows[0][2].ToString();

                    int fileNumber = int.Parse(_ds.Tables[0].Rows[0][0].ToString());
                    int auxCount = 0;
                    decimal fileTotal = 0;
                    for (int i = 0; i < _ds.Tables[0].Rows.Count; i++)
                    {
                        auxCount++;
                        // Adding Line
                        PayoutFile.LinesPayouts.Add(_ds.Tables[0].Rows[i][1].ToString());
                        // Sum line amount
                        decimal lineAmount = 0;
                        if (!string.IsNullOrEmpty(_ds.Tables[0].Rows[i][3].ToString()))
                        {
                            lineAmount = decimal.Parse(_ds.Tables[0].Rows[i][3].ToString());
                        }

                        fileTotal += lineAmount;

                        if ((i + 1) != _ds.Tables[0].Rows.Count && int.Parse(_ds.Tables[0].Rows[i + 1][0].ToString()) != fileNumber)
                        {
                            PayoutFile.FileTotal = fileTotal.ToString().Replace(",", ".");
                            PayoutFile.RowsPayouts = auxCount - 1; // substracting header record

                            fileNumber = int.Parse(_ds.Tables[0].Rows[i + 1][0].ToString());
                            result.PayoutFiles.Add(PayoutFile);
                            // INITIALIZE NEW PAYOUTFILE
                            PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile
                            {
                                LinesPayouts = new List<string>()
                            };
                            fileTotal = 0;
                            auxCount = 0;
                        }
                    }
                    PayoutFile.FileTotal = fileTotal.ToString().Replace(",", ".");
                    PayoutFile.RowsPayouts = auxCount - 1;
                    result.PayoutFiles.Add(PayoutFile);

                    result.RowsPreRegister = _ds.Tables[1].Rows.Count;
                    result.LinesPreRegister = new string[_ds.Tables[1].Rows.Count];
                    for (int i = 0; i < _ds.Tables[1].Rows.Count; i++)
                    {
                        result.LinesPreRegister[i] = _ds.Tables[1].Rows[i][0].ToString();

                    }

                }
                else
                {
                    //result.RowsPayouts = 0;
                    result.RowsPreRegister = 0;
                }

                result.Status = "OK";
                result.StatusMessage = "OK";
            }

            catch (Exception ex)
            {
                //result.RowsPayouts = 0;
                result.RowsPreRegister = 0;
                result.Status = "ERROR";
                result.StatusMessage = ex.Message;
            }

            return result;

        }

        [BankActionDownloadIdentifier("SABADELL")]
        public SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBankSabadell(bool TransactionMechanism, string JSON, int internalFiles)
        {

            SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response result = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response();
            string SabadellDownloadSp = "[LP_Operation].[MEX_Payout_SABADELL_Bank_Operation_Download]";

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand(SabadellDownloadSp, _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JSON };
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
                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables.Count > 0)
                {
                    result.PayoutFiles = new List<SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile>();
                    SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;
                    PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile
                    {
                        LinesPayouts = new List<string>()
                    };
                    result.PreRegisterLot = _ds.Tables[0].Rows[0][2].ToString();

                    int fileNumber = int.Parse(_ds.Tables[0].Rows[0][0].ToString());
                    int auxCount = 0;
                    decimal fileTotal = 0;
                    for (int i = 0; i < _ds.Tables[0].Rows.Count; i++)
                    {
                        auxCount++;
                        // Adding Line
                        PayoutFile.LinesPayouts.Add(_ds.Tables[0].Rows[i][1].ToString());
                        // Sum line amount
                        decimal lineAmount = 0;
                        if (!string.IsNullOrEmpty(_ds.Tables[0].Rows[i][3].ToString()))
                        {
                            lineAmount = decimal.Parse(_ds.Tables[0].Rows[i][3].ToString());
                        }

                        fileTotal += lineAmount;

                        if ((i + 1) != _ds.Tables[0].Rows.Count && int.Parse(_ds.Tables[0].Rows[i + 1][0].ToString()) != fileNumber)
                        {
                            PayoutFile.FileTotal = fileTotal.ToString().Replace(",", ".");
                            PayoutFile.RowsPayouts = auxCount - 1; // substracting header record

                            fileNumber = int.Parse(_ds.Tables[0].Rows[i + 1][0].ToString());
                            result.PayoutFiles.Add(PayoutFile);
                            // INITIALIZE NEW PAYOUTFILE
                            PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile
                            {
                                LinesPayouts = new List<string>()
                            };
                            fileTotal = 0;
                            auxCount = 0;
                        }
                    }
                    PayoutFile.FileTotal = fileTotal.ToString().Replace(",", ".");
                    PayoutFile.RowsPayouts = auxCount - 1;
                    result.PayoutFiles.Add(PayoutFile);

                    result.RowsPreRegister = _ds.Tables[1].Rows.Count;
                    result.LinesPreRegister = new string[_ds.Tables[1].Rows.Count];

                    result.DownloadCount = int.Parse(_ds.Tables[0].Rows[0][4].ToString());

                    for (int i = 0; i < _ds.Tables[1].Rows.Count; i++)
                    {
                        result.LinesPreRegister[i] = _ds.Tables[1].Rows[i][0].ToString();

                    }

                }
                else
                {
                    //result.RowsPayouts = 0;
                    result.RowsPreRegister = 0;
                }

                result.Status = "OK";
                result.StatusMessage = "OK";
            }

            catch (Exception ex)
            {
                //result.RowsPayouts = 0;
                result.RowsPreRegister = 0;
                result.Status = "ERROR";
                result.StatusMessage = ex.Message;
            }

            return result;

        }

        [BankActionDownloadIdentifier("SRM")]
        public SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBankSantander(bool TransactionMechanism, string JSON, int internalFiles)
        {

            SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response result = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response();
            string SrmDownloadSp = "[LP_Operation].[MEX_Payout_SANTANDER_Bank_Operation_Download]";

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand(SrmDownloadSp, _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JSON };
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
                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables.Count > 0)
                {
                    result.PayoutFiles = new List<SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile>();
                    SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;
                    PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile
                    {
                        LinesPayouts = new List<string>(),

                        RowsPayouts = _ds.Tables[0].Rows.Count
                    };

                    for (int i = 0; i < _ds.Tables[0].Rows.Count; i++)
                    {
                        PayoutFile.LinesPayouts.Add(_ds.Tables[0].Rows[i][0].ToString());
                    }

                    PayoutFile.FileTotal = _ds.Tables[2].Rows[0][0].ToString();
                    result.PayoutFiles.Add(PayoutFile);

                    result.DownloadCount = _ds.Tables[0].Rows.Count;
                    result.RowsPreRegister = _ds.Tables[1].Rows.Count;
                    result.LinesPreRegister = new string[_ds.Tables[1].Rows.Count];

                    for (int i = 0; i < _ds.Tables[1].Rows.Count; i++)
                    {
                        result.LinesPreRegister[i] = _ds.Tables[1].Rows[i][0].ToString();
                    }
                }
                else
                {
                    result.DownloadCount = 0;
                    result.RowsPreRegister = 0;
                    result.LinesPreRegister = new string[0];
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

        [BankActionDownloadIdentifier("BANORTE")]
        public SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBankBanorte(bool TransactionMechanism, string JSON, int internalFiles)
        {

            SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response result = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response();
            string SrmDownloadSp = "[LP_Operation].[MEX_Payout_BANORTE_Bank_Operation_Download]";

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand(SrmDownloadSp, _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JSON };
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
                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables.Count > 0)
                {
                    result.PayoutFiles = new List<SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile>();
                    SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;
                    PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile
                    {
                        LinesPayouts = new List<string>(),

                        RowsPayouts = _ds.Tables[0].Rows.Count
                    };

                    for (int i = 0; i < _ds.Tables[0].Rows.Count; i++)
                    {
                        PayoutFile.LinesPayouts.Add(_ds.Tables[0].Rows[i][0].ToString());
                    }

                    PayoutFile.FileTotal = _ds.Tables[2].Rows[0][0].ToString();
                    result.PayoutFiles.Add(PayoutFile);

                    result.DownloadCount = _ds.Tables[0].Rows.Count;
                    result.RowsPreRegister = _ds.Tables[1].Rows.Count;
                    result.LinesPreRegister = new string[_ds.Tables[1].Rows.Count];

                    for (int i = 0; i < _ds.Tables[1].Rows.Count; i++)
                    {
                        result.LinesPreRegister[i] = _ds.Tables[1].Rows[i][0].ToString();
                    }
                }
                else
                {
                    result.DownloadCount = 0;
                    result.RowsPreRegister = 0;
                    result.LinesPreRegister = new string[0];
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

        [BankActionDownloadIdentifier("BBVAMEX")]
        public SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBankBBVAMEX(bool TransactionMechanism, string JSON, int internalFiles)
        {

            SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response result = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response();
            string SrmDownloadSp = "[LP_Operation].[MEX_Payout_BBVA_Bank_Operation_Download]";

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand(SrmDownloadSp, _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JSON };
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
                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables.Count > 0)
                {
                    result.PayoutFiles = new List<SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile>();
                    SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;
                    PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile
                    {
                        LinesPayouts = new List<string>(),

                        RowsPayouts = _ds.Tables[0].Rows.Count
                    };

                    for (int i = 0; i < _ds.Tables[0].Rows.Count; i++)
                    {
                        PayoutFile.LinesPayouts.Add(_ds.Tables[0].Rows[i][0].ToString());
                    }

                    PayoutFile.FileTotal = _ds.Tables[3].Rows[0][0].ToString();
                    result.PayoutFiles.Add(PayoutFile);

                    result.DownloadCount = _ds.Tables[0].Rows.Count;

                    result.RowsPreRegister = _ds.Tables[1].Rows.Count;
                    result.LinesPreRegister = new string[_ds.Tables[1].Rows.Count];

                    for (int i = 0; i < _ds.Tables[1].Rows.Count; i++)
                    {
                        result.LinesPreRegister[i] = _ds.Tables[1].Rows[i][0].ToString();
                    }

                    result.RowsPreRegisterSameBank = _ds.Tables[2].Rows.Count;
                    result.LinesPreRegisterSameBank = new string[_ds.Tables[2].Rows.Count];

                    for (int i = 0; i < _ds.Tables[2].Rows.Count; i++)
                    {
                        result.LinesPreRegisterSameBank[i] = _ds.Tables[2].Rows[i][0].ToString();
                    }
                }
                else
                {
                    result.DownloadCount = 0;
                    result.RowsPreRegister = 0;
                    result.LinesPreRegister = new string[0];
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

        [BankActionDownloadIdentifier("PMIMEX")]
        public SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBankPMIMEX(bool TransactionMechanism, string JSON, int internalFiles)
        {
            SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response result = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response();

            const string storedProcedureName = "[LP_Operation].[MEX_Payout_PMIAmericas_Bank_Operation_Download]";

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
                    result.PayoutFiles = new List<SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile>();
                    SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;
                    PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile
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

        [BankActionDownloadIdentifier("SCOTMEX")]
        public SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBankScotiaBankMexico(bool TransactionMechanism, string JSON, int internalFiles)
        {

            SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response result = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response();
            string SrmDownloadSp = "[LP_Operation].[MEX_Payout_ScotiaBank_Bank_Operation_Download]";

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand(SrmDownloadSp, _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JSON };
                _cmd.Parameters.Add(_prm);

                //if (TransactionMechanism)
                //{
                //    _prm = new SqlParameter("@TransactionMechanism", SqlDbType.Bit) { Value = TransactionMechanism };
                //    _cmd.Parameters.Add(_prm);
                //}
                //else
                //{
                //    _prm = new SqlParameter("@TransactionMechanism", SqlDbType.Bit) { Value = false };
                //    _cmd.Parameters.Add(_prm);
                //}

                _ds = new DataSet();
                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);

                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables.Count <= 0)
                {
                    result.DownloadCount = 0;
                    result.RowsPreRegister = 0;
                    result.LinesPreRegister = new string[0];
                    result.Status = "OK";
                    result.StatusMessage = "OK";
                    return result;
                }

                result.PayoutFiles = new List<SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile>();
                SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;

                PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile
                {
                    LinesPayouts = new List<string>(),

                    RowsPayouts = _ds.Tables[0].Rows.Count
                };

                for (int i = 0; i < _ds.Tables[0].Rows.Count; i++)
                {
                    PayoutFile.LinesPayouts.Add(_ds.Tables[0].Rows[i][0].ToString());
                }

                result.PayoutFiles.Add(PayoutFile);

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

        [BankActionDownloadIdentifier("STPMEX")]
        public SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response DownloadBatchLotTransactionToBankSTPMexico(bool TransactionMechanism, string JSON, int internalFiles)
        {

            SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response result = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.Response();
            string SrmDownloadSp = "[LP_Operation].[MEX_Payout_STPMEX_Bank_Operation_Download]";

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand(SrmDownloadSp, _conn);
                _cmd.CommandType = CommandType.StoredProcedure;
                _cmd.CommandTimeout = 0;
                _prm = new SqlParameter("@JSON", SqlDbType.VarChar) { Value = JSON };
                _cmd.Parameters.Add(_prm);
                _ds = new DataSet();
                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);

                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables.Count <= 0)
                {
                    result.DownloadCount = 0;
                    result.RowsPreRegister = 0;
                    result.LinesPreRegister = new string[0];
                    result.Status = "OK";
                    result.StatusMessage = "OK";
                    return result;
                }

                result.PayoutFiles = new List<SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile>();
                SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile PayoutFile;

                PayoutFile = new SharedModel.Models.Services.Mexico.PayOutMexico.DownloadLotBatchTransactionToBank.PayoutFile();
                PayoutFile.LinesPayouts = new List<string>();

                PayoutFile.RowsPayouts = _ds.Tables[0].Rows.Count;

                for (int i = 0; i < _ds.Tables[0].Rows.Count; i++)
                {
                    PayoutFile.LinesPayouts.Add(_ds.Tables[0].Rows[i][0].ToString());
                }

                result.PayoutFiles.Add(PayoutFile);

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



        public List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> UpdateLotBatchTransactionFromBank(Int64 CurrencyFxClose, bool TransactionMechanism, List<SharedModel.Models.Services.Payouts.Payouts.UploadModelMifel> uploadModel)
        {
            List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> Detail = new List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail>();

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Operation].[MEX_Payout_MIFEL_Bank_Operation_Upload]", _conn)
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
                    Detail.Add(DataRowHelper.CreateItemFromRow<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail>(row));
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

        public List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> UpdateLotBatchTransactionFromBankSantander(Int64 CurrencyFxClose, bool TransactionMechanism, List<SharedModel.Models.Services.Payouts.Payouts.UploadModelMifel> uploadModel)
        {
            List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> Detail = new List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail>();

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Operation].[MEX_Payout_SANTANDER_Bank_Operation_Upload]", _conn)
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
                    Detail.Add(DataRowHelper.CreateItemFromRow<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail>(row));
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

        public List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> UpdateLotBatchTransactionFromBankSabadell(Int64 CurrencyFxClose, bool TransactionMechanism, List<SharedModel.Models.Services.Payouts.Payouts.UploadModelMifel> uploadModel)
        {
            List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> Detail = new List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail>();

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Operation].[MEX_Payout_SABADELL_Bank_Operation_Upload]", _conn)
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
                    Detail.Add(DataRowHelper.CreateItemFromRow<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail>(row));
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
        public List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> UpdateLotBatchFromBankPreRegister(string idBankPreRegisterLot, string accountWithErrors, bool TransactionMechanism)
        {
            List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail> DetailList = new List<SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail>();


            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Operation].[MEX_Payout_MIFEL_Bank_Operation_Upload_PreRegister]", _conn)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 0
                };
                _prm = new SqlParameter("@BankPreRegisterLot", SqlDbType.VarChar) { Value = idBankPreRegisterLot };
                _cmd.Parameters.Add(_prm);
                _prm = new SqlParameter("@accountWithErrors", SqlDbType.VarChar) { Value = accountWithErrors };
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

                _dt = new DataTable();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_dt);

                if (_dt.Rows.Count > 0)
                {
                    foreach (DataRow row in _dt.Rows)
                    {
                        SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail Detail = new SharedModel.Models.Services.Mexico.PayOutMexico.UploadTxtFromBank.TransactionDetail
                        {
                            Ticket = row[0].ToString(),
                            TransactionDate = Convert.ToDateTime(row[1]),
                            Amount = Convert.ToDecimal(row[2]),
                            Currency = row[3].ToString(),
                            LotNumber = Convert.ToInt64(row[4]),
                            LotCode = row[5].ToString(),
                            Recipient = row[6].ToString(),
                            RecipientId = row[7].ToString(),
                            RecipientAccountNumber = row[8].ToString(),
                            AcreditationDate = Convert.ToDateTime(row[9]),
                            Description = row[10].ToString(),
                            InternalDescription = row[11].ToString(),
                            ConceptCode = row[12].ToString(),
                            BankAccountType = row[13].ToString(),
                            EntityIdentificationType = row[14].ToString(),
                            InternalStatus = row[15].ToString(),
                            InternalStatusDescription = row[16].ToString(),
                            idEntityUser = row[17].ToString(),
                            TransactionId = row[18].ToString(),
                            StatusCode = row[19].ToString()
                        };

                        DetailList.Add(Detail);
                    }

                }

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return DetailList;
        }
    }
}