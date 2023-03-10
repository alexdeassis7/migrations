/****** Object:  StoredProcedure [LP_Operation].[PER_Payout_Santander_Bank_Operation_Download]    Script Date: 4/27/2022 11:37:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [LP_Operation].[PER_Payout_Santander_Bank_Operation_Download]
																					(
																						@TransactionMechanism	BIT
																						, @JSON					VARCHAR(MAX)
																					)
AS
BEGIN

	BEGIN TRY

			/* CONFIG BLOCK: INI */

			DECLARE @idCountry	INT
			SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [Name] = 'Peru' AND [Active] = 1 )

			DECLARE @idProvider	INT
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'STRPER' AND [Active] = 1 )

			-- DECLARING TABLE WITH SELECTED TICKETS TO DOWNLOAD
			DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
			INSERT INTO @TempTxsToDownload
			SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)

			DECLARE @idProviderPayWayService INT
			SET @idProviderPayWayService = ( SELECT [PPWS].[idProviderPayWayService] 
												FROM [LP_Configuration].[ProviderPayWayServices]		[PPWS]
													INNER JOIN [LP_Configuration].[Provider]			[PR]	ON	[PR].[idProvider]		= [PPWS].[idProvider]
													INNER JOIN [LP_Configuration].[PayWayServices]	[PWS]	ON	[PWS].[idPayWayService] = [PPWS].[idPayWayService]
												WHERE [PR].[idProvider] = @idProvider AND [PR].[idCountry] = @idCountry
													AND [PWS].[Code] = 'BANKDEPO' AND [PWS].[idCountry] = @idCountry )

			DECLARE @idTransactionTypeProvider INT
			SET @idTransactionTypeProvider = ( SELECT [idTransactionTypeProvider]
												FROM [LP_Configuration].[TransactionTypeProvider] [TTP]
													INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [TTP].[idTransactionType]
												WHERE [TTP].[idProvider] = @idProvider AND [TT].[Code] = 'PODEPO')


			DECLARE @TempPayoutBody TABLE
			(
				[idx]								INT IDENTITY (1,1)
				,[ProviderDocumentType]						VARCHAR(1)
				, [ProviderDocumentNumber]			VARCHAR(11)
				, [DocumentType]					VARCHAR(2)
				, [DocumentNumber]					VARCHAR(11)
				, [CurrencyCode]					VARCHAR(2)
				, [Amount]							VARCHAR(15)
				, [PaymentDate]						VARCHAR(10)
				, [Concept]							VARCHAR(30)
				, [MeanOfPayment]					VARCHAR(2)
				, [RecipientAccount]				VARCHAR(10)
				, [Reference]						VARCHAR(30)
				, [CCI]								VARCHAR(20)
				, [BenefName]						VARCHAR(14)
				, [BenefPatSurname]					VARCHAR(15)
				, [BenefMatSurname]					VARCHAR(15)
				, [BenefPersonType]					VARCHAR(1)
				, [BenefCompany]					VARCHAR(44)
				, [LineComplete]					VARCHAR(MAX)
				, [idTransactionLot]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransaction]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			)

			DECLARE @LinesPayout TABLE
			(
				[idLine]			INT IDENTITY(1,1)
				, [Line]			VARCHAR(MAX)
			)

			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* BODY BLOCK: INI */

			INSERT INTO @TempPayoutBody ([ProviderDocumentType],[ProviderDocumentNumber],[DocumentType],[DocumentNumber],[CurrencyCode],[Amount],[PaymentDate],
			[Concept],[MeanOfPayment],[RecipientAccount],[CCI],[BenefName],[BenefPatSurname],[BenefMatSurname],[BenefPersonType],[BenefCompany],
			[idTransactionLot],[idTransaction],[Reference])
			SELECT
				[ProviderDocumentType] =  (CASE [EIT].Code
											WHEN 'DNI' THEN 1
											WHEN 'RUC' THEN 2
											WHEN 'CE' THEN 3
											WHEN 'Passport' THEN 8
											ELSE 0
											END),
				[ProviderDocumentNumber] = RIGHT(SPACE(11) + [TRD].RecipientCUIT,11),
				[DocumentType] =  'OT',
				[DocumentNumber] = RIGHT(CONCAT(SPACE(12), [T].[idTransaction]), 11), -- CHECK
				[CurrencyCode] = '01',
				[Amount] = RIGHT(REPLICATE('0', 15) + CAST(REPLACE(FORMAT([TD].[NetAmount],'N', 'en-US'),',','') AS VARCHAR), 15),
				[PaymentDate] = FORMAT(GETDATE(), 'dd-MM-yyyy'),
				[Concept] = SPACE(30),
				[MeanOfPayment] = (CASE [BC].Code
									WHEN '056' THEN '01'
									ELSE '03'
									END),
				[RecipientAccount] = SPACE(10),
				[CCI] = LEFT((CAST([TRD].[RecipientAccountNumber] AS VARCHAR) + SPACE(20)), 20),
				[BenefName] = (CASE [EIT].Code
											WHEN 'RUC' THEN SPACE(14)
											ELSE LEFT([TRD].Recipient + SPACE(14), 14)
											END),
				[BenefPatSurname] = SPACE(15),
				[BenefMatSurname] = SPACE(15),
				[BenefPersonType] = (CASE [EIT].Code
											WHEN 'RUC' THEN 'J'
											ELSE 'N'
											END),
				[BenefCompany] = (CASE [EIT].Code
											WHEN 'RUC' THEN LEFT([TRD].Recipient + SPACE(44), 44)
											ELSE SPACE(44)
											END),
				[Reference] = RIGHT(CONCAT(SPACE(30), [T].[idTransaction]), 30)
				,[idTransactionLot]			= [TL].[idTransactionLot]
				,[idTransaction]				= [T].[idTransaction]
			FROM
				[LP_Operation].[Transaction]									[T]
					INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]				= [TL].[idTransactionLot]
					INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]					= [TRD].[idTransaction]
					INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]					= [TD].[idTransaction]
					INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]			= [BAT].[idBankAccountType] 
																						AND [BAT].[idCountry]					= @idCountry
					INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]					= [T2].[idTransaction]
					INNER JOIN  [LP_Configuration].[BankCode]					[BC]	ON	[BC].[idBankCode]					= [TRD].[idBankCode]
					 LEFT JOIN  [LP_Entity].[EntityIdentificationType]			[EIT]	ON	[EIT].[idEntityIdentificationType]	= [TRD].[idEntityIdentificationType]
					 LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]				= [T].[idTransaction]
					 LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant]			= [TESM].[idEntitySubMerchant]
					INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]

			WHERE
				[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
				AND [TD].[NetAmount] > 0
			ORDER BY [T].[TransactionDate] ASC

			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

	
			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempPayoutBody
			SET [LineComplete] = [ProviderDocumentType] + [ProviderDocumentNumber] + [DocumentType] + [DocumentNumber] + [CurrencyCode] + [Amount] + [PaymentDate]
			+ [Concept] + [MeanOfPayment] + [RecipientAccount] + [CCI] + [BenefName] + [BenefPatSurname] + [BenefMatSurname] + [BenefPersonType]
			+ [BenefCompany] + [Reference]


			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			
			/* INSERT LINES BLOCK: INI */
			INSERT INTO @LinesPayout
			SELECT [LineComplete] FROM @TempPayoutBody

			/* INSERT LINES BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* UPDATE TRANSACTIONS STATUS BLOCK: INI */

			DECLARE @idStatus INT
			DECLARE @idLotOut INT
			SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('InProgress')
			SET @idLotOut =  ( SELECT MAX([idLotOut]) + 1 FROM [LP_Operation].[Transaction] )
			IF(@idLotOut IS NULL)
			BEGIN
				SET @idLotOut = 1
			END

			
			BEGIN TRANSACTION

				UPDATE	[LP_Operation].[TransactionLot]
				SET		[idStatus] = @idStatus
				WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM @TempPayoutBody)

				UPDATE	[LP_Operation].[Transaction]
				SET		[idStatus] = @idStatus
						,[idProviderPayWayService] = @idProviderPayWayService
						,[idTransactionTypeProvider] = @idTransactionTypeProvider
						,[idLotOut] = @idLotOut
						,[lotOutDate] = GETDATE()
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempPayoutBody)

				UPDATE	[LP_Operation].[TransactionRecipientDetail]
				SET		[idStatus] = @idStatus
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempPayoutBody)

				UPDATE	[LP_Operation].[TransactionDetail]
				SET		[idStatus] = @idStatus
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempPayoutBody)

				UPDATE	[LP_Operation].[TransactionInternalStatus]
				SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempPayoutBody)

			COMMIT TRANSACTION
			

			/* UPDATE TRANSACTIONS STATUS BLOCK: FIN */

			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* SELECT FINAL BLOCK: INI */

			DECLARE @Rows INT
			SET @Rows = ((SELECT COUNT(*) FROM @TempPayoutBody))

			IF(@Rows > 0)
			BEGIN
				SELECT [Line] FROM @LinesPayout ORDER BY [idLine] ASC
			END

			/* SELECT FINAL BLOCK: FIN */

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()--'INTERNAL ERROR'
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

		RAISERROR
				(
					@ErrorMessage,
					@ErrorSeverity,
					@ErrorState
				);
	END CATCH
END
