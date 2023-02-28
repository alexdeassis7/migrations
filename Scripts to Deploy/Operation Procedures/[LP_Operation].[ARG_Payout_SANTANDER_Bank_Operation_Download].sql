CREATE OR ALTER PROCEDURE [LP_Operation].[ARG_Payout_SANTANDER_Bank_Operation_Download]
																			(
																				@TransactionMechanism		BIT
																				, @JSON						VARCHAR(MAX)
																			)
AS
BEGIN

			BEGIN TRY

					/* CONFIG BLOCK: INI */

					DECLARE @idCountry	INT
					SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE Code = 'ARS' AND [Active] = 1 )

					DECLARE @idProvider INT
					SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'SANTAR' AND [idCountry] = @idCountry AND [Active] = 1 )

					-- DECLARING TABLE WITH SELECTED TICKETS TO DOWNLOAD
					DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
					INSERT INTO @TempTxsToDownload
					SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)

					DECLARE @idProviderPayWayService INT
					SET @idProviderPayWayService = ( SELECT [PPWS].[idProviderPayWayService] 
														FROM [LP_Configuration].[ProviderPayWayServices]		[PPWS]
															INNER JOIN [LP_Configuration].[Provider]			[PR]	ON	[PR].[idProvider]		= [PPWS].[idProvider]
															INNER JOIN [LP_Configuration].[PayWayServices]	[PWS]	ON	[PWS].[idPayWayService] = [PPWS].[idPayWayService]
														WHERE [PR].[Code] = 'SANTAR' AND [PR].[idCountry] = @idCountry
															AND [PWS].[Code] = 'BANKDEPO' AND [PWS].[idCountry] = @idCountry )

					DECLARE @idTransactionTypeProvider INT
					SET @idTransactionTypeProvider = ( SELECT [idTransactionTypeProvider]
														FROM [LP_Configuration].[TransactionTypeProvider] [TTP]
															INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [TTP].[idTransactionType]
														WHERE [TTP].[idProvider] = @idProvider AND [TT].[Code] = 'PODEPO' AND [TT].[idCountry] = @idCountry )

					DECLARE @TempPayoutBody TABLE
					(
						[idx]						BIGINT	IDENTITY(1, 1)
						, [RegistryType]			VARCHAR(1)
						, [OperationType]			VARCHAR(1)
						, [Currency]				VARCHAR(1)
						, [ProviderNumber]			VARCHAR(15)
						, [VoucherType]				VARCHAR(2)
						, [VoucherNumber]			VARCHAR(15)
						, [Filler]					VARCHAR(4)
						, [ProviderName]			VARCHAR(30)
						, [ProviderAddress]			VARCHAR(30)
						, [ProviderLocation]		VARCHAR(20)
						, [ZIPPrefix]				VARCHAR(1)
						, [ZIPCode]					VARCHAR(5)
						, [ZIPBlock]				VARCHAR(3)
						, [Filler2]					VARCHAR(1)
						, [Zeros]					VARCHAR(83)
						, [Filler3]					VARCHAR(11)
						, [ProviderCuit]			VARCHAR(11)
						, [Filler4]					VARCHAR(45)
						, [ExtraData]				VARCHAR(18)
						, [ExtraData2]				VARCHAR(15)
						, [ExtraData3]				VARCHAR(15)
						, [Filler5]					VARCHAR(60)
						, [DistributionType]		VARCHAR(3)
						, [DistributionBranch]		VARCHAR(3)
						, [PaycheckType]			VARCHAR(3)
						, [BeneficiaryGrouping]		VARCHAR(1)
						, [CBUCountry]				VARCHAR(4)
						, [CBU]						VARCHAR(26)
						, [EmissionDate]			VARCHAR(8)
						, [PayoutDate]				VARCHAR(8)
						, [Amount]					VARCHAR(15)
						, [PaymentType]				VARCHAR(2)
						, [BeneficiaryDocumentType]	VARCHAR(3)
						, [BeneficiaryDocument]		VARCHAR(11)
						, [DocumentType1]			VARCHAR(3)
						, [DocumentNumber1]			VARCHAR(11)
						, [DocumentType2]			VARCHAR(3)
						, [DocumentNumber2]			VARCHAR(11)
						, [ReceiptType]				VARCHAR(3)
						, [SettlementNumber]		VARCHAR(19)
						, [CUITDigit]				VARCHAR(1)
						, [CUITProduct]				VARCHAR(3)
						, [CUITInstance]			VARCHAR(2)
						, [Filler6]					VARCHAR(1)
						, [BeneficiaryPaycheck]		VARCHAR(60)
						, [Filler7]					VARCHAR(59)

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
					INSERT INTO @TempPayoutBody ([RegistryType], [OperationType], [Currency], [ProviderNumber], [VoucherType], [VoucherNumber], [Filler], [ProviderName], [ProviderAddress], [ProviderLocation], [ZIPPrefix], [ZIPCode], [ZIPBlock]
					, [Filler2], [Zeros], [Filler3], [ProviderCuit], [Filler4], [ExtraData], [ExtraData2], [ExtraData3], [Filler5], [DistributionType], [DistributionBranch], [PaycheckType], [BeneficiaryGrouping], [CBUCountry], [CBU], [EmissionDate], [PayoutDate], [Amount], [PaymentType], [BeneficiaryDocumentType], [BeneficiaryDocument], [DocumentType1], [DocumentNumber1], [DocumentType2]
					, [DocumentNumber2], [ReceiptType], [SettlementNumber], [CUITDigit], [CUITProduct], [CUITInstance], [Filler6], [BeneficiaryPaycheck], [Filler7], [idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
					SELECT
						[RegistryType]				= 'D'
						, [OperationType]			= SPACE(1)
						, [Currency]				= '0'
						, [ProviderNumber]			= LEFT([TRD].[RecipientCUIT] + SPACE(15),15)
						, [VoucherType]				= 'OP'
						, [VoucherNumber]			=  LEFT([T2].[Ticket] + SPACE(15),15)
						, [Filler]					= '0000'
						, [ProviderName]			= LEFT([TRD].[Recipient] + SPACE(30),30)
						, [ProviderAddress]			= SPACE(30)
						, [ProviderLocation]		= SPACE(20)
						, [ZIPPrefix]				= SPACE(1)
						, [ZIPCode]					= '00000'
						, [ZIPBlock]				= SPACE(3)
						, [Filler2]					= SPACE(1)
						, [Zeros]					= '00000000000000000000000000000000000000000000000000000000000000000000000000000000000'
						, [Filler3]					= SPACE(11)
						, [ProviderCuit]			= LEFT([TRD].[RecipientCUIT] + SPACE(11),11)
						, [Filler4]					= SPACE(45)
						, [ExtraData]				= SPACE(18)
						, [ExtraData2]				= SPACE(15)
						, [ExtraData3]				= SPACE(15)
						, [Filler5]					= SPACE(60)
						, [DistributionType]		= '001'
						, [DistributionBranch]		= '001'
						, [PaycheckType]			= SPACE(3)
						, [BeneficiaryGrouping]		= 'N'
						, [CBUCountry]				= '0054'
						, [CBU]						= LEFT('0' + SUBSTRING([TRD].[CBU],1,8) + '000' + SUBSTRING([TRD].[CBU],9,14) + SPACE(22),26)
						, [EmissionDate]			= FORMAT([T].[TransactionDate],'yyyyMMdd')
						, [PayoutDate]				= CASE 
														WHEN [BC].[Code] IN ('00384','00143','00415')  THEN IIF(DATEPART(WEEKDAY, GETDATE()) = 6, FORMAT(GETDATE() + 3, 'yyyyMMdd'), FORMAT(GETDATE() + 1, 'yyyyMMdd'))	--neobanks(wilo, brubank, rebanking)
														ELSE FORMAT(GETDATE(), 'yyyyMMdd')
														END
						, [Amount]					= RIGHT('00000000000000' + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(20)), '.', ''), ',', ''), 15)
						, [PaymentType]				= CASE 
														WHEN [BC].[Code] = '00072'  THEN '50'
														WHEN [BC].[Code] IN ('00384','00143','00415')  THEN '52'	--neobanks(wilo, brubank, rebanking)
														ELSE '57'
														END
						, [BeneficiaryDocumentType]	= SPACE(3)
						, [BeneficiaryDocument]		= '00000000000'
						, [DocumentType1]			= SPACE(3)
						, [DocumentNumber1]			= '00000000000'
						, [DocumentType2]			= SPACE(3)
						, [DocumentNumber2]			= '00000000000'
						, [ReceiptType]				= SPACE(3)
						, [SettlementNumber]		= RIGHT('000000000000000000' + [T2].[Ticket],19) 
						, [CUITDigit]				= '0'
						, [CUITProduct]				= '000'
						, [CUITInstance]			= '00'
						, [Filler6]					= SPACE(1)
						, [BeneficiaryPaycheck]		= SPACE(60)
						, [Filler7]					= SPACE(59)
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
																									AND [BAT].[idCountry]					= @idCountry
							INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]			= [T2].[idTransaction]
							INNER JOIN	[LP_Common].[Status]							[S]		ON	[T].[idStatus]				= [S].[idStatus]
							INNER JOIN	[LP_Configuration].[BankCode]					[BC]    ON	[TRD].[idBankCode]			= [BC].[idBankCode]
							LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]		= [T].[idTransaction]
							LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant] = [TESM].[idEntitySubMerchant]
							INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]
					WHERE
						[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
						AND [TD].[NetAmount] > 0
					ORDER BY [T].[TransactionDate] ASC


			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempPayoutBody
				SET [LineComplete] = [RegistryType] + [OperationType] + [Currency] + [ProviderNumber] + [VoucherType] + [VoucherNumber] + [Filler] + [ProviderName] + [ProviderAddress] + [ProviderLocation] + [ZIPPrefix] + [ZIPCode] + [ZIPBlock] + [Filler2] + [Zeros] + [Filler3] + [ProviderCuit] + [Filler4] + [ExtraData] + [ExtraData2] + [ExtraData3] + [Filler5] + [DistributionType] + [DistributionBranch] + [PaycheckType] + [BeneficiaryGrouping] + [CBUCountry] + [CBU] + [EmissionDate] + [PayoutDate] + [Amount] + [PaymentType] + [BeneficiaryDocumentType] + [BeneficiaryDocument] + [DocumentType1] + [DocumentNumber1] + [DocumentType2] + [DocumentNumber2] + [ReceiptType] + [SettlementNumber] + [CUITDigit] + [CUITProduct] + [CUITInstance] + [Filler6] + [BeneficiaryPaycheck] + [Filler7]

			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* HEADER BLOCK: INI */

					DECLARE @Header VARCHAR(MAX)
					DECLARE @FileNumber VARCHAR(MAX)

					SET @FileNumber = (SELECT ISNULL(MAX([FileControlNumber]),0) + 1 FROM [LP_Operation].[ProviderFileControl] WHERE [idProvider] = @idProvider)

					DECLARE @HeaderType VARCHAR(1)
					,@CompanyCode VARCHAR(MAX)
					,@Channel VARCHAR(MAX)
					,@SendDigit VARCHAR(MAX)
					,@Zeros VARCHAR(MAX)
					,@Empty VARCHAR(MAX)
					,@ConceptCode VARCHAR(MAX)
					,@CuitValidation VARCHAR(MAX)
					,@Filler VARCHAR(MAX)
					
					SELECT
						@HeaderType = 'H'
						,@CompanyCode = '30716132028001001' 
						,@Channel = '007'
						,@SendDigit = RIGHT('00000' + @FileNumber,5)
						,@Zeros = '00000'
						,@Empty = SPACE(2)
						,@ConceptCode = SPACE(5)
						,@CuitValidation = 'S'
						,@Filler = SPACE(611)
					



					SET @Header = @HeaderType + @CompanyCode + @Channel + @SendDigit + @Zeros + @Empty + @ConceptCode + @CuitValidation + @Filler

			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			
			/* FOOTER BLOCK: INI */

					DECLARE @Footer VARCHAR(MAX)

					DECLARE @RowType VARCHAR(1)
							,@ZerosFooter VARCHAR(15)
							,@AmountFooter VARCHAR(15)
							,@QtyFooter VARCHAR(7)
							,@FillerFooter VARCHAR(612)

					DECLARE @QtyLine VARCHAR(7)
							,@AmountPreFooter VARCHAR(15)

					SET @QtyLine = (SELECT COUNT(*) FROM @TempPayoutBody)
					SET @AmountPreFooter = (SELECT SUM(DecimalAmount) FROM @TempPayoutBody)

					SELECT @RowType =  'T'
							,@ZerosFooter = '000000000000000'
							,@AmountFooter = RIGHT('00000000000000' + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount](@AmountPreFooter) AS VARCHAR(20)), '.', ''), ',', ''), 15)
							,@QtyFooter = RIGHT('0000000' + @QtyLine,7)
							,@FillerFooter = SPACE(612)
		
					SET @Footer = @RowType + @ZerosFooter + @AmountFooter + @QtyFooter + @FillerFooter


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
					END
			INSERT INTO [LP_Operation].[ProviderFileControl](idProvider, FileControlNumber)
					VALUES(@idProvider, @FileNumber)
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



