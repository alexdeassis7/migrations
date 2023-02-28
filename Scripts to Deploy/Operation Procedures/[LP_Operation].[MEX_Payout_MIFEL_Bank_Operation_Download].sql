SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [LP_Operation].[MEX_Payout_MIFEL_Bank_Operation_Download]
																					(
																						@TransactionMechanism	BIT
																						, @JSON					VARCHAR(MAX)
																					)
AS

--DECLARE @TransactionMechanism BIT
--SET		@TransactionMechanism = 1
--DECLARE @JSON VARCHAR(MAX)
--SET		@JSON = '{"PaymentType":2,"FileCode":null,"idMerchant":"16","idSubMerchant":"16","amount":"200000000000"}'
----UPDATE [LP_Operation].[Transaction] SET idStatus = 1 WHERE idProviderPayWayService = 11 

BEGIN

	BEGIN TRY

			/* CONFIG BLOCK: INI */

			DECLARE @idCountry	INT
			SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = 'MEX' AND [Active] = 1 )

			DECLARE @idProvider	INT
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'MIFEL' AND [Active] = 1 )

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

			DECLARE @FieldSeparator AS CHAR(1) = '|'
			DECLARE @LineEnding AS CHAR(1) = ';'


			CREATE TABLE #TempPayoutBody
			(
				[idx]							INT IDENTITY (1,1)
				, [RegistryType]				VARCHAR(MAX)
				, [BeneficiaryAccount]			VARCHAR(MAX)
				, [Value]						VARCHAR(MAX)
				, [Reference]					VARCHAR(MAX)
				, [AccountConcept]				VARCHAR(MAX)
				, [BeneficiaryConcept]			VARCHAR(MAX)
				, [BeneficiaryPhone]			VARCHAR(MAX)
				, [BeneficiaryEmail]			VARCHAR(MAX)
				, [RFC]							VARCHAR(MAX)
				, [IVA]							VARCHAR(MAX)

				, [LineComplete]				VARCHAR(MAX)
				, [idTransactionLot]			BIGINT NOT NULL
				, [idTransaction]				BIGINT NOT NULL

				, [DecimalAmount]					DECIMAL(18,6) NOT NULL
				, [Acum]							DECIMAL(18,6) NULL
				, [ToProcess]						BIT NOT NULL
			)

			DECLARE @TempPayoutHeader TABLE
			(
				[Description]				VARCHAR(MAX)	
				, [NumberOfTxs]				VARCHAR(MAX)
				, [DebitSummation]			VARCHAR(MAX)
				, [OriginDebitAccount]		VARCHAR(MAX)
				, [PaymentType]				VARCHAR(MAX)
				, [idTransactionLot]		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransaction]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			)

			DECLARE @TempPreRegister TABLE
			(
				[idx]							INT IDENTITY (1,1)
				, [AccountNumber]				VARCHAR(MAX)
				, [BeneficiaryName]				VARCHAR(MAX)
				, [BeneficiaryAlias]			VARCHAR(MAX)
				, [BeneficiaryEmail]			VARCHAR(MAX)
				, [BeneficiaryPhone]			VARCHAR(MAX)
				, [MaxAmount]					VARCHAR(MAX)
				, [RegisterType]				CHAR(1)	

				, [LineComplete]				VARCHAR(MAX)
			)


			DECLARE @LinesPayout TABLE
			(
				[idLine]			INT IDENTITY(1,1)
				, [Line]			VARCHAR(MAX)
				, [FileNumber]		INT
				, [Amount]			DECIMAL(18,2)
			)

			DECLARE @LinesPreRegister TABLE
			(
				[idLine]			INT IDENTITY(1,1)
				, [Line]			VARCHAR(MAX)
			)


			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* BODY BLOCK: INI */

			INSERT INTO #TempPayoutBody ([RegistryType], [BeneficiaryAccount], [Value], [AccountConcept], [BeneficiaryConcept], [BeneficiaryPhone], [BeneficiaryEmail], [RFC], [IVA], [idTransactionLot], [idTransaction], [Reference], [DecimalAmount], [ToProcess])
			SELECT
				[RegistryType]					= '20'
				, [BeneficiaryAccount]			= [TRD].[RecipientAccountNumber]
				, [Value]						= CAST(CAST([TD].[NetAmount] AS DECIMAL(13,2)) AS VARCHAR(14))
				, [AccountConcept]				= LEFT([TRD].[Recipient] , 11)
				, [BeneficiaryConcept]			= [T2].[Ticket]
				, [BeneficiaryPhone]			= '5555555555'
				, [BeneficiaryEmail]			= ''
				, [RFC]							= ''
				, [IVA]							= ''
				, [idTransactionLot]			= [TL].[idTransactionLot]
				, [idTransaction]				= [T].[idTransaction]
				, [Reference]					= ''

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
				AND LEFT([TRD].[RecipientAccountNumber], 3) != '042'
			ORDER BY [T].[TransactionDate] ASC

			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */



			/* BENEFICIARIES BLOCK: INI */

			INSERT INTO @TempPreRegister ([AccountNumber], [MaxAmount], [BeneficiaryName], [BeneficiaryAlias], [BeneficiaryEmail], [BeneficiaryPhone], [RegisterType])
			SELECT

				[AccountNumber]					= [TRD].[RecipientAccountNumber]
				, [MaxAmount]					= '20000000'				
				, [BeneficiaryName]				= LEFT('N'+[TRD].[Recipient], 15)
				, [BeneficiaryAlias]			= CONCAT(LEFT([TRD].[Recipient], 11), RIGHT([TRD].[RecipientAccountNumber], 4)) 
				, [BeneficiaryEmail]			= ''
				, [BeneficiaryPhone]			= '5555555555'
				, [RegisterType]				= 'G'

			FROM
				[LP_Operation].[TransactionRecipientDetail]			[TRD]
				INNER JOIN #TempPayoutBody							[TEMP]	ON	[TEMP].[idTransaction]				= [TRD].[idTransaction]
				INNER JOIN [LP_Operation].[Transaction]				[T]		ON	[T].idTransaction					= [TRD].[idTransaction]
				INNER JOIN [LP_Operation].[TransactionDetail]		[TD]	ON	[TD].idTransaction					= [T].[idTransaction]
				INNER JOIN [LP_Configuration].[BankCode]			[BC]	ON	[BC].[idBankCode]					= [TRD].[idBankCode]
				INNER JOIN [LP_Entity].[EntityIdentificationType]	[EIT]	ON	[EIT].[idEntityIdentificationType]	= [TRD].[idEntityIdentificationType]
				INNER JOIN [LP_Configuration].[BankAccountType]		[BAT]	ON	[BAT].[idBankAccountType]			= [TRD].[idBankAccountType]
			WHERE
				[TD].[NetAmount] > = 0
				
			-- DELETING ACCOUNTS THAT HAVE ALREADY BEEN SENT TO BANK
			DELETE [TPreRegister]
			FROM @TempPreRegister [TPreRegister]
			INNER JOIN LP_Operation.BankPreRegisterBankAccount [PRBA] ON [PRBA].[AccountNumber] = [TPreRegister].[AccountNumber]

			-- SEARCHING ACCOUNTS WITH SAME ALIAS
			DECLARE @PreRegisterDuplicatedAlias AS TABLE (idx INT)

			INSERT INTO @PreRegisterDuplicatedAlias(idx)
			SELECT idx
			FROM @TempPreRegister [TPreRegister]
			INNER JOIN LP_Operation.BankPreRegisterBankAccount [PRBA] ON [PRBA].[AccountAlias] = [TPreRegister].[BeneficiaryAlias]

			-- UPDATE DUPLICATED ALIAS
			UPDATE [TPreRegister]
			SET BeneficiaryAlias = CONCAT(LEFT(BeneficiaryAlias, 13), CAST(RIGHT([TPreRegister].[idx], 2) AS VARCHAR)) 
			FROM @TempPreRegister [TPreRegister]
			INNER JOIN @PreRegisterDuplicatedAlias [PRDA] ON [PRDA].[idx] = [TPreRegister].[idx]

			-- CREATING LOT
			DECLARE @idBankPreRegisterLot INT
			INSERT INTO LP_Operation.[BankPreRegisterLot]([Status])
			VALUES(1)

			SET @idBankPreRegisterLot = SCOPE_IDENTITY()

			-- INSERTING NEW BANK ACCOUNTS TO BE SENT INTO CONTROL TABLE
			INSERT INTO LP_Operation.BankPreRegisterBankAccount(AccountNumber, idBankPreRegisterLot, AccountAlias)
			SELECT AccountNumber, @idBankPreRegisterLot, BeneficiaryAlias
			FROM (
                SELECT  AccountNumber, 
                        BeneficiaryAlias, 
                        ROW_NUMBER() OVER(PARTITION BY AccountNumber ORDER BY [idx]) [RN]
                    FROM @TempPreRegister
              ) a
			WHERE [RN] = 1
			
			-- DELETING DUPLICATED ACCOUNT NUMBER FROM PRE REGISTER ROWS
			DELETE FROM @TempPreRegister
			WHERE [idx] IN (
				SELECT [idx]
				FROM (
					SELECT  AccountNumber, 
							BeneficiaryAlias, 
							idx,
							ROW_NUMBER() OVER(PARTITION BY AccountNumber ORDER BY [idx]) [RN]
					FROM @TempPreRegister
				) a
				WHERE a.[RN] > 1
			)

			UPDATE @TempPreRegister
			SET [LineComplete] = CAST([idx] AS VARCHAR) + @FieldSeparator + '20' + @FieldSeparator + '' + @FieldSeparator + '' + @FieldSeparator + [AccountNumber] + @FieldSeparator + [MaxAmount] + @FieldSeparator + [BeneficiaryName] + @FieldSeparator
									+ [BeneficiaryAlias] + @FieldSeparator + [BeneficiaryEmail] + @FieldSeparator + [BeneficiaryPhone] + @FieldSeparator + [RegisterType] + @LineEnding

			/* BENEFICIARIES BLOCK: FIN */

			/* FILTERING REPEATED / UNIQUE AMOUNTS: INI */
			DECLARE @PayoutFileNumber AS INT = 1

			--WHILE (SELECT COUNT(1) FROM #TempPayoutBody) > 0
			--BEGIN

			--SET @PayoutFileNumber = @PayoutFileNumber + 1
			

			--DECLARE @NotRepeatedAmountRowsSet AS TABLE (Amount DECIMAL(18,2))
			--DECLARE @RepeatedAmountRowsSet AS TABLE (Amount DECIMAL(18,2))
			--DECLARE @UniqueRepeatedAmountRowsSet AS TABLE (idTransaction BIGINT)

			---- GETING UNIQUE AMOUNT TXS
			--INSERT INTO @NotRepeatedAmountRowsSet(Amount)
			--SELECT [TEMP].[DecimalAmount]
			--FROM #TempPayoutBody [TEMP]
			--GROUP BY 
			--	[TEMP].[DecimalAmount]
			--HAVING
			--	COUNT(*) = 1

			---- GETING REPEATED AMOUNT TXS
			--INSERT INTO @RepeatedAmountRowsSet(Amount)
			--SELECT [TEMP].[DecimalAmount]
			--FROM #TempPayoutBody [TEMP]
			--GROUP BY 
			--	[DecimalAmount]
			--HAVING
			--	COUNT(*) > 1

			---- GETTING MIN ID OF REPEATED AMOUNTS
			--INSERT INTO @UniqueRepeatedAmountRowsSet(idTransaction)
			--select min([TEMP].idtransaction)
			--FROM #TempPayoutBody [TEMP]
			--inner join @RepeatedAmountRowsSet rr on rr.Amount = [TEMP].DecimalAmount
			--group by rr.Amount

			--SELECT TEMP.*
			--INTO #TEMP_BACK_PAYOUTS
			--FROM #TempPayoutBody TEMP
			--LEFT JOIN @NotRepeatedAmountRowsSet RR ON RR.Amount = TEMP.DecimalAmount
			--LEFT JOIN @UniqueRepeatedAmountRowsSet UR ON UR.idTransaction = TEMP.idTransaction
			--WHERE RR.Amount IS NULL AND UR.idTransaction IS NULL

			---- DELETING DUPLICATED AMOUNT PAYOUTS
			--DELETE [TEMP]
			--FROM #TempPayoutBody TEMP
			--LEFT JOIN @NotRepeatedAmountRowsSet RR ON RR.Amount = TEMP.DecimalAmount
			--LEFT JOIN @UniqueRepeatedAmountRowsSet UR ON UR.idTransaction = TEMP.idTransaction
			--WHERE RR.Amount IS NULL AND UR.idTransaction IS NULL

			/* FILTERING REPEATED / UNIQUE AMOUNTS: FIN */

			/* UPDATE TICKET ALTERNATIVE WITH 7 CHARACTERS FOR MIFEL SYSTEM BLOCK: INI */

			DECLARE @maxTicket VARCHAR(7)

			DECLARE @nextTicketCalculation BIGINT
			DECLARE @nextTicket VARCHAR(7) 

			DECLARE @NewTicketAlternative VARCHAR(7)
			DECLARE @txnum AS INT

			DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
				SELECT idx
				FROM #TempPayoutBody

			OPEN tx_cursor;

			FETCH NEXT FROM tx_cursor INTO @txnum

			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @maxTicket =  ( SELECT MAX([TicketAlternative7]) FROM [LP_Operation].[Ticket] )
					IF(@maxTicket IS NULL)
					BEGIN
						SET @nextTicket = REPLICATE('0', 7)
					END
					ELSE
					BEGIN
						SET @nextTicketCalculation =   ( SELECT CAST (@maxTicket AS BIGINT)  + 1  )
						SET @nextTicket = ( SELECT CAST (@nextTicketCalculation AS VARCHAR(7)) )
					END

					SET @NewTicketAlternative = RIGHT(REPLICATE('0', 7) + @nextTicket ,7)

						UPDATE [LP_Operation].[Ticket]
						SET
							[TicketAlternative7] = @NewTicketAlternative,
							[DB_UpdDateTime] = GETUTCDATE()
						FROM
							[LP_Operation].[Ticket] [T]
								INNER JOIN #TempPayoutBody [TEMP] ON [T].[idTransaction] = [TEMP].[idTransaction]
						WHERE
							[TEMP].[idx] = @txnum

						UPDATE #TempPayoutBody
						SET [Reference] = @NewTicketAlternative
						WHERE [idx] = @txnum

					FETCH NEXT FROM tx_cursor INTO @txnum
				END

			CLOSE tx_cursor
			DEALLOCATE tx_cursor

			/* UPDATE TICKET ALTERNATIVE WITH 10 CHARACTERS FOR SUPERVIELLE SYSTEM BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE #TempPayoutBody
			SET [LineComplete] = @FieldSeparator + CAST([idx] AS VARCHAR) + @FieldSeparator + [RegistryType] + @FieldSeparator + '' + @FieldSeparator + [BeneficiaryAccount] + @FieldSeparator + [Value] + @FieldSeparator + 'MXP' + @FieldSeparator 
								+ [AccountConcept] + @FieldSeparator + [BeneficiaryConcept] + @FieldSeparator + [BeneficiaryEmail] + @FieldSeparator + [BeneficiaryPhone] + @FieldSeparator + [RFC] + @FieldSeparator + [IVA] + @FieldSeparator 
								+ [Reference] + @FieldSeparator + @LineEnding

			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* HEADER BLOCK: INI */

			DECLARE @Header VARCHAR(MAX)

			DECLARE @TxsCount VARCHAR(6)
			SET @TxsCount = CONVERT(VARCHAR(6), ( SELECT COUNT (*) FROM #TempPayoutBody ))

			DECLARE @TotalCredits VARCHAR(17)
			SET @TotalCredits = (SELECT CAST(SUM(CAST([DecimalAmount] AS DECIMAL(13,2))) AS VARCHAR(17)) FROM #TempPayoutBody) /* Importe total: 15 enteros y 2 decimales. */

			DECLARE @PaymentType VARCHAR(15)
			SET @PaymentType = 'Transfers'

			DECLARE @DebitAccount VARCHAR(15)
			SET @DebitAccount = '01600525782'

			DECLARE @Description VARCHAR(20) --I: Inmediata, M: Medio Dia, N: Noche
			SET @Description = 'Pago proveedor'

			SET @Header = @FieldSeparator + @TxsCount + @FieldSeparator + @TotalCredits + @FieldSeparator + @PaymentType + @FieldSeparator + @DebitAccount + @FieldSeparator + @Description + @LineEnding

			/* HEADER BLOCK: FIN */

			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */



			
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* INSERT LINES BLOCK: INI */

			INSERT INTO @LinesPayout(Line, FileNumber) VALUES(@Header, @PayoutFileNumber)

			INSERT INTO @LinesPayout(Line,FileNumber,Amount)
			SELECT [LineComplete], @PayoutFileNumber, DecimalAmount FROM #TempPayoutBody

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
				WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM #TempPayoutBody)

				UPDATE	[LP_Operation].[Transaction]
				SET		[idStatus] = @idStatus
						,[idProviderPayWayService] = @idProviderPayWayService
						,[idTransactionTypeProvider] = @idTransactionTypeProvider
						,[idLotOut] = @idLotOut
						,[lotOutDate] = GETDATE()
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM #TempPayoutBody)

				UPDATE	[LP_Operation].[TransactionRecipientDetail]
				SET		[idStatus] = @idStatus
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM #TempPayoutBody)

				UPDATE	[LP_Operation].[TransactionDetail]
				SET		[idStatus] = @idStatus
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM #TempPayoutBody)

				UPDATE	[LP_Operation].[TransactionInternalStatus]
				SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM #TempPayoutBody)

			COMMIT TRANSACTION

			/* UPDATE TRANSACTIONS STATUS BLOCK: FIN */

			---- GET BACKED PAYOUTS TO PROCESS
			--TRUNCATE TABLE #TempPayoutBody

			--INSERT INTO #TempPayoutBody([RegistryType], [BeneficiaryAccount], [Value], [Reference], [AccountConcept], [BeneficiaryConcept], [BeneficiaryPhone], [BeneficiaryEmail], [RFC], [IVA], [LineComplete], [idTransactionLot], [idTransaction], [DecimalAmount], [Acum], [ToProcess])
			--SELECT [RegistryType], [BeneficiaryAccount], [Value], [Reference], [AccountConcept], [BeneficiaryConcept], [BeneficiaryPhone], [BeneficiaryEmail], [RFC], [IVA], [LineComplete], [idTransactionLot], [idTransaction], [DecimalAmount], [Acum], [ToProcess]
			--FROM #TEMP_BACK_PAYOUTS

			---- DELETING TEMP TABLE
			--DROP TABLE #TEMP_BACK_PAYOUTS

			--END -- END WHILE

			INSERT INTO @LinesPreRegister
			SELECT [LineComplete] FROM @TempPreRegister

			/* INSERT LINES BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */




			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* SELECT FINAL BLOCK: INI */

			--SELECT DATALENGTH([Line]), * FROM @Lines

			DECLARE @Rows INT
			SET @Rows = ((SELECT COUNT(*) FROM @LinesPayout))

			IF(@Rows > 0)
			BEGIN
				SELECT [FileNumber], [Line], RIGHT('000000' + CAST(@idBankPreRegisterLot AS VARCHAR(6)), 6), [Amount] FROM @LinesPayout ORDER BY [idLine] ASC
				SELECT [Line] FROM @LinesPreRegister ORDER BY [idLine] ASC
			END 

			/* SELECT FINAL BLOCK: FIN */

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE() -- 'INTERNAL ERROR'
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
