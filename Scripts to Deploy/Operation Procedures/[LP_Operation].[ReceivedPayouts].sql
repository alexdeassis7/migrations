CREATE OR ALTER  PROCEDURE [LP_Operation].[ReceivedPayouts]
													(
														 @json			[LP_Common].[LP_F_VMAX]
														, @country_code	[LP_Common].[LP_F_C3]
													)
AS
	BEGIN
		DECLARE @idCountry	INT
		SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @country_code AND [Active] = 1 )

		DECLARE @idPaymentType INT
		SET @idPaymentType = (SELECT [idPaymentType] FROM [LP_Configuration].[PaymentType] WHERE [CatalogValue] = CAST(JSON_VALUE(@JSON, '$.PaymentType') AS VARCHAR(1))  AND [idCountry] = @idCountry  AND [Active] = 1 ) 

		DECLARE @Amount [LP_Common].[LP_F_DECIMAL]
		SET @Amount = ( SELECT [LP_Common].[fnConvertIntToExtendedDecimalAmount](CAST(JSON_VALUE(@JSON, '$.amount') AS BIGINT) ) )

		DECLARE @idMerchant INT
		SET @idMerchant = CAST(JSON_VALUE(@JSON, '$.idMerchant') AS INT )

		DECLARE @idSubMerchant INT
		SET @idSubMerchant = CAST(JSON_VALUE(@JSON, '$.idSubMerchant') AS INT )

		DECLARE @searchInput VARCHAR(60)
		SET @searchInput = CAST(JSON_VALUE(@JSON, '$.merchantId') AS VARCHAR(60) )

		DECLARE @RESP xml


		DECLARE @TempPayoutBody TABLE
			(
				[idx]							INT IDENTITY (1,1)
				,[LotNumber]						VARCHAR(MAX)
				,[Ticket]							VARCHAR(MAX)
				,[TransactionDate]					VARCHAR(MAX)
				,[InternalDescription]				VARCHAR(MAX)
				,[LastName]							VARCHAR(MAX)
				,[SubMerchantIdentification]		VARCHAR(MAX)
				,[BeneficiaryName]					VARCHAR(MAX) NULL
				,[AccountNumber]					VARCHAR(MAX)
				,[TicketAlternative]				VARCHAR(MAX)
				,[GrossValueClient]					[LP_Common].[LP_F_DECIMAL]
				,[TaxWithholdings]					[LP_Common].[LP_F_DECIMAL]
				,[TaxWithholdingsARBA]				[LP_Common].[LP_F_DECIMAL]
				,[NetAmount]						[LP_Common].[LP_F_DECIMAL]
				,[LocalTax]							[LP_Common].[LP_F_DECIMAL]
				,[ToProcess]						[LP_Common].[LP_F_BOOL] NULL
				,[Repeated]							[LP_Common].[LP_F_BOOL] DEFAULT(0)
				,[HistoricalyRepetead]				[LP_Common].[LP_F_BOOL] DEFAULT(0)
				,[idTransaction]					BIGINT
			)
		
		INSERT INTO @TempPayoutBody ([LotNumber],[Ticket],[TransactionDate],[InternalDescription],[LastName],[SubMerchantIdentification],[GrossValueClient],[TaxWithholdings],[TaxWithholdingsARBA],[NetAmount],[LocalTax],[ToProcess],[idTransaction],[BeneficiaryName],[AccountNumber],[TicketAlternative])
		SELECT [TL].[LotNumber]
					,[T2].[Ticket]
					,[T].[TransactionDate]
					,[TRD].[InternalDescription]
					,[EU].[LastName]
					,[ESM].[SubMerchantIdentification]
					,[T].[GrossValueClient]
					,[TD].[TaxWithholdings]
					,[TD].[TaxWithholdingsARBA] 
					,[TD].[NetAmount]
					,[TD].[LocalTax]
					, 0
					,[T].[idTransaction]
					,[TRD].[Recipient]
					,[TRD].[RecipientAccountNumber]
					,(CASE WHEN [TicketAlternative7] IS NOT NULL THEN [TicketAlternative7] 
					  WHEN [TicketAlternative8] IS NOT NULL THEN [TicketAlternative8]
					  ELSE [TicketAlternative] END)
				FROM
					[LP_Operation].[Transaction]									[T]
						INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]				= [TL].[idTransactionLot]
						INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]					= [TRD].[idTransaction]
						INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]					= [TD].[idTransaction]
						INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]			= [BAT].[idBankAccountType] 
																							AND [BAT].[idCountry]					= @idCountry
						INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]					= [T2].[idTransaction]
						INNER JOIN  [LP_Configuration].[BankCode]					[BC]	ON	[BC].[idBankCode]					= [TRD].[idBankCode]
						INNER JOIN  [LP_Entity].[EntityUser]						[EU]	ON  [T].[idEntityUser]					= [EU].[idEntityUser]
						INNER JOIN [LP_Common].[Status]								[ST]	ON	[ST].idStatus = [T].[idStatus]
						INNER JOIN  [LP_Configuration].[TransactionTypeProvider] TTP ON TTP.idTransactionTypeProvider = T.idTransactionTypeProvider
						LEFT JOIN  [LP_Entity].[EntityIdentificationType]			[EIT]	ON	[EIT].[idEntityIdentificationType]	= [TRD].[idEntityIdentificationType]
						 LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]				= [T].[idTransaction]
						 LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant]			= [TESM].[idEntitySubMerchant]

				WHERE
					[TRD].[idPaymentType] = @idPaymentType
					AND [ST].Code = 'Received'
					AND ( [ESM].[idEntityUser] = @idMerchant OR @idMerchant IS NULL )
					AND ( [ESM].[idEntitySubMerchant] = @idSubMerchant OR @idSubMerchant IS NULL)
					AND [TD].[NetAmount] > 0
					AND TTP.idTransactionType = 2
					AND ((CAST(T2.Ticket AS VARCHAR(60)) = @searchInput OR CAST(TRD.InternalDescription AS VARCHAR(60)) = @searchInput) OR (@searchInput IS NULL OR @searchInput = ''))


			/* CHECKING REPEATED TICKETS IN PAYOUTS BLOCK: INI */ 
			;WITH Duplicates AS
			(
				SELECT
					Ticket,
					RowNum = ROW_NUMBER() OVER (PARTITION BY Ticket ORDER BY idx)
				FROM
					@TempPayoutBody
			)
			UPDATE @TempPayoutBody
			SET Repeated = 1
			FROM Duplicates d
			INNER JOIN @TempPayoutBody t ON t.Ticket = d.Ticket
			WHERE d.Ticket = t.Ticket
			AND d.RowNum > 1
			/* CHECKING REPEATED TICKETS IN PAYOUTS BLOCK: FIN */

			/* CHECKING HISTORIC REPEATED TICKETS IN PAYOUTS BLOCK: INI */ 
			;WITH Duplicates AS
			(
				SELECT
					[Ticket],
					RowNum = ROW_NUMBER() OVER (PARTITION BY [Ticket] ORDER BY [idTicket])
				FROM
				   [LP_Operation].[Ticket]
			)
			UPDATE @TempPayoutBody
			SET HistoricalyRepetead = 1
			FROM Duplicates d
			INNER JOIN @TempPayoutBody t ON t.Ticket = d.Ticket
			WHERE d.Ticket = t.Ticket
			AND d.RowNum > 1
			/* CHECKING HISTORIC REPEATED TICKETS IN PAYOUTS BLOCK: FIN */

			SET @RESP = (SELECT CAST ((SELECT [LotNumber]
					,[Ticket]
					,[TransactionDate]
					,[InternalDescription]
					,[LastName]
					,[SubMerchantIdentification]
					,[GrossValueClient]
					,[TaxWithholdings]
					,[TaxWithholdingsARBA] 
					,[LocalTax]
					,[NetAmount]
					,[Repeated]
					,[HistoricalyRepetead]
					,[BeneficiaryName]					
					,[AccountNumber]				
					,[TicketAlternative]				
					,RIGHT('000000' + CAST([BPT].[idBankPreRegisterLot] AS VARCHAR), 6) AS [PreRegisterLot]
                    ,[BPT].[Approved] AS [PreRegisterApproved]
                    FROM @TempPayoutBody [TEMP]
                    LEFT JOIN [LP_Operation].[BankPreRegisterTransaction] [BPT] ON [BPT].[idTransaction] = [TEMP].[idTransaction]
					FOR JSON PATH) AS XML)
					)
		
		SELECT @RESP
END
GO


