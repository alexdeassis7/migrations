USE [LocalPaymentStaging]
GO

/****** Object:  StoredProcedure [LP_Operation].[ListPayOuts]    Script Date: 2/3/2022 17:45:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [LP_Operation].[ListPayOuts]
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

		DECLARE @txLimit INT
		SET @txLimit = CAST(JSON_VALUE(@JSON, '$.txLimit') AS INT )

		DECLARE @txMaxAmount DECIMAL(13,2)
		SET @txMaxAmount = CAST(JSON_VALUE(@JSON, '$.txMaxAmount') AS DECIMAL(13,2) )

		DECLARE @dateTo	[LP_Common].[LP_A_DB_INSDATETIME]
		SET @dateTo =  CAST(JSON_VALUE(@JSON, '$.dateTo') AS DATETIME )

		print 'hola: ' + @JSON
		DECLARE @bankInclude VARCHAR(MAX)
		SET @bankInclude =   CAST(JSON_QUERY(@JSON, '$.bankIncludes') AS VARCHAR(MAX) )
		IF @bankInclude is not null BEGIN
			SET @bankInclude= REPLACE (@bankInclude, '[','');
			SET @bankInclude= REPLACE (@bankInclude, ']','');
			SET @bankInclude= REPLACE (@bankInclude,  '"','');
		END 
		print '@bankInclude: '
	    print @bankInclude

		DECLARE @bankExclude VARCHAR(MAX)
		SET @bankExclude =  CAST(JSON_QUERY(@JSON, '$.bankExcludes') AS VARCHAR(MAX) )
		IF @bankExclude is not null BEGIN
			SET @bankExclude= REPLACE (@bankExclude, '[','');
			SET @bankExclude= REPLACE (@bankExclude, ']','');
			SET @bankExclude= REPLACE (@bankExclude,  '"','');
		END 
		print '@bankExclude: '
		print  @bankExclude

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
				,[GrossValueClient]					[LP_Common].[LP_F_DECIMAL]
				,[TaxWithholdings]					[LP_Common].[LP_F_DECIMAL]
				,[TaxWithholdingsARBA]				[LP_Common].[LP_F_DECIMAL]
				,[NetAmount]						[LP_Common].[LP_F_DECIMAL]
				,[LocalTax]							[LP_Common].[LP_F_DECIMAL]
				,[Bank]								VARCHAR(MAX)
				,[ToProcess]						[LP_Common].[LP_F_BOOL] NULL
				,[Repeated]							[LP_Common].[LP_F_BOOL] DEFAULT(0)
				,[HistoricalyRepetead]				[LP_Common].[LP_F_BOOL] DEFAULT(0)
			)
		
		INSERT INTO @TempPayoutBody ([LotNumber],[Ticket],[TransactionDate],[InternalDescription],[LastName],[SubMerchantIdentification],[GrossValueClient],[TaxWithholdings],[TaxWithholdingsARBA],[NetAmount],[LocalTax],[ToProcess],[Bank])
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
					,[BC].[Name]
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
						INNER JOIN  [LP_Configuration].[TransactionTypeProvider]	TTP		ON TTP.idTransactionTypeProvider = T.idTransactionTypeProvider
						 LEFT JOIN  [LP_Entity].[EntityIdentificationType]			[EIT]	ON	[EIT].[idEntityIdentificationType]	= [TRD].[idEntityIdentificationType]
						 LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]				= [T].[idTransaction]
						 LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant]			= [TESM].[idEntitySubMerchant]

				WHERE
					[TRD].[idPaymentType] = @idPaymentType
					AND [T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
					AND ( [ESM].[idEntityUser] = @idMerchant OR @idMerchant IS NULL )
					AND ( [T].[TransactionDate] <= @dateTo OR @dateTo IS NULL )
					AND ( [ESM].[idEntitySubMerchant] = @idSubMerchant OR @idSubMerchant IS NULL)
					AND ( [TD].[NetAmount] <= @txMaxAmount OR @txMaxAmount IS NULL)
					AND [TD].[NetAmount] > 0
					AND TTP.idTransactionType = 2
					AND (BC.Code in (SELECT value FROM STRING_SPLIT ( @bankInclude , ',') ) or @bankInclude IS NULL)
					AND (BC.Code not in (SELECT value FROM STRING_SPLIT ( @bankExclude , ',') ) or @bankExclude IS NULL)
					
				ORDER BY [T].[TransactionDate] ASC

					
		/* FILTERING PAYOUTS BY AMOUNT BLOCK: INI */  

			DECLARE
				@qtyRowsTemp BIGINT
				, @idxRowsTemp BIGINT
				, @ActualAmount DECIMAL(18, 6)
				, @Acum DECIMAL(18, 6)

			SET @Acum = 0

			SET @idxRowsTemp = 1
			SET @qtyRowsTemp = (SELECT COUNT(*) FROM @TempPayoutBody)

			IF(@qtyRowsTemp > 0 AND @Amount IS NOT NULL)
			BEGIN
				WHILE(@idxRowsTemp <= @qtyRowsTemp)
					BEGIN
						SELECT @ActualAmount = [NetAmount] FROM @TempPayoutBody WHERE [idx] = @idxRowsTemp ORDER BY idx ASC

						SET @Acum = @Acum + @ActualAmount

						IF( ( @Acum <= @Amount ) OR  ( @Amount IS NULL) )  
							BEGIN
								UPDATE @TempPayoutBody SET [ToProcess] = 1 WHERE [idx] = @idxRowsTemp
							END
						ELSE
							BEGIN
								SET @Acum = @Acum - @ActualAmount
							END

						SET @idxRowsTemp = @idxRowsTemp + 1
					END
			END
			ELSE 
			BEGIN
				UPDATE @TempPayoutBody SET [ToProcess] = 1
			END

			DELETE FROM @TempPayoutBody WHERE [ToProcess] = 0


			/* FILTERING PAYOUTS TO PROCESS BY AMOUNT BLOCK: FIN */

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

		IF @txLimit IS NULL 
		BEGIN
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
						,[Bank]
						FROM @TempPayoutBody 
						ORDER BY [TransactionDate] ASC FOR JSON PATH) AS XML))
		END
		ELSE
		BEGIN
			SET @RESP = (SELECT CAST ((SELECT TOP (@txLimit) [LotNumber]
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
						,[Bank]
						FROM @TempPayoutBody
						ORDER BY [TransactionDate] FOR JSON PATH) AS XML))
		END

		SELECT @RESP
END
GO


