/****** Object:  StoredProcedure [LP_Operation].[PER_Payout_BCP_Bank_Operation_Download]    Script Date: 12/28/2021 5:13:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [LP_Operation].[PER_Payout_BCP_Bank_Operation_Download]
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
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BCPPER' AND [Active] = 1 )

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


			DECLARE @TempPayoutHeader TABLE
			(
				[RegisterType]					VARCHAR(1)
				,[QuantityOfPayments]			VARCHAR(6)
				,[ProcessDate]					VARCHAR(8)
				,[AccountType]					VARCHAR(1)
				,[PayingCurrency] 				VARCHAR(4)
				,[PayingAccount]				VARCHAR(20)
				,[TotalAmount]					VARCHAR(17)
				,[Reference]					VARCHAR(40)
				,[ITFExoneration]				VARCHAR(1)
				,[Checksum]						VARCHAR(15)
				,[LineComplete]					VARCHAR(MAX)
			)

			DECLARE @TempPayoutBody TABLE
			(
				[idx]								INT IDENTITY (1,1)
				,[RegisterType]						VARCHAR(1)
				, [BeneficiaryAccountType]			VARCHAR(1)
				, [BeneficiaryAccountNumber]		VARCHAR(20)
				, [PaymentMethod]					VARCHAR(1)
				, [BeneficiaryDocumentType]			VARCHAR(1)
				, [BeneficiaryDocumentNumber]		VARCHAR(12)
				, [Correlative]						VARCHAR(3)
				, [BeneficiaryName]					VARCHAR(75)
				, [BeneficiaryReference]			VARCHAR(40)
				, [CompanyReference]				VARCHAR(20)
				, [Currency]						VARCHAR(4)
				, [Amount]							VARCHAR(17)
				, [ValidateIDC]						VARCHAR(1)
				, [LineComplete]					VARCHAR(MAX)
				, [DecimalAmount]					[LP_Common].[LP_F_DECIMAL]
				, [AccountAsNum]					DECIMAL(38,0)
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

			INSERT INTO @TempPayoutBody ([RegisterType],[BeneficiaryAccountType],[BeneficiaryAccountNumber],[PaymentMethod],[BeneficiaryDocumentType],[BeneficiaryDocumentNumber],[Correlative]
										,[BeneficiaryName],[BeneficiaryReference],[CompanyReference],[Currency],[Amount],[ValidateIDC],[DecimalAmount],[AccountAsNum],[idTransactionLot],[idTransaction])
			SELECT
				[RegisterType] = 2,
				[BeneficiaryAccountType] = (CASE [BC].Code
											WHEN '002' THEN LEFT([BAT].Code, 1)
											ELSE 'B'
											END), --TODO
				[BeneficiaryAccountNumber] = (CASE [BC].Code
												WHEN '002' THEN	(CASE LEFT([BAT].Code, 1)
																WHEN 'A' THEN LEFT(LEFT(LEFT(RIGHT(CAST([TRD].[RecipientAccountNumber] AS VARCHAR),17),3) + RIGHT(CAST([TRD].[RecipientAccountNumber] AS VARCHAR), 13) ,14) + SPACE(20),20)
																ELSE LEFT(LEFT(LEFT(RIGHT(CAST([TRD].[RecipientAccountNumber] AS VARCHAR),17),3) + RIGHT(CAST([TRD].[RecipientAccountNumber] AS VARCHAR), 12) ,13) + SPACE(20), 20)
																END)
												ELSE LEFT((CAST([TRD].[RecipientAccountNumber] AS VARCHAR) + SPACE(20)), 20)
												END),
				[PaymentMethod] = 1,
				[BeneficiaryDocumentType] = (CASE [EIT].Code
											WHEN 'DNI' THEN 1
											WHEN 'CE' THEN 3
											WHEN 'Passport' THEN 4
											WHEN 'RUC' THEN 6
											ELSE 7
											END), --TODO
				[BeneficiaryDocumentNumber] = LEFT([TRD].RecipientCUIT + SPACE(12),12),
				[Correlative] = '   ',
				[BeneficiaryName] = LEFT([TRD].Recipient + SPACE(75), 75),
				[BeneficiaryReference] =  SPACE(40),
				[CompanyReference] = SPACE(20),
				[Currency] = '0001',
				[Amount] = RIGHT(REPLICATE('0', 15) + CAST(REPLACE(FORMAT([TD].[NetAmount],'N', 'en-US'),',','') AS VARCHAR), 17),
				[ValidateIDC] = 'S',
				[DecimalAmount] = [TD].[NetAmount],
				[AccountAsNum] = CAST([TRD].[RecipientAccountNumber] AS BIGINT)
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

			INSERT INTO @TempPayoutHeader ([RegisterType],[QuantityOfPayments],[ProcessDate],[AccountType],[PayingCurrency],[PayingAccount]
						,[TotalAmount],[Reference],[ITFExoneration],[Checksum])
			SELECT
				[RegisterType] = '1',
				[QuantityOfPayments] = RIGHT('000000' + CAST((SELECT COUNT(*) FROM @TempPayoutBody) AS VARCHAR), 6),
				[ProcessDate] = FORMAT(GETDATE(), 'yyyyMMdd'),
				[AccountType] = 'C',
				[PayingCurrency] = '0001',
				[PayingAccount] = '1949400642078       ',
				[TotalAmount] = RIGHT(REPLICATE('0', 15) + CAST(REPLACE(FORMAT((SELECT SUM(DecimalAmount) FROM @TempPayoutBody),'N', 'en-US'),',','') AS VARCHAR), 17),
				[Reference] = SPACE(40),
				[ITFExoneration] = 'N',
				[Checksum] = RIGHT((REPLICATE('0', 15) + CAST((1949400642078 + (SELECT SUM(AccountAsNum) FROM @TempPayoutBody)) AS VARCHAR)), 15)

			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

	
			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempPayoutBody
			SET [LineComplete] = [RegisterType] + [BeneficiaryAccountType] + [BeneficiaryAccountNumber] + [PaymentMethod] + [BeneficiaryDocumentType] + [BeneficiaryDocumentNumber] + [Correlative] + [BeneficiaryName] + [BeneficiaryReference] + [CompanyReference] + [Currency] + [Amount] + [ValidateIDC]

			UPDATE @TempPayoutHeader
			SET [LineComplete] = [RegisterType] + [QuantityOfPayments] + [ProcessDate] + [AccountType] + [PayingCurrency] + [PayingAccount] + [TotalAmount] + [Reference] + [ITFExoneration] + [Checksum]

			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			
			/* INSERT LINES BLOCK: INI */
			INSERT INTO @LinesPayout
			SELECT [LineComplete] FROM @TempPayoutHeader

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
