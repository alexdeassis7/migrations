using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace SharedModel.Models.View
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class Dashboard
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class DashboardLotes
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {

            /// <summary>
            /// [ES|EN][ID Lote|ID PayOut][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public Int64 idTransactionLot { get; set; }
            /// <summary>
            /// [ES|EN][Nombre del Cliente|Customer Name][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string customer_name { get; set; }
            /// <summary>
            /// [ES|EN][Tipo de Transacción|Transaction Type][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string transaction_type { get; set; }
            /// <summary>
            /// [ES|EN][Fecha de Acreditación|Accreditation Date][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string accreditation_date { get; set; }
            /// <summary>
            /// [ES|EN][Importe Bruto|Gross Amount][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string gross_amount { get; set; }
            /// <summary>
            /// [ES|EN][Importe Neto|Net Amount][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string net_amount { get; set; }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string lot_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            /// <summary>
            /// [ES|EN][Retenciones de Impuestos|Tax Withholdings][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string tax_withholdings { get; set; }
            /// <summary>
            /// [ES|EN][Comisiones|Commissions][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string commissions { get; set; }
            /// <summary>
            /// [ES|EN][IVA|VAT][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string vat { get; set; }
            /// <summary>
            /// [ES|EN][Costo Banco|Bank Cost][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string bank_cost { get; set; }
            /// <summary>
            /// [ES|EN][IVA Costo Banco|VAT Bank Cost][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string bank_cost_vat { get; set; }
            /// <summary>
            /// [ES|EN][Percepción de Ingresos Brutos|Gross Revenue Perception][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string gross_revenue_perception { get; set; }
            /// <summary>
            /// [ES|EN][Impuesto al Débito|Debit Tax][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string tax_debit { get; set; }
            /// <summary>
            /// [ES|EN][Impuesto al Crédito|Credit Tax][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string tax_credit { get; set; }
            /// <summary>
            /// [ES|EN][Redondeo|Rounding][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string rounding { get; set; }
            /// <summary>
            /// [ES|EN][IVA a Pagar|VAT to Pay][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string pay_vat { get; set; }
            /// <summary>
            /// [ES|EN][Saldo|Balance][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string balance { get; set; }
            /// <summary>
            /// [ES|EN][Saldo Banco|Bank Balance][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string bank_balance { get; set; }
            /// <summary>
            /// [ES|EN][Estado|Status][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            public string status { get; set; }
            /// <summary>
            /// [ES|EN][Listado de Transacciones|List of Transactions][{LECTURA|ESCRITURA}{READ|WRITE}]
            /// </summary>
            private List<List.Response> pri_transaction_list = new List<List.Response>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public List<List.Response> transaction_list { get { return pri_transaction_list; } set { pri_transaction_list = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class List
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string idEntityAccount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string cycle { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string id_status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string id_transactioType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string pageSize { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string offset { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                private Request _request = new Request();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public Request request { get { return _request; } set { _request = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

                private List<DashboardLotes> _dashboardLotes = new List<DashboardLotes>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public List<DashboardLotes> dashboardLotes { get { return _dashboardLotes; } set { _dashboardLotes = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }


#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class DashboardTransactions
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int transaction_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public DateTime TransactionDate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public float amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int transactionLot_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int transactionType_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int status_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int EntityAccount_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int transactionRecipientDetail_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string Recipient { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string RecipientCUIT { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string CBU { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string RecipientAccountNumber { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string TransactionAcreditationDate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string Description { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string InternalDescription { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string ConceptCode { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string BankAccountType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string EntityIdentificationType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string CurrencyType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string PaymentType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public float CreditTax { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public float DebitTax { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente


        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class ListTransaction
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string idTransactionLot { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string id_status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string pageSize { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string offset { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                /*  private Request _request = new Request();
                  public  Request request { get { return _request; } set { _request = value; } }

                  private List<DashboardTransactions> _dashboardTrans= new List<DashboardTransactions>();
                  public List<DashboardTransactions> dashboardTrans { get { return _dashboardTrans; } set { _dashboardTrans = value; } }
                  */
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string TransactionList { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Indicators
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string cycle { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string indicators { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class DollarToday
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string dollarToday { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class MainReport
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public static explicit operator Request(Dictionary<string, string> data) => new Request
                {
                    type = data.ContainsKey("type") ? data["type"] : null
                };
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string mainReportData { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class ClientReport
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string clientReportData { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class ProviderCycle
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class ProviderTransaction
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public int idProvider { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string provider { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string transactionType { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public double gross { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public double comission { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public double vat { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public double percIIBB { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public double percVat { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public double percProfit { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public double net { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string cycle { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public DateTime? dateReceived { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string date { get { return dateReceived != null ? dateReceived.Value.ToString("dd-MM-yyyy") : ""; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                private string data = string.Empty;
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Data { get { return data; } set { data = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public class ResponseModel
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public ResponseModel(string data)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    {
                        transactions = JsonConvert.DeserializeObject<List<ProviderTransaction>>(data);
                    }

                    //public ResponseModel(string data)
                    //{

                    //    JArray json = JArray.Parse(data);
                    //    foreach (JObject item in json)
                    //    {
                    //        if (!transactions.Any(o => o.provider == (string)((JValue)item["provider"]).Value))
                    //        {
                    //            transactions.Add(new ProviderTransaction { idProvider= Convert.ToInt32(((JValue)item["idProvider"]).Value),  provider = (string)((JValue)item["provider"]).Value });
                    //        }
                    //        ProviderTransaction p = transactions.First(o => o.provider == (string)((JValue)item["provider"]).Value);

                    //        p.transactionType = (string)((JValue)item["transactionType"]).Value;
                    //        p.gross = (double)((JValue)item["gross"]).Value;
                    //        p.comission = (double)((JValue)item["comission"]).Value;
                    //        p.vat = (double)((JValue)item["vat"]).Value;
                    //        p.percIIBB = (double)((JValue)item["percIIBB"]).Value;
                    //        p.percVat = (double)((JValue)item["percVat"]).Value;
                    //        p.percProfit = (double)((JValue)item["percProfit"]).Value;
                    //        p.net = (double)((JValue)item["net"]).Value;
                    //        p.cycle = (string)((JValue)item["cycle"]).Value;

                    //        if (item.ContainsKey("dateReceived"))
                    //        {
                    //            p.dateReceived = (DateTime)((JValue)item["dateReceived"]).Value;
                    //        }
                    //    }
                    //}

                    private List<ProviderTransaction> transactions = new List<ProviderTransaction>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public List<ProviderTransaction> Transactions
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    {
                        get { return transactions; }
                        set { transactions = value; }
                    }
                }
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class MerchantCycle
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public class MerchantsTransaction
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public Int32 idEntityMerchant { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public string merchant { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public string method { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public double gross { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public double comission { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public double vat { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public double ars { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public double exrate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public double usd { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public string cycle { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public DateTime? payDate { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public double exchange { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public double revenueOper { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public double revenueFx { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public DateTime? StartCycle { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public DateTime? EndCycle { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                }

                private string data = string.Empty;
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Data { get { return data; } set { data = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public class ResponseModel
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public ResponseModel(string data)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    {
                        transactions = JsonConvert.DeserializeObject<List<MerchantsTransaction>>(data);                      
                    }

                    private List<MerchantsTransaction> transactions = new List<MerchantsTransaction>();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    public List<MerchantsTransaction> Transactions
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                    {
                        get { return transactions; }
                        set { transactions = value; }
                    }
                }
            }
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class CashProviderCycle
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [Required(ErrorMessage = "Parameter quote_currency is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string idProvider { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter quote_currency is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string cycle { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public General.ErrorModel.Error ErrorRow { get; set; } = new General.ErrorModel.Error();
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response : Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string StatusMessage { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class CashMerchantCycle
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
                [Required(ErrorMessage = "Parameter :: idEntityMerchant :: is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string idEntityMerchant { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: StartCycle :: is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string StartCycle { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                [Required(ErrorMessage = "Parameter :: EndCycle :: is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string EndCycle { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public General.ErrorModel.Error ErrorRow { get; set; } = new General.ErrorModel.Error();
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public class Response : Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string Status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string StatusMessage { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }
        }
    }
}
