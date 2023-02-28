CREATE OR ALTER PROCEDURE [LP_Operation].[BRA_Payout_PLURAL_Bank_Operation_Download]
													(
														 @json			[LP_Common].[LP_F_VMAX]
													)
AS
	BEGIN
		BEGIN TRY

			/* CONFIG BLOCK: INI */

			DECLARE @idCountry	INT
			SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'BRL' AND [Active] = 1 )

			DECLARE @idProvider	INT
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'PLURAL' AND [Active] = 1 )

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

			DECLARE @RESP xml


			DECLARE @TempPayoutBody TABLE
				(
					[idx]								INT IDENTITY (1,1)
					,[IdTransactionLot]					VARCHAR(MAX)
					,[IdTransaction]					VARCHAR(MAX)
					,[TID]								VARCHAR(MAX)
					,[Amount]							VARCHAR(MAX)
					,[PaymentDate]						VARCHAR(MAX)
					,[BankNumber]						VARCHAR(MAX)
					,[BankBranch]						VARCHAR(MAX)
					,[BankAccountNumber]				VARCHAR(MAX)
					,[BankAccountType]					VARCHAR(MAX)
					,[BeneficiaryName]					VARCHAR(MAX)
					,[BeneficiaryDocument]				VARCHAR(MAX)
					,[CustomerName]						VARCHAR(MAX)
					,[CustomerEmail]					VARCHAR(MAX)
					,[CustomerDocument]					VARCHAR(MAX)
					,[CustomerMobilePhone]				VARCHAR(MAX)
					,[Description]						VARCHAR(MAX)
					,[ToProcess]						[LP_Common].[LP_F_BOOL] NULL
				)
		
			INSERT INTO @TempPayoutBody ([IdTransactionLot],[IdTransaction],[TID],[Amount],[PaymentDate],[BankNumber],[BankBranch],[BankAccountNumber],[BankAccountType],[BeneficiaryName],[BeneficiaryDocument],[CustomerName],[CustomerEmail],[CustomerDocument],[CustomerMobilePhone],[Description],[ToProcess])
			SELECT 
						[T].[idTransactionLot]
						,[T].[idTransaction]
						,[T2].[Ticket]
						,FORMAT([TD].[NetAmount],'#,###.##')
						,FORMAT([T].[TransactionDate],'yyyy/MM/dd')
						,[BC].[Code]
						,LEFT(REPLACE(REPLACE(REPLACE([TRD].[BankBranch],'.',''),'-',''),'/',''),4)
						,REPLACE(REPLACE(REPLACE(REPLACE([TRD].[RecipientAccountNumber],'.',''),'X','0'),'/',''),'-','')
						,CASE 
							WHEN LEN(REPLACE(REPLACE(REPLACE([TRD].[RecipientAccountNumber],'.',''),'-',''),'/','')) > 11 THEN  IIF([BAT].[Code] = 'C','003','004')
							ELSE IIF([BAT].[Code] = 'C','001','002')
							END
						,[TRD].[Recipient]
						,[TRD].[RecipientCUIT]
						,'LP DO BRASIL SERVICIO DE PAGAMENTO EIRIELI'
						,'Support@localpayment.com'
						,'34669130000133'
						,'11900000000'
						,'LocalPayment Payout'
						, 1
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
							INNER JOIN  [LP_Configuration].[TransactionTypeProvider]	[TTP]	ON	[TTP].[idTransactionTypeProvider] = [T].[idTransactionTypeProvider]
							 LEFT JOIN  [LP_Entity].[EntityIdentificationType]			[EIT]	ON	[EIT].[idEntityIdentificationType]	= [TRD].[idEntityIdentificationType]
							 LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]				= [T].[idTransaction]
							 LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant]			= [TESM].[idEntitySubMerchant]
							 INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]

					WHERE
						[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
						AND [TTP].[idTransactionType] = 2
					
			
			--	/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			--	/* UPDATE TRANSACTIONS STATUS BLOCK: INI */

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

				SELECT [CustomerDocument]												AS [CNPJ Cliente]
													,'0001'																						AS [Agencia Cliente]
													,'44601'																					AS [Conta Cliente com digito]
													,[CustomerName]																				AS [Nome Favorecido]
													,[BeneficiaryDocument]																		AS [CPF CNPJ Favorecido]
													,(CASE WHEN LEN(BeneficiaryDocument) = 11 THEN 'F'
														ELSE 'J' END)																			AS [Pessoa Fisica ou Juridica]
													,[BankNumber]																				AS [Código banco]
													,[BankBranch]																				AS [Agência]
                                                    ,LEFT([BankAccountNumber], LEN([BankAccountNumber]) - 1)                                    AS [Conta corrente]
                                                    ,RIGHT([BankAccountNumber], 1)                                                              AS [Dígito conta corrente]
													,[Amount]																					AS [Valor]
													,[TID]																						AS [Observação= LOCALPAYMENT ID]
													FROM @TempPayoutBody


				/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
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
