/****** Object:  StoredProcedure [LP_Filter].[GetMerchantReportAgrouped]    Script Date: 3/4/2020 11:05:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LP_Filter].[GetAccountReportAgrouped]
	@merchantId bigint,
	@statusId int = null,
	@dateFrom nvarchar(8),
	@dateTo nvarchar(8)
AS
BEGIN

SELECT	
		[idEntityUser]
		, CAST([t].[TransactionDate] AS DATE) Fecha
		, CAST([t].ProcessedDate AS DATE) Fecha_Procesamiento
		, COUNT(t.idTransaction) Cant_transacciones
		, SUM(GrossAmount) GrossAmount_Sum
		, SUM([TD].[TaxWithholdings]) Sum_TaxWithholdings
		, SUM([TD].[TaxWithholdingsArba]) Sum_TaxWithholdingsArba
		, SUM([TD].[NetAmount]) [Sum_Payable]

FROM [LP_Operation].[Transaction] [t]
INNER JOIN [LP_Operation].[TransactionDetail] [td] on t.idTransaction = td.idTransaction and (@statusId is null or t.idStatus = @statusId)
LEFT JOIN [LP_Common].[Status] pend on pend.idStatus = t.idStatus and (pend.idStatus = 1 or pend.idStatus = 2)
LEFT JOIN [LP_Common].[Status] conf on conf.idStatus = t.idStatus and (conf.idStatus = 4)
WHERE 
	[t].Active = 1 
	AND t.idEntityUser = @merchantId 
	AND [t].TransactionDate BETWEEN LP_Common.[fnStringToDate](@dateFrom) AND LP_Common.[fnStringToDate](@dateTo)
GROUP BY
	idEntityUser
	, cast([t].TransactionDate as date)
	, cast([t].processeddate as date)
ORDER BY
	cast([t].TransactionDate as date)
END
