CREATE OR ALTER PROCEDURE [LP_Operation].[URY_Payout_BROU_Bank_Operation_Download]
																					(
																						@TransactionMechanism	BIT
																						, @JSON					VARCHAR(MAX)
																					)
AS
BEGIN

	BEGIN TRY

			/* CONFIG BLOCK: INI */

			DECLARE @idCountry	INT
			SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'UYU' AND [Active] = 1 )

			DECLARE @idProvider	INT
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BROU' AND [Active] = 1 )

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
				,[LineType]						VARCHAR(1)
				,[IsBROU]						VARCHAR(2) -- 1 BROU, 2 Otros bancos
				,[BenefAccount]					VARCHAR(30)
				,[BenefName]					VARCHAR(80)
				,[Amount]						VARCHAR(19) --Usa separador decimal .
				,[Ticket]						VARCHAR(30)
				,[Description]					VARCHAR(80)
				,[PaymentDate]					VARCHAR(10)
				,[SwiftCode]					VARCHAR(11)
				,[OperationCode]				VARCHAR(2)
				,[Email]						VARCHAR(40)
				,[PhoneNumber]					VARCHAR(20)
				,[Adress]						VARCHAR(35)

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

			DECLARE @LinesPayoutBrou TABLE
			(
				[idLine]			INT IDENTITY(1,1)
				, [Line]			VARCHAR(MAX)
			)

			DECLARE @NextAvailableDay VARCHAR(10)
			SET @NextAvailableDay = (SELECT FORMAT(DATEADD(day,
										CASE
										   WHEN DATENAME(WEEKDAY,GETDATE()) = 'Friday' THEN 3
										   WHEN DATENAME(WEEKDAY,GETDATE()) = 'Saturday' THEN 2
										   ELSE 1
										END,
										GETDATE()),'dd/MM/yyyy'))
			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* BODY BLOCK NOT BROU: INI */

			INSERT INTO @TempPayoutBody ([LineType] ,[IsBROU] ,[BenefAccount] ,[BenefName] ,[Amount] ,[Ticket] ,[Description] ,[PaymentDate] ,[SwiftCode] ,[OperationCode] ,[Email] ,[PhoneNumber] ,[Adress],
			[idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
			SELECT
				[LineType]						= 'D'
				,[IsBROU]						= CASE WHEN  [BC].[Code] != '1001' THEN '2'
														ELSE '1'
													END
				,[BenefAccount]					= [TRD].[RecipientAccountNumber]
				,[BenefName]					= [TRD].[Recipient]
				,[Amount]						= CAST([TD].[NetAmount] AS DECIMAL(16,2))
				,[Ticket]						= [T2].[Ticket]
				,[Description]					= ''
				,[PaymentDate]					= @NextAvailableDay
				,[SwiftCode]					= CASE WHEN  [BC].[Code] != '1001' THEN [BC].[SubCode]
														ELSE ''
													END
				,[OperationCode]				= '08'
				,[Email]						= ''
				,[PhoneNumber]					= ''
				,[Adress]						= ''
				,[idTransactionLot]				= [TL].[idTransactionLot]
				,[idTransaction]				= [T].[idTransaction]
				,[DecimalAmount]				= [TD].[NetAmount]
				,[ToProcess]					= 1
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


			/* BODY BLOCK NOT BROU: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* HEADER BLOCK: INI */

					DECLARE @Header VARCHAR(MAX)
					DECLARE @HeaderBrou VARCHAR(MAX)

					DECLARE @HeaderType		VARCHAR(1)
							,@BrouCode		VARCHAR(9)
							,@ServiceType	VARCHAR(4)
							,@Despcription	VARCHAR(16)
							,@Currency		VARCHAR(3)
							,@TotalAmount	VARCHAR(20)
							,@PaymentDate	VARCHAR(10)
							,@LPAccount		VARCHAR(14)
							,@Filler		VARCHAR(1)
							,@Description2	VARCHAR(80)
							,@Email			VARCHAR(40)
							,@Registers		VARCHAR(9)
							,@Phone			VARCHAR(20)
							,@SendEmail		VARCHAR(1)
							,@SendPhone		VARCHAR(1)
							
					DECLARE	@HeaderTypeB		VARCHAR(1)
							,@BrouCodeB			VARCHAR(9)
							,@ServiceTypeB		VARCHAR(4)
							,@DespcriptionB		VARCHAR(16)
							,@CurrencyB			VARCHAR(3)
							,@TotalAmountB		VARCHAR(20)
							,@PaymentDateB		VARCHAR(10)
							,@LPAccountB		VARCHAR(14)
							,@FillerB			VARCHAR(1)
							,@Description2B		VARCHAR(80)
							,@EmailB			VARCHAR(40)
							,@RegistersB		VARCHAR(9)
							,@PhoneB			VARCHAR(20)
							,@SendEmailB		VARCHAR(1)
							,@SendPhoneB		VARCHAR(1)

					SELECT
						@HeaderType		= 'H'
						,@BrouCode		= '278614'
						,@ServiceType	= '54'
						,@Despcription	= ''
						,@Currency		= 'UYP'
						,@TotalAmount	= CAST(SUM(DecimalAmount) AS DECIMAL(18,2))
						,@PaymentDate	= @NextAvailableDay
						,@LPAccount		= '11030901600001'
						,@Filler		= ''
						,@Description2	= ''
						,@Email			= ''
						,@Registers		= COUNT(idx)
						,@Phone			= ''
						,@SendEmail		= 'N'
						,@SendPhone		= 'N'
					FROM @TempPayoutBody
					WHERE [IsBROU] != 1

					SELECT
						@HeaderTypeB		= 'H'
						,@BrouCodeB			= '278614'
						,@ServiceTypeB		= '56'
						,@DespcriptionB		= ''
						,@CurrencyB			= 'UYP'
						,@TotalAmountB		= CAST(SUM(DecimalAmount) AS DECIMAL(18,2))
						,@PaymentDateB		= @NextAvailableDay
						,@LPAccountB		= '11030901600001'
						,@FillerB			= ''
						,@Description2B		= ''
						,@EmailB			= ''
						,@RegistersB		= COUNT(idx)
						,@PhoneB			= ''
						,@SendEmailB		= 'N'
						,@SendPhoneB		= 'N'
					FROM @TempPayoutBody
					WHERE [IsBROU] = 1


					SET @Header = @HeaderType + ';' + @BrouCode + ';' + @ServiceType + ';' + @Despcription + ';' + @Currency + ';' + @TotalAmount + ';' + @PaymentDate + ';' + @LPAccount + ';' + @Filler + ';' + @Description2 + ';' + @Email + ';' + @Registers + ';' + @Phone + ';' + @SendEmail + ';' + @SendPhone
					SET @HeaderBrou = @HeaderTypeB + ';' + @BrouCodeB + ';' + @ServiceTypeB + ';' + @DespcriptionB + ';' + @CurrencyB + ';' + @TotalAmountB + ';' + @PaymentDateB + ';' + @LPAccountB + ';' + @FillerB + ';' + @Description2B + ';' + @EmailB + ';' + @RegistersB + ';' + @PhoneB + ';' + @SendEmailB + ';' + @SendPhoneB
					
			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempPayoutBody
			SET [LineComplete] = [LineType] + ';' + [IsBROU] + ';' + [BenefAccount] + ';' + [BenefName] + ';' + [Amount] + ';' + [Ticket] + ';' + [Description] + ';' + [PaymentDate] + ';' + [SwiftCode] + ';' + [OperationCode] + ';' + [Email] + ';' + [PhoneNumber] + ';' + [Adress]

			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			
			/* INSERT LINES BLOCK: INI */
			INSERT INTO @LinesPayout VALUES(@Header)
			INSERT INTO @LinesPayout
			SELECT [LineComplete] FROM @TempPayoutBody WHERE [IsBROU] != 1

			INSERT INTO @LinesPayoutBrou VALUES(@HeaderBrou)
			INSERT INTO @LinesPayoutBrou
			SELECT [LineComplete] FROM @TempPayoutBody WHERE [IsBROU] = 1

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
					,@RowsBrou INT
			SET @Rows = ((SELECT COUNT(*) FROM @TempPayoutBody WHERE [IsBROU] != 1))
			SET @RowsBrou = ((SELECT COUNT(*) FROM @TempPayoutBody WHERE [IsBROU] = 1))

			IF(@Rows > 0 OR @RowsBrou > 0)
			BEGIN
				SELECT [Line] FROM @LinesPayout ORDER BY [idLine] ASC
				SELECT [Line] FROM @LinesPayoutBrou ORDER BY [idLine] ASC
				SELECT @TotalAmount
				SELECT @TotalAmountB
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
