USE [LocalPaymentProd]
GO
/****** Object:  StoredProcedure [LP_Operation].[ARG_Payout_ITAU_Bank_Operation_Download]    Script Date: 05/07/2021 09:15:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER   PROCEDURE [LP_Operation].[ARG_Payout_ITAU_Bank_Operation_Download]
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

					DECLARE @idBank	INT
                	SET @idBank = ( SELECT [idBankCode] FROM [LP_Configuration].[BankCode] WHERE [Code] = '00259' AND [idCountry] = @idCountry AND [Active] = 1 )

					DECLARE @idProvider INT
					SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'ITAU' AND [idCountry] = @idCountry AND [Active] = 1 )

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

					DECLARE @TempRegDetalleA TABLE(
						idTempRegDetalleA	INT IDENTITY(1,1),
                        SecuencialNumRec	VARCHAR(4),
                        RecordType          VARCHAR(1) DEFAULT 'C',
                        ActionType          VARCHAR(1) DEFAULT 'A',
                        BeneficiaryId       VARCHAR(22),
                        BeneficiaryName     VARCHAR(60),
						BeneficiaryDocType	VARCHAR(2),
                        BeneficiaryDocument	VARCHAR(11),
						BeneficiaryNIT		VARCHAR(11),
                        BeneficiaryAccount	VARCHAR(29),
                        AddressStreetName   VARCHAR(30) DEFAULT SPACE(30),
						AddressStreetNumber	VARCHAR(6) DEFAULT REPLICATE('0',6),
						AddressFlatNumber	VARCHAR(6) DEFAULT SPACE(6),
						AddressFlatLetter	VARCHAR(6) DEFAULT SPACE(6),
						AddressPostalCode	VARCHAR(8) DEFAULT SPACE(8),
						PrintCard   		VARCHAR(1) DEFAULT ' ',
						Filler1	    		VARCHAR(92) DEFAULT SPACE(40) + REPLICATE('0',52),
						DistType        	VARCHAR(2) DEFAULT SPACE(2),
						DistOffice		    VARCHAR(4) DEFAULT SPACE(4),
						DocToRequest	    VARCHAR(2) DEFAULT SPACE(2),
						BeneficiaryPhone	VARCHAR(20) DEFAULT SPACE(20),
						BeneficiaryEmail	VARCHAR(100) DEFAULT SPACE(100),
						AddressLocality 	VARCHAR(50) DEFAULT SPACE(50),
						AddressProvince		VARCHAR(50) DEFAULT SPACE(50),
						PaymentDate 		VARCHAR(8),
                        PaymentAmount		VARCHAR(17),
                        TicketNumber		VARCHAR(56),
						FreeSpace1			VARCHAR(30) DEFAULT SPACE(30),
						FreeSpace2			VARCHAR(30) DEFAULT SPACE(30),
						FreeSpace3			VARCHAR(30) DEFAULT SPACE(30),
						Filler2			    VARCHAR(217) DEFAULT SPACE(217),

						idBank				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                        idTransactionLot	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                        idTransaction  		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT], 
                        DecimalAmount		[LP_Common].[LP_F_DECIMAL],

						LineComplete		VARCHAR(MAX)
					)


					DECLARE @TempRegDetalleB TABLE
					(
						idTempRegDetalleB	INT IDENTITY(1,1),
						Recordtype			VARCHAR(1) DEFAULT 'F',
                        PaymentMode         VARCHAR(2),
                        BeneficiaryAccount  VARCHAR(29),
                        PaymentAmount       VARCHAR(17),
                        FreeSpace1          VARCHAR(17) DEFAULT REPLICATE('0',17),
                        PaymentDate         VARCHAR(8),
						EmissionType		VARCHAR(2) DEFAULT '  ',
                        Filler1             VARCHAR(15) DEFAULT SPACE(15),
						PaymentConcept		VARCHAR(3) DEFAULT 'VAR',
                        PaymentRef          VARCHAR(56),
                        Filler2             VARCHAR(650) DEFAULT SPACE(650),
						LineComplete		VARCHAR(MAX)
					)

                    DECLARE @TempRegDetalleC TABLE
					(
						idTempRegDetalleC	INT IDENTITY(1,1),
						Recordtype			VARCHAR(1) DEFAULT 'D',
                        Filler1             VARCHAR(1) DEFAULT 'A',
                        DocumentType        VARCHAR(2) DEFAULT 'OP',
                        DocumentNumber      VARCHAR(22) DEFAULT REPLICATE('0',22),
                        Filler2             VARCHAR(188) DEFAULT SPACE(188),
                        PaymentDate         VARCHAR(8),
                        PaymentAmount       VARCHAR(17),
                        Filler3             VARCHAR(201) DEFAULT SPACE(120) + REPLICATE('0',81),
                        FreeSpace1          VARCHAR(30) DEFAULT SPACE(30),
                        FreeSpace2          VARCHAR(30) DEFAULT SPACE(30),
                        FreeSpace3          VARCHAR(30) DEFAULT SPACE(30),
                        Datanet1            VARCHAR(18) DEFAULT SPACE(18),
                        Datanet2            VARCHAR(15) DEFAULT SPACE(15),
                        Datanet3            VARCHAR(15) DEFAULT SPACE(15),
                        Filler4             VARCHAR(222) DEFAULT SPACE(30) + REPLICATE('0',6) + SPACE(186),
						LineComplete		VARCHAR(MAX)
					)

					DECLARE @LpCUIT VARCHAR(11)
					SET @LpCUIT = '30716132028'

					DECLARE @LPCodigoConvenio AS VARCHAR(20)
					SET @LPCodigoConvenio = SPACE(20)

					DECLARE @LpEMAIL VARCHAR(30)
					SET @LpEMAIL = 'itauargentina@localpayment.com'

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


					INSERT INTO @TempRegDetalleA ([SecuencialNumRec], [BeneficiaryId], [BeneficiaryDocType], [BeneficiaryDocument], [BeneficiaryNIT], [BeneficiaryName], 
                                                 [BeneficiaryAccount], [PaymentAmount], [PaymentDate], [TicketNumber], [BeneficiaryEmail], [idBank], [idTransactionLot], [idTransaction], [DecimalAmount])
					SELECT 
                        ' ' AS [SecuencialNumRec],
                        LEFT('CT' + TRD.RecipientCUIT + SPACE(22), 22) AS [BeneficiaryId],
                        RIGHT('CT', 2) AS [BeneficiaryDocType],
                        RIGHT(REPLICATE('0', 11) + TRD.RecipientCUIT, 11) AS [BeneficiaryDocument],
                        RIGHT(REPLICATE('0', 11) + TRD.RecipientCUIT, 11) AS [BeneficiaryNIT],
                        LEFT(UPPER(TRD.Recipient) + SPACE(60), 60)  AS [BeneficiaryName],
                        LEFT([TRD].[CBU] + SPACE(29), 29) AS [BeneficiaryAccount],
                        RIGHT(REPLICATE('0', 17) + CAST(REPLACE(CAST(TD.NetAmount as decimal(15,2)), '.', '') AS VARCHAR), 17) AS [PaymentAmount],
                        FORMAT(@TodayDate, 'yyyyMMdd') AS [PaymentDate],
                        LEFT(T2.Ticket + SPACE(56), 56) AS [TicketNumber],
						LEFT(@LpEMAIL + SPACE(100), 100) AS [BeneficiaryEmail],
						[BC].idBankCode AS [idBank],
                        [T].idTransactionLot AS [idTransactionLot],
                        [T].idTransaction AS [idTransaction],
                        [TD].[NetAmount] AS [DecimalAmount]
					FROM
						[LP_Operation].[Transaction]									[T]
							INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]		        = [TL].[idTransactionLot]
							INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]			        = [TRD].[idTransaction]
							INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]			        = [TD].[idTransaction]
							INNER JOIN	[LP_Operation].[TransactionFromTo]				[TFT]	ON	[T].[idTransaction]			        = [TFT].[IdTransaction]
							INNER JOIN	[LP_Configuration].[PaymentType]				[PT]	ON	[TRD].[idPaymentType]		        = [PT].[idPaymentType]
							INNER JOIN	[LP_Configuration].[CurrencyType]				[CT]	ON	[T].[CurrencyTypeLP]		        = [CT].[idCurrencyType]
							INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]	        = [BAT].[idBankAccountType]
																								AND [BAT].[idCountry]			        = @idCountry
							INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]			        = [T2].[idTransaction]
							INNER JOIN	[LP_Common].[Status]							[S]		ON	[T].[idStatus]				        = [S].[idStatus]
							LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]		        = [T].[idTransaction]
							LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant]         = [TESM].[idEntitySubMerchant]
							INNER JOIN  [LP_Configuration].[BankCode]					[BC]	ON	[BC].[idBankCode]			        = [TRD].[idBankCode]
							INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]
					WHERE
						[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
						AND [TD].[NetAmount] > 0
					ORDER BY [T].[TransactionDate] ASC

                    INSERT INTO @TempRegDetalleB ([PaymentMode], [BeneficiaryAccount], [PaymentAmount], [PaymentDate], [PaymentRef])
                    SELECT 
						CASE WHEN [TR2].[idBank] = @idBank THEN '14' ELSE '26' END AS [PaymentMode],
                        [TR2].[BeneficiaryAccount] AS [BeneficiaryAccount],
                        [TR2].[PaymentAmount] AS [PaymentAmount],
                        [TR2].[PaymentDate] AS [PaymentDate],
                        [TR2].[TicketNumber] AS [PaymentRef]
                    FROM @TempRegDetalleA [TR2]

                    INSERT INTO @TempRegDetalleC ([DocumentNumber], [Filler2], [PaymentAmount], [PaymentDate])
                    SELECT 
                        [TR2].[PaymentDate] + RIGHT(REPLICATE('0', 14) + CAST([TR2].idTempRegDetalleA + 1 AS VARCHAR), 14) AS [DocumentNumber],
                        '000'+SPACE(185) AS [Filler2],
                        [TR2].[PaymentAmount] AS [PaymentAmount],
                        [TR2].[PaymentDate] AS [PaymentDate]
                    FROM @TempRegDetalleA [TR2]


					/* UPDATING SEQUENCE NUMBER: INI */  

					DECLARE     @qtyRowsTemp BIGINT
						      , @idxRowsTemp BIGINT
                              , @totalAmountTrxTemp VARCHAR(17)

					SET @idxRowsTemp = 1
					SET @qtyRowsTemp = (SELECT COUNT(*) FROM @TempRegDetalleA)
                    SET @totalAmountTrxTemp = (SELECT SUM(DecimalAmount) FROM @TempRegDetalleA)

					IF(@qtyRowsTemp > 0)
					BEGIN
						WHILE(@idxRowsTemp <= @qtyRowsTemp)
						BEGIN
							UPDATE @TempRegDetalleA SET SecuencialNumRec = RIGHT(REPLICATE('0', 4) + CAST(@Secuencia AS VARCHAR), 4) WHERE idTempRegDetalleA = @idxRowsTemp
							SET @Secuencia = @Secuencia + 1

							SET @idxRowsTemp = @idxRowsTemp + 1
						END
					END

					/* UPDATING SEQUENCE NUMBER: FIN */
					/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

					-- LINE
                    
					UPDATE @TempRegDetalleA 
					SET [LineComplete] = [RecordType] + [ActionType] + [BeneficiaryId] + [BeneficiaryName] + [BeneficiaryDocType] + [BeneficiaryDocument] + [BeneficiaryNIT] + 
						                 [AddressStreetName] + [AddressStreetNumber] + [AddressFlatNumber] + [AddressFlatLetter] + [AddressPostalCode] + [PrintCard] + 
						                 [Filler1] + [DistType] + [DistOffice] + [DocToRequest] + [BeneficiaryPhone] + [BeneficiaryEmail] + [AddressLocality] + [AddressProvince] + [PaymentDate] + 
						                 [FreeSpace1] + [FreeSpace2] + [FreeSpace3] + [Filler2]
                    
                    UPDATE @TempRegDetalleB 
					SET [LineComplete] = [Recordtype] + [PaymentMode] + [BeneficiaryAccount] + [PaymentAmount] + [FreeSpace1] + [PaymentDate] + [EmissionType] + 
                                         [Filler1] + [PaymentConcept] + [PaymentRef] + [Filler2]

                    UPDATE @TempRegDetalleC 
					SET [LineComplete] = [Recordtype] + [Filler1] + [DocumentType] + [DocumentNumber] + [Filler2] + [PaymentDate]  + [PaymentAmount] + 
						                 [Filler3] + [FreeSpace1] + [FreeSpace2] + [FreeSpace3] + [Datanet1] + [Datanet2] + [Datanet3] + [Filler4]

			/* BODY BLOCK: FIN */
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
			
            /* HEADER BLOCK: INI */

                DECLARE @Header VARCHAR(MAX)

                DECLARE @HRecordType        AS VARCHAR(1) = 'H'
                DECLARE @HIdentNumber       AS VARCHAR(11) = @LpCUIT
                DECLARE @HProductCode       AS VARCHAR(3) = '700'
                DECLARE @HBankAgreement     AS VARCHAR(6) = '000001'
                DECLARE @HSecuencialNumRec  AS VARCHAR(5) = RIGHT(REPLICATE('0',5) + CAST(@FileControlNumber AS VARCHAR),5)
                DECLARE @HGenerationDate    AS VARCHAR(8) = FORMAT(@TodayDate, 'yyyyMMdd')
                DECLARE @HRefreshDebt       AS VARCHAR(1) = ' '
                DECLARE @HPublishType       AS VARCHAR(1) = 'O'
                DECLARE @HFileType          AS VARCHAR(1) = 'P'
                DECLARE @HFileActInd        AS VARCHAR(1) = ' '
                DECLARE @HFiller            AS VARCHAR(762) = SPACE(762)

                SET @Header = @HRecordType + @HIdentNumber + @HProductCode + @HBankAgreement + @HSecuencialNumRec + @HGenerationDate + @HRefreshDebt + 
                            @HPublishType + @HFileType + @HFileActInd + @HFiller 

			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* FOOTER BLOCK: INI */
					
                DECLARE @Footer VARCHAR(MAX)

                DECLARE @FRecordType         AS VARCHAR(1)   = 'T'
                DECLARE @FIdentNumber        AS VARCHAR(11)  = @LpCUIT
                DECLARE @FProductCode        AS VARCHAR(3)   = '700'
                DECLARE @FBankAgreement      AS VARCHAR(6)   = '000001'
                DECLARE @FSecuencialNumRec   AS VARCHAR(5)   = RIGHT(REPLICATE('0',5) + CAST(@FileControlNumber AS VARCHAR),5)
                DECLARE @FGenerationDate     AS VARCHAR(8)   = FORMAT(@TodayDate, 'yyyyMMdd')
                DECLARE @FFiller             AS VARCHAR(5)   = '00000'
                DECLARE @FTotalAmount        AS VARCHAR(17)  = RIGHT(REPLICATE('0', 17) + REPLACE(REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount](@totalAmountTrxTemp) AS VARCHAR(17)), '.', ''), ',', ''), 17)
                DECLARE @FCantOfRecords      AS VARCHAR(9)   = RIGHT(REPLICATE('0', 9)  + CAST(@qtyRowsTemp * 3 AS VARCHAR), 9)
                DECLARE @FFiller2            AS VARCHAR(744) = SPACE(744)

                SET @Footer = @FRecordType + @FIdentNumber + @FProductCode + @FBankAgreement + @FSecuencialNumRec + @FGenerationDate + 
                              @FFiller + @FTotalAmount + @FCantOfRecords + @FFiller2

			/* FOOTER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* INSERT LINES BLOCK: INI */

            DECLARE @txnum AS INT

			-- inserting file header
			INSERT INTO @Lines VALUES(@Header)

			-- INSERT INTERNAL TXS
			IF(SELECT COUNT(1) FROM @TempRegDetalleA) > 0
			BEGIN

				DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
					SELECT idTempRegDetalleA
					FROM @TempRegDetalleA

				OPEN tx_cursor;

				FETCH NEXT FROM tx_cursor INTO @txnum

				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- INSERTING REG A
					INSERT INTO @Lines
					SELECT [LineComplete] FROM @TempRegDetalleA WHERE [idTempRegDetalleA] = @txnum

					-- INSERTING REG B
					INSERT INTO @Lines
					SELECT [LineComplete]
					FROM @TempRegDetalleB WHERE [idTempRegDetalleB] = @txnum

                    -- INSERTING REG C
					INSERT INTO @Lines
					SELECT [LineComplete]
					FROM @TempRegDetalleC WHERE [idTempRegDetalleC] = @txnum

					FETCH NEXT FROM tx_cursor INTO @txnum
				END

				CLOSE tx_cursor
				DEALLOCATE tx_cursor
			END

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
					WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM @TempRegDetalleA)

					UPDATE	[LP_Operation].[Transaction]
					SET		[idStatus] = @idStatus
							 ,[idProviderPayWayService] = @idProviderPayWayService
							 ,[idTransactionTypeProvider] = @idTransactionTypeProvider
							 ,[idLotOut] = @idLotOut
							 ,[lotOutDate] = GETDATE()
					WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempRegDetalleA)

					UPDATE	[LP_Operation].[TransactionRecipientDetail]
					SET		[idStatus] = @idStatus
					WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempRegDetalleA)

					UPDATE	[LP_Operation].[TransactionDetail]
					SET		[idStatus] = @idStatus
					WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempRegDetalleA)

					UPDATE	[LP_Operation].[TransactionInternalStatus]
					SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
					WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempRegDetalleA)

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