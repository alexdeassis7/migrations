USE [LocalPaymentStaging]
GO
/****** Object:  StoredProcedure [LP_Configuration].[GetAMLBlackList_BRA]    Script Date: 7/23/2021 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [LP_Configuration].[GetAMLBlackList_BRA]
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	DECLARE @BeneficiaryData TABLE(
		Document_Id [LP_Common].[LP_F_C40],
		AccountNumber [LP_Common].[LP_F_C40],
		Beneficiary [LP_Common].[LP_F_Description],
		Total_transactions INT,
		Total_Value [LP_Common].[LP_F_DECIMAL]
	)
	DECLARE @SenderData TABLE(
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
		TRD.RecipientCUIT Document_Id,
		TRD.RecipientAccountNumber,
		TRD.Recipient Beneficiary,
		COUNT(*) Total_Transactions,
		SUM(TD.GrossAmount) Total_Value
	FROM [LP_Operation].[TransactionRecipientDetail] TRD
	INNER JOIN [LP_Operation].[Transaction] T ON TRD.idTransaction = T.idTransaction
    INNER JOIN [LP_Operation].[TransactionDetail] TD ON TD.idTransaction = T.idTransaction  
	INNER JOIN [LP_Operation].[TransactionEntitySubMerchant] TESM ON TESM.idTransaction = T.idTransaction
	INNER JOIN [LP_Entity].[EntitySubMerchant] ESM ON TESM.idEntitySubMerchant = ESM.idEntitySubMerchant
	INNER JOIN [LP_Entity].[EntityUser] EU ON ESM.idEntityUser = EU.idEntityUser
	INNER JOIN [LP_Configuration].[CurrencyExchange] CE ON T.idCurrencyExchange = CE.idCurrencyExchange
	INNER JOIN [LP_Configuration].[CurrencyType] CT ON CE.CurrencyBase = CT.idCurrencyType
    INNER JOIN [LP_Common].[Status] ST ON T.idStatus = ST.idStatus
	INNER JOIN [LP_Location].[Country] CO ON EU.idCountry = CO.idCountry
	INNER JOIN  [LP_Configuration].[TransactionTypeProvider] TTP ON TTP.idTransactionTypeProvider = T.idTransactionTypeProvider
	WHERE ST.Code IN ('Received','InProgress','Executed','OnHold')
	AND TRD.Recipient IS NOT NULL
	AND TRD.RecipientAccountNumber IS NOT NULL 
	AND TRD.RecipientCUIT IS NOT NULL 
	AND TTP.idTransactionType = 2
	AND [CO].ISO3166_1_ALFA003 = 'BRA'
	GROUP BY TRD.RecipientCUIT, TRD.Recipient, TRD.RecipientAccountNumber
	ORDER BY Total_Value DESC

	--GET SENDER DATA
	INSERT INTO @SenderData
	SELECT 
		TCI.SenderName Sender,
		COUNT(*) Total_Transactions,
		SUM(TD.GrossAmount) Total_Value
	FROM [LP_CustomerInformation].[TransactionCustomerInfomation] TCI
	INNER JOIN [LP_Operation].[TransactionRecipientDetail] TRD ON TCI.idTransaction = TRD.idTransaction
	INNER JOIN [LP_Operation].[Transaction] T ON TRD.idTransaction = T.idTransaction
    INNER JOIN [LP_Operation].[TransactionDetail] TD ON TD.idTransaction = T.idTransaction  
	INNER JOIN [LP_Operation].[TransactionEntitySubMerchant] TESM ON TESM.idTransaction = T.idTransaction
	INNER JOIN [LP_Entity].[EntitySubMerchant] ESM ON TESM.idEntitySubMerchant = ESM.idEntitySubMerchant
	INNER JOIN [LP_Entity].[EntityUser] EU ON ESM.idEntityUser = EU.idEntityUser
	INNER JOIN [LP_Configuration].[CurrencyExchange] CE ON T.idCurrencyExchange = CE.idCurrencyExchange
	INNER JOIN [LP_Configuration].[CurrencyType] CT ON CE.CurrencyBase = CT.idCurrencyType
    INNER JOIN [LP_Common].[Status] ST ON T.idStatus = ST.idStatus
	INNER JOIN [LP_Location].[Country] CO ON EU.idCountry = CO.idCountry
	INNER JOIN  [LP_Configuration].[TransactionTypeProvider] TTP ON TTP.idTransactionTypeProvider = T.idTransactionTypeProvider
	WHERE ST.Code IN ('Received','InProgress','Executed','OnHold')
	AND TCI.SenderName IS NOT NULL
	AND TTP.idTransactionType = 2
	AND [CO].ISO3166_1_ALFA003 = 'BRA'
	GROUP BY TCI.SenderName, CT.Code, ESM.SubMerchantIdentification
	ORDER BY Total_Value DESC

	INSERT INTO @BlackList (BeneficiaryName,AccountNumber,DocumentId,Total_Value,IsSender)
	SELECT Beneficiary AS BeneficiaryName, AccountNumber, Document_Id AS DocumentId, SUM(Total_Value),0
	FROM @BeneficiaryData
	GROUP BY Beneficiary, AccountNumber,Document_Id
	HAVING SUM(Total_Value) >= 230000

	INSERT INTO @BlackList (BeneficiaryName, AccountNumber, DocumentId, Total_Value,IsSender)
	SELECT Sender AS BeneficiaryName, '0','0', SUM(Total_Value),1
	FROM @SenderData
	WHERE Sender NOT IN (SELECT BeneficiaryName FROM @BlackList)
	GROUP BY Sender
	HAVING SUM(Total_Value) >= 230000

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
