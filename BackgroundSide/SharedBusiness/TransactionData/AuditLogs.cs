using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedBusiness.TransactionData
{
    public class AuditLogs
    {
        public object getAuditLogs(string dateTo, string dateFrom, int quantity, string dataToSearch)
        {
            object resultado;
            DAO.DataAccess.TransactionData.DAOTransactionData AuditLogs = new DAO.DataAccess.TransactionData.DAOTransactionData();
            resultado = AuditLogs.getAuditLogs(dateTo, dateFrom, quantity, dataToSearch);
            return resultado;
        }

    }
}