/****** Object:  StoredProcedure [LP_Operation].[ARG_Payout_GALICIA_Bank_Operation_Download]    Script Date: 3/11/2020 11:09:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [LP_Operation].[ARG_Payout_GALICIA_Bank_Operation_Download]
																			(
																				@TransactionMechanism		BIT
																				, @JSON						VARCHAR(MAX)
																			)
AS

--DECLARE	@TransactionMechanism BIT
--SET		@TransactionMechanism = 1
--DECLARE	@JSON VARCHAR(MAX)
--SET		@JSON = '{"PaymentType":2,"idMerchant":"12", "idSubMerchant":"5", "amount":"7000000000000500000"}'
----UPDATE [LP_Operation].[Transaction] SET idStatus = 1 WHERE idProviderPayWayService in (12,4) 


BEGIN

			BEGIN TRY

					/* CONFIG BLOCK: INI */

					DECLARE @idCountry	INT
					SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE Code = 'ARS' AND [Active] = 1 )

					DECLARE @idProvider INT
					SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BGALICIA' AND [idCountry] = @idCountry AND [Active] = 1 )
					
					DECLARE @idPaymentType INT
					SET @idPaymentType = (SELECT [idPaymentType] FROM [LP_Configuration].[PaymentType] WHERE [CatalogValue] = CAST(JSON_VALUE(@JSON, '$.PaymentType') AS VARCHAR(1))  AND [idCountry] = @idCountry  AND [Active] = 1 ) 

					-- DECLARING TABLE WITH SELECTED TICKETS TO DOWNLOAD
					DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
					INSERT INTO @TempTxsToDownload
					SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)

					DECLARE @idProviderPayWayService INT
					SET @idProviderPayWayService = ( SELECT [PPWS].[idProviderPayWayService] 
														FROM [LP_Configuration].[ProviderPayWayServices]		[PPWS]
															INNER JOIN [LP_Configuration].[Provider]			[PR]	ON	[PR].[idProvider]		= [PPWS].[idProvider]
															INNER JOIN [LP_Configuration].[PayWayServices]	[PWS]	ON	[PWS].[idPayWayService] = [PPWS].[idPayWayService]
														WHERE [PR].[Code] = 'BGALICIA' AND [PR].[idCountry] = @idCountry
															AND [PWS].[Code] = 'BANKDEPO' AND [PWS].[idCountry] = @idCountry )

					DECLARE @idTransactionTypeProvider INT
					SET @idTransactionTypeProvider = ( SELECT [idTransactionTypeProvider]
														FROM [LP_Configuration].[TransactionTypeProvider] [TTP]
															INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [TTP].[idTransactionType]
														WHERE [TTP].[idProvider] = @idProvider AND [TT].[Code] = 'PODEPO' AND [TT].[idCountry] = @idCountry )

					DECLARE @TempPayoutBody TABLE
					(
						[idx]						BIGINT	IDENTITY(1, 1)
						, [BeneficiaryName]			VARCHAR(MAX)
						, [LEN_BeneficiaryName]		INT
						, [BeneficiaryCuit]			VARCHAR(MAX)
						, [LEN_BeneficiaryCuit]		INT
						, [AvailibityDate]			VARCHAR(MAX)
						, [LEN_AvailibityDate]		INT
						, [CreditAccountType]		VARCHAR(MAX)
						, [LEN_CreditAccountType]	INT
						, [CreditCurrency]			VARCHAR(MAX)
						, [LEN_CreditCurrency]		INT
						, [CreditAccount]			VARCHAR(MAX)
						, [LEN_CreditAccount]		INT
						, [CBU]						VARCHAR(MAX)
						, [LEN_CBU]					INT
						, [TransactionCode]			VARCHAR(MAX)
						, [LEN_TransactionCode]		INT
						, [PayType]					VARCHAR(MAX)
						, [LEN_PayType]				INT
						, [Amount]					VARCHAR(MAX)
						, [LEN_Amount]				INT
						, [Legend]					VARCHAR(MAX)
						, [LEN_Legend]				INT
						, [InternalDescription]		VARCHAR(MAX)
						, [LEN_InternalDescription]	INT
						, [ProcessDate]				VARCHAR(MAX)
						, [LEN_ProcessDate]			INT
						, [ConceptCode]				VARCHAR(MAX)
						, [LEN_ConceptCode]			INT
						, [CommercePay]				VARCHAR(MAX)
						, [LEN_CommercePay]			INT
						, [FillerBody]				VARCHAR(MAX)
						, [LEN_FillerBody]			INT

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

					DECLARE @GaliciaBankCode [LP_Common].[LP_F_C3]
					SET @GaliciaBankCode = (SELECT RIGHT([Code], 3) FROM [LP_Configuration].[BankCode] WHERE [Code] = '00007' AND [idCountry] = 1)

					INSERT INTO @TempPayoutBody ([BeneficiaryName], [LEN_BeneficiaryName], [BeneficiaryCuit], [LEN_BeneficiaryCuit], [AvailibityDate], [LEN_AvailibityDate], [CreditAccountType], [LEN_CreditAccountType],
												[CreditCurrency], [LEN_CreditCurrency], [CreditAccount], [LEN_CreditAccount], [CBU], [LEN_CBU], [TransactionCode], [LEN_TransactionCode], [PayType], [LEN_PayType], [Amount], [LEN_Amount],
												[Legend], [LEN_Legend], [InternalDescription], [LEN_InternalDescription], [ProcessDate], [LEN_ProcessDate], [ConceptCode], [LEN_ConceptCode], [CommercePay], [LEN_CommercePay], [FillerBody],
												[LEN_FillerBody], [idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
					SELECT
							[BeneficiaryName]			= LEFT([TRD].[Recipient] + '                ', 16)
						, [LEN_BeneficiaryName]		= DATALENGTH(LEFT([TRD].[Recipient] + '                ', 16))
						, [BeneficiaryCuit]			= [TRD].[RecipientCUIT]
						, [LEN_BeneficiaryCuit]		= DATALENGTH([TRD].[RecipientCUIT])
						, [AvailibityDate]			= CASE WHEN [TRD].[TransactionAcreditationDate] < GETDATE() THEN CONVERT(VARCHAR(8), GETDATE(), 112) ELSE CONVERT(VARCHAR(8), [TRD].[TransactionAcreditationDate], 112) END
						, [LEN_AvailibityDate]		= DATALENGTH(CONVERT(VARCHAR(8), [TRD].[TransactionAcreditationDate], 112))
						, [CreditAccountType]		= 
													CASE
														WHEN [BAT].[Code] IN('C') THEN 'C'
														WHEN [BAT].[Code] IN('A') THEN 'A'
													END
						, [LEN_CreditAccountType]	= 
													CASE
														WHEN [BAT].[Code] IN('C') THEN DATALENGTH('C')
														WHEN [BAT].[Code] IN('A') THEN DATALENGTH('A')
													END
						, [CreditCurrency]			=
													CASE
														WHEN [CT].[Code] IN('ARS') THEN '1'
														WHEN [CT].[Code] IN('USD') THEN '2'
													END
						, [LEN_CreditCurrency]		=
													CASE
														WHEN [CT].[Code] IN('ARS') THEN DATALENGTH('1')
														WHEN [CT].[Code] IN('USD') THEN DATALENGTH('2')
													END
						, [CreditAccount]			=	'000000000000'
													/*CASE
														WHEN LEFT([TRD].[CBU], 3) = @GaliciaBankCode THEN RIGHT('00000000000' + [TRD].[RecipientAccountNumber], 12)
														ELSE '000000000000'
													END*/
						, [LEN_CreditAccount]		=	DATALENGTH('000000000000')
													/*CASE
														WHEN LEFT([TRD].[CBU], 3) = @GaliciaBankCode THEN DATALENGTH(RIGHT('00000000000' + [TRD].[RecipientAccountNumber], 12))
														ELSE DATALENGTH('000000000000')
													END*/
						, [CBU]						=	RIGHT('00000000000000000000000000' +  [LP_Common].[fnGetCBUGaliciaBankFormat]([TRD].[CBU]), 26)
													/*CASE
														WHEN LEFT([TRD].[CBU], 3) = @GaliciaBankCode THEN '00000000000000000000000000'
														ELSE RIGHT('00000000000000000000000000' +  [LP_Common].[fnGetCBUGaliciaBankFormat]([TRD].[CBU]), 26)
													END*/
						, [LEN_CBU]					=	DATALENGTH(RIGHT('00000000000000000000000000' + [LP_Common].[fnGetCBUGaliciaBankFormat]([TRD].[CBU]), 26))
													/*CASE
														WHEN LEFT([TRD].[CBU], 3) = @GaliciaBankCode THEN DATALENGTH('00000000000000000000000000')
														ELSE DATALENGTH(RIGHT('00000000000000000000000000' + [LP_Common].[fnGetCBUGaliciaBankFormat]([TRD].[CBU]), 26))
													END*/
						, [TransactionCode]			= '32'
						, [LEN_TransactionCode]		= DATALENGTH('32')
						, [PayType]					= [PT].[CatalogValue]
						, [LEN_PayType]				= DATALENGTH([PT].[CatalogValue])
						, [Amount]					= RIGHT('00000000000000' + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(20)), '.', ''), ',', ''), 14)
						, [LEN_Amount]				= DATALENGTH(RIGHT('00000000000000' + REPLACE(REPLACE(CAST([T].[GrossValueLP] AS VARCHAR(20)), '.', ''), ',', ''), 14))
/*
						, [Legend]					= LEFT([ESM].[SubMerchantIdentification] + '               ', 15)
						, [LEN_Legend]				= DATALENGTH(LEFT([ESM].[SubMerchantIdentification] + '               ', 15))
*/
						, [Legend]					= LEFT('               ', 15)
						, [LEN_Legend]				= DATALENGTH(LEFT('               ', 15))
						, [InternalDescription]		= LEFT([T2].[Ticket] + '                      ' , 22)
						, [LEN_InternalDescription]	= DATALENGTH(LEFT([T2].[Ticket] + '                      ' , 22))
						, [ProcessDate]				= CONVERT(VARCHAR(8), [T].[TransactionDate], 112)
						, [LEN_ProcessDate]			= DATALENGTH(CONVERT(VARCHAR(8), [T].[TransactionDate], 112))
						, [ConceptCode]				= RIGHT('00' + isnull([TRD].[ConceptCode],''), 2)
						, [LEN_ConceptCode]			= DATALENGTH(RIGHT('  ' + isnull([TRD].[ConceptCode],''), 2))
						, [CommercePay]				= '  '
						, [LEN_CommercePay]			= DATALENGTH('  ')
						, [FillerBody]				= '         '
						, [LEN_FillerBody]			= DATALENGTH('         ')
						, [idTransactionLot]		= [TL].[idTransactionLot]
						, [idTransaction]			= [T].[idTransaction]
						, [DecimalAmount]			= [TD].[NetAmount]
						, [ToProcess]				= 0
					FROM
						[LP_Operation].[Transaction]									[T]
							INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]		= [TL].[idTransactionLot]
							INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]			= [TRD].[idTransaction]
							INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]			= [TD].[idTransaction]
							INNER JOIN	[LP_Operation].[TransactionFromTo]				[TFT]	ON	[T].[idTransaction]			= [TFT].[IdTransaction]
							INNER JOIN	[LP_Configuration].[PaymentType]				[PT]	ON	[TRD].[idPaymentType]		= [PT].[idPaymentType]
							INNER JOIN	[LP_Configuration].[CurrencyType]				[CT]	ON	[T].[CurrencyTypeLP]		= [CT].[idCurrencyType]
							INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]	= [BAT].[idBankAccountType]
							INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]			= [T2].[idTransaction]
							INNER JOIN	[LP_Common].[Status]							[S]		ON	[T].[idStatus]				= [S].[idStatus]
							INNER JOIN  [LP_Configuration].[TransactionTypeProvider]	[TTP]	ON	[TTP].[idTransactionTypeProvider] = [T].[idTransactionTypeProvider]
							LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]		= [T].[idTransaction]
							LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant] = [TESM].[idEntitySubMerchant]
							INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]
					WHERE
						[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
						AND [TD].[NetAmount] > 0
						AND [TTP].[idTransactionType] = 2
					ORDER BY [T].[TransactionDate] ASC


					--UPDATE LP_Operation.[Transaction]
					--SET
					--	[idTransactionMechanism] = @idTransactionMechanism
					--WHERE [idTransaction] IN(SELECT [idTransaction] FROM @TempPayoutBody)


			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempPayoutBody
				SET [LineComplete] = [BeneficiaryName] + [BeneficiaryCuit] + [AvailibityDate] + [CreditAccountType] + [CreditCurrency] + [CreditAccount] + [CBU] +
									[TransactionCode] +	[PayType] + [Amount] + [Legend] + [InternalDescription] + [ProcessDate] + [ConceptCode] + [CommercePay] + [FillerBody]

			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* HEADER BLOCK: INI */

					DECLARE @Header VARCHAR(MAX)

					DECLARE @FileType VARCHAR(3)
					SET @FileType = '*P2'

					DECLARE @BusinessCode VARCHAR(6)
					--SET @BusinessCode = RIGHT('000000' + 'LOCALP', 6) /* Completar con 0 (ceros) a la izquierda. */
					SET @BusinessCode = '023052'

					DECLARE @CUIT VARCHAR(11)
					SET @CUIT = '30716132028'

					DECLARE @AccountType VARCHAR(1)
					SET @AccountType = RIGHT(' ' + 'C', 1) /* A: Caja de Ahorro | C: Cuenta Corriente ==> de no informar completar con espacios. */

					DECLARE @CurrencyTypeAccount VARCHAR(1)
					SET @CurrencyTypeAccount = '1' /* 1: $ (ARS) | 2: U$S (Dólar). */

					DECLARE @DebitAccount VARCHAR(12)
					--SET @DebitAccount = RIGHT('000000000000' + '', 12) /* En formato BGBA. De no informar, completar con ceros. */
					SET @DebitAccount ='000833661753'

					DECLARE @DebitCBU VARCHAR(26)
					SET @DebitCBU = RIGHT('00000000000000000000000000' + '', 26) /* Cuenta débito en formato CBU. De no informar completar con ceros. */

					DECLARE @TotalAmount VARCHAR(14)
					SET @TotalAmount = RIGHT('00000000000000' + (SELECT CAST(SUM(CAST([Amount] AS BIGINT)) AS VARCHAR(14)) FROM @TempPayoutBody), 14) /* Importe total: 12 enteros y 2 decimales. */

					DECLARE @MinimunAvailibityDate VARCHAR(8)
					SET @MinimunAvailibityDate = (SELECT MIN([AvailibityDate]) FROM @TempPayoutBody) /* Mínima fecha de disponibilidad de los pagos informados, en formato: AAAAMMDD. */

					DECLARE @FillerHeader VARCHAR(68)
					SET @FillerHeader = '                                                                    '


					SET @Header = @FileType + @BusinessCode + @CUIT + @AccountType + @CurrencyTypeAccount + @DebitAccount + @DebitCBU + @TotalAmount + @MinimunAvailibityDate + @FillerHeader

			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* FOOTER BLOCK: INI */

					DECLARE @Footer VARCHAR(MAX)

					DECLARE @RowType VARCHAR(2)
					SET @RowType = '*F' /* Valor Fijo. */

					DECLARE @QtyRows VARCHAR(7)
					DECLARE @QtyLine INT
					SET @QtyLine = (SELECT COUNT(*) FROM @TempPayoutBody)
					SET @QtyRows = RIGHT('0000000' + CAST(@QtyLine AS VARCHAR(7)), 7) /* Cantidad total de registros, completar con ceros a la izquierda. */

					DECLARE @FillerFooter VARCHAR(135)
					SET @FillerFooter = '                                                                                                                                       '

					SET @Footer = @RowType + @BusinessCode + @QtyRows + @FillerFooter

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


			/* TRACKING TRANSACTIONS DATES BLOCK: INI*/

					--DECLARE @Lots TABLE
					--(
					--	[IDX]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1)
					--	, [idLot]		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL
					--)

					--INSERT INTO @Lots ([idLot])
					--SELECT DISTINCT [idTransactionLot] FROM @TempPayoutBody

					--DECLARE @qtyLots INT, @lotIDX INT

					--SET @qtyLots = (SELECT COUNT([idLot]) FROM @Lots)
					--SET @lotIDX = 1

					--WHILE(@lotIDX <= @qtyLots)
					--BEGIN
					--	DECLARE @LoteNum [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
					--	SET @LoteNum = (SELECT [idLot] FROM @Lots WHERE [IDX] = @lotIDX)

					--	EXEC [LP_Operation].[Tracking_Init] @LoteNum

					--	SET @lotIDX = @lotIDX + 1
					--END	

			/*  TRACKING TRANSACTIONS DATES BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* SELECT FINAL BLOCK: INI */

					DECLARE @Rows INT
					SET @Rows = ((SELECT COUNT(*) FROM @TempPayoutBody))

					IF(@Rows > 0)
					BEGIN
						SELECT [Line] FROM @Lines ORDER BY [idLine] ASC
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



GO


