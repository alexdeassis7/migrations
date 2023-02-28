CREATE OR ALTER PROCEDURE [LP_Operation].[COL_Payout_OCCIDENTE_Bank_Operation_Download]
																			(
																				@TransactionMechanism		BIT
																				, @JSON						VARCHAR(MAX)
																			)
AS
BEGIN

			BEGIN TRY

					/* CONFIG BLOCK: INI */

					DECLARE @idCountry	INT
					SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE Code = 'COP' AND [Active] = 1 )

					DECLARE @idProvider INT
					SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'OCCIDENTE' AND [idCountry] = @idCountry AND [Active] = 1 )

					-- DECLARING TABLE WITH SELECTED TICKETS TO DOWNLOAD
					DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
					INSERT INTO @TempTxsToDownload
					SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)

					DECLARE @idProviderPayWayService INT
					SET @idProviderPayWayService = ( SELECT [PPWS].[idProviderPayWayService] 
														FROM [LP_Configuration].[ProviderPayWayServices]		[PPWS]
															INNER JOIN [LP_Configuration].[Provider]			[PR]	ON	[PR].[idProvider]		= [PPWS].[idProvider]
															INNER JOIN [LP_Configuration].[PayWayServices]	[PWS]	ON	[PWS].[idPayWayService] = [PPWS].[idPayWayService]
														WHERE [PR].[Code] = 'OCCIDENTE' AND [PR].[idCountry] = @idCountry
															AND [PWS].[Code] = 'BANKDEPO' AND [PWS].[idCountry] = @idCountry )

					DECLARE @idTransactionTypeProvider INT
					SET @idTransactionTypeProvider = ( SELECT [idTransactionTypeProvider]
														FROM [LP_Configuration].[TransactionTypeProvider] [TTP]
															INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [TTP].[idTransactionType]
														WHERE [TTP].[idProvider] = @idProvider AND [TT].[Code] = 'PODEPO' )

					DECLARE @TempPayoutBody TABLE
					(
						[idx]						BIGINT	IDENTITY(1, 1)
						, [RegistryType]			VARCHAR(1)
						, [Consecutive]				VARCHAR(4)
						, [LPAccount]				VARCHAR(16)
						, [Beneficiary]				VARCHAR(30)
						, [BeneficiaryId]			VARCHAR(11)
						, [BankCode]				VARCHAR(4)
						, [PaymentDate]				VARCHAR(8)
						, [PaymentType]				VARCHAR(1)
						, [Amount]					VARCHAR(15)
						, [BenefAccount]			VARCHAR(16)
						, [Ticket]					VARCHAR(12)
						, [AccountType]				VARCHAR(1)
						, [Concept]					VARCHAR(80)

						, [LineComplete]			VARCHAR(MAX)
						, [idTransactionLot]		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
						, [idTransaction]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]		

						, [DecimalAmount]			[LP_Common].[LP_F_DECIMAL]
						, [Acum]					[LP_Common].[LP_F_DECIMAL] NULL
						, [ToProcess]				[LP_Common].[LP_F_BOOL]
					)

					DECLARE @Lines TABLE
					(
						[idLine]			INT IDENTITY(1,1)
						, [Line]			VARCHAR(MAX)
					)

					/* CONFIG BLOCK: FIN */
					/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


					/* BODY BLOCK: INI */
					INSERT INTO @TempPayoutBody ([RegistryType] ,[LPAccount] ,[Beneficiary] ,[BeneficiaryId] ,[BankCode] ,[PaymentDate] ,[PaymentType] ,[Amount] 
					,[BenefAccount] ,[Ticket] ,[AccountType] ,[Concept], [idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
					SELECT
						[RegistryType] = '2'
						,[LPAccount] = RIGHT('0000000000000000' + '291815710',16)
						,[Beneficiary] = LEFT([TRD].[Recipient] + SPACE(30),30)
						,[BeneficiaryId] = RIGHT('00000000000' + [TRD].[RecipientCUIT],11) 
						,[BankCode] = RIGHT('0000' + RIGHT([BC].[Code] ,3),4)
						,[PaymentDate] = FORMAT(GETDATE(), 'yyyyMMdd')
						,[PaymentType] = CASE --SI Banco Occidente 2 sino 3
												WHEN [BC].[Code] = 1023 THEN '2'
												ELSE '3'
										END
						,[Amount] = RIGHT('00000000000000000' + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(14)), '.', ''), ',', ''), 15)
						,[BenefAccount] = LEFT( [TRD].[RecipientAccountNumber] + SPACE(16),16)
						,[Ticket] = ''
						,[AccountType] = CASE WHEN [BAT].[Code] = 37 THEN 'A'
												ELSE 'C'
										END
						,[Concept] = SPACE(80)

						, [idTransactionLot]		= [TL].[idTransactionLot]
						, [idTransaction]			= [T].[idTransaction]
						, [DecimalAmount]			= [TD].[NetAmount]
						, [ToProcess]				= 1
					FROM
						[LP_Operation].[Transaction]									[T]
							INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]		= [TL].[idTransactionLot]
							INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]			= [TRD].[idTransaction]
							INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]			= [TD].[idTransaction]
							INNER JOIN	[LP_Operation].[TransactionFromTo]				[TFT]	ON	[T].[idTransaction]			= [TFT].[IdTransaction]
							INNER JOIN	[LP_Configuration].[PaymentType]				[PT]	ON	[TRD].[idPaymentType]		= [PT].[idPaymentType]
							INNER JOIN	[LP_Configuration].[CurrencyType]				[CT]	ON	[T].[CurrencyTypeLP]		= [CT].[idCurrencyType]
							INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]	= [BAT].[idBankAccountType]
																									AND [BAT].[idCountry]					= @idCountry
							INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]			= [T2].[idTransaction]
							INNER JOIN	[LP_Common].[Status]							[S]		ON	[T].[idStatus]				= [S].[idStatus]
							INNER JOIN	[LP_Configuration].[BankCode]					[BC]    ON	[TRD].[idBankCode]			= [BC].[idBankCode]
							LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]		= [T].[idTransaction]
							LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant] = [TESM].[idEntitySubMerchant]
							INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]		= [T].[idTransaction]
					WHERE
						[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
						AND [TD].[NetAmount] > 0
					ORDER BY [T].[TransactionDate] ASC


			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE TICKET ALTERNATIVE WITH 12 CHARACTERS FOR OCCIDENTE SYSTEM BLOCK: INI */

			--DECLARE @count INT
			--DECLARE @i INT
			--SET @count = ( SELECT COUNT(*) FROM @TempReg2 )
			--SET @i = 1

			DECLARE @maxTicket VARCHAR(12)

			DECLARE @nextTicketCalculation BIGINT
			DECLARE @nextTicket VARCHAR(12) 

			DECLARE @NewTicketAlternative VARCHAR(12)
			DECLARE @txnum AS INT

			DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
			  SELECT idx
			  FROM @TempPayoutBody

			OPEN tx_cursor;

			FETCH NEXT FROM tx_cursor INTO @txnum

			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @maxTicket =  ( SELECT MAX([TicketAlternative12]) FROM [LP_Operation].[Ticket] )
					IF(@maxTicket IS NULL)
					BEGIN
						SET @nextTicket = REPLICATE('0', 12)
					END
					ELSE
					BEGIN
						SET @nextTicketCalculation =   ( SELECT CAST (@maxTicket AS BIGINT)  + 1  )
						SET @nextTicket = ( SELECT CAST (@nextTicketCalculation AS VARCHAR(12)) )
					END

					SET @NewTicketAlternative = RIGHT(REPLICATE('0', 12) + @nextTicket ,12)

						UPDATE [LP_Operation].[Ticket]
						SET
							[TicketAlternative12] = @NewTicketAlternative,
							[DB_UpdDateTime] = GETUTCDATE()
						FROM
							[LP_Operation].[Ticket] [T]
								INNER JOIN @TempPayoutBody [TEMP] ON [T].[idTransaction] = [TEMP].[idTransaction]
						WHERE
							[TEMP].[idx] = @txnum

						UPDATE @TempPayoutBody
						SET [Ticket] = @NewTicketAlternative
						WHERE [idx] = @txnum

					FETCH NEXT FROM tx_cursor INTO @txnum
				END

			CLOSE tx_cursor
			DEALLOCATE tx_cursor

			/* UPDATE TICKET ALTERNATIVE WITH 12 CHARACTERS FOR OCCIDENTE SYSTEM BLOCK: FIN */


			/* UPDATE PAYOUT BLOCK: INI */
			DECLARE @id VARCHAR(4) 
			SET @id = 0 
			UPDATE @TempPayoutBody SET @id = [Consecutive] = RIGHT('0000' + CAST(@id + 1 AS VARCHAR(4)),4)

			UPDATE @TempPayoutBody
				SET [LineComplete] = [RegistryType] + [Consecutive] + [LPAccount] + [Beneficiary] + [BeneficiaryId] + [BankCode] + [PaymentDate] + [PaymentType] + [Amount] + [BenefAccount] + [Ticket] + [AccountType] + [Concept]

			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* HEADER BLOCK: INI */

					DECLARE @Header VARCHAR(MAX)

					DECLARE @HeaderType VARCHAR(1)
					,@Consecutive VARCHAR(4)
					,@PaymentDate VARCHAR(8)
					,@QtyTxs VARCHAR(4)
					,@AmountTxs VARCHAR(18)
					,@MainAccount VARCHAR(16)
					,@FileIdentifier VARCHAR(6)
					,@HeaderZeros VARCHAR(142)

					DECLARE @QtyLine VARCHAR(7)
						,@AmountPreFooter VARCHAR(18)

					SET @QtyLine = (SELECT COUNT(*) FROM @TempPayoutBody)
					SET @AmountPreFooter = (SELECT SUM(DecimalAmount) FROM @TempPayoutBody)

					
					SELECT
						@HeaderType = '1'
						,@Consecutive = '0000' 
						,@PaymentDate = FORMAT(GETDATE(), 'yyyyMMdd')
						,@QtyTxs = RIGHT('0000' + @QtyLine,4)
						,@AmountTxs = RIGHT('000000000000000000' + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount](@AmountPreFooter) AS VARCHAR(20)), '.', ''), ',', ''), 18)
						,@MainAccount = RIGHT('0000000000000000' + '291815710',16) --TODO Pedir numero de cuenta
						,@FileIdentifier = '000000'
						,@HeaderZeros = REPLICATE('0',142)
					



					SET @Header = @HeaderType + @Consecutive + @PaymentDate + @QtyTxs + @AmountTxs + @MainAccount + @FileIdentifier + @HeaderZeros 

			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			
			/* FOOTER BLOCK: INI */

					DECLARE @Footer VARCHAR(MAX)

					DECLARE @RowType VARCHAR(1)
							,@ZerosFooter VARCHAR(15)
							,@QtyFooter VARCHAR(4)
							,@AmountFooter VARCHAR(18)
							,@FillerFooter VARCHAR(172)


					SELECT @RowType =  '3'
							,@ZerosFooter = '9999'
							,@QtyFooter = RIGHT('0000' + @QtyLine,4)
							,@AmountFooter = RIGHT('0000000000000000000' + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount](@AmountPreFooter) AS VARCHAR(20)), '.', ''), ',', ''), 18)
							,@FillerFooter = REPLICATE('0',172)
		
					SET @Footer = @RowType + @ZerosFooter + @QtyFooter + @AmountFooter + @FillerFooter


			/* FOOTER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* INSERT LINES BLOCK: INI */

					INSERT INTO @Lines VALUES(@Header)

					INSERT INTO @Lines
					SELECT [LineComplete] FROM @TempPayoutBody
					INSERT INTO @Lines VALUES(@Footer)
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

					COMMIT TRAN

			/* UPDATE TRANSACTIONS STATUS BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* SELECT FINAL BLOCK: INI */

					DECLARE @Rows INT
					SET @Rows = ((SELECT COUNT(*) FROM @TempPayoutBody))

					IF(@Rows > 0)
					BEGIN
						SELECT [Line] FROM @Lines ORDER BY [idLine] ASC
						SELECT CAST(@AmountPreFooter AS DECIMAL(16,2))
					END
			/* SELECT FINAL BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN

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



