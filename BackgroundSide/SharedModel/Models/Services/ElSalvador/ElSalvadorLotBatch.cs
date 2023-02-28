using System;
using System.Collections.Generic;
using SharedModel.Models.Services.Chile;

namespace SharedModel.Models.Services.ElSalvador
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class ElSalvadorLotBatch
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        /// <summary>
        /// [ES|EN][ID Lote|ID PayOut][{LECTURA|ESCRITURA}{READ|WRITE}]
        /// </summary>
        public Int64 payout_id { get; set; }
        /// <summary>
        /// [ES|EN][Nombre del Cliente|Customer Name][{LECTURA|ESCRITURA}{READ|WRITE}]
        /// </summary>
        public string customer_name { get; set; }
        /// <summary>
        /// [ES|EN][Tipo de Transacción|Transaction Type][{LECTURA|ESCRITURA}{READ|WRITE}]
        /// </summary>
        public string transaction_type { get; set; }
        /// <summary>
        /// [ES|EN][Estado|Status][{LECTURA|ESCRITURA}{READ|WRITE}]
        /// </summary>
        public string status { get; set; }
        /// <summary>
        /// [ES|EN][Fecha de Proceso|Process Date][{LECTURA|ESCRITURA}{READ|WRITE}]
        /// </summary>
        public string lot_date { get; set; }
        /// <summary>
        /// [ES|EN][Importe Bruto|Gross Amount][{LECTURA|ESCRITURA}{READ|WRITE}]
        /// </summary>
        public Int64 gross_amount { get; set; }
        /// <summary>
        /// [ES|EN][Importe Neto|Net Amount][{LECTURA|ESCRITURA}{READ|WRITE}]
        /// </summary>
        public Int64 net_amount { get; set; }
        
#pragma warning disable CS1587 // El comentario XML no está situado en un elemento válido del idioma
/// <summary>
        /// [ES|EN][Saldo|Balance][{LECTURA|ESCRITURA}{READ|WRITE}]
        /// </summary>
        //public Int64 account_balance { get; set; }
        /// <summary>
        /// [ES|EN][Listado de Transacciones|List of Transactions][{LECTURA|ESCRITURA}{READ|WRITE}]
        /// </summary>
        private List<ElSalvadorPayoutListResponse> pri_transaction_list = new List<ElSalvadorPayoutListResponse>();
#pragma warning restore CS1587 // El comentario XML no está situado en un elemento válido del idioma
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public List<ElSalvadorPayoutListResponse> transaction_list { get { return pri_transaction_list; } set { pri_transaction_list = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }
}