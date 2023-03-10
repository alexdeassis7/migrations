CREATE OR ALTER PROCEDURE [LP_Operation].[CHL_Payout_BCHILE_Bank_Operation_Download]
																					(
																						@TransactionMechanism	BIT
																						, @JSON					VARCHAR(MAX)
																					)
AS
BEGIN

	BEGIN TRY

			/* CONFIG BLOCK: INI */

			DECLARE @idCountry	INT
			SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'CLP' AND [Active] = 1 )

			DECLARE @idProvider	INT
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BCHILE' AND [Active] = 1 )

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
				[idx]							INT IDENTITY (1,1)
				, [RegistryType]				VARCHAR(MAX)
				, [LEN_RegistryType]			INT				--1 valor 6
				, [BeneficiaryNIT]				VARCHAR(MAX)
				, [LEN_BeneficiaryNIT]			INT				--15 alineado a la izquierda con espacios a la derecha
				, [BeneficiaryName]				VARCHAR(MAX)
				, [LEN_BeneficiaryName]			INT				--30
				, [BeneficiaryBank]				VARCHAR(MAX)
				, [LEN_BeneficiaryBank]			INT				--9 
				, [BeneficiaryAccount]			VARCHAR(MAX)
				, [LEN_BeneficiaryAccount]		INT				--17 alineado a la izquierda con espacios a la derecha
				, [PaymentPlaceIndicator]		VARCHAR(MAX)	
				, [LEN_PaymentPlaceIndicator]	INT				--1 no requerido. Solo aplica para generacion masiva de cheques .             Le estan poniendo una S
				, [TxType]						VARCHAR(MAX)
				, [LEN_TxType]					INT				--2				valores 27 (CC) y 37 (CA)
				, [Value]						VARCHAR(MAX)
				, [LEN_Value]					INT				--17 (15+2)
				, [PaymentDate]					VARCHAR(MAX)
				, [LEN_PaymentDate]				INT				--8 AAAAMMDD
				, [Reference]					VARCHAR(MAX)
				, [LEN_Reference]				INT				--21 no requerido
				, [IdType]						VARCHAR(MAX)
				, [LEN_IdType]					INT				--1 no requerido, a menos si el pago solo es para entregar por ventanilla
				, [CollectionOffice]			VARCHAR(MAX)
				, [LEN_CollectionOffice]		INT				--Bancolombia oficinas codes. Si es en todas las oficinas , o es a cuentas va: 00000
				, [Fax]							VARCHAR(MAX)	
				, [LEN_Fax]						INT				--15 no requerido
				, [Email]						VARCHAR(MAX)	
				, [LEN_Email]					INT				--80 no requerido	
				, [AuthorizedId]				VARCHAR(MAX)	
				, [LEN_AuthorizedId]			INT				--15 requerido. Id del autorizado para reclamar cheques por ventanilla. solo requerido bajo esta modalidad
				, [FillerBody]					VARCHAR(MAX)
				, [LEN_FillerBody]				INT				--27

				, [LineComplete]				VARCHAR(MAX)
				, [idTransactionLot]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransaction]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

				, [DecimalAmount]					[LP_Common].[LP_F_DECIMAL]
				, [Acum]							[LP_Common].[LP_F_DECIMAL] NULL
				, [ToProcess]						[LP_Common].[LP_F_BOOL]
			)

			DECLARE @LinesPayout TABLE
			(
				[idLine]			INT IDENTITY(1,1)
				, [Line]			VARCHAR(MAX)
			)

			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* BODY BLOCK: INI */

			INSERT INTO @TempPayoutBody ([RegistryType], [LEN_RegistryType], [BeneficiaryNIT], [LEN_BeneficiaryNIT], [BeneficiaryName], [LEN_BeneficiaryName], [BeneficiaryBank], [LEN_BeneficiaryBank],
										[BeneficiaryAccount], [LEN_BeneficiaryAccount], [PaymentPlaceIndicator], [LEN_PaymentPlaceIndicator], [TxType], [LEN_TxType], [Value], [LEN_Value], [PaymentDate], [LEN_PaymentDate],
										[Reference], [LEN_Reference], [IdType], [LEN_IdType], [CollectionOffice], [LEN_CollectionOffice], [Fax], [LEN_Fax], [Email], [LEN_Email], [AuthorizedId], [LEN_AuthorizedId],
										[FillerBody], [LEN_FillerBody], [idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
			SELECT
				[RegistryType]					= '6'
				, [LEN_RegistryType]			= 1
				, [BeneficiaryNIT]				= LEFT([TRD].[RecipientCUIT] + '               ', 15)
				, [LEN_BeneficiaryNIT]			= DATALENGTH(LEFT([TRD].[RecipientCUIT] + '               ', 15))
				, [BeneficiaryName]				= LEFT([TRD].[Recipient] + '                              ', 30)
				, [LEN_BeneficiaryName]			= DATALENGTH(LEFT([TRD].[Recipient] + '                              ', 30))
				, [BeneficiaryBank]				= RIGHT('000000000' + [BC].[SubCode], 9)
				, [LEN_BeneficiaryBank]			= DATALENGTH(RIGHT('000000000' + [BC].[SubCode], 9))
				, [BeneficiaryAccount]			= LEFT([TRD].[RecipientAccountNumber] + '                 ', 17)
				, [LEN_BeneficiaryAccount]		= DATALENGTH(LEFT([TRD].[RecipientAccountNumber] + '                 ', 17))
				, [PaymentPlaceIndicator]		= 'S'
				, [LEN_PaymentPlaceIndicator]	= 1
				, [TxType]						= RIGHT(IIF([BC].[SubCode] = '1507', '37', [BAT].[Code]), 2)
				, [LEN_TxType]					= DATALENGTH(RIGHT([BAT].[Code], 2))
				, [Value]                       = RIGHT('00000000000000000' + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(14)), '.', ''), ',', ''), 17)
				, [LEN_Value]					= DATALENGTH(RIGHT('00000000000000000' + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(14)), '.', ''), ',', ''), 17))
				, [PaymentDate]					= CONVERT(VARCHAR(8), [T].[TransactionDate], 112)
				, [LEN_PaymentDate]				= DATALENGTH(CONVERT(VARCHAR(8), [T].[TransactionDate], 112))
				, [Reference]					= LEFT([T2].[Ticket] + '                     ', 21)
				, [LEN_Reference]				= DATALENGTH(LEFT([T2].[Ticket] + '                     ', 21))
				, [IdType]						= [EIT].[Code]
				, [LEN_IdType]					= 1
				, [CollectionOffice]			= '00000'
				, [LEN_CollectionOffice]		= 5
				, [Fax]							= NULL
				, [LEN_Fax]						= 0                  
				, [Email]						= NULL
				, [LEN_Email]					= 0 
				, [AuthorizedId]				= NULL	
				, [LEN_AuthorizedId]			= 0
				, [FillerBody]					= '                           '
				, [LEN_FillerBody]				= 27
				, [idTransactionLot]			= [TL].[idTransactionLot]
				, [idTransaction]				= [T].[idTransaction]

				, [DecimalAmount]				= [TD].[NetAmount]
				, [ToProcess]					= 1


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

			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempPayoutBody
			SET [LineComplete] = [RegistryType] + [BeneficiaryNIT] + [BeneficiaryName] + [BeneficiaryBank] + [BeneficiaryAccount] + [PaymentPlaceIndicator] + [TxType] + [Value] + [PaymentDate] + 
								[Reference] + [IdType] + [CollectionOffice] + [FillerBody]

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


			/* TRACKING TRANSACTIONS DATES */




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

		DECLARE @ErrorMessage NVARCHAR(4000) = 'INTERNAL ERROR'
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
