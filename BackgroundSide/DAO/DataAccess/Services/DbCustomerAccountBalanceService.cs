using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using SharedModel.Models;
using SharedModel.Models.View;

namespace DAO.DataAccess.Services
{
    public class DbCustomerAccountBalanceService
    {
        private readonly SqlConnection _sqlConnection;
        private SqlCommand _sqlCommand;

        public DbCustomerAccountBalanceService() =>
            _sqlConnection = new SqlConnection(ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString);

        public CustomerAccountBalanceResponse GetAccountBalance(DateTime fromDate, DateTime toDate)
        {
            var customerBalance = new CustomerAccountBalanceResponse();

            if (_sqlConnection.State == ConnectionState.Open)
                _sqlConnection.Close();

            _sqlCommand = new SqlCommand("[LP_Operation].[MerchantReportOnlyTotal_Caller]", _sqlConnection)
            {
                CommandTimeout = 0,
                CommandType = CommandType.StoredProcedure,
            };

            var from = fromDate.ToString("yyyyMMdd");
            var to = toDate.ToString("yyyyMMdd");

            _sqlCommand.Parameters.AddWithValue("@fromDate", from);
            _sqlCommand.Parameters.AddWithValue("@toDate", to);

            _sqlConnection.Open();

            using (var sqlDataReader = _sqlCommand.ExecuteReader())
            {
                while (sqlDataReader.Read())
                {
                    customerBalance.Add(new CustomerAccountBalanceItem
                    {
                        EntityUser = (int)sqlDataReader["EntityUser"],
                        Merchant = (string)sqlDataReader["Merchant"],
                        TotalBalance = (decimal)sqlDataReader["TotalBalance"],
                        Currency = (string)sqlDataReader["Currency"],
                    });
                }
            }

            _sqlConnection.Close();

            return customerBalance;
        }
    }
}