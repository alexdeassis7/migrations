USE [LocalPaymentProd]
GO
/****** Object:  StoredProcedure [LP_Operation].[ListTransactionClientsDetails]    Script Date: 3/11/2022 2:14:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER     PROCEDURE [LP_Operation].[ListTransactionClientsDetails]
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
											--, [TD].[LocalTax]
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
											,[Amount]          = CASE
                            WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
                                [W].[GrossValueClient]
							WHEN [TT].[Code] = 'Return' OR [TT].[Code] = 'Recall' THEN
								[T].[GrossValueClient]
                            ELSE
                                [TD].[GrossAmount]
                            END,
            [Payable]         = CASE
							WHEN [TT].[Code] = 'Return' OR [TT].[Code] = 'Recall' THEN
								[T].[GrossValueClient]
                            ELSE
                                [TD].[NetAmount]
                            END,
			[Fx Merchant]        = IIF
                            (
                            [S].[Code] NOT IN ('Rejected', 'Canceled'), 
                            (
                                CASE
                                WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] IN('AddBalance', 'AddDebit', 'ReceivedCo') THEN
                                    0
                                WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
                                    CAST([CE].[Value] AS DECIMAL(18,6))
                                ELSE 
                                    CASE
                                    WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN
                                        0
                                    ELSE
                                    CAST([CE].[Value] * (1 - [CB].[Base_Buy] / 100)  AS DECIMAL(18,6))
                                    END
                                END
                            ),
                            0
                            ),
			[Pending]         = ISNULL(CASE
								WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN 
									IIF
									(
									[S].[Code] NOT IN ('Rejected', 'Canceled', 'Executed','PAID_FIRST', 'Returned', 'Recalled'),
									IIF
									(
										[TO].[Code] = 'PO' OR [TO].[Code] = 'RF',
										-1 * [T].[GrossValueLP], 1 * [T].[GrossValueLP]
									),
									0
									)
								ELSE
									IIF
									(
									[S].[Code] NOT IN ('Rejected', 'Canceled', 'Executed','PAID_FIRST', 'Returned', 'Recalled'),
									IIF
									(
										[TO].[Code] = 'PO' OR [TO].[Code] = 'RF',
										-1 * [T].[GrossValueClient] / ( [CE].[Value] * (1 - [CB].[Base_Buy] / 100)),
										1 * [T].[GrossValueClient] / ( [CE].[Value] * (1 - [CB].[Base_Buy] / 100))
									),
									0
									)
								END, 0),
			[Confirmed]         = IIF
                                      (
                                        [S].[Code] IN ('Executed','PAID_FIRST', 'Returned', 'Recalled'),
                                        IIF
                                        (
                                          [TO].[Code] = 'PO' OR [TO].[Code] = 'RF',
                                          ISNULL([W].[GrossValueClient], [W].[GrossValueLP]),
                                          ISNULL([W].[GrossValueLP], [W].[GrossValueClient])
                                        ),
                                        NULL
                                      ),
			[LocalTax]        = --ISNULL([TD].[LocalTax] * -1, 0),
								IIF
								(
									[TT].[Name] = 'Return',
									ISNULL([TDR2].LocalTax, 0), 
									ISNULL([TD].[LocalTax] * -1, 0)
								),
			[Commission]      = IIF
								(
									[TT].[Name] = 'Return',
									ISNULL([TDR2].Commission, 0), 
									CASE 
										WHEN [EU].[CommissionDeductsFromOtherAccount] = 1
											THEN 0 
											ELSE 
												IIF
												(
													[S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
													IIF
													(
														[TO].[Code] = 'PI'
														,IIF
														(
															[ECE].[idCurrencyTypeClient] != [ECE].[idCurrencyTypeLP]
															,[TD].[Commission_With_VAT]
															,[LP_Operation].[fnGetCommisionExchange]([CE].[idCurrencyExchange],[CB].[idCurrencyBase],[TD].[Commission_With_VAT],0)
														)
														,[TD].[Commission_With_VAT]
													),
													0
												)
										END
								)
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
														LEFT JOIN [LP_Configuration].[CurrencyExchange]						[CEC]   ON  [T].[idCurrencyExchangeClosed] = [CEC].[idCurrencyExchange]
														LEFT JOIN [LP_Configuration].[CurrencyBase]							[CB]	ON	[T].[idCurrencyBase]			= [CB].[idCurrencyBase]
														INNER JOIN [LP_Configuration].[TransactionTypeProvider]				[TTP]	ON	[T].[idTransactionTypeProvider] = [TTP].[idTransactionTypeProvider]
														INNER JOIN [LP_Configuration].[TransactionType]						[TP]	ON	[TP].[idTransactionType] = [TTP].[idTransactionType]
														INNER JOIN [LP_Location].[Country]									[C]		ON	[C].[idCountry]					= [EU].[idCountry]
														LEFT JOIN [LP_Configuration].[BankCode]								[BC]	ON	[BC].[idBankCode]				= [TRD].[idBankCode]
														INNER JOIN [LP_Common].[Status]										[S]		ON	[S].[idStatus]					= [T].[idStatus]
														LEFT JOIN [LP_Operation].[TransactionInternalStatus]				[TIS]   ON  [TIS].[idTransaction]			= [T].[idTransaction]
														LEFT JOIN [LP_Configuration].[LPInternalStatusClient]				[ISC]	ON	[ISC].[idInternalStatus]		= [TIS].[idInternalStatus]
														LEFT JOIN [LP_Configuration].[LPInternalError]						[LPIE]	ON	[LPIE].[idLPInternalError]		= [ISC].[idLPInternalError]
														LEFT JOIN [LP_Configuration].[TransactionType]						[TT]    ON [TTP].[idTransactionType]    = [TT].[idTransactionType]
														LEFT JOIN [LP_Configuration].[TransactionGroup]						[TG]    ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
														LEFT JOIN [LP_Configuration].[TransactionOperation]					[TO]    ON [TG].[idTransactionOperation]  = [TO].[idTransactionOperation]
														LEFT JOIN [LP_Operation].[TransactionRecipientDetail]				[TRD2]	ON [T].[ReferenceTransaction]        = 	[TRD2].[InternalDescription]
														LEFT JOIN [LP_Operation].[TransactionDetail]						[TDR2]	ON [TRD2].[idTransaction]        	 =	[TDR2].[idTransaction]
														LEFT JOIN [LP_Entity].[EntityCurrencyExchange]          [ECE]                                       ON [EU].[idEntityUser]        = [ECE].[idEntityUser]                        
										WHERE
											[T].[idTransactionTypeProvider] IN (SELECT [idTransactionTypeProvider] FROM @idTransactionTypeProvidersPODEPO)
											AND ( (( [T].[TransactionDate] >= @dateFrom ) OR ( @dateFrom  IS NULL ) ) AND ( ( [T].[TransactionDate] <= @dateTo ) OR ( @dateTo IS NULL ) ))	
											AND ( ( [T].[idEntityUser] = @idEntityUser ) OR ( @idEntityUser IS NULL ) )	
											AND ( ( [T].[idEntityAccount] = @idEntityAccount ) OR ( @idEntityAccount IS NULL ) )	
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

