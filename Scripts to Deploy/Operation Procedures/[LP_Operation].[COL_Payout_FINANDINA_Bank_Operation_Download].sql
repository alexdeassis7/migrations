
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [LP_Operation].[COL_Payout_FINANDINA_Bank_Operation_Download]
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
                SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'FINANDINA' AND [Active] = 1 )

                DECLARE @idBank	INT
                SET @idBank = ( SELECT [idBankCode] FROM [LP_Configuration].[BankCode] WHERE [Code] = '1019' AND [idCountry] = @idCountry AND [Active] = 1 )

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

                DECLARE @TempLoteHeader TABLE (
                    idLoteHeader		INT IDENTITY(1,1),
                    RecordType  		VARCHAR(1) DEFAULT '1',
                    Filler       		VARCHAR(4) DEFAULT '0000',
                    ProcessDate		    VARCHAR(8),
                    SecuencialNumRec	VARCHAR(6) DEFAULT '000001',
                    AccountType		    VARCHAR(1) DEFAULT '1',
                    AccountNumber		VARCHAR(10),
                    Filler2             VARCHAR(155) DEFAULT REPLICATE('0', 155),
                    LineComplete		VARCHAR(MAX)
                )

                DECLARE @TempLoteFooter TABLE(
                    idLoteFooter		INT IDENTITY(1,1),
                    RecordType  		VARCHAR(1) DEFAULT '3',
                    Filler       		VARCHAR(4) DEFAULT '9999',
                    CantOfRecords	    VARCHAR(4),
                    TotalAmount         VARCHAR(17),
                    Filler2             VARCHAR(159) DEFAULT REPLICATE('0', 159),
                    LineComplete		VARCHAR(MAX)
                )

                DECLARE @TempRegDetalle TABLE(
                    idTempRegDetalle	        INT IDENTITY(1,1),
                    RecordType  		        VARCHAR(1) DEFAULT '2',
                    SecuencialNumRec	        VARCHAR(4),
                    BeneficiaryDocType	        VARCHAR(3),
                    BeneficiaryNIT              VARCHAR(11),
                    BeneficiaryFirstName		VARCHAR(70),
                    BeneficiaryLastName 		VARCHAR(70),
                    CompanyName          		VARCHAR(140),
                    BeneficiaryAccount	        VARCHAR(17),
                    BeneficiaryAccType	        VARCHAR(1),
                    BeneficiaryBank	            VARCHAR(4),
                    PaymentAmount		        VARCHAR(17),
                    TicketNumber		        VARCHAR(30) DEFAULT SPACE(30),
                    Reference2		            VARCHAR(30) DEFAULT SPACE(30),

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

                INSERT INTO @TempRegDetalle ([BeneficiaryDocType], [BeneficiaryNIT], [BeneficiaryFirstName], [BeneficiaryLastName], [CompanyName], 
                    [BeneficiaryAccount], [BeneficiaryAccType], [BeneficiaryBank], [PaymentAmount], [TicketNumber], [Reference2], 
                    [idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
                SELECT 
                    RIGHT(REPLICATE(' ', 3) + CASE WHEN [EIT].[Name] = 'NIT' THEN 'NIT' ELSE 'CI' END, 3) AS [BeneficiaryDocType],
                    RIGHT(REPLICATE('0', 11) + TRD.RecipientCUIT, 11) AS [BeneficiaryNIT],
                    CASE WHEN [EIT].[Name] != 'NIT' THEN LEFT(UPPER(TRD.Recipient) + SPACE(70), 70) ELSE SPACE(70) END AS [BeneficiaryFirstName],
                    SPACE(70) AS [BeneficiaryLastName],
                    CASE WHEN [EIT].[Name] = 'NIT' THEN LEFT(UPPER(TRD.Recipient) + SPACE(140), 140) ELSE SPACE(140) END AS [CompanyName],
                    LEFT([TRD].[RecipientAccountNumber] + SPACE(17), 17) AS [BeneficiaryAccount],
                    CASE WHEN [BAT].[Code] = 37 THEN '6' ELSE '1' END AS [BeneficiaryAccType],
                    [BC].[Code] AS [BeneficiaryBank],
                    RIGHT(REPLICATE('0', 17) + CAST(REPLACE(CAST(TD.NetAmount as decimal(15,2)), '.', '') AS VARCHAR), 17) AS [PaymentAmount],
                    LEFT(T2.Ticket + SPACE(30), 30) AS [TicketNumber],
                    SPACE(30) AS [Reference2],
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

            /* UPDATE TICKET ALTERNATIVE WITH 10 CHARACTERS FOR SCOTIA SYSTEM BLOCK: INI */

                DECLARE @maxTicket VARCHAR(10)

                DECLARE @nextTicketCalculation BIGINT
                DECLARE @nextTicket VARCHAR(10) 

                DECLARE @NewTicketAlternative VARCHAR(10)
                DECLARE @txnum AS INT

                DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
                    SELECT idTempRegDetalle
                    FROM @TempRegDetalle

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
                                INNER JOIN @TempRegDetalle [TEMP] ON [T].[idTransaction] = [TEMP].[idTransaction]
                        WHERE
                            [TEMP].[idTempRegDetalle] = @txnum

                        UPDATE @TempRegDetalle
                        SET [TicketNumber] = LEFT(@NewTicketAlternative + SPACE(30), 30)
                        WHERE [idTempRegDetalle] = @txnum

                        FETCH NEXT FROM tx_cursor INTO @txnum

                    END
                CLOSE tx_cursor
                DEALLOCATE tx_cursor

			/* UPDATE TICKET ALTERNATIVE WITH 10 CHARACTERS FOR SCOTIA SYSTEM BLOCK: FIN */
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


			/* HEADER AND FOOTER BLOCK: INI */
                DECLARE @LotCount AS INT

                SET @LotCount = 0

                IF @QtyRowsReg > 0
                BEGIN
                    SET @LotCount = @LotCount + 1

                    INSERT INTO @TempLoteHeader ([ProcessDate], [SecuencialNumRec], [AccountNumber])
                    SELECT 
                        FORMAT(@TodayDate, 'yyyyMMdd') AS [ProcessDate],
                        RIGHT('000000' + CAST(@FileControlNumber as VARCHAR), 6) AS [SecuencialNumRec],
                        @LpBankAccountNumber AS [AccountNumber]

                    INSERT INTO @TempLoteFooter ([CantOfRecords],[TotalAmount])
                    SELECT
                        RIGHT('000' + CAST(@QtyRowsReg as VARCHAR), 4) AS [SecuencialNumRec],
                        RIGHT(REPLICATE('0', 17) + CAST(REPLACE(CAST(@TotalAmount as decimal(15,2)), '.', '') AS VARCHAR), 17)  AS [TotalAmount]

                END

                -- LINE
                UPDATE @TempLoteHeader 
                SET [LineComplete] = [RecordType] + [Filler] + [ProcessDate] + [SecuencialNumRec] + [AccountType] + [AccountNumber] + [Filler2]


                UPDATE @TempLoteFooter
                SET [LineComplete] = [RecordType] + [Filler] + [CantOfRecords] + [TotalAmount] + [Filler2]

			
			/* HEADER AND FOOTER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT BLOCK: INI */

				UPDATE @TempRegDetalle 
                SET	[LineComplete] = [RecordType] + [SecuencialNumRec] + [BeneficiaryDocType] + [BeneficiaryNIT] + [BeneficiaryFirstName] + [BeneficiaryLastName] 
                                    + [CompanyName] + [BeneficiaryAccount] + [BeneficiaryAccType] + [BeneficiaryBank] + [PaymentAmount]	
                                    + [TicketNumber] + [Reference2]

			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* INSERT LINES BLOCK: INI */

			-- inserting file header
			INSERT INTO @Lines 
                SELECT [LineComplete] FROM @TempLoteHeader

			-- INSERT INTERNAL TXS
            INSERT INTO @Lines 
                SELECT [LineComplete] FROM @TempRegDetalle

            -- inserting file footer
			INSERT INTO @Lines 
                SELECT [LineComplete] FROM @TempLoteFooter

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
					WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempRegDetalle)

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