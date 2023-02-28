/****** Object:  StoredProcedure [LP_Operation].[ARG_Payout_SUPERVIELLE_Bank_Operation_Download]    Script Date: 6/25/2020 6:23:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



alter PROCEDURE [LP_Operation].[ARG_Payout_SUPERVIELLE_Bank_Operation_Download]
																				(
																					@TransactionMechanism		BIT
																					, @JSON						VARCHAR(MAX)
																				)
AS

--DECLARE @TransactionMechanism BIT
--SET		@TransactionMechanism = 1
--DECLARE @JSON VARCHAR(MAX)
--SET		@JSON = '{"PaymentType":2,"idMerchant":"12", "idSubMerchant":"5", "amount":999999999999999999}'
----UPDATE [LP_Operation].[Transaction] SET idStatus = 1 WHERE idProviderPayWayService in (12,4) 

BEGIN

	BEGIN TRY
			/* CONFIG BLOCK: INI */

			DECLARE @idCountry	INT
			SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'ARS' AND [Active] = 1 )

			DECLARE @idProvider INT
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BSPVIELLE' AND [idCountry] = @idCountry AND [Active] = 1 )

			-- DECLARING TABLE WITH SELECTED TICKETS TO DOWNLOAD
			DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
			INSERT INTO @TempTxsToDownload
			SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)

			DECLARE @idProviderPayWayService INT
			SET @idProviderPayWayService = ( SELECT [PPWS].[idProviderPayWayService] 
												FROM [LP_Configuration].[ProviderPayWayServices]		[PPWS]
													INNER JOIN [LP_Configuration].[Provider]			[PR]	ON	[PR].[idProvider]		= [PPWS].[idProvider]
													INNER JOIN [LP_Configuration].[PayWayServices]		[PWS]	ON	[PWS].[idPayWayService] = [PPWS].[idPayWayService]
												WHERE [PR].[Code] = 'BSPVIELLE' AND [PR].[idCountry] = @idCountry
													AND [PWS].[Code] = 'BANKDEPO' AND [PWS].[idCountry] = @idCountry )

			DECLARE @idTransactionTypeProvider INT
			SET @idTransactionTypeProvider = ( SELECT [idTransactionTypeProvider]
													FROM [LP_Configuration].[TransactionTypeProvider]	[TTP]
														INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [TTP].[idTransactionType]
													WHERE [TTP].[idProvider] = @idProvider 
														AND [TT].[Code] = 'PODEPO' AND [TT].[idCountry] = @idCountry )


			DECLARE @TempPayoutBody TABLE
			(
				[idx]								INT IDENTITY (1,1)
				,[RecordType]						VARCHAR(MAX)
				, [LEN_RecordType]					INT
				, [PayOrderNumber]					VARCHAR(MAX)
				, [LEN_PayOrderNumber]				INT
				, [CheckNumber]						VARCHAR(MAX)
				, [LEN_CheckNumber]					INT
				, [Amount]							VARCHAR(MAX)
				, [LEN_Amount]						INT
				, [CrossCheck]						VARCHAR(MAX)
				, [LEN_CrossCheck]					INT
				, [NotToOrder]						VARCHAR(MAX)
				, [LEN_NotToOrder]					INT
				, [PayInstrumentNumber]				VARCHAR(MAX)
				, [LEN_PayInstrumentNumber]			INT
				, [EmisionDate]						VARCHAR(MAX)
				, [LEN_EmisionDate]					INT
				, [PaymentDate]						VARCHAR(MAX)
				, [LEN_PaymentDate]					INT
				, [DeliveryCentreNumber]			VARCHAR(MAX)
				, [LEN_DeliveryCentreNumber]		INT
				, [Market]							VARCHAR(MAX)
				, [LEN_Market]						INT
				, [WhoWithdraws]					VARCHAR(MAX)
				, [LEN_WhoWithdraws]				INT
				, [PayingAccountType]				VARCHAR(MAX)
				, [LEN_PayingAccountType]			INT
				, [PayingAccountBranchNumber]		VARCHAR(MAX)
				, [LEN_PayingAccountBranchNumber]	INT
				, [PayingAccountNumber]				VARCHAR(MAX)
				, [LEN_PayingAccountNumber]			INT
				, [GroupedWithholdings]				VARCHAR(MAX)
				, [LEN_GroupedWithholdings]			INT
				, [1st_Signer_DocType]				VARCHAR(MAX)
				, [LEN_1stSigner_DocType]			INT
				, [1st_Signer_DocNumber]			VARCHAR(MAX)
				, [LEN_1stSigner_DocNumber]			INT
				, [1stSigner_Position]				VARCHAR(MAX)
				, [LEN_1stSigner_Position]			INT
				, [2ndSigner_DocType]				VARCHAR(MAX)
				, [LEN_2ndSigner_DocType]			INT
				, [2ndSigner_DocNumber]				VARCHAR(MAX)
				, [LEN_2ndSigner_DocNumber]			INT
				, [2ndSigner_Position]				VARCHAR(MAX)
				, [LEN_2ndSigner_Position]			INT
				, [3rdSigner_DocType]				VARCHAR(MAX)
				, [LEN_3rdSigner_DocType]			INT
				, [3rdSigner_DocNumber]				VARCHAR(MAX)
				, [LEN_3rdSigner_DocNumber]			INT
				, [3rdSigner_Position]				VARCHAR(MAX)
				, [LEN_3rdSigner_Position]			INT
				, [4thSigner_DocType]				VARCHAR(MAX)
				, [LEN_4thSigner_DocType]			INT
				, [4thSigner_DocNumber]				VARCHAR(MAX)
				, [LEN_4thSigner_DocNumber]			INT
				, [4thSigner_Position]				VARCHAR(MAX)
				, [LEN_4thSigner_Position]			INT
				, [RetentionSigner_DocType]			VARCHAR(MAX)
				, [LEN_RetentionSigner_DocType]		INT
				, [RetentionSigner_DocNumber]		VARCHAR(MAX)
				, [LEN_RetentionSigner_DocNumber]	INT
				, [RetentionSigner_Position]		VARCHAR(MAX)
				, [LEN_RetentionSigner_Position]	INT

				--Beneficaries Data
				, [BeneficiaryCBU]					VARCHAR(MAX)
				, [LEN_BeneficiaryCBU]				INT
				, [PaymentDescription]				VARCHAR(MAX)
				, [LEN_PaymentDescription]			INT
				, [BeneficiaryCUIT]					VARCHAR(MAX)
				, [LEN_BeneficiaryCUIT]				INT
				, [BeneficiaryName]					VARCHAR(MAX)
				, [LEN_BeneficiaryName]				INT
				, [PersonType]						VARCHAR(MAX)
				, [LEN_PersonType]					INT
				, [Street]							VARCHAR(MAX)
				, [LEN_Street]						INT
				, [AddressNumber]					VARCHAR(MAX)
				, [LEN_AddressNumber]				INT
				, [Floor]							VARCHAR(MAX)
				, [LEN_Floor]						INT
				, [ZipCode]							VARCHAR(MAX)
				, [LEN_ZipCode]						INT
				, [City]							VARCHAR(MAX)
				, [LEN_City]						INT
				, [ProvinceNumber]					VARCHAR(MAX)
				, [LEN_ProvinceNumber]				INT
				, [CountryNumber]					VARCHAR(MAX)
				, [LEN_CountryNumber]				INT
				, [TelephoneNumber]					VARCHAR(MAX)
				, [LEN_TelephoneNumber]				INT
				, [GrossIncomeNumber]				VARCHAR(MAX)
				, [LEN_GrossIncomeNumber]			INT
				, [Email]							VARCHAR(MAX)
				, [LEN_Email]						INT

				, [LineComplete]					VARCHAR(MAX)
				, [idTransactionLot]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransaction]					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

				, [NormalTicket]					[LP_Common].[LP_F_C150]

				, [DecimalAmount]					[LP_Common].[LP_F_DECIMAL]
				, [Acum]							[LP_Common].[LP_F_DECIMAL] NULL
				, [ToProcess]						[LP_Common].[LP_F_BOOL]
			)

			DECLARE @Lines TABLE
			(
				[idLine]			INT IDENTITY(1,1)
				, [Line]			VARCHAR(MAX)
			)

			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* BODY BLOCK: INI */

			INSERT INTO @TempPayoutBody ( [RecordType], [LEN_RecordType], [PayOrderNumber], [LEN_PayOrderNumber], [CheckNumber], [LEN_CheckNumber], [Amount], [LEN_Amount], [CrossCheck], [LEN_CrossCheck], [NotToOrder], [LEN_NotToOrder], [PayInstrumentNumber],
										[LEN_PayInstrumentNumber], [EmisionDate], [LEN_EmisionDate], [PaymentDate], [LEN_PaymentDate], [DeliveryCentreNumber], [LEN_DeliveryCentreNumber], [Market], [LEN_Market], [WhoWithdraws],
										[LEN_WhoWithdraws], [PayingAccountType], [LEN_PayingAccountType], [PayingAccountBranchNumber], [LEN_PayingAccountBranchNumber], [PayingAccountNumber], [LEN_PayingAccountNumber], [GroupedWithholdings],
										[LEN_GroupedWithholdings], [1st_Signer_DocType], [LEN_1stSigner_DocType], [1st_Signer_DocNumber], [LEN_1stSigner_DocNumber], [1stSigner_Position], [LEN_1stSigner_Position], [2ndSigner_DocType], [LEN_2ndSigner_DocType],
										[2ndSigner_DocNumber], [LEN_2ndSigner_DocNumber], [2ndSigner_Position], [LEN_2ndSigner_Position], [3rdSigner_DocType], [LEN_3rdSigner_DocType], [3rdSigner_DocNumber], [LEN_3rdSigner_DocNumber], [3rdSigner_Position],
										[LEN_3rdSigner_Position], [4thSigner_DocType], [LEN_4thSigner_DocType], [4thSigner_DocNumber], [LEN_4thSigner_DocNumber], [4thSigner_Position], [LEN_4thSigner_Position], [RetentionSigner_DocType],
										[LEN_RetentionSigner_DocType], [RetentionSigner_DocNumber], [LEN_RetentionSigner_DocNumber], [RetentionSigner_Position], [LEN_RetentionSigner_Position], [BeneficiaryCBU], [LEN_BeneficiaryCBU], [PaymentDescription],
										[LEN_PaymentDescription], [BeneficiaryCUIT], [LEN_BeneficiaryCUIT], [BeneficiaryName], [LEN_BeneficiaryName], [PersonType], [LEN_PersonType], [Street], [LEN_Street], [AddressNumber], [LEN_AddressNumber], [Floor],
										[LEN_Floor], [ZipCode], [LEN_ZipCode], [City], [LEN_City], [ProvinceNumber], [LEN_ProvinceNumber], [CountryNumber], [LEN_CountryNumber], [TelephoneNumber], [LEN_TelephoneNumber], [GrossIncomeNumber], [LEN_GrossIncomeNumber],
										[Email], [LEN_Email], [idTransactionLot], [idTransaction], [NormalTicket], [DecimalAmount], [ToProcess])
			SELECT

				/*Config account part*/	
				[RecordType]							= '0'
				, [LEN_RecordType]						= 1
				, [PayOrderNumber]						= '          '
				, [LEN_PayOrderNumber]					= 10
				, [CheckNumber]							= '0000000000'
				, [LEN_CheckNumber]						= 10
				, [Amount]								= RIGHT('0000000000000000' + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(20)), '.', ''), ',', ''), 16)	   
				, [LEN_Amount]							= 16
				, [CrossCheck]							= '0'
				, [LEN_CrossCheck]						= 1
				, [NotToOrder]							= '0'
				, [LEN_NotToOrder]						= 1
				, [PayInstrumentNumber]					= '00007' --Transferencia Inmediata = 00007
				, [LEN_PayInstrumentNumber]				= 5
				, [EmisionDate]							= ( SELECT CONVERT(VARCHAR, GETDATE(), 112) )
				, [LEN_EmisionDate]						= 8
				, [PaymentDate]							= ( SELECT CONVERT(VARCHAR, GETDATE(), 112) )
				, [LEN_PaymentDate]						= 8
				, [DeliveryCentreNumber]				= '00000'	
				, [LEN_DeliveryCentreNumber]			= 5
				, [Market]							    = '00'
				, [LEN_Market]							= 2
				, [WhoWithdraws]						= ' ' 
				, [LEN_WhoWithdraws]					= 1
				, [PayingAccountType]					= '01' --01: CC, 02: CA
				, [LEN_PayingAccountType]				= 2
				, [PayingAccountBranchNumber]			= '281'
				, [LEN_PayingAccountBranchNumber]		= 3
				, [PayingAccountNumber]					= '03876690003'
				, [LEN_PayingAccountNumber]				= 11
				, [GroupedWithholdings]					= '0'
				, [LEN_GroupedWithholdings]				= 1

				/*Signers part*/
				, [1st_Signer_DocType]					= '34'				/* 34 = CUIL */
				, [LEN_1stSigner_DocType]				= 2
				, [1st_Signer_DocNumber]				= '020313031447'   /* CUIL DE EZEQUIEL ISRAEL (Firmante de la Cuenta) */
				, [LEN_1stSigner_DocNumber]				= 12
				, [1stSigner_Position]					= 'Gerente                                           ' 
				, [LEN_1stSigner_Position]				= 50
				, [2ndSigner_DocType]					= '  '
				, [LEN_2ndSigner_DocType]				= 2
				, [2ndSigner_DocNumber]					= '            '
				, [LEN_2ndSigner_DocNumber]				= 12
				, [2ndSigner_Position]					= '                                                  '
				, [LEN_2ndSigner_Position]				= 50
				, [3rdSigner_DocType]					= '  '
				, [LEN_3rdSigner_DocType]				= 2
				, [3rdSigner_DocNumber]					= '            '
				, [LEN_3rdSigner_DocNumber]				= 12
				, [3rdSigner_Position]					= '                                                  '
				, [LEN_3rdSigner_Position]				= 50
				, [4thSigner_DocType]					= '  '
				, [LEN_4thSigner_DocType]				= 2
				, [4thSigner_DocNumber]					= '            '
				, [LEN_4thSigner_DocNumber]				= 12
				, [4thSigner_Position]					= '                                                  '
				, [LEN_4thSigner_Position]				= 50

				/*Retentions Signer*/
				, [RetentionSigner_DocType]				= '34'				/* 34 = CUIL */
				, [LEN_RetentionSigner_DocType]			= 2
				, [RetentionSigner_DocNumber]			= '020313031447'    /* CUIL DE EZEQUIEL ISRAEL (Firmante de la Cuenta) */
				, [LEN_RetentionSigner_DocNumber]		= 12
				, [RetentionSigner_Position]			= 'Gerente                                           '
				, [LEN_RetentionSigner_Position]		= 50

				/*Beneficaries Data*/
				, [BeneficiaryCBU]						= LEFT([TRD].[CBU] + '                         ', 25) 
				, [LEN_BeneficiaryCBU]					= 25
				, [PaymentDescription]                  = LEFT(ISNULL([TRD].[Description], '') + '                                                                                                                                                                                                        ', 200)
				, [LEN_PaymentDescription]				= 200
				, [BeneficiaryCUIT]						= RIGHT('00000000000' + [TRD].[RecipientCUIT], 11)
				, [LEN_BeneficiaryCUIT]					= 11
				, [BeneficiaryName]						= LEFT([TRD].[Recipient] + '                                             ', 45)
				, [LEN_BeneficiaryName]					= 45
				, [PersonType]							= ' '
				, [LEN_PersonType]						= 1
				, [Street]								= '                              '
				, [LEN_Street]							= 30
				, [AddressNumber]						= '     '
				, [LEN_AddressNumber]					= 5
				, [Floor]								= '          '
				, [LEN_Floor]							= 10						
				, [ZipCode]								= '01407'
				, [LEN_ZipCode]							= 5					
				, [City]								= '                    '
				, [LEN_City]							= 20
				, [ProvinceNumber]						= '01'
				, [LEN_ProvinceNumber]					= 2
				, [CountryNumber]						= '080'  /* Argentina */
				, [LEN_CountryNumber]					= 3
				, [TelephoneNumber]						= '01144444444    '
				, [LEN_TelephoneNumber]					= 15
				, [GrossIncomeNumber]					= '99999999999' 
				, [LEN_GrossIncomeNumber]				= 11
				, [Email]								= LEFT(ISNULL([TCI].[Email], '') + '                                                  ', 50)
				, [LEN_Email]							= 50

				, [idTransactionLot]					= [TL].[idTransactionLot]
				, [idTransaction]						= [T].[idTransaction]

				, [NormalTicket]						= [T2].[Ticket]

				, [DecimalAmount]						= [TD].[NetAmount]
				, [ToProcess]							= 0

			FROM
				[LP_Operation].[Transaction]												[T]
					INNER JOIN	[LP_Operation].[TransactionLot]								[TL]	ON	[T].[idTransactionLot]		= [TL].[idTransactionLot]
					INNER JOIN	[LP_Operation].[TransactionRecipientDetail]					[TRD]	ON	[T].[idTransaction]			= [TRD].[idTransaction]
					INNER JOIN	[LP_Operation].[TransactionDetail]							[TD]	ON	[T].[idTransaction]			= [TD].[idTransaction]
					INNER JOIN	[LP_Operation].[TransactionFromTo]							[TFT]	ON	[T].[idTransaction]			= [TFT].[IdTransaction]
					INNER JOIN	[LP_Configuration].[PaymentType]							[PT]	ON	[TRD].[idPaymentType]		= [PT].[idPaymentType]
					INNER JOIN	[LP_Configuration].[CurrencyType]							[CT]	ON	[T].[CurrencyTypeLP]		= [CT].[idCurrencyType]
					INNER JOIN	[LP_Configuration].[BankAccountType]						[BAT]	ON	[TRD].[idBankAccountType]	= [BAT].[idBankAccountType]
					INNER JOIN	[LP_Operation].[Ticket]										[T2]	ON	[T].[idTransaction]			= [T2].[idTransaction]
					INNER JOIN	[LP_Common].[Status]										[S]		ON	[T].[idStatus]				= [S].[idStatus]
					INNER JOIN  [LP_Configuration].[TransactionTypeProvider]	[TTP]	ON	[TTP].[idTransactionTypeProvider] = [T].[idTransactionTypeProvider]
					LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]				[TESM]	ON	[TESM].[idTransaction]		= [T].[idTransaction]
					LEFT JOIN	[LP_Entity].[EntitySubMerchant]								[ESM]	ON	[ESM].[idEntitySubMerchant] = [TESM].[idEntitySubMerchant]
					LEFT JOIN   [LP_CustomerInformation].[TransactionCustomerInfomation]	[TCI]	ON	[TCI].[idTransaction]		= [T].[idTransaction]
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


			/* UPDATE TICKET ALTERNATIVE WITH 10 CHARACTERS FOR SUPERVIELLE SYSTEM BLOCK: INI */

			DECLARE @maxTicket VARCHAR(10)

			DECLARE @nextTicketCalculation BIGINT
			DECLARE @nextTicket VARCHAR(10) 

			DECLARE @NewTicketAlternative VARCHAR(10)
			DECLARE @txnum AS INT

			DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
			  SELECT idx
			  FROM @TempPayoutBody

			OPEN tx_cursor;

			FETCH NEXT FROM tx_cursor INTO @txnum

			WHILE @@FETCH_STATUS = 0
			  BEGIN
						SET @maxTicket =  ( SELECT MAX([TicketAlternative]) FROM [LP_Operation].[Ticket] )
						IF(@maxTicket IS NULL)
						BEGIN
							SET @nextTicket = '0000000000'
						END
						ELSE
						BEGIN
							SET @nextTicketCalculation =   ( SELECT CAST (@maxTicket AS BIGINT)  + 1  )
							SET @nextTicket = ( SELECT CAST (@nextTicketCalculation AS VARCHAR(10)) )
						END

						SET @NewTicketAlternative = RIGHT('0000000000' + @nextTicket ,10)

							UPDATE [LP_Operation].[Ticket]
							SET
								[TicketAlternative] = @NewTicketAlternative,
								DB_UpdDateTime = GETUTCDATE()
							FROM
								[LP_Operation].[Ticket] [T]
									INNER JOIN @TempPayoutBody [TEMP] ON [T].[idTransaction] = [TEMP].[idTransaction]
							WHERE
								[TEMP].[idx] = @txnum

							UPDATE @TempPayoutBody
							SET [PayOrderNumber] = @NewTicketAlternative
							WHERE [idx] = @txnum
					  FETCH NEXT FROM tx_cursor INTO @txnum
				  END

				CLOSE tx_cursor
				DEALLOCATE tx_cursor

			/* UPDATE TICKET ALTERNATIVE WITH 10 CHARACTERS FOR SUPERVIELLE SYSTEM BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempPayoutBody
			SET [LineComplete] = [RecordType] + [PayOrderNumber] + [CheckNumber] + [Amount] + [CrossCheck] + [NotToOrder] + [PayInstrumentNumber] + [EmisionDate] + [PaymentDate] + [DeliveryCentreNumber] + [Market] +
								 [WhoWithdraws] + [PayingAccountType] + [PayingAccountBranchNumber] + [PayingAccountNumber] + [GroupedWithholdings] + [1st_Signer_DocType] + [1st_Signer_DocNumber] + [1stSigner_Position] +
								 [2ndSigner_DocType] + [2ndSigner_DocNumber] + [2ndSigner_Position] + [3rdSigner_DocType] + [3rdSigner_DocNumber] + [3rdSigner_Position] +[4thSigner_DocType] +[4thSigner_DocNumber] +
								 [4thSigner_Position] + [RetentionSigner_DocType] + [RetentionSigner_DocNumber] + [RetentionSigner_Position] + [BeneficiaryCBU] + [PaymentDescription] + [BeneficiaryCUIT] + [BeneficiaryName] +
								 [PersonType] + [Street] + [AddressNumber] + [Floor] + [ZipCode] + [City] + [ProvinceNumber] + [CountryNumber] + [TelephoneNumber] + [GrossIncomeNumber] + [Email]


			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* HEADER BLOCK: INI */

			DECLARE @Header VARCHAR(MAX)

			DECLARE @CuitLP VARCHAR(11)
			SET @CuitLP = '30716132028'

			DECLARE @PaymentArea VARCHAR(3)
			SET @PaymentArea = '001'

			DECLARE @SoftwareVersion VARCHAR(14)
			SET @SoftwareVersion = 'PP-50-20130701'

			DECLARE @CompanyName VARCHAR(19)
			SET @CompanyName = 'LOCALPAYMENT S.R.L.'

			SET @Header =  @CuitLP + @PaymentArea + ';' + @SoftwareVersion + ';' + @CompanyName + ';------' 

			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* CONTROL RECORD BLOCK: INI */

			DECLARE @ControlRecord VARCHAR(MAX)

			DECLARE @RecordType VARCHAR(1)
			SET @RecordType = '3'

			DECLARE @QtyRecords INT
			SET @QtyRecords = (SELECT COUNT(*) FROM @TempPayoutBody)
			DECLARE @Records VARCHAR(9)
			SET @Records = RIGHT('000000000' + CAST(@QtyRecords AS VARCHAR(9)), 9) /* Cantidad total de registros, completar con ceros a la izquierda. */

			DECLARE @TotalAmount VARCHAR(MAX) = RIGHT('00000000000000000000' + (SELECT CAST(SUM(CAST([Amount] AS BIGINT)) AS VARCHAR(20)) FROM @TempPayoutBody), 20)


			SET @ControlRecord = @RecordType + @Records + @TotalAmount 

			/* CONTROL RECORD BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* INSERT LINES BLOCK: INI */

			INSERT INTO @Lines VALUES(@Header)

			INSERT INTO @Lines
			SELECT [LineComplete] FROM @TempPayoutBody

			INSERT INTO @Lines VALUES(@ControlRecord)

			/* INSERT LINES BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* UPDATE TRANSACTIONS STATUS BLOCK: INI */

			DECLARE @idStatus INT
			SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('InProgress')

			BEGIN TRANSACTION

				UPDATE	[LP_Operation].[TransactionLot]
				SET		[idStatus] = @idStatus
				WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM @TempPayoutBody)

				UPDATE	[LP_Operation].[Transaction]
				SET		[idStatus] = @idStatus
						,[idProviderPayWayService] = @idProviderPayWayService
						,[idTransactionTypeProvider] = @idTransactionTypeProvider
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


			/* TRACKING TRANSACTIONS DATES BLOCK: INI */

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

			/* TRACKING TRANSACTIONS DATES BLOCK: FIN */
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


