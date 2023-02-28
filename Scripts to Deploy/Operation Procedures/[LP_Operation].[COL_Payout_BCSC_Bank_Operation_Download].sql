
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [LP_Operation].[COL_Payout_BCSC_Bank_Operation_Download]
																			(
																				@TransactionMechanism		BIT
																				, @JSON						VARCHAR(MAX)
																			)
AS


BEGIN

			BEGIN TRY

                /* CONFIG BLOCK: INI */

                DECLARE @idCountry	INT
                SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'COP' AND [Active] = 1 )

                DECLARE @idProvider INT
                SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BCSC' AND [Active] = 1 )

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

                DECLARE @TempRegDetalle TABLE(
                    idTempRegDetalle	        INT IDENTITY(1,1),
					SecuencialNumRec	        VARCHAR(4),
                    RecordType  		        VARCHAR(1) DEFAULT '6',

                    BeneficiaryAccType	        VARCHAR(2),
                    BeneficiaryAccount	        VARCHAR(17),
                    BeneficiaryBank	            VARCHAR(9),
                    BeneficiaryIdentif          VARCHAR(15),
                    BeneficiaryName		        VARCHAR(22),

                    PaymentAmount		        VARCHAR(12),
                    Description                 VARCHAR(10) DEFAULT 'PROVEEDOR ',
                    TicketNumber		        VARCHAR(30) DEFAULT SPACE(30),
                    
                    IdentfValidation            VARCHAR(2) DEFAULT 'V ',

                    Filler1                     VARCHAR(13) DEFAULT SPACE(13),
                    Filler2                     VARCHAR(27) DEFAULT SPACE(27),

                    LineComplete		VARCHAR(MAX), 
                    idTransactionLot	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                    idTransaction  		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                    DecimalAmount		[LP_Common].[LP_F_DECIMAL], 
                    ToProcess			[LP_Common].[LP_F_BOOL]
                )

                DECLARE @LpBankAccountNumber AS VARCHAR(10)
                SET @LpBankAccountNumber = '9110011577'

                DECLARE @TodayDate as DATETIME
                SET @TodayDate = GETDATE()

                DECLARE @Secuencia AS INT
                SET @Secuencia = 1

                DECLARE @Lines TABLE
                (
                    [idLine]			INT IDENTITY(1,1)
                    , [Line]			VARCHAR(MAX)
                )

                /* CONFIG BLOCK: FIN */
                /* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


                /* BODY BLOCK: INI */

                INSERT INTO @TempRegDetalle ([BeneficiaryAccType], [PaymentAmount], [BeneficiaryAccount], [BeneficiaryBank], [BeneficiaryIdentif], [BeneficiaryName], 
                    [TicketNumber], [idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
                SELECT 
                    CASE WHEN [BC].[Code] = '1551' THEN '52' 
                         WHEN [BC].[Code] = '1151' THEN '52'
                         ELSE 
                            CASE 
								WHEN [BAT].[Code] = 37 THEN '32' 
								ELSE '22' 
							END 
                    END AS [BeneficiaryAccType],
                    RIGHT(REPLICATE('0', 12) + CAST(REPLACE(CAST(TD.NetAmount as decimal(10,2)), '.', '') AS VARCHAR), 12) AS [PaymentAmount],
                    LEFT([TRD].[RecipientAccountNumber] + SPACE(17), 17) AS [BeneficiaryAccount],
                    CASE WHEN [BC].[Code] = '1052' THEN '000010524' 
                         WHEN [BC].[Code] = '1040' THEN '000010401' 
                         WHEN [BC].[Code] = '1032' THEN '000010320' 
                         WHEN [BC].[Code] = '1001' THEN '000010016' 
                         WHEN [BC].[Code] = '1023' THEN '000010236' 
                         WHEN [BC].[Code] = '1062' THEN '000010621' 
                         WHEN [BC].[Code] = '1060' THEN '000010605' 
                         WHEN [BC].[Code] = '1002' THEN '000010029' 
                         WHEN [BC].[Code] = '1007' THEN '000010074' 
                         WHEN [BC].[Code] = '1061' THEN '000010618' 
                         WHEN [BC].[Code] = '1013' THEN '000010139' 
                         WHEN [BC].[Code] = '1009' THEN '000010090' 
                         WHEN [BC].[Code] = '1019' THEN '000010197' 
                         WHEN [BC].[Code] = '1292' THEN '000012920' 
                         WHEN [BC].[Code] = '1283' THEN '000012836' 
                         WHEN [BC].[Code] = '1051' THEN '000010511' 
                         WHEN [BC].[Code] = '1012' THEN '000010126' 
                         WHEN [BC].[Code] = '1058' THEN '000010582' 
                         WHEN [BC].[Code] = '1502' THEN '000015024' 
                         WHEN [BC].[Code] = '1551' THEN '000015516' 
                         WHEN [BC].[Code] = '1151' THEN '000011510' 
                         WHEN [BC].[Code] = '1507' THEN '000015079' 
                         WHEN [BC].[Code] = '1063' THEN '000010634' 
                         WHEN [BC].[Code] = '1014' THEN '000010142' 
                         WHEN [BC].[Code] = '1006' THEN '000010061' 
                         WHEN [BC].[Code] = '0550' THEN '000015503' 
                         WHEN [BC].[Code] = '1076' THEN '000010760' 
                         WHEN [BC].[Code] = '1090' THEN '000010906' 
                         WHEN [BC].[Code] = '1066' THEN '000010663' 
                    END AS [BeneficiaryBank],
                    LEFT(TRD.RecipientCUIT + REPLICATE(' ', 15), 15) AS [BeneficiaryIdentif],
                    LEFT(UPPER(TRD.Recipient) + SPACE(22), 22) AS [BeneficiaryName],
                    
                    LEFT(T2.Ticket + SPACE(30), 30) AS [TicketNumber],

                    [T].idTransactionLot AS [idTransactionLot],
                    [T].idTransaction AS [idTransaction],
                    [TD].[NetAmount] AS [DecimalAmount],
                    0 AS [ToProcess]
                FROM
                    [LP_Operation].[Transaction]									[T]
                        INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]		= [TL].[idTransactionLot]
                        INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]			= [TRD].[idTransaction]
                        INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]			= [TD].[idTransaction]
                        INNER JOIN	[LP_Operation].[TransactionFromTo]				[TFT]	ON	[T].[idTransaction]			= [TFT].[IdTransaction]
                        INNER JOIN	[LP_Configuration].[PaymentType]				[PT]	ON	[TRD].[idPaymentType]		= [PT].[idPaymentType]
                        INNER JOIN	[LP_Configuration].[CurrencyType]				[CT]	ON	[T].[CurrencyTypeLP]		= [CT].[idCurrencyType]
                        INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]	= [BAT].[idBankAccountType]
                                                                                            AND [BAT].[idCountry]			= @idCountry
                        INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]			= [T2].[idTransaction]
                        INNER JOIN	[LP_Common].[Status]							[S]		ON	[T].[idStatus]				= [S].[idStatus]
                        LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]		= [T].[idTransaction]
                        LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant] = [TESM].[idEntitySubMerchant]
                        INNER JOIN  [LP_Configuration].[BankCode]					[BC]	ON	[BC].[idBankCode]			= [TRD].[idBankCode]
                        INNER JOIN	[LP_Entity].[EntityIdentificationType]			[EIT]   ON	[TRD].[idEntityIdentificationType]	= [EIT].[idEntityIdentificationType]
                        INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]
                WHERE
                    [T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
                    AND [TD].[NetAmount] > 0
                ORDER BY [T].[TransactionDate] ASC

			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE SECUENCIAL NUMBER AND GET CANT OF RECORDS : INI */

                UPDATE @TempRegDetalle
                SET [SecuencialNumRec] = RIGHT(REPLICATE(0, 4) + CAST([idTempRegDetalle] AS VARCHAR), 4)

                DECLARE @QtyRowsReg AS BIGINT = (SELECT COUNT(1) FROM @TempRegDetalle)
                DECLARE @TotalAmount AS DECIMAL = (SELECT SUM(DecimalAmount) FROM @TempRegDetalle)

			/* UPDATE SECUENCIAL NUMBER AND GET CANT OF RECORDS: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


            /* GET FILE SEQUENCE NUMBER BLOCK: INI */
				
			DECLARE @FileControlNumber AS BIGINT = NULL
			SELECT @FileControlNumber = MAX(FileControlNumber)
			FROM LP_Operation.[ProviderFileControl]
			WHERE idProvider = @idProvider
			
			IF @FileControlNumber IS NULL
			BEGIN
				SET @FileControlNumber = 1
			END
			ELSE
			BEGIN
				SET @FileControlNumber = @FileControlNumber + 1
			END

			/* GET FILE SEQUENCE NUMBER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* UPDATE PAYOUT BLOCK: INI */

				UPDATE @TempRegDetalle 
                SET	[LineComplete] = [RecordType] + [BeneficiaryAccType] + [PaymentAmount] + [BeneficiaryAccount] + [BeneficiaryBank] + [BeneficiaryIdentif] + [BeneficiaryName] + [IdentfValidation] 
                                    + [Filler1] + [Description] + [TicketNumber] + [Filler2] 

			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* INSERT LINES BLOCK: INI */

			-- INSERT INTERNAL TXS
            INSERT INTO @Lines 
                SELECT [LineComplete] FROM @TempRegDetalle


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

					/*UPDATE	[LP_Operation].[TransactionLot]
					SET		[idStatus] = @idStatus
					WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM @TempRegDetalle)

					UPDATE	[LP_Operation].[Transaction]
					SET		[idStatus] = @idStatus
							 ,[idProviderPayWayService] = @idProviderPayWayService
							 ,[idTransactionTypeProvider] = @idTransactionTypeProvider
							 ,[idLotOut] = @idLotOut
							 ,[lotOutDate] = GETDATE()
					WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempRegDetalle)

					UPDATE	[LP_Operation].[TransactionRecipientDetail]
					SET		[idStatus] = @idStatus
					WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempRegDetalle)

					UPDATE	[LP_Operation].[TransactionDetail]
					SET		[idStatus] = @idStatus
					WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempRegDetalle)

					UPDATE	[LP_Operation].[TransactionInternalStatus]
					SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
					WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempRegDetalle)*/

					-- SAVE PROVIDER FILE CONTROL 
					INSERT INTO [LP_Operation].[ProviderFileControl](idProvider, FileControlNumber)
					VALUES(@idProvider, @FileControlNumber)

				COMMIT TRAN

			/* UPDATE TRANSACTIONS STATUS BLOCK: FIN */


			/* SELECT FINAL BLOCK: INI */

					DECLARE @Rows INT
					SET @Rows = ((SELECT COUNT(*) FROM @Lines))

					IF(@Rows > 0)
					BEGIN
						SELECT [Line] FROM @Lines ORDER BY [idLine] ASC
                        SELECT SUM([LP_Common].[fnConvertDecimalToIntToAmount]([DecimalAmount])) as Total FROM @TempRegDetalle
					END

			/* SELECT FINAL BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN

				--DECLARE @ErrorMessage NVARCHAR(4000) = 'INTERNAL ERROR'
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

GO