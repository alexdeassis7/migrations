using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using DAO.DataAccess.Services.Paraguay;
using Newtonsoft.Json;
using SharedMaps.Converters.Services.Paraguay;
using SharedModel.Models.Services.Paraguay;

namespace SharedBusiness.Services.Paraguay
{
	public class BIPayoutParaguay
	{
		private readonly Dictionary<string, MethodInfo> bankMethodDictionary = new Dictionary<string, MethodInfo>();
		public BIPayoutParaguay()
		{
			var methodCollectionFound = typeof(DbPayOutParaguay).GetMethods()
			.Where(m => m.GetCustomAttributes(typeof(BankActionDownloadIdentifier), false).Length > 0)
			.ToList();

			foreach (var (methodDownloadBank, customAttribute) in from methodDownloadBank in methodCollectionFound
																  let customAttribute = methodDownloadBank.GetCustomAttribute<BankActionDownloadIdentifier>()
																  select (methodDownloadBank, customAttribute))
			{
				bankMethodDictionary.Add(customAttribute.Name, methodDownloadBank);
			}
		}
		static readonly object _locker = new object();
		public List<SharedModel.Models.Services.Paraguay.ParaguayPayoutCreateResponse> LotTransaction(List<SharedModel.Models.Services.Paraguay.ParaguayPayoutCreateRequest> data, string customer, bool TransactionMechanism, string countryCode)
		{
			try
			{
				/* CASTEO REQUEST - LOT */
				var LPMapper = new PayOutMapperParaguay();
				var LotBatch = LPMapper.MapperModels(data);

				/* CONN DAO LOT - LOT */
				Payouts.BIPayOut LPDAO = new Payouts.BIPayOut();
				lock (_locker)
				{
					LotBatch = LPDAO.CreateLotTransaction(LotBatch, customer, countryCode, TransactionMechanism);
				}

				/* CASTEO LOT - RESPONSE */
				var Response = LPMapper.MapperModels(LotBatch);
				return Response;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public PayOutParaguay.DownloadLotBatchTransactionToBank.Response DownloadLotBatchTransactionToBank
	 (List<string> tickets,
	  bool TransactionMechanism,
	  string providerName)
		{
			string serializedTickets = JsonConvert.SerializeObject(tickets);

			// ********************************
			// CASOS CONTEMPLADOS
			// ********************************
			// - ITAU

			PayOutParaguay.DownloadLotBatchTransactionToBank.Response result =
				PerformDownloadBatchLotTransactionToBank(TransactionMechanism, providerName, serializedTickets);

			if (result.PayoutFiles.Count > 0)
			{
				//Payouts Txt
				for (int i = 0; i < result.PayoutFiles.Count; i++)
				{
					byte[] bytesPayouts = null;

					using (MemoryStream memory = new MemoryStream())
					{
						using (StreamWriter writer = new StreamWriter(memory, Encoding.GetEncoding(437)))
						{

							for (int j = 0; j < result.PayoutFiles[i].LinesPayouts.Count; j++)
							{
								writer.WriteLine(result.PayoutFiles[i].LinesPayouts[j]);
							}

							writer.Flush();
							memory.Position = 0;
							bytesPayouts = memory.ToArray();
							result.PayoutFiles[i].FileBase64_Payouts = Convert.ToBase64String(bytesPayouts);
							result.PayoutFiles[i].LinesPayouts = null;
						}

					}
				}
			}

			if (result.ExcelRows > 0)
			{
				// Transferencias Txt
				byte[] bytesTransferencias = result.ExcelExportByteArray;

				using (MemoryStream memory = new MemoryStream())
				{
					using (StreamWriter writer = new StreamWriter(memory, Encoding.GetEncoding(437)))
					{
						writer.Flush();
						memory.Position = 0;
						result.FileBase64_ExcelFileOut = Convert.ToBase64String(bytesTransferencias);
					}
				}
			}

			return result;
		}

		private PayOutParaguay.DownloadLotBatchTransactionToBank.Response PerformDownloadBatchLotTransactionToBank(bool TransactionMechanism, string providerName, string JSON)
		{
			PayOutParaguay.DownloadLotBatchTransactionToBank.Response result;

			MethodInfo bankPayoutDownloadFunction = bankMethodDictionary[providerName];

			if (bankPayoutDownloadFunction == null)
				throw new NullReferenceException("Method not implemented or not decorated with the attribute of type <BankActionDownloadIdentifier>");

			Type t = typeof(DbPayOutParaguay);

			var obj = Activator.CreateInstance(t, false);

			result = (PayOutParaguay.DownloadLotBatchTransactionToBank.Response)
				bankPayoutDownloadFunction.Invoke(obj, new object[] { TransactionMechanism, JSON });
			return result;
		}


		public SharedModel.Models.Services.Paraguay.PayOutParaguay.UploadTxtFromBank.Response UploadExcelFromBankItau(List<ParaguayExcelUploadResponse> excelData, int currencyFx, string datetime, bool TransactionMechanism, string countryCode)
		{
			var ResponseModel = new PayOutParaguay.UploadTxtFromBank.Response();

			var BatchLotDetail = new PayOutParaguay.UploadTxtFromBank.BatchLotDetail();
			var Detail = new PayOutParaguay.UploadTxtFromBank.TransactionDetail();
			var uploadModel = new List<SharedModel.Models.Services.Payouts.Payouts.UploadModel>();

			try
			{

				var DbPayOut = new DbPayOutParaguay();

				foreach (var transaction in excelData)
				{
					var trxStatus = transaction.STATUS.ToUpper();
					if (trxStatus == "PAGADO" || trxStatus == "RECHAZADO")
					{
						var status = trxStatus == "PAGADO" ? "EXECUTED" : "REJECTED";
						var rejectionDetail = transaction.REJECTED_DETAIL.ToUpper();
						uploadModel.Add(new SharedModel.Models.Services.Payouts.Payouts.UploadModelItau() { ticket = transaction.TICKET_ID, status = status, rejectDetail = rejectionDetail });
					}
				}

				ResponseModel.TransactionDetail = DbPayOut.UpdateLotBatchTransactionFromBank(currencyFx, TransactionMechanism, uploadModel);

				ResponseModel.BatchLotDetail = BatchLotDetail;
				if (ResponseModel.TransactionDetail == null)
				{
					ResponseModel.TransactionDetail.Add(Detail);
					ResponseModel.Rows = 0;
				}

				ResponseModel.Status = "OK";
				ResponseModel.StatusMessage = "OK";
				ResponseModel.Rows = ResponseModel.TransactionDetail.Count;
			}
			catch (Exception)
            {
				ResponseModel.Status = "ERROR";
				ResponseModel.StatusMessage = "The upload file does not have a valid format";
				ResponseModel.Rows = 0;
			}

			return ResponseModel;
		}
	}
}
