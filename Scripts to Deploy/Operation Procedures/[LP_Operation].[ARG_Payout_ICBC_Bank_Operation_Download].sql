
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [LP_Operation].[ARG_Payout_ICBC_Bank_Operation_Download]
																			(
																				@TransactionMechanism		BIT
																				, @JSON						VARCHAR(MAX)
																			)
AS


BEGIN

			BEGIN TRY

                /* CONFIG BLOCK: INI */

                DECLARE @idCountry	INT
                SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = 'ARG' AND [Active] = 1 )

                DECLARE @idProvider INT
                SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'ICBC' AND [idCountry] = @idCountry AND [Active] = 1 )

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
					SecuencialNumRec	        VARCHAR(14),
                    RecordType  		        VARCHAR(4) DEFAULT 'PPV4',

                    BeneficiaryAccType	        VARCHAR(2) DEFAULT '00',
                    BeneficiaryAccShape	        VARCHAR(1) DEFAULT 'C',
                    BeneficiaryAccount	        VARCHAR(22),
                    BeneficiaryIdentifType      VARCHAR(2),
                    BeneficiaryIdentif          VARCHAR(11),
                    BeneficiaryName		        VARCHAR(50),
                    BeneficiaryAddStreet		VARCHAR(30) DEFAULT SPACE(30),
                    BeneficiaryAddNumber		VARCHAR(5) DEFAULT REPLICATE('0',5),
                    BeneficiaryAddress		    VARCHAR(19) DEFAULT SPACE(19),
                    BeneficiaryAddPostalCode	VARCHAR(8) DEFAULT SPACE(8),
                    BeneficiaryAddProvince		VARCHAR(1) DEFAULT SPACE(1),
                    BeneficiaryEmail		    VARCHAR(48) DEFAULT SPACE(48),

                    PaymentType                 VARCHAR(1) DEFAULT('2'),
                    PaymentCurrency             VARCHAR(3) DEFAULT('ARP'),
                    PaymentAmount		        VARCHAR(18),
                    PaymentDate		            VARCHAR(8),
                    TicketNumber		        VARCHAR(12) DEFAULT SPACE(12),

                    Filler1                     VARCHAR(272)    DEFAULT SPACE(272),

                    LineComplete		VARCHAR(MAX), 
                    idTransactionLot	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                    idTransaction  		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                    DecimalAmount		[LP_Common].[LP_F_DECIMAL], 
                    ToProcess			[LP_Common].[LP_F_BOOL]
                )

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

                INSERT INTO @TempRegDetalle ([BeneficiaryAccount], [BeneficiaryIdentifType], [BeneficiaryName], [BeneficiaryIdentif], [PaymentAmount], [PaymentDate], 
                                             [idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
                SELECT 
                    LEFT([TRD].[CBU] + SPACE(22), 22) AS [BeneficiaryAccount],
                    '06' AS [BeneficiaryIdentifType],   --CUIT/CUIL
                    LEFT(UPPER(TRD.Recipient) + SPACE(50), 50) AS [BeneficiaryName],
                    RIGHT(REPLICATE('0', 11) + TRD.RecipientCUIT, 11) AS [BeneficiaryIdentif],
                    RIGHT(REPLICATE('0', 18) + CAST(REPLACE(CAST(TD.NetAmount as decimal(16,2)), '.', '') AS VARCHAR), 15) AS [PaymentAmount],
                    FORMAT(@TodayDate, 'yyyyMMdd') as [PaymentDate],

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
                SELECT idTempRegDetalle
                FROM @TempRegDetalle

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
                                    INNER JOIN @TempRegDetalle [TEMP] ON [T].[idTransaction] = [TEMP].[idTransaction]
                            WHERE
                                [TEMP].[idTempRegDetalle] = @txnum

                            UPDATE @TempRegDetalle
                            SET [TicketNumber] = @NewTicketAlternative
                            WHERE [idTempRegDetalle] = @txnum

                        FETCH NEXT FROM tx_cursor INTO @txnum
                    END

                CLOSE tx_cursor
                DEALLOCATE tx_cursor

			/* UPDATE TICKET ALTERNATIVE WITH 12 CHARACTERS FOR ICBC SYSTEM BLOCK: FIN */
            /* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

            /* UPDATING SEQUENCE NUMBER: INI */  

                DECLARE     @qtyRowsTemp BIGINT
                            , @idxRowsTemp BIGINT

                SET @idxRowsTemp = 1
                SET @qtyRowsTemp = (SELECT COUNT(*) FROM @TempRegDetalle)

                IF(@qtyRowsTemp > 0)
                BEGIN
                    WHILE(@idxRowsTemp <= @qtyRowsTemp)
                    BEGIN
                        UPDATE @TempRegDetalle SET SecuencialNumRec = RIGHT(REPLICATE('0', 14) + CAST(@Secuencia AS VARCHAR), 14) WHERE idTempRegDetalle = @idxRowsTemp
                        SET @Secuencia = @Secuencia + 1

                        SET @idxRowsTemp = @idxRowsTemp + 1
                    END
                END

            /* UPDATING SEQUENCE NUMBER: FIN */
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
                SET	[LineComplete] = [RecordType] + [PaymentType] + [PaymentCurrency] + [PaymentAmount] + [PaymentDate] + [TicketNumber] + [BeneficiaryAccShape] + [BeneficiaryAccType] 
                                    + [BeneficiaryAccount] + [BeneficiaryName] + [BeneficiaryIdentifType] + [BeneficiaryIdentif] + [BeneficiaryAddStreet] + [BeneficiaryAddNumber] + [BeneficiaryAddress] 
                                    + [BeneficiaryAddPostalCode] + [BeneficiaryAddProvince] + [Filler1]

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