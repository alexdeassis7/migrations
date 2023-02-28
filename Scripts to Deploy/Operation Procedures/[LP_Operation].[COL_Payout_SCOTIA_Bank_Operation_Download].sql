
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [LP_Operation].[COL_Payout_SCOTIA_Bank_Operation_Download]
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
                SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'SCOTIACOL' AND [Active] = 1 )

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
                    SecuencialNumRec	VARCHAR(5) DEFAULT '00001',
                    RecordType  		VARCHAR(2) DEFAULT '01',
                    ProcessDate		    VARCHAR(8),
                    AccountNIT		    VARCHAR(11),
                    AccountKey		    VARCHAR(10),
                    CantOfRecords	    VARCHAR(6),
                    MovementType        VARCHAR(1) DEFAULT '2',
                    PaymentOffice		VARCHAR(4),
                    AccountNumber		VARCHAR(12),
                    ValidationResult    VARCHAR(10),
                    LotNumber           VARCHAR(10),
                    RejectionReason     VARCHAR(10),
                    ProcessID           VARCHAR(10),
                    ProcessUser         VARCHAR(10),
                    LineComplete		VARCHAR(MAX)
                )

                DECLARE @TempLoteFooter TABLE(
                    idLoteFooter		INT IDENTITY(1,1),
                    SecuencialNumRec	VARCHAR(5),
                    RecordType  		VARCHAR(2) DEFAULT '03',
                    CantOfRecords	    VARCHAR(6),
                    LineComplete		VARCHAR(MAX)
                )

                DECLARE @TempRegDetalle TABLE(
                    idTempRegDetalle	        INT IDENTITY(1,1),
                    SecuencialNumRec	        VARCHAR(5),
                    RecordType  		        VARCHAR(2) DEFAULT '02',
                    BeneficiaryAccIntNumber   	VARCHAR(12),
                    BeneficiaryNIT              VARCHAR(11),
                    BeneficiaryName		        VARCHAR(40),
                    TransactionCode             VARCHAR(3),
                    MovementType		        VARCHAR(2) DEFAULT '02',
                    PaymentAmount		        VARCHAR(17),
                    TicketNumber                VARCHAR(10),
                    PaymentNumber		        VARCHAR(6),
                    RetentionAmount		        VARCHAR(15),
                    IVAAmount	                VARCHAR(15),
                    PaymentDate                 VARCHAR(8),
                    DebitNoteNumber             VARCHAR(10),
                    DebitNoteAmount             VARCHAR(15),
                    BeneficiaryBank	            VARCHAR(8),
                    BeneficiaryAccount	        VARCHAR(17),
                    BeneficiaryAccType	        VARCHAR(1),
                    BeneficiaryDocType	        VARCHAR(1),
                    Description		            VARCHAR(80) DEFAULT SPACE(80),
                    RejectionReason	            VARCHAR(4) DEFAULT SPACE(4),

                    LineComplete		VARCHAR(MAX), 
                    idTransactionLot	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                    idTransaction  		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                    DecimalAmount		[LP_Common].[LP_F_DECIMAL], 
                    ToProcess			[LP_Common].[LP_F_BOOL]
                )


                DECLARE @LpKeyField AS VARCHAR(10)
                SET @LpKeyField = 'PGLOCPAYME'

                DECLARE @LpBankAccountNumber AS VARCHAR(12)
                SET @LpBankAccountNumber = '004452022234'

                DECLARE @LpBankAccountNIT AS VARCHAR(11)
                SET @LpBankAccountNIT = '09012811556'

                DECLARE @LpPaymentOfficeCode AS VARCHAR(4)
                SET @LpPaymentOfficeCode = '0002'

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

                INSERT INTO @TempRegDetalle ([BeneficiaryAccIntNumber], [BeneficiaryNIT], [BeneficiaryName], [TransactionCode], [PaymentAmount], 
                    [TicketNumber], [PaymentNumber], [RetentionAmount], [IVAAmount], [PaymentDate], [DebitNoteNumber], 
                    [DebitNoteAmount], [BeneficiaryBank], [BeneficiaryAccount], [BeneficiaryAccType], [BeneficiaryDocType], 
                    [idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
                SELECT 
                    CASE WHEN @idBank = [BC].[idBankCode] THEN RIGHT(REPLICATE('0', 12) + [TRD].[RecipientAccountNumber], 12) ELSE REPLICATE('0', 12) END AS [BeneficiaryAccIntNumber],
                    RIGHT(REPLICATE('0', 11) + TRD.RecipientCUIT, 11) AS [BeneficiaryNIT],
                    LEFT(UPPER(TRD.Recipient) + SPACE(40), 40) AS [BeneficiaryName],
                    CASE WHEN @idBank = [BC].[idBankCode] THEN '902' ELSE '911' END AS [TransactionCode],
                    RIGHT(REPLICATE('0', 15) + CAST(REPLACE(CAST(TD.NetAmount as decimal(13,2)), '.', '') AS VARCHAR), 15) AS [PaymentAmount],
                    RIGHT(REPLICATE(' ', 10) + T2.Ticket, 10) AS [TicketNumber],
                    REPLICATE('0', 6) AS [PaymentNumber],
                    REPLICATE('0', 15) AS [RetentionAmount],
                    REPLICATE('0', 15) AS [IVAAmount],
                    FORMAT(@TodayDate, 'ddMMyyyy') AS [PaymentDate],
                    REPLICATE('0', 10) AS [DebitNoteNumber],
                    REPLICATE('0', 15) AS [DebitNoteAmount],
                    [BC].[SubCode2] AS [BeneficiaryBank],
                    CASE WHEN @idBank != [BC].[idBankCode] THEN RIGHT(REPLICATE('0', 17) + [TRD].[RecipientAccountNumber], 17) ELSE REPLICATE('0', 17) END AS [BeneficiaryAccount],
                    CASE WHEN [BAT].[Code] = 37 THEN '2' ELSE '1' END AS [BeneficiaryAccType],
                    CASE WHEN [EIT].[Name] = 'CC' THEN 'C' 
                            WHEN [EIT].[Name] = 'CE' THEN 'E'  
                            WHEN [EIT].[Name] = 'PASS' THEN 'P' 
                            WHEN [EIT].[Name] = 'TI' THEN 'I' 
                            WHEN [EIT].[Name] = 'NIT' THEN 'N' END AS [BeneficiaryDocType],
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
                SET [SecuencialNumRec] = RIGHT(REPLICATE(0, 5) + CAST([idTempRegDetalle]+1 AS VARCHAR), 5)

                DECLARE @QtyRowsReg AS BIGINT = (SELECT COUNT(1) FROM @TempRegDetalle)

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
                        SET [TicketNumber] = LEFT(@NewTicketAlternative + REPLICATE(' ', 10), 10)
                        WHERE [idTempRegDetalle] = @txnum

                        FETCH NEXT FROM tx_cursor INTO @txnum

                    END
                CLOSE tx_cursor
                DEALLOCATE tx_cursor

			/* UPDATE TICKET ALTERNATIVE WITH 10 CHARACTERS FOR SCOTIA SYSTEM BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* HEADER AND FOOTER BLOCK: INI */
					DECLARE @LotCount AS INT

					SET @LotCount = 0

					IF @QtyRowsReg > 0
					BEGIN
						SET @LotCount = @LotCount + 1

						INSERT INTO @TempLoteHeader ([ProcessDate], [AccountNIT], [AccountKey], [CantOfRecords], 
                        [PaymentOffice], [AccountNumber])
						SELECT 
                            FORMAT(@TodayDate, 'ddMMyyyy') AS [ProcessDate],
							@LpBankAccountNIT AS [AccountNIT],
                            @LpKeyField AS [AccountKey],
                            CAST(@QtyRowsReg AS VARCHAR) AS [CantOfRecords],
                            @LpPaymentOfficeCode AS [PaymentOffice],
                            @LpBankAccountNumber AS [AccountNumber]

						INSERT INTO @TempLoteFooter ([SecuencialNumRec],[CantOfRecords])
						SELECT
							RIGHT('00000' + CAST(@QtyRowsReg + 2 as VARCHAR), 5) AS [SecuencialNumRec],
                            RIGHT('000000' + CAST(@QtyRowsReg + 2 as VARCHAR), 6) AS [CantOfRecords]

					END

					-- LINE
					UPDATE @TempLoteHeader 
					SET [LineComplete] = '<ENCABEZADO REGISTRO="' +  [SecuencialNumRec] + '" '+
                                    'TIPO_REGISTRO="'+ [RecordType] + '" ' +
                                    'FECHA_RECIBO="'+ FORMAT(@TodayDate, 'ddMMyyyy') + '" '+
                                    'NIT_CLIENTE="'+ @LpBankAccountNIT + '" '+
                                    'CLAVE="'+ @LpKeyField + '" '+
                                    'REGISTROS_ENVIADOS="'+ RIGHT(REPLICATE('0',6) + CAST(@QtyRowsReg + 2  AS VARCHAR),6) + '" '+
                                    'TIPO_CARGO="'+ [MovementType] + '" '+
                                    'OFICINA_PAGO="'+ @LpPaymentOfficeCode + '" '+
                                    'NUMERO_CUENTA="'+ @LpBankAccountNumber + '" '+
                                    'RESULTADO_VALIDACION="0" '+
                                    'NUMERO_LOTE="0" '+
                                    'MOTIVO_RECHAZO="" '+
                                    'ID_PROCESO="0" '+
                                    'USUARIO=""/>'


					UPDATE @TempLoteFooter
					SET [LineComplete] = '<TOTAL REGISTRO="' +  [SecuencialNumRec] + '" '+
                                    'TIPO_REGISTRO="'+ [RecordType] + '" ' +
                                    'NUMERO_REGISTRO="'+ [CantOfRecords] + '"/>' 

			
			/* HEADER AND FOOTER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT BLOCK: INI */

				UPDATE @TempRegDetalle 
                SET	[LineComplete] = '<REGISTRO REGISTRO="' +  [SecuencialNumRec] + '" '+
                        'TIPO_REGISTRO="'+ [RecordType] + '" ' +
                        'NUMERO_CUENTA="'+ [BeneficiaryAccIntNumber] + '" '+
                        'NIT_BENEFICIARIO="'+ [BeneficiaryNIT] + '" '+
                        'NOMBRE_BENEFICIARIO="'+ [BeneficiaryName] + '" '+
                        'CODIGO_TRANSACCION="'+ [TransactionCode] + '" '+
                        'TIPO_CARGO="'+ [MovementType] + '" '+
                        'VALOR_NETO="'+ [PaymentAmount] + '" '+
                        'NUMERO_FACTURA="'+ [TicketNumber] + '" '+
                        'NUMERO_CONTROL_PAGO="'+ [PaymentNumber] + '" '+
                        'VALOR_RETENCION="'+ [RetentionAmount] + '" '+
                        'VALOR_IVA="'+ [IVAAmount] + '" '+
                        'FECHA_PAGO="'+ [PaymentDate] + '" '+
                        'NUMERO_NOTA_DEBITO="'+ [DebitNoteNumber] + '" '+
                        'VALOR_NOTA_DEBITO="'+ [DebitNoteAmount] + '" '+
                        'CODIGO_BANCO="'+ [BeneficiaryBank] + '" '+
                        'NUMERO_CUENTA_ABONO="'+ [BeneficiaryAccount] + '" '+
                        'CLASE_CUENTA="'+ [BeneficiaryAccType] + '" '+
                        'TIPO_DOCUMENTO="'+ [BeneficiaryDocType] + '" '+
                        'ADENDA="'+ [Description] + '" '+
                        'MOTIVO_RECHAZO="'+ [RejectionReason] + '"/>'

			/* UPDATE PAYOUT BLOCK: FIN */
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


			/* INSERT LINES BLOCK: INI */

            -- init root tag & xml tag
            INSERT INTO @Lines VALUES ('<?xml version="1.0" encoding="ISO-8859-1"?>')
			INSERT INTO @Lines VALUES ('<ROOT>')

			-- inserting file header
			INSERT INTO @Lines 
                SELECT [LineComplete] FROM @TempLoteHeader

			-- INSERT INTERNAL TXS
            INSERT INTO @Lines 
                SELECT [LineComplete] FROM @TempRegDetalle

            -- inserting file footer
			INSERT INTO @Lines 
                SELECT [LineComplete] FROM @TempLoteFooter
            
            -- end root tag
			INSERT INTO @Lines VALUES ('</ROOT>')

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