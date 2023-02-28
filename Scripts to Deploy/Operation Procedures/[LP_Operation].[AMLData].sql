CREATE OR ALTER PROCEDURE [LP_Operation].[AMLData]
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- turn it on

	DECLARE @BeneficiaryData TABLE(
		Merchant [LP_Common].[LP_F_Description],
		Submerchant [LP_Common].[LP_F_Description],
		FromDate [LP_Common].[LP_A_OP_InsDateTime],
		ToDate [LP_Common].[LP_A_OP_InsDateTime],
		Document_Id [LP_Common].[LP_F_C40],
		Beneficiary [LP_Common].[LP_F_Description],
		Total_transactions INT,
		Total_Value [LP_Common].[LP_F_DECIMAL],
		Currency [LP_Common].[LP_F_Code]
	)
	DECLARE @SenderData TABLE(
		Merchant [LP_Common].[LP_F_Description],
		Submerchant [LP_Common].[LP_F_Description],
		FromDate [LP_Common].[LP_A_OP_InsDateTime],
		ToDate [LP_Common].[LP_A_OP_InsDateTime],
		Sender [LP_Common].[LP_F_Description],
		Total_transactions INT,
		Total_Value [LP_Common].[LP_F_DECIMAL],
		Currency [LP_Common].[LP_F_Code]
	)

	DECLARE @BeneficiaryReport TABLE (
		Merchant [LP_Common].[LP_F_Description],
		Submerchant [LP_Common].[LP_F_Description],
		FromDate [LP_Common].[LP_A_OP_InsDateTime],
		ToDate [LP_Common].[LP_A_OP_InsDateTime],
		Document_Id [LP_Common].[LP_F_C40],
		Beneficiary [LP_Common].[LP_F_Description],
		Total_transactions INT,
		Total_Value [LP_Common].[LP_F_DECIMAL],
		Currency [LP_Common].[LP_F_Code]
	)

	DECLARE @SenderReport TABLE(
		Merchant [LP_Common].[LP_F_Description],
		Submerchant [LP_Common].[LP_F_Description],
		FromDate [LP_Common].[LP_A_OP_InsDateTime],
		ToDate [LP_Common].[LP_A_OP_InsDateTime],
		Sender [LP_Common].[LP_F_Description],
		Total_transactions INT,
		Total_Value [LP_Common].[LP_F_DECIMAL],
		Currency [LP_Common].[LP_F_Code]
	)

---------------------GET BENEFICIARY DATA
	
	INSERT INTO @BeneficiaryData
	SELECT 
		EU.FirstName Merchant,
		ESM.SubMerchantIdentification SubMerchant,
		MIN(TransactionAcreditationDate),
		MAX(TransactionAcreditationDate),
		TRD.RecipientCUIT Document_Id,
		TRD.Recipient Beneficiary,
		COUNT(*) Total_Transactions,
		(SUM(t.GrossValueClient) / CE.Value) Total_Value,
		CT.Code Currency
	FROM [LP_Operation].[TransactionRecipientDetail] TRD
	INNER JOIN [LP_Operation].[Transaction] T ON TRD.idTransaction = T.idTransaction
	INNER JOIN [LP_Operation].[TransactionEntitySubMerchant] TESM ON TESM.idTransaction = T.idTransaction
	INNER JOIN [LP_Entity].[EntitySubMerchant] ESM ON TESM.idEntitySubMerchant = ESM.idEntitySubMerchant
	INNER JOIN [LP_Entity].[EntityUser] EU ON ESM.idEntityUser = EU.idEntityUser
	INNER JOIN [LP_Configuration].[CurrencyExchange] CE ON T.idCurrencyExchange = CE.idCurrencyExchange
	INNER JOIN [LP_Configuration].[CurrencyType] CT ON CE.CurrencyBase = CT.idCurrencyType
	INNER JOIN  [LP_Configuration].[TransactionTypeProvider] TTP ON TTP.idTransactionTypeProvider = T.idTransactionTypeProvider
	WHERE T.idStatus = 4
	AND ESM.SubMerchantIdentification = 'Payoneer withdrawals'
	AND TransactionAcreditationDate > DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)
	AND TTP.idTransactionType = 2
	GROUP BY TRD.RecipientCUIT, TRD.Recipient, CT.Code, CE.Value, EU.FirstName, ESM.SubMerchantIdentification
	ORDER BY Total_Value DESC

	
	INSERT INTO @BeneficiaryReport (Merchant,Submerchant,FromDate,ToDate,Document_Id,Beneficiary,Total_transactions,Total_Value,Currency)
	SELECT 
		Merchant,
		Submerchant,
		CONVERT(VARCHAR,MIN(FromDate),23) [Date From],
		CONVERT(VARCHAR,MAX(ToDate),23) [Date To],
		Document_Id,
		Beneficiary,
		SUM(Total_transactions) TotalTransactions,
		SUM(Total_Value) TotalValue,
		Currency
	FROM @BeneficiaryData
	WHERE FromDate > DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
	GROUP BY Document_Id,Beneficiary,Currency,Merchant,Submerchant
	HAVING SUM(Total_Value) BETWEEN 10000 AND 25000
	ORDER BY Merchant, TotalValue DESC

	INSERT INTO @BeneficiaryReport (Merchant,Submerchant,FromDate,ToDate,Document_Id,Beneficiary,Total_transactions,Total_Value,Currency)
	SELECT 
		Merchant,
		Submerchant,
		CONVERT(VARCHAR,MIN(FromDate),23) [Date From],
		CONVERT(VARCHAR,MAX(ToDate),23) [Date To],
		Document_Id,
		Beneficiary,
		SUM(Total_transactions) TotalTransactions,
		SUM(Total_Value) TotalValue,
		Currency
	FROM @BeneficiaryData
	WHERE FromDate > DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
	GROUP BY Document_Id,Beneficiary,Currency,Merchant,Submerchant
	HAVING SUM(Total_Value) >= 25000
	UNION
	SELECT 
		Merchant,
		Submerchant,
		CONVERT(VARCHAR,MIN(FromDate),23) [Date From],
		CONVERT(VARCHAR,MAX(ToDate),23) [Date To],
		Document_Id,
		Beneficiary,
		SUM(Total_transactions) TotalTransactions,
		SUM(Total_Value) TotalValue,
		Currency
	FROM @BeneficiaryData
	GROUP BY Document_Id,Beneficiary,Currency,Merchant,Submerchant
	HAVING SUM(Total_Value) >= 100000
	ORDER BY Merchant, TotalValue DESC

--------------------GET SENDER DATA

	INSERT INTO @SenderData
	SELECT 
		EU.FirstName Merchant,
		ESM.SubMerchantIdentification SubMerchant,
		MIN(TransactionAcreditationDate),
		MAX(TransactionAcreditationDate),
		TCI.SenderName Sender,
		COUNT(*) Total_Transactions,
		(SUM(t.GrossValueClient) / CE.Value) Total_Value,
		CT.Code Currency
	FROM [LP_CustomerInformation].[TransactionCustomerInfomation] TCI
	INNER JOIN [LP_Operation].[TransactionRecipientDetail] TRD ON TCI.idTransaction = TRD.idTransaction
	INNER JOIN [LP_Operation].[Transaction] T ON TRD.idTransaction = T.idTransaction
	INNER JOIN [LP_Operation].[TransactionEntitySubMerchant] TESM ON TESM.idTransaction = T.idTransaction
	INNER JOIN [LP_Entity].[EntitySubMerchant] ESM ON TESM.idEntitySubMerchant = ESM.idEntitySubMerchant
	INNER JOIN [LP_Entity].[EntityUser] EU ON ESM.idEntityUser = EU.idEntityUser
	INNER JOIN [LP_Configuration].[CurrencyExchange] CE ON T.idCurrencyExchange = CE.idCurrencyExchange
	INNER JOIN [LP_Configuration].[CurrencyType] CT ON CE.CurrencyBase = CT.idCurrencyType
	INNER JOIN  [LP_Configuration].[TransactionTypeProvider] TTP ON TTP.idTransactionTypeProvider = T.idTransactionTypeProvider
	WHERE T.idStatus = 4
	AND ESM.SubMerchantIdentification = 'Payoneer withdrawals'
	AND TransactionAcreditationDate > DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)
	AND TCI.SenderName IS NOT NULL
	AND TTP.idTransactionType = 2
	GROUP BY TCI.SenderName, CT.Code, CE.Value, EU.FirstName, ESM.SubMerchantIdentification
	ORDER BY Total_Value DESC

	INSERT INTO @SenderReport (Merchant,Submerchant,FromDate,ToDate,Sender,Total_transactions,Total_Value,Currency)
	SELECT
		Merchant,
		Submerchant,
		CONVERT(VARCHAR,MIN(FromDate),23) [Date From],
		CONVERT(VARCHAR,MAX(ToDate),23) [Date To],
		Sender,
		SUM(Total_transactions) TotalTransactions,
		SUM(Total_Value) TotalValue,
		Currency
	FROM @SenderData
	WHERE FromDate > DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
	GROUP BY Sender,Currency,Merchant,Submerchant
	HAVING SUM(Total_Value) BETWEEN 10000 AND 25000
	ORDER BY Merchant, TotalValue DESC

	INSERT INTO @SenderReport (Merchant,Submerchant,FromDate,ToDate,Sender,Total_transactions,Total_Value,Currency)
	SELECT
		Merchant,
		Submerchant,
		CONVERT(VARCHAR,MIN(FromDate),23) [Date From],
		CONVERT(VARCHAR,MAX(ToDate),23) [Date To],
		Sender,
		SUM(Total_transactions) TotalTransactions,
		SUM(Total_Value) TotalValue,
		Currency
	FROM @SenderData
	WHERE FromDate > DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
	GROUP BY Sender,Currency,Merchant,Submerchant
	HAVING SUM(Total_Value) >= 25000
	UNION
	SELECT
		Merchant,
		Submerchant,
		CONVERT(VARCHAR,MIN(FromDate),23) [Date From],
		CONVERT(VARCHAR,MAX(ToDate),23) [Date To],
		Sender,
		SUM(Total_transactions) TotalTransactions,
		SUM(Total_Value) TotalValue,
		Currency
	FROM @SenderData
	GROUP BY Sender,Currency,Merchant,Submerchant
	HAVING SUM(Total_Value) >= 100000
	ORDER BY Merchant, TotalValue DESC

------------------------ GET REPORT DATA

	SELECT 
		B.Merchant
		,B.Submerchant
		,B.FromDate AS [Date From]
		,B.ToDate AS [Date To]
		,B.Document_Id
		,B.Beneficiary
		,B.Total_transactions  AS TotalTransactions
		,B.Total_Value AS TotalValue
		,B.Currency
	FROM @BeneficiaryReport B
	LEFT JOIN [LP_Configuration].[AmlLimits] A ON A.[BeneficiaryName] = B.Beneficiary AND A.[DocumentId] = B.Document_Id
	WHERE (B.Total_Value < 25000 OR B.Total_Value < A.[Limit])

	SELECT 
		B.Merchant
		,B.Submerchant
		,B.FromDate AS [Date From]
		,B.ToDate AS [Date To]
		,B.Document_Id
		,B.Beneficiary
		,B.Total_transactions  AS TotalTransactions
		,B.Total_Value AS TotalValue
		,B.Currency
	FROM @BeneficiaryReport B
	LEFT JOIN [LP_Configuration].[AmlLimits] A ON A.[BeneficiaryName] = B.Beneficiary AND A.[DocumentId] = B.Document_Id
	WHERE (B.Total_Value >= 25000 AND B.Total_Value >= A.[Limit])
	OR (B.Total_Value >= 25000 AND A.[Limit] IS NULL)

	SELECT 
		B.Merchant
		,B.Submerchant
		,B.FromDate AS [Date From]
		,B.ToDate AS [Date To]
		,B.Sender
		,B.Total_transactions  AS TotalTransactions
		,B.Total_Value AS TotalValue
		,B.Currency
	FROM @SenderReport B
	LEFT JOIN [LP_Configuration].[AmlLimits] A ON A.[BeneficiaryName] = B.Sender
	WHERE (B.Total_Value < 25000 OR B.Total_Value < A.[Limit])

	SELECT 
		B.Merchant
		,B.Submerchant
		,B.FromDate AS [Date From]
		,B.ToDate AS [Date To]
		,B.Sender
		,B.Total_transactions  AS TotalTransactions
		,B.Total_Value AS TotalValue
		,B.Currency
	FROM @SenderReport B
	LEFT JOIN [LP_Configuration].[AmlLimits] A ON A.[BeneficiaryName] = B.Sender
	WHERE (B.Total_Value >= 25000 AND B.Total_Value >= A.[Limit])
	OR (B.Total_Value >= 25000 AND A.[Limit] IS NULL)

	SELECT
		EU.FirstName [Merchant]
		,ESM.SubMerchantIdentification [SubMerchant]
		,TRD.Recipient [Beneficiary]
		,TRD.RecipientCUIT [Beneficiary Document]
		,T.TransactionDate [Transaction Date]
		,T.idTransaction [Transaction Id]
		,TL.LotNumber [Lot Number]
		,P.Description
		,TRD.InternalDescription [Merchant Id]
		,TCK.Ticket
		,[LP_Configuration].[fnGetCurrencyCodeOperation]('LOCAL', [T].[idEntityUser]) [Currency]
		,TD.GrossAmount [Gross Amount]
		,TD.TaxWithholdings
		,TD.TaxWithholdingsARBA
		,TD.NetAmount [Net Amount]
	FROM [LP_Operation].[Transaction] T
	INNER JOIN [LP_Operation].[TransactionDetail] TD ON T.idTransaction = TD.idTransaction
	INNER JOIN [LP_Operation].[TransactionRecipientDetail] TRD ON T.idTransaction = TRD.idTransaction
	INNER JOIN [LP_Operation].[TransactionLot] TL ON T.idTransactionLot = TL.idTransactionLot
	INNER JOIN [LP_Operation].[TransactionEntitySubMerchant] TESM ON TESM.idTransaction = T.idTransaction
	INNER JOIN [LP_Entity].[EntitySubMerchant] ESM ON TESM.idEntitySubMerchant = ESM.idEntitySubMerchant
	INNER JOIN [LP_Entity].[EntityUser] EU ON ESM.idEntityUser = EU.idEntityUser
	INNER JOIN [LP_Configuration].[CurrencyExchange] CE ON T.idCurrencyExchange = CE.idCurrencyExchange
	INNER JOIN [LP_Configuration].[CurrencyType] CT ON CE.CurrencyBase = CT.idCurrencyType
	INNER JOIN [LP_Operation].[Ticket] TCK ON TCK.idTransaction = T.idTransaction
	INNER JOIN [LP_Configuration].[TransactionTypeProvider] TTP ON [T].[idTransactionTypeProvider]  = [TTP].[idTransactionTypeProvider]
	INNER JOIN [LP_Configuration].[Provider] P ON [TTP].[idProvider]  = [P].[idProvider]
	INNER JOIN [LP_CustomerInformation].[TransactionCustomerInfomation] TCI ON TCI.idTransaction = T.idTransaction
	WHERE T.idStatus = 4
		AND ESM.SubMerchantIdentification = 'Payoneer withdrawals'
		AND TransactionAcreditationDate > DATEADD(MONTH,-1,GETDATE()) 
		AND TRD.Recipient IN (SELECT Beneficiary FROM @BeneficiaryReport)
	ORDER BY Beneficiary

	SELECT
		EU.FirstName [Merchant]
		,ESM.SubMerchantIdentification [SubMerchant]
		,TCI.SenderName [Sender]
		,T.TransactionDate [Transaction Date]
		,T.idTransaction [Transaction Id]
		,TL.LotNumber [Lot Number]
		,P.Description
		,TRD.InternalDescription [Merchant Id]
		,TCK.Ticket
		,[LP_Configuration].[fnGetCurrencyCodeOperation]('LOCAL', [T].[idEntityUser]) [Currency]
		,TD.GrossAmount [Gross Amount]
		,TD.TaxWithholdings
		,TD.TaxWithholdingsARBA
		,TD.NetAmount [Net Amount]
	FROM [LP_Operation].[Transaction] T
	INNER JOIN [LP_Operation].[TransactionDetail] TD ON T.idTransaction = TD.idTransaction
	INNER JOIN [LP_Operation].[TransactionRecipientDetail] TRD ON T.idTransaction = TRD.idTransaction
	INNER JOIN [LP_Operation].[TransactionLot] TL ON T.idTransactionLot = TL.idTransactionLot
	INNER JOIN [LP_Operation].[TransactionEntitySubMerchant] TESM ON TESM.idTransaction = T.idTransaction
	INNER JOIN [LP_Entity].[EntitySubMerchant] ESM ON TESM.idEntitySubMerchant = ESM.idEntitySubMerchant
	INNER JOIN [LP_Entity].[EntityUser] EU ON ESM.idEntityUser = EU.idEntityUser
	INNER JOIN [LP_Configuration].[CurrencyExchange] CE ON T.idCurrencyExchange = CE.idCurrencyExchange
	INNER JOIN [LP_Configuration].[CurrencyType] CT ON CE.CurrencyBase = CT.idCurrencyType
	INNER JOIN [LP_Operation].[Ticket] TCK ON TCK.idTransaction = T.idTransaction
	INNER JOIN [LP_Configuration].[TransactionTypeProvider] TTP ON [T].[idTransactionTypeProvider]  = [TTP].[idTransactionTypeProvider]
	INNER JOIN [LP_Configuration].[Provider] P ON [TTP].[idProvider]  = [P].[idProvider]
	INNER JOIN [LP_CustomerInformation].[TransactionCustomerInfomation] TCI ON TCI.idTransaction = T.idTransaction
	WHERE T.idStatus = 4
		AND ESM.SubMerchantIdentification = 'Payoneer withdrawals'
		AND TransactionAcreditationDate > DATEADD(MONTH,-1,GETDATE()) 
		AND TCI.SenderName IN (SELECT Sender FROM @SenderReport)
	ORDER BY Sender

SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- turn it off

END