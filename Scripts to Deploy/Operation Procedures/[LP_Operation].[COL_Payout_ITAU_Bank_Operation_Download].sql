
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [LP_Operation].[COL_Payout_ITAU_Bank_Operation_Download]
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
                SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'ITAUCOL' AND [Active] = 1 )

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
					SecuencialNumRec	        VARCHAR(5),
                    RecordType  		        VARCHAR(1) DEFAULT '1',

                    BeneficiaryAccType	        VARCHAR(3),
                    BeneficiaryAccount	        VARCHAR(17),
                    BeneficiaryBank	            VARCHAR(3),
                    BeneficiaryIdentifType      VARCHAR(2),
                    BeneficiaryIdentif          VARCHAR(15),
                    BeneficiaryName		        VARCHAR(22),
                    BeneficiaryEmail            VARCHAR(100) DEFAULT SPACE(100),
                    BeneficiaryTelf1            VARCHAR(14) DEFAULT SPACE(14),
                    BeneficiaryTelf2            VARCHAR(14) DEFAULT SPACE(14),
                    BeneficiaryFax              VARCHAR(14) DEFAULT SPACE(14),
                    BeneficiaryAddress          VARCHAR(53) DEFAULT SPACE(53),  -- ADDRESS(40) + COUNTRY (4) + PROVINCE (4) + CITY (5)

                    BankBranch                  VARCHAR(3) DEFAULT SPACE(3),
                    PaymentType                 VARCHAR(2) DEFAULT 'CR',
                    PaymentDate                 VARCHAR(6),
                    PaymentAmount		        VARCHAR(14),
                    Observation                 VARCHAR(80) DEFAULT SPACE(80),
                    TicketNumber		        VARCHAR(20),
                    
                    InternalIdentifType         VARCHAR(2),
                    InternalIdentifNumber       VARCHAR(15),          
                    InternalAccType             VARCHAR(3),
                    InternalAccNumber           VARCHAR(17),
                    
                    OficialSignal               VARCHAR(1) DEFAULT 'N',

                    LineComplete		        VARCHAR(MAX), 
                    idTransactionLot	        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                    idTransaction  		        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                    DecimalAmount		        [LP_Common].[LP_F_DECIMAL], 
                    ToProcess			        [LP_Common].[LP_F_BOOL]
                )

                DECLARE @LpBankAccountNumber AS VARCHAR(17)
                SET @LpBankAccountNumber = '729031389        '

                DECLARE @LpBankIdentifNumber AS VARCHAR(15)
                SET @LpBankIdentifNumber = '9012811556     '

                DECLARE @BasicAddress AS VARCHAR(40)
                SET @BasicAddress = 'CRA 9 NO 115 06 30 PISO17 EDIF TIERRAFIR'

                DECLARE @AddressCountry AS VARCHAR(4)
                SET @AddressCountry = 'COL '

                DECLARE @AddressProvince AS VARCHAR(4)
                SET @AddressProvince = '11  '

                DECLARE @AddressCity AS VARCHAR(5)
                SET @AddressCity = '11001'

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

                INSERT INTO @TempRegDetalle ([BeneficiaryAccType], [PaymentAmount], [BeneficiaryAccount], [BeneficiaryBank], [BeneficiaryIdentifType], [BeneficiaryIdentif], 
                                             [BeneficiaryName], [PaymentDate], [TicketNumber], [InternalAccType], [InternalAccNumber], [InternalIdentifNumber], [InternalIdentifType], 
                                             [BeneficiaryTelf1], [BeneficiaryAddress], [idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
                SELECT 
                    CASE WHEN [BAT].[Code] = 37 THEN 'AHO' ELSE 'CTE' END AS [BeneficiaryAccType],
                    RIGHT(REPLICATE('0', 14) + CAST(REPLACE(CAST(TD.NetAmount as decimal(12,2)), '.', '') AS VARCHAR), 14) AS [PaymentAmount],
                    LEFT([TRD].[RecipientAccountNumber] + SPACE(17), 17) AS [BeneficiaryAccount],
                    '0' + RIGHT([BC].[Code], 2) AS [BeneficiaryBank],
                    CASE WHEN [EIT].[Name] = 'CC' THEN '01'
                         WHEN [EIT].[Name] = 'CE' THEN '02'
                         WHEN [EIT].[Name] = 'NIT' THEN '03'
                         WHEN [EIT].[Name] = 'TI' THEN '04'
                         WHEN [EIT].[Name] = 'PASS' THEN '05'
                         ELSE '00'
                    END AS [BeneficiaryIdentifType],
                    LEFT(TRD.RecipientCUIT + SPACE(15), 15) AS [BeneficiaryIdentif],
                    LEFT(UPPER(TRD.Recipient) + SPACE(22), 22) AS [BeneficiaryName],
                    FORMAT(@TodayDate, 'MMddyy') AS [PaymentDate],
                    
                    LEFT(T2.Ticket + SPACE(20), 20) AS [TicketNumber],
                    'AHO' AS [InternalAccType],
                    @LpBankAccountNumber AS [InternalAccNumber],
                    @LpBankIdentifNumber AS [InternalIdentifNumber],
                    '03' AS [InternalIdentifType],

                    '16398493' + SPACE(6) AS [BeneficiaryTelf1],
                    @BasicAddress + @AddressCountry + @AddressProvince + @AddressCity AS [BeneficiaryAddress],

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
                SET [SecuencialNumRec] = RIGHT(REPLICATE(0, 5) + CAST([idTempRegDetalle] AS VARCHAR), 5)

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
                SET	[LineComplete] = [RecordType] + [SecuencialNumRec] + [PaymentDate] + [BeneficiaryIdentifType] + [BeneficiaryIdentif] + [BeneficiaryName] + [OficialSignal] 
                                    + [BankBranch] + [BeneficiaryBank] + [BeneficiaryAccType] + [BeneficiaryAccount] + [PaymentType] + [PaymentAmount] + [TicketNumber] + [Observation] 
                                    + [BeneficiaryEmail] + [BeneficiaryTelf1] + [BeneficiaryTelf2] + [BeneficiaryFax] + [BeneficiaryAddress] + 
                                    + [InternalIdentifType] + [InternalIdentifNumber] + [InternalAccType] + [InternalAccNumber]

			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* INSERT LINES BLOCK: INI */

			-- INSERT INTERNAL TXS
            INSERT INTO @Lines 
                SELECT [LineComplete] FROM @TempRegDetalle ORDER BY idTempRegDetalle


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