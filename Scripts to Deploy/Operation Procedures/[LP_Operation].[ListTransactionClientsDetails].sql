GO
/****** Object:  StoredProcedure [LP_Operation].[ListTransactionClientsDetails]    Script Date: 7/1/2021 4:46:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [LP_Operation].[ListTransactionClientsDetails]
																(
																	@customer	[LP_Common].[LP_F_C50]
																	, @json		[LP_Common].[LP_F_VMAX]
																)
AS											
BEGIN

	DECLARE
		@qtyAccount				[LP_Common].[LP_F_INT]
		, @idEntityAccount		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idEntityUser			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @Message				[LP_Common].[LP_F_C50]
		, @Status				[LP_Common].[LP_F_BOOL]
		, @merchantId			VARCHAR(60)
		, @idTransaction		VARCHAR(60)
		, @dateFrom				[LP_Common].[LP_A_DB_INSDATETIME]
		, @dateTo				[LP_Common].[LP_A_DB_INSDATETIME]
		, @lotFrom				[LP_Common].[LP_F_C10]
		, @lotTo				[LP_Common].[LP_F_C10]
		, @idEntitySubMerchant	[LP_Common].[LP_F_INT]
		, @pageSize				[LP_Common].[LP_F_INT]
		, @offset				[LP_Common].[LP_F_INT]
		, @countryCode			[LP_Common].[LP_F_C10]
		, @jsonResult			XML

	DECLARE 
		@idTransactionTypeProvidersPODEPO TABLE(
													idTransactionTypeProvider	INT
												)

	INSERT INTO @idTransactionTypeProvidersPODEPO (idTransactionTypeProvider)
		SELECT 
			[TTP].[idTransactionTypeProvider] 
		FROM 
			[LP_Configuration].[TransactionTypeProvider]	[TTP]
			INNER JOIN [LP_Configuration].[Provider]		[P]		ON	[P].[idProvider]		 = [TTP].[idProvider]
			INNER JOIN [LP_Configuration].[TransactionType] [TP]	ON	[TP].[idTransactionType] = [TTP].[idTransactionType]
		WHERE 
			[TP].[Code] IN ('PODEPO','PAYIN')
			AND [TTP].[Active]	= 1
			AND [P].[Active]	= 1
			AND [TP].[Active]	= 1 

	SELECT 
		@qtyAccount = COUNT(*)
	FROM 
		[LP_Security].[EntityAccount] [EA] 
		JOIN [LP_Entity].[EntityUser] [EU] ON [EA].idEntityUser = [EU].idEntityUser 
	WHERE 
		[EA].[UserSiteIdentification] = @customer
		AND [EA].[Active] = 1;

	SELECT
			@dateFrom				= CAST(JSON_VALUE(@JSON, '$.dateFrom') AS VARCHAR(8))
			, @dateTo				= CAST(JSON_VALUE(@JSON, '$.dateTo') AS VARCHAR(8))
			, @lotFrom				= CAST(JSON_VALUE(@JSON, '$.lotFrom') AS VARCHAR(10))
			, @lotTo				= CAST(JSON_VALUE(@JSON, '$.lotTo') AS VARCHAR(10))
			, @idEntitySubMerchant  = CAST(JSON_VALUE(@JSON, '$.idEntitySubMerchant') AS INT)
			, @idEntityUser   		= CAST(JSON_VALUE(@JSON, '$.idEntityUser') AS INT) 
			, @idEntityAccount  	= CAST(JSON_VALUE(@JSON, '$.idEntityAccount') AS INT) 
			, @pageSize				= CAST(JSON_VALUE(@JSON, '$.pageSize') AS INT)
			, @offset				= CAST(JSON_VALUE(@JSON, '$.offset') AS INT)
			, @merchantId			= CAST(JSON_VALUE(@JSON, '$.merchantId') AS VARCHAR(60))
			, @idTransaction		= CAST(JSON_VALUE(@JSON, '$.idTransaction') AS VARCHAR)
			, @countryCode			= CAST(JSON_VALUE(@JSON, '$.countryCode') AS VARCHAR(3))

	IF (@countryCode IS NULL) OR (@idEntityUser IN (SELECT [idEntityUser] FROM [LP_Security].[EntityAccountUser]  WHERE idEntityAccount = @idEntityAccount))
	BEGIN
		SET @idEntityAccount = @idEntityUser
		SET @idEntityUser = NULL
	END

	IF @customer LIKE '%localpayment%'  
	BEGIN
		SET @idEntityAccount = NULL
	END

	IF(@qtyAccount = 1)
	BEGIN

		SET @dateTo = DATEADD(HOUR, 23, @dateTo)
		SET @dateTo = DATEADD(MINUTE, 59, @dateTo)
		SET @dateTo = DATEADD(SECOND, 59, @dateTo)

		IF(@pageSize IS NULL)
			SET @pageSize = ( SELECT COUNT([idTransaction]) FROM [LP_Operation].[Transaction] WITH(NOLOCK) )

		SET @jsonResult =
						(
							SELECT
								CAST
								(
									(
										SELECT		
											[T].[idTransaction]
											, [TL].[LotNumber]
											, ISNULL([TRD].[Recipient],[TPD].[PayerName]) AS Recipient
											, ISNULL([TRD].[RecipientCUIT],[TPD].[PayerDocumentNumber]) AS RecipientCUIT
											, (CASE WHEN [TRD].[CBU] IS NOT NULL AND [TRD].[CBU] != '' THEN [TRD].[CBU]
												ELSE ISNULL([TRD].[RecipientAccountNumber],[TPD].[PayerAccountNumber]) END) AS CBU
											, [T].[TransactionDate]
											, [T].[ProcessedDate]
											, [TD].[LocalTax]
											, [CurrencyType] = [CT].[Code]
											, [T].[GrossValueClient]
											, [CurrencyTypeUsd] = 'USD'
											, [GrossValueClientUsd] = [T].[GrossValueClient] / ( [CE].[Value] * (1 - [CB].[Base_Buy] / 100))
											, [TCI].[Address]
											, [TCI].[Country]
											, [TCI].[City]
											, [TCI].[Email]
											, [TCI].[Birthdate]
											, [TCI].[SenderPhoneNumber]
											, [TCI].[SenderEmail]
											, [TK].[Ticket]
											, (CASE WHEN [TK].[TicketAlternative7]	IS NOT NULL	THEN [TicketAlternative7] 
												WHEN [TK].[TicketAlternative8]		IS NOT NULL	THEN [TicketAlternative8]
												WHEN [TK].[TicketAlternative12]		IS NOT NULL	THEN [TicketAlternative12]
												ELSE [TK].[TicketAlternative] END) AS [AlternativeTicket]
											, (CASE WHEN [TP].[Code] = 'Return' OR [TP].[Code] = 'Recall' THEN [T].[ReferenceTransaction]
												ELSE ISNULL([TRD].[InternalDescription],[TPD].[MerchantId]) END) AS InternalDescription
											, [Merchant] = [EU].[FirstName]
											, [ESM].[SubMerchantIdentification]
											, [TP].[Name] AS TransactionType
											, [TRD].[BankBranch]
											, [TRD].[RecipientPhoneNumber]
											, [BC].[Code] AS BankCode
											, [S].[Name] AS [Status]
											, ISNULL([LPIE].[Description],[S].[Description]) AS DetailStatus
											, [T].[idLotOut] AS idLotOut
											, [T].[lotOutDate] AS LotOutDate
										FROM
											[LP_Operation].[Transaction]											[T]
												INNER JOIN [LP_Operation].[TransactionLot]							[TL]	ON	[T].[idTransactionLot]			= [TL].[idTransactionLot]
												LEFT JOIN [LP_Entity].[EntityUser]									[EU]	ON  [T].[idEntityUser]				= [EU].[IdEntityUser]
												LEFT JOIN [LP_Operation].[TransactionDetail]						[TD]	ON	[TD].[idTransaction]			= [T].[idTransaction]
												LEFT JOIN [LP_Operation].[TransactionRecipientDetail]				[TRD]	ON	[T].[Idtransaction]				= [TRD].[Idtransaction]
												LEFT JOIN [LP_Operation].[TransactionPayinDetail]					[TPD]	ON	[T].[Idtransaction]				= [TPD].[Idtransaction]
												LEFT JOIN [LP_Operation].[Wallet]									[W]		ON  [W].[idTransaction]				= [T].[idTransaction]
												LEFT JOIN [LP_Configuration].[CurrencyType]							[CT]	ON	[T].[CurrencyTypeClient]		= [CT].[idCurrencyType]
												LEFT JOIN [LP_Configuration].[CurrencyType]							[CTT]	ON	[CTT].[idCurrencyType]			= [W].[idCurrencyTypeClient]
												LEFT JOIN [LP_CustomerInformation].[TransactionCustomerInfomation]	[TCI]	ON	[T].[IdTransaction]				= [TCI].[IdTransaction]
												LEFT JOIN [LP_Operation].[Ticket]									[TK]	ON	(([T].[idTransaction]			= [TK].[idTransaction]) OR ([TK].[idTransaction] IS NULL))
												LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]				[TESM]	ON	[T].[idTransaction]				= [TESM].[idTransaction]
												LEFT JOIN [LP_Entity].[EntitySubMerchant]							[ESM]	ON	[TESM].[idEntitySubMerchant]	= [ESM].[idEntitySubMerchant]
												LEFT JOIN [LP_Configuration].[CurrencyExchange] 					[CE]	ON	[T].[idCurrencyExchange]		= [CE].[idCurrencyExchange]
												LEFT JOIN [LP_Configuration].[CurrencyBase]							[CB]	ON	[T].[idCurrencyBase]			= [CB].[idCurrencyBase]
												INNER JOIN [LP_Configuration].[TransactionTypeProvider]				[TTP]	ON	[T].[idTransactionTypeProvider] = [TTP].[idTransactionTypeProvider]
												INNER JOIN [LP_Configuration].[TransactionType]						[TP]	ON	[TP].[idTransactionType] = [TTP].[idTransactionType]
												INNER JOIN [LP_Location].[Country]									[C]		ON	[C].[idCountry]					= [EU].[idCountry]
												LEFT JOIN [LP_Configuration].[BankCode]								[BC]	ON	[BC].[idBankCode]				= [TRD].[idBankCode]
												INNER JOIN [LP_Common].[Status]										[S]		ON	[S].[idStatus]					= [T].[idStatus]
												LEFT JOIN [LP_Operation].[TransactionInternalStatus]				[TIS]   ON  [TIS].[idTransaction]			= [T].[idTransaction]
												LEFT JOIN [LP_Configuration].[LPInternalStatusClient]				[ISC]	ON	[ISC].[idInternalStatus]		= [TIS].[idInternalStatus]
												LEFT JOIN [LP_Configuration].[LPInternalError]						[LPIE]	ON	[LPIE].[idLPInternalError]		= [ISC].[idLPInternalError]

										WHERE
											[T].[idTransactionTypeProvider] IN (SELECT [idTransactionTypeProvider] FROM @idTransactionTypeProvidersPODEPO)
											AND ( (( [T].[TransactionDate] >= @dateFrom ) OR ( @dateFrom  IS NULL ) ) AND ( ( [T].[TransactionDate] <= @dateTo ) OR ( @dateTo IS NULL ) ))	
											AND ( ( [T].[idEntityUser] = @idEntityUser ) OR ( @idEntityUser IS NULL ) )	
											AND ( ( [T].[idEntityAccount] IN (SELECT idEntityAccount FROM [LP_Security].[EntityAccountUser] WHERE idEntityUser = @idEntityAccount) ) OR ( @idEntityAccount IS NULL ) )	
											AND ( ( [TESM].[idEntitySubMerchant] = @idEntitySubMerchant ) OR ( @idEntitySubMerchant IS NULL ))
											AND ( ( [C].[ISO3166_1_ALFA003] = @countryCode ) OR (@countryCode IS NULL) )
											AND ((CAST(TK.Ticket AS VARCHAR(60)) = @merchantId OR CAST(TRD.InternalDescription AS VARCHAR(60)) = @merchantId OR CAST(T.idLotOut AS VARCHAR(60)) = @merchantId ) OR (@merchantId IS NULL OR @merchantId = ''))
										ORDER BY
											[T].[Idtransaction]
										OFFSET ISNULL(@offset,0) ROWS  
										FETCH NEXT ISNULL(@pageSize, 100) ROWS ONLY
										FOR JSON PATH
									) AS xml
								)
						)

		SELECT @jsonResult
	END
	ELSE
	BEGIN
		SET @Status = 0
		SET @Message = 'CLIENTE INEXISTENTE. VERFIQUE SU CUSTOMER_ID'
	END
	END

