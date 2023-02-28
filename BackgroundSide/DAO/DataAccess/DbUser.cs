using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using Newtonsoft.Json;
namespace DAO.DataAccess
{
    public class DbUser : DAO.Interfaces.Security.IDbSecurity
    {
        SqlConnection _conn;
        SqlCommand _cmd;
        SqlParameter _prm;
        SqlDataAdapter _da;
        DataSet _ds;
        DataTable _dt;

        public DbUser() { }
        public SharedModel.Models.User.User GetUserInfo(SharedModel.Models.Security.AccountModel.Login Credential)
        {
            SharedModel.Models.User.User UserInf = new SharedModel.Models.User.User();
            SharedModel.Models.Database.General.Result.Validation ValidationResult = new SharedModel.Models.Database.General.Result.Validation();

            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Entity].[GetEntityInfo]", _conn);
                _cmd.CommandType = CommandType.StoredProcedure;
                _cmd.CommandTimeout = 0;
                _prm = new SqlParameter("@ClientID", SqlDbType.VarChar, 50) { Value = Credential.ClientID };
                _cmd.Parameters.Add(_prm);
                _prm = new SqlParameter("@App", SqlDbType.Bit) { Value = Credential.WebAcces };
                _cmd.Parameters.Add(_prm);

                _ds = new DataSet();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                UserInf = JsonConvert.DeserializeObject<SharedModel.Models.User.User>(_ds.Tables[0].Rows[0][0].ToString());

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return UserInf;
        }

        public List<SharedModel.Models.User.User> GetListUsers()
        {
            List<SharedModel.Models.User.User> ListUsers = new List<SharedModel.Models.User.User>();
            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);


                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Entity].[GetListUsers]", _conn);
                _cmd.CommandType = CommandType.StoredProcedure;
                _cmd.CommandTimeout = 0;

                _ds = new DataSet();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
                ListUsers = JsonConvert.DeserializeObject<List<SharedModel.Models.User.User>>(_ds.Tables[0].Rows[0][0].ToString());
            }
            catch (Exception)
            {

                throw;
            }
            return ListUsers;


        }


        public List<SharedModel.Models.Account.ListAccountsResponse> GetListAccounts()
        {
            List<SharedModel.Models.Account.ListAccountsResponse> ListUsers = new List<SharedModel.Models.Account.ListAccountsResponse>();
            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);


                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                //_cmd = new SqlCommand("[LP_Entity].[GetListUsers]", _conn);
                _cmd = new SqlCommand("[LP_Entity].[ListAccountUser]", _conn);
                _cmd.CommandType = CommandType.StoredProcedure;
                _cmd.CommandTimeout = 0;

                _ds = new DataSet();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
                ListUsers = JsonConvert.DeserializeObject<List<SharedModel.Models.Account.ListAccountsResponse>>(_ds.Tables[0].Rows[0][0].ToString(), new JsonSerializerSettings{NullValueHandling = NullValueHandling.Ignore});
            }
            catch (Exception ex)
            {

                throw ex;
            }
            return ListUsers;


        }

        public List<SharedModelDTO.User.UserIntoAccountRequest> CreateUsers(SharedModelDTO.User.UserIntoAccountRequest request)
        {
            var Response = new List<SharedModelDTO.User.UserIntoAccountRequest>();
            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);
                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Filter].[AddUserToClient]", _conn);
                _cmd.CommandType = CommandType.StoredProcedure;
                _cmd.CommandTimeout = 0;
                _prm = new SqlParameter("@JSON", SqlDbType.NVarChar) { Value = JsonConvert.SerializeObject(request) };
                _cmd.Parameters.Add(_prm);
                _ds = new DataSet();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);
                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
                Response = JsonConvert.DeserializeObject<List<SharedModelDTO.User.UserIntoAccountRequest>>(_ds.Tables[0].Rows[0][0].ToString());
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return Response;


        }

        public List<SharedModel.Models.Account.AccountResponse> CreateAccount(SharedModel.Models.Account.AccountRequest request)
        {
            var Response = new List<SharedModel.Models.Account.AccountResponse>();
            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);
                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Filter].[AddClientFull]", _conn);
                _cmd.CommandType = CommandType.StoredProcedure;
                _cmd.CommandTimeout = 0;
                _prm = new SqlParameter("@JSON", SqlDbType.NVarChar) { Value = JsonConvert.SerializeObject(request) };
                _cmd.Parameters.Add(_prm);
                _ds = new DataSet();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);
                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                if (_ds.Tables[0].Rows[0][0].ToString() == "50000")
                {
                    return Response = null;
                }

                Response = JsonConvert.DeserializeObject<List<SharedModel.Models.Account.AccountResponse>>(_ds.Tables[0].Rows[0][0].ToString());

            }
            catch (Exception ex)
            {
                throw ex;
            }
            return Response;
        }

        public Boolean CheckAccount(SharedModel.Models.Account.CheckAccount request)
        {
            var Response = false;
            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);
                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Filter].[MerchantNameEmailExists]", _conn);
                _cmd.CommandType = CommandType.StoredProcedure;
                _cmd.CommandTimeout = 0;
                _prm = new SqlParameter("@MerchantName", SqlDbType.NVarChar) { Value = request.merchantName.ToString() };
                _cmd.Parameters.Add(_prm);
                _prm = new SqlParameter("@Email", SqlDbType.NVarChar) { Value = request.email.ToString() };
                _cmd.Parameters.Add(_prm);
                _ds = new DataSet();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);
                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
                Response = Convert.ToBoolean(int.Parse(_ds.Tables[0].Rows[0][0].ToString()));
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return Response;


        }
        

        public List<SharedModel.Models.User.User> GetListKeyUsers()
        {
            List<SharedModel.Models.User.User> ListUsers = new List<SharedModel.Models.User.User>();
            try
            {
                _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);


                if (_conn.State == ConnectionState.Open)
                    _conn.Close();

                _cmd = new SqlCommand("[LP_Entity].[GetListKeyUsers]", _conn);
                _cmd.CommandType = CommandType.StoredProcedure;
                _cmd.CommandTimeout = 0;

                _ds = new DataSet();
                _da = new SqlDataAdapter(_cmd);
                _da.Fill(_ds);

                if (_conn.State == ConnectionState.Open)
                    _conn.Close();
                ListUsers = JsonConvert.DeserializeObject<List<SharedModel.Models.User.User>>(_ds.Tables[0].Rows[0][0].ToString());
            }
            catch (Exception)
            {

                throw;
            }
            return ListUsers;


        }
    }
}