CREATE OR ALTER PROCEDURE [LP_Configuration].[GetAMLBlackList]
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	DECLARE @BeneficiaryData TABLE(
		FromDate [LP_Common].[LP_A_OP_InsDateTime],
		Document_Id [LP_Common].[LP_F_C40],
		AccountNumber [LP_Common].[LP_F_C40],
		Beneficiary [LP_Common].[LP_F_Description],
		Total_transactions INT,
		Total_Value [LP_Common].[LP_F_DECIMAL]
	)
	DECLARE @SenderData TABLE(
		FromDate [LP_Common].[LP_A_OP_InsDateTime],
		Sender [LP_Common].[LP_F_Description],
		Total_transactions INT,
		Total_Value [LP_Common].[LP_F_DECIMAL]
	)

	DECLARE @BlackList TABLE(
		DocumentId [LP_Common].[LP_F_C40],
		AccountNumber [LP_Common].[LP_F_C40],
		BeneficiaryName [LP_Common].[LP_F_Description],
		Total_Value [LP_Common].[LP_F_DECIMAL],
		IsSender	[LP_Common].[LP_F_C40]
	)

	--GET BENEFICIARY DATA
	INSERT INTO @BeneficiaryData
	SELECT 
		MIN(TransactionAcreditationDate),
		TRD.RecipientCUIT Document_Id,
		TRD.RecipientAccountNumber,
		TRD.Recipient Beneficiary,
		COUNT(*) Total_Transactions,
		(SUM(t.GrossValueClient) / CE.Value) Total_Value
	FROM [LP_Operation].[TransactionRecipientDetail] TRD
	INNER JOIN [LP_Operation].[Transaction] T ON TRD.idTransaction = T.idTransaction
	INNER JOIN [LP_Operation].[TransactionEntitySubMerchant] TESM ON TESM.idTransaction = T.idTransaction
	INNER JOIN [LP_Entity].[EntitySubMerchant] ESM ON TESM.idEntitySubMerchant = ESM.idEntitySubMerchant
	INNER JOIN [LP_Entity].[EntityUser] EU ON ESM.idEntityUser = EU.idEntityUser
	INNER JOIN [LP_Configuration].[CurrencyExchange] CE ON T.idCurrencyExchange = CE.idCurrencyExchange
	INNER JOIN [LP_Configuration].[CurrencyType] CT ON CE.CurrencyBase = CT.idCurrencyType
	INNER JOIN  [LP_Configuration].[TransactionTypeProvider] TTP ON TTP.idTransactionTypeProvider = T.idTransactionTypeProvider
	WHERE T.idStatus = 4
	AND TransactionAcreditationDate > DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)
	AND TTP.idTransactionType = 2
	GROUP BY TRD.RecipientCUIT, TRD.Recipient, CT.Code, CE.Value, TRD.RecipientAccountNumber
	ORDER BY Total_Value DESC

	--GET SENDER DATA
	INSERT INTO @SenderData
	SELECT 
		MIN(TransactionAcreditationDate),
		TCI.SenderName Sender,
		COUNT(*) Total_Transactions,
		(SUM(t.GrossValueClient) / CE.Value) Total_Value
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
	AND TransactionAcreditationDate > DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)
	AND TCI.SenderName IS NOT NULL
	AND TTP.idTransactionType = 2
	GROUP BY TCI.SenderName, CT.Code, CE.Value, EU.FirstName, ESM.SubMerchantIdentification
	ORDER BY Total_Value DESC

	INSERT INTO @BlackList (BeneficiaryName,AccountNumber,DocumentId,Total_Value,IsSender)
	SELECT Beneficiary AS BeneficiaryName, AccountNumber, Document_Id AS DocumentId, SUM(Total_Value),0
	FROM @BeneficiaryData
	GROUP BY Beneficiary, AccountNumber,Document_Id
	HAVING SUM(Total_Value) >= 100000
	UNION
	SELECT Beneficiary AS BeneficiaryName, AccountNumber, Document_Id AS DocumentId , SUM(Total_Value),0
	FROM @BeneficiaryData
	WHERE FromDate > DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
	GROUP BY Beneficiary, AccountNumber,Document_Id
	HAVING SUM(Total_Value) >= 25000

	INSERT INTO @BlackList (BeneficiaryName, AccountNumber, DocumentId, Total_Value,IsSender)
	SELECT Sender AS BeneficiaryName, '0','0', SUM(Total_Value),1
	FROM @SenderData
	WHERE Sender NOT IN (SELECT BeneficiaryName FROM @BlackList)
	GROUP BY Sender
	HAVING SUM(Total_Value) >= 100000
	UNION 
	SELECT Sender AS BeneficiaryName, '0','0', SUM(Total_Value),1
	FROM @SenderData
	WHERE FromDate >  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
	GROUP BY Sender
	HAVING SUM(Total_Value) >= 25000

	DELETE B FROM @BlackList B
	INNER JOIN [LP_Configuration].[AmlLimits] A ON A.[BeneficiaryName] = B.BeneficiaryName AND A.[DocumentId] = B.DocumentId
	WHERE B.Total_Value < A.[Limit]

	DELETE B FROM @BlackList B
	INNER JOIN [LP_Configuration].[AmlLimits] A ON A.[BeneficiaryName] = B.BeneficiaryName AND [B].[IsSender] = 1
	WHERE B.Total_Value < A.[Limit]

	DECLARE @JSON XML

	SET @JSON	=
				(
					SELECT
						CAST
						(
							(
								SELECT [BeneficiaryName],[AccountNumber],[DocumentId],[IsSender] FROM @BlackList
								FOR JSON PATH
							) AS XML
						)
				)

	IF (@JSON IS NULL)
		SELECT '[]'
	ELSE
		SELECT @JSON
COMMIT
SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- turn it off
END
