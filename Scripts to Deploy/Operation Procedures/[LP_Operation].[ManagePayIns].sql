CREATE  OR ALTER PROCEDURE [LP_Operation].[ManagePayIns]
													(
														 @json			[LP_Common].[LP_F_VMAX]
														, @country_code	[LP_Common].[LP_F_C3]
													)
AS
	BEGIN
		DECLARE @idCountry	INT
		SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @country_code AND [Active] = 1 )

		DECLARE @idProvider INT
		SET @idProvider = (SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = CAST(JSON_VALUE(@JSON, '$.provider') AS VARCHAR(100))  AND [idCountry] = @idCountry  AND [Active] = 1 )

		DECLARE @idMerchant INT
		SET @idMerchant = CAST(JSON_VALUE(@JSON, '$.merchant') AS INT )

		DECLARE @idSubMerchant INT
		SET @idSubMerchant = CAST(JSON_VALUE(@JSON, '$.submerchant') AS INT )

		DECLARE @RESP xml


		DECLARE @TempPayoutBody TABLE
			(
				[idx]							INT IDENTITY (1,1)
				,[payin_id]							BIGINT
				,[amount]							[LP_Common].[LP_F_DECIMAL]
				,[ticket]							VARCHAR(MAX)
				,[transaction_date]					VARCHAR(MAX)
				,[merchant_id]						VARCHAR(MAX)
				,[payer_name]						VARCHAR(MAX)
				,[payer_document_number]			VARCHAR(MAX)
				,[payer_account_number]				VARCHAR(MAX) NULL
				,[submerchant_code]					VARCHAR(MAX) 
				,[merchant_name]					VARCHAR(MAX) 
			)
		
		INSERT INTO @TempPayoutBody ([payin_id],[amount],[ticket],[transaction_date],[merchant_id],[payer_name],[payer_document_number],[payer_account_number],[submerchant_code],[merchant_name]	)
		SELECT		[T].[idTransaction]
					,[TD].[GrossAmount]
					,[T2].[Ticket]
					,[T].[TransactionDate]
					,[TRD].[MerchantId]
					,[TRD].[PayerName]
					,[TRD].[PayerDocumentNumber]
					,[TRD].[PayerAccountNumber]
					,[ESM].[SubMerchantIdentification]
					,[EU].[LastName]
				FROM
					[LP_Operation].[Transaction]									[T]
						INNER JOIN	[LP_Operation].[TransactionPayinDetail]			[TRD]	ON	[T].[idTransaction]					= [TRD].[idTransaction]
						INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]					= [TD].[idTransaction]
						INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]					= [T2].[idTransaction]
						INNER JOIN  [LP_Entity].[EntityUser]						[EU]	ON  [T].[idEntityUser]					= [EU].[idEntityUser]
						INNER JOIN	[LP_Common].[Status]							[ST]	ON	[ST].[idStatus]						= [T].[idStatus]
						INNER JOIN  [LP_Configuration].[TransactionTypeProvider]    [TTP]	ON  [TTP].[idTransactionTypeProvider]	= [T].[idTransactionTypeProvider]
						 LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]				= [T].[idTransaction]
						 LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant]			= [TESM].[idEntitySubMerchant]

				WHERE
					[ST].Code = 'InProgress'
					AND ( [ESM].[idEntityUser] = @idMerchant OR @idMerchant IS NULL )
					AND ( [ESM].[idEntitySubMerchant] = @idSubMerchant OR @idSubMerchant IS NULL)
					AND [TD].[NetAmount] > 0
					AND [EU].[idCountry] = @idCountry
					AND [TTP].[idProvider] = @idProvider



			SET @RESP = (SELECT CAST ((SELECT *
                    FROM @TempPayoutBody [TEMP]
					FOR JSON PATH) AS XML)
					)
		
		SELECT @RESP
END