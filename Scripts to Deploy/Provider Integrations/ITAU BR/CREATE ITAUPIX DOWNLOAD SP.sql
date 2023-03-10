USE [LocalPaymentProd]
GO
/****** Object:  StoredProcedure [LP_Operation].[BRA_Payout_ITAUPIX_Bank_Operation_Download]    Script Date: 11/23/2021 7:46:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   PROCEDURE [LP_Operation].[BRA_Payout_ITAUPIX_Bank_Operation_Download]
																			(
																				@TransactionMechanism		BIT
																				, @JSON						VARCHAR(MAX)
																			)
AS


BEGIN

			BEGIN TRY

					/* CONFIG BLOCK: INI */

					DECLARE @idCountry	INT
					SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE Code = 'BRL' AND [Active] = 1 )

					DECLARE @BankCode AS VARCHAR(3)
					SET @BankCode = '341'

					DECLARE @idProvider INT
					SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'ITAUBRPIX' AND [idCountry] = @idCountry AND [Active] = 1 )

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
						CodBanco			VARCHAR(3),
						LoteServicio		VARCHAR(4),
						TipoRegistro		VARCHAR(1) DEFAULT '1',
						TipoOperacion		VARCHAR(1) DEFAULT 'C',
						TipoServicio		VARCHAR(2),
						FormaLanzamiento	VARCHAR(2),
						NroLayoutLote		VARCHAR(3) DEFAULT '040',
						CNAB				VARCHAR(1) DEFAULT ' ',
						TipoSuscripEmpresa	VARCHAR(1),
						NroSuscripEmpresa	VARCHAR(14),
						CodigoConvenio		VARCHAR(20),
						AgMantenimCta		VARCHAR(5),
						DigVerificAgencia	VARCHAR(1),
						NroCtaCorriente		VARCHAR(12),
						DigVerifAgciaCta	VARCHAR(1), -- swapped
						DigVerificCuenta	VARCHAR(1), -- swapped
						NombreEmpresa		VARCHAR(30),
						MensajeInfo1		VARCHAR(40),
						DirEmpresa			VARCHAR(30),
						NumLocal			VARCHAR(5),
						NroDepto			VARCHAR(15),
						Ciudad				VARCHAR(20),
						CEP					VARCHAR(5),
						ComplementoCEP		VARCHAR(3),
						Estado				VARCHAR(2),
						FormaPago			VARCHAR(2),
						CNAB2				VARCHAR(6) DEFAULT SPACE(6),
						CodigoDevolucion	VARCHAR(10),
						LineComplete		VARCHAR(MAX),
						SameBank			BIT
					)

					DECLARE @TempLoteFooter TABLE(
						idLoteFooter		INT IDENTITY(1,1),
						CodBanco			VARCHAR(3),
						LoteServicio		VARCHAR(4),
						TipoRegistro		VARCHAR(1) DEFAULT '5',
						CNAB				VARCHAR(9) DEFAULT SPACE(9),
						CantidadRegistros	VARCHAR(6),
						SumaMontos			VARCHAR(18),
						SumaMonedas			VARCHAR(18),
						NumAvisoDebito		VARCHAR(6),
						CNAB2				VARCHAR(165) DEFAULT SPACE(165),
						CodigoDevolucion	VARCHAR(10),
						LineComplete		VARCHAR(MAX),
						SameBank			BIT
					)

					DECLARE @TempRegDetalleA TABLE(
						idTempRegDetalleA	INT IDENTITY(1,1),
						CodBanco			VARCHAR(3),
						LoteServicio		VARCHAR(4),
						TipoRegistro		VARCHAR(1) DEFAULT '3',
						NroSecuenciaReg		VARCHAR(5),
						CodSegmento			VARCHAR(1) DEFAULT 'A',
						TipoMovimiento		VARCHAR(1),
						CodInstruccion		VARCHAR(2),
						CodCamara			VARCHAR(3),
						CodBancoBenef		VARCHAR(3),
						AgMantenimCta		VARCHAR(5),
						DigVerificAgencia	VARCHAR(1),
						NroCtaCorriente		VARCHAR(12),
						DigVerifAgciaCta	VARCHAR(1),
						DigVerificCuenta	VARCHAR(1),
						NombreBenef			VARCHAR(30),
						DocDeEmpresa		VARCHAR(20),
						DataDePago			VARCHAR(8),
						TipoMoneda			VARCHAR(3),
						MontoMoneda			VARCHAR(15),
						MontoPago			VARCHAR(15),
						DocDeBanco			VARCHAR(20),
						FechaEfectiva		VARCHAR(8),
						MontoPagoReal		VARCHAR(15),
						Informacion			VARCHAR(40),
						CodTipoServicio		VARCHAR(2),
						CodTED				VARCHAR(5),
						CodComplementario	VARCHAR(2),
						CNAB				VARCHAR(3) DEFAULT SPACE(3),
						AvisoBenef			VARCHAR(1),
						CodigoDevolucion	VARCHAR(10),
						idTransaction		BIGINT,
						DecimalAmount		DECIMAL(13,2),
						ToProcess			BIT DEFAULT 1,
						LineComplete		VARCHAR(MAX)
					)


					DECLARE @LpCUIT VARCHAR(11)
					SET @LpCUIT = '30716132028'

					DECLARE @LPBankBranch AS VARCHAR(5)
					SET @LPBankBranch = '06393'

					DECLARE @LPBankAccountNumber AS VARCHAR(12)
					SET @LPBankAccountNumber = '000000021730'

					DECLARE @LPBankAccountVerifier AS CHAR(1)
					SET @LPBankAccountVerifier = '9'

					DECLARE @LPCodigoConvenio AS VARCHAR(20)
					SET @LPCodigoConvenio = SPACE(20)

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


					INSERT INTO @TempRegDetalleA ([CodBanco], [LoteServicio], [NroSecuenciaReg], [TipoMovimiento], [CodInstruccion], 
						[CodCamara], [CodBancoBenef], [AgMantenimCta], [DigVerificAgencia], [NroCtaCorriente], [DigVerifAgciaCta], [DigVerificCuenta], 
						[NombreBenef], [DocDeEmpresa], [DataDePago], [TipoMoneda], [MontoMoneda], [MontoPago], 
						[DocDeBanco], [FechaEfectiva], [MontoPagoReal], [Informacion], [CodTipoServicio], [CodTED], [CodComplementario], 
						[AvisoBenef], [CodigoDevolucion], [idTransaction], [DecimalAmount])
					SELECT 
						@BankCode AS [CodBanco], --341
						'0001' AS [LoteServicio], -- batch number -> always 0001
												-- the register type was set by default to 3 before
						'' AS [NroSecuenciaReg], -- record number -> starts at 00001 and increases, is set below
												-- segment code set by default to A before
						'0' AS [TipoMovimiento], -- for itau this is a 3 digit number
						'00' AS [CodInstruccion], -- completes the movement type above for itau
						'009' AS [CodCamara], -- 009 for PIX
						[BC].[Code] AS [CodBancoBenef],  -- recipient bank code, should be taken from queried table
						RIGHT(REPLICATE('0', 5) + LEFT([TRD].[BankBranch], 4), 5) AS [AgMantenimCta], -- branch receiver
						' ' AS [DigVerificAgencia], -- space
						RIGHT(REPLICATE('0', 12) + LEFT(REPLACE(REPLACE(REPLACE(REPLACE([TRD].[RecipientAccountNumber],'.',''), '-', ''),'X','0'),'/',''), LEN(REPLACE(REPLACE(REPLACE(REPLACE([TRD].[RecipientAccountNumber],'.',''), '-', ''),'X','0'),'/','')) -1), 12) AS [NroCtaCorriente], -- account receiver
						' ' AS [DigVerifAgciaCta], -- space
						RIGHT(REPLACE([TRD].[RecipientAccountNumber], 'X', '0'), 1) AS [DigVerificCuenta], -- receiver DAC
						LEFT(TRD.Recipient + SPACE(30), 30) AS [NombreBenef], -- recipient name
						LEFT(TRD.RecipientCUIT + SPACE(20), 20) AS [DocDeEmpresa], -- arbitrary number given by us
						FORMAT(@TodayDate, 'ddMMyyyy') AS [DataDePago], -- today's date
						'REA' AS [TipoMoneda], -- REAL
						'        0100000' AS [MontoMoneda], -- ISPB (empty) + Transfer type (PIX) + zeros
						RIGHT(REPLICATE('0', 15) + CAST(REPLACE(CAST(TD.NetAmount as decimal(13,2)), '.', '') AS VARCHAR), 15) AS [MontoPago], -- payment amount
						SPACE(20) AS [DocDeBanco], -- document number attributed by bank + 5 blank spaces
						REPLICATE('0', 8) AS [FechaEfectiva], -- only in return statement
						REPLICATE('0', 15) AS [MontoPagoReal], -- only in return statement
						CONCAT(SPACE(20),'000000',RIGHT('00000000000000' + [TRD].RecipientCUIT, 14)) AS [Informacion], -- THIS SHOULD BE 20 spaces + 6 zeros + CNPJ (14) --[TRD].
						'07' AS [CodTipoServicio], -- purpose of doc: payment to suppliers
						'00010' AS [CodTED], -- purpose of ted -> 00010 = Credited to Current Account or Savings Account (left it for PIX because it worked like this)
						SPACE(2) AS [CodComplementario], -- spaces
												-- default as 3 spaces
						'0' AS [AvisoBenef], -- notice to recipient
						SPACE(10) AS [CodigoDevolucion], -- spaces
						[T].idTransaction AS [idTransaction],
						[TD].[NetAmount] AS [DecimalAmount]
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
							INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]
					WHERE
						[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
						AND [TD].[NetAmount] > 0
					ORDER BY [T].[TransactionDate] ASC

					DECLARE @IterationI AS BIGINT = 1
					DECLARE @QtyRowsReg2 AS BIGINT = (SELECT COUNT(1) FROM @TempRegDetalleA)
					DECLARE @idRegDetalleATemp AS BIGINT


					/* UPDATING SEQUENCE NUMBER: INI */  -- record number is set here

					DECLARE
						@qtyRowsTemp BIGINT
						, @idxRowsTemp BIGINT

					SET @idxRowsTemp = 1
					SET @qtyRowsTemp = (SELECT COUNT(*) FROM @TempRegDetalleA)

					IF(@qtyRowsTemp > 0)
					BEGIN
						WHILE(@idxRowsTemp <= @qtyRowsTemp)
						BEGIN
							UPDATE @TempRegDetalleA SET NroSecuenciaReg = RIGHT(REPLICATE('0', 5) + CAST(@Secuencia AS VARCHAR), 5) WHERE idTempRegDetalleA = @idxRowsTemp
							SET @Secuencia = @Secuencia + 1

							SET @idxRowsTemp = @idxRowsTemp + 1
						END
					END
					/* UPDATING SEQUENCE NUMBER: FIN */
					/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


					/* UPDATE TICKET ALTERNATIVE WITH 10 CHARACTERS FOR SUPERVIELLE SYSTEM BLOCK: INI */

					DECLARE @maxTicket VARCHAR(10)

					DECLARE @nextTicketCalculation BIGINT
					DECLARE @nextTicket VARCHAR(10) 

					DECLARE @NewTicketAlternative VARCHAR(10)
					DECLARE @txnum AS INT

					DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
					  SELECT idTempRegDetalleA
					  FROM @TempRegDetalleA

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
									INNER JOIN @TempRegDetalleA [TEMP] ON [T].[idTransaction] = [TEMP].[idTransaction]
							WHERE
								[TEMP].[idTempRegDetalleA] = @txnum

							UPDATE @TempRegDetalleA
							SET [DocDeEmpresa] = LEFT(@NewTicketAlternative + REPLICATE(' ', 20), 20)
							WHERE [idTempRegDetalleA] = @txnum

							FETCH NEXT FROM tx_cursor INTO @txnum

					  END
					CLOSE tx_cursor
					DEALLOCATE tx_cursor

			/* UPDATE TICKET ALTERNATIVE WITH 10 CHARACTERS FOR SUPERVIELLE SYSTEM BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

					DECLARE @LotCount AS INT

					SET @LotCount = 0

					IF (SELECT COUNT(1) FROM @TempRegDetalleA WHERE [CodBancoBenef] = @BankCode ) > 0
					BEGIN
						SET @LotCount = @LotCount + 1

						INSERT INTO @TempLoteHeader ([CodBanco], [LoteServicio], [TipoServicio], [FormaLanzamiento], [TipoSuscripEmpresa], 
						[NroSuscripEmpresa], [CodigoConvenio], [AgMantenimCta], [DigVerificAgencia], [NroCtaCorriente], 
						[DigVerifAgciaCta], [DigVerificCuenta], [NombreEmpresa], [MensajeInfo1], [DirEmpresa], [NumLocal], 
						[NroDepto], [Ciudad], [CEP], [ComplementoCEP], [Estado], [FormaPago], [CodigoDevolucion], [SameBank])
						SELECT 
							@BankCode AS [CodBanco], -- Bank code
							RIGHT('000' + CAST(@LotCount as VARCHAR), 4) AS [LoteServicio], -- shouldn't this be 0001?
													-- type of record, set by default as 1
													-- type of transaction, set by default as C
							'20' AS [TipoServicio], -- type of payment: 20 -> suppliers
							'45' AS [FormaLanzamiento], -- 45: pix transfer
														-- layout version, set to 040 by default
														-- space set by default
							'2' AS [TipoSuscripEmpresa], -- 2 = cnpj
							'34669130000133' AS [NroSuscripEmpresa], -- cnpj LP
							@LPCodigoConvenio AS [CodigoConvenio], -- codigo convenio set as 20 blanks before (doesn't exist in rendimento)
							@LPBankBranch AS [AgMantenimCta], -- LP bank branch
							' ' AS [DigVerificAgencia], -- blank
							@LPBankAccountNumber AS [NroCtaCorriente], -- account
							' ' AS [DigVerifAgciaCta], -- blank
							@LPBankAccountVerifier AS [DigVerificCuenta], -- DAC
							'Local Paym                    ' AS [NombreEmpresa], -- name
							SPACE(40) AS [MensajeInfo1],     -- batch purpose + current account history (both blank)
							'RUA JOSE PAULINO              ' AS [DirEmpresa], -- company address
							'00229' AS [NumLocal],            -- location number 
							LEFT('SALA 401' + SPACE(15), 15) AS [NroDepto], -- supplement
							LEFT('CAMPINAS' + SPACE(20), 20) AS [Ciudad], -- city
							'13026' AS [CEP],                 --  postal code
							'515' AS [ComplementoCEP],        --  postal code
							'SP' AS [Estado],                 --  state
															  --  6 blanks set by default
							'  ' AS [FormaPago],              --  blank for itau
							SPACE(10) AS [CodigoDevolucion],   --  blank for itau
							1 -- same bank

						INSERT INTO @TempLoteFooter (CodBanco, LoteServicio, CantidadRegistros, SumaMontos, SumaMonedas, NumAvisoDebito, CodigoDevolucion, SameBank)
						SELECT
							@BankCode AS [CodBanco],  -- bank code
							RIGHT('000' + CAST(@LotCount as VARCHAR), 4) AS [LoteServicio], -- batch code -> shouldn't this be 0001?
																								-- type of record set to 5 by default
																								-- 9 spaces by default
							RIGHT('000000' + CAST((COUNT(1)) + 2 AS VARCHAR), 6) AS [CantidadRegistros], -- quantity of records
							RIGHT(REPLICATE('0', 18) + REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount](SUM(DecimalAmount)) AS VARCHAR(18)), '.', ''), 18) AS [SumaMontos], -- payment amount
							REPLICATE('0', 18) AS [SumaMonedas],     -- 18 zeros
							REPLICATE(' ', 6) AS [NumAvisoDebito],   -- doesn't exist for itau
							REPLICATE(' ', 10) AS [CodigoDevolucion],-- doesn't exist for itau
							1 -- same bank
						FROM @TempRegDetalleA
						WHERE CodBancoBenef = @BankCode

						UPDATE @TempRegDetalleA SET [LoteServicio] = RIGHT('000' + CAST(@LotCount as VARCHAR), 4)
						WHERE CodBancoBenef = @BankCode

					END

					IF (SELECT COUNT(1) FROM @TempRegDetalleA WHERE [CodBancoBenef] <> @BankCode ) > 0
					BEGIN
						
						SET @LotCount = @LotCount + 1

						INSERT INTO @TempLoteHeader ([CodBanco], [LoteServicio], [TipoServicio], [FormaLanzamiento], [TipoSuscripEmpresa], 
						[NroSuscripEmpresa], [CodigoConvenio], [AgMantenimCta], [DigVerificAgencia], [NroCtaCorriente], [DigVerifAgciaCta], 
						[DigVerificCuenta], [NombreEmpresa], [MensajeInfo1], [DirEmpresa], [NumLocal], 
						[NroDepto], [Ciudad], [CEP], [ComplementoCEP], [Estado], [FormaPago], [CodigoDevolucion], [SameBank])
						SELECT 
							@BankCode AS [CodBanco], -- bank code
							RIGHT('000' + CAST(@LotCount as VARCHAR), 4) AS [LoteServicio], -- shouldn't this be 0001?
							                                                                -- type of record, set by default as 1
                                                                                            -- type of transaction, set by default as C
							'20' AS [TipoServicio],  -- type of service
							'45' AS [FormaLanzamiento], -- 45 for PIX
							'2' AS [TipoSuscripEmpresa], -- 2: cnpj
							'34669130000133' AS [NroSuscripEmpresa], -- cnpj LP
							@LPCodigoConvenio AS [CodigoConvenio],  -- codigo convenio set as 20 blanks before (doesn't exist in rendimento)
							@LPBankBranch AS [AgMantenimCta], -- LP bank branch
							' ' AS [DigVerificAgencia], -- blank
							@LPBankAccountNumber AS [NroCtaCorriente], -- account
							' ' AS [DigVerifAgciaCta], -- blank
							@LPBankAccountVerifier AS [DigVerificCuenta], -- blank
							'Local Paym                    ' AS [NombreEmpresa], -- name
							SPACE(40) AS [MensajeInfo1], -- batch purpose + current account history (both blank)
							'RUA JOSE PAULINO              ' AS [DirEmpresa], -- company address
							'00229' AS [NumLocal],            -- location number 
							LEFT('SALA 401' + SPACE(15), 15) AS [NroDepto], -- supplement
							LEFT('CAMPINAS' + SPACE(20), 20) AS [Ciudad], -- city
							'13026' AS [CEP],                 --  postal code
							'515' AS [ComplementoCEP],        --  postal code
							'SP' AS [Estado],                 --  state
                                                              --  6 blanks set by default
							'  ' AS [FormaPago],              --  blank for itau
							SPACE(10) AS [CodigoDevolucion],   --  blank for itau
							0 -- not the same bank

						INSERT INTO @TempLoteFooter (CodBanco, LoteServicio, CantidadRegistros, SumaMontos, SumaMonedas, NumAvisoDebito, CodigoDevolucion, SameBank)
						SELECT
							@BankCode AS [CodBanco],
							RIGHT('000' + CAST(@LotCount as VARCHAR), 4) AS [LoteServicio],
							RIGHT('000000' + CAST((COUNT(1)) + 2 AS VARCHAR), 6) AS [CantidadRegistros],
							RIGHT(REPLICATE('0', 18) + REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount](SUM(DecimalAmount)) AS VARCHAR(18)), '.', ''), 18) AS [SumaMontos],
							REPLICATE('0', 18) AS [SumaMonedas],
							REPLICATE('0', 6) AS [NumAvisoDebito],
							REPLICATE('0', 10) AS [CodigoDevolucion],
							0 -- not the same bank
						FROM @TempRegDetalleA
						WHERE CodBancoBenef <> @BankCode

						UPDATE @TempRegDetalleA SET [LoteServicio] = RIGHT('000' + CAST(@LotCount as VARCHAR), 4)
						WHERE CodBancoBenef <> @BankCode

						--UPDATE @TempLoteFooter
						--SET [LineComplete] = CodBanco + LoteServicio + TipoRegistro + CNAB + CantidadRegistros + SumaMontos + SumaMonedas + NumAvisoDebito + CNAB2 + CodigoDevolucion 
						
					END


					-- LINE
					UPDATE @TempLoteHeader 
					SET [LineComplete] = [CodBanco] + [LoteServicio] + [TipoRegistro] + [TipoOperacion] + [TipoServicio] + [FormaLanzamiento] + [NroLayoutLote] + [CNAB] + 
						[TipoSuscripEmpresa] + [NroSuscripEmpresa] + [CodigoConvenio] + [AgMantenimCta] + [DigVerificAgencia] + [NroCtaCorriente] + 
						[DigVerifAgciaCta] + [DigVerificCuenta] + [NombreEmpresa] + [MensajeInfo1] + [DirEmpresa] + [NumLocal] + [NroDepto] + [Ciudad] + [CEP] + [ComplementoCEP] + [Estado] + 
						[FormaPago] + [CNAB2] + [CodigoDevolucion]

					UPDATE @TempLoteFooter
					SET [LineComplete] = CodBanco + LoteServicio + TipoRegistro + CNAB + CantidadRegistros + SumaMontos + SumaMonedas + NumAvisoDebito + CNAB2 + CodigoDevolucion 

			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */



			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempRegDetalleA
			SET [LineComplete] = [CodBanco] + [LoteServicio] + [TipoRegistro] + [NroSecuenciaReg] + [CodSegmento] + [TipoMovimiento] + [CodInstruccion] + 
				[CodCamara] + [CodBancoBenef] + [AgMantenimCta] + [DigVerificAgencia] + [NroCtaCorriente]  + [DigVerifAgciaCta] + [DigVerificCuenta] + [NombreBenef] + 
				[DocDeEmpresa] + [DataDePago] + [TipoMoneda] + [MontoMoneda] + [MontoPago] + [DocDeBanco] + [FechaEfectiva] + [MontoPagoReal] + [Informacion] + [CodTipoServicio] + 
				[CodTED] + [CodComplementario] + [CNAB] + [AvisoBenef] + [CodigoDevolucion]

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

			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			/* HEADER BLOCK: INI */

					DECLARE @Header VARCHAR(MAX)

					DECLARE @HCodBanco AS VARCHAR(3) = @BankCode -- bank code
					DECLARE @HLoteServicio as varchar(4) = '0000' -- batch code
					DECLARE @HTipoRegistro AS VARCHAR(1) = '0' -- type of record
					DECLARE @HC2nab AS VARCHAR(9) = '      080' -- 6 blanks + file layout version
					DECLARE @HTipoInsEmpresa AS VARCHAR(1) = '2' -- cnpj
					DECLARE @HNumInsEmpresa AS VARCHAR(14) = '34669130000133' -- LP cnpj
					DECLARE @HCodConvenio AS VARCHAR(20) = @LPCodigoConvenio -- blank
					DECLARE @HAgCuenta AS VARCHAR(5) = @LPBankBranch -- bank branch
					DECLARE @HDigVerifAg AS VARCHAR(1) = ' ' -- blank
					DECLARE @HNumCuenta AS VARCHAR(12) = @LPBankAccountNumber -- bank account number
					DECLARE @HDigVerifCtaAg AS VARCHAR(1) = ' ' -- blank (swapped)
					DECLARE @HDigVerifCta AS VARCHAR(1) = @LPBankAccountVerifier -- DAC (swapped)
					DECLARE @HNomEmp AS VARCHAR(30) = 'Local Paym                    ' -- name
					DECLARE @HNomBanco AS VARCHAR(30) = LEFT('BANCO ITAU' + SPACE(30), 30) -- bank name
					DECLARE @HCnab2 AS VARCHAR(10) = SPACE(10) -- blanks
					DECLARE @HCodRet AS VARCHAR(1) = '1' -- remittance
					DECLARE @HDataArc AS VARCHAR(8) = FORMAT(@TodayDate, 'ddMMyyyy') -- date
					DECLARE @HHoraArc AS VARCHAR(6) = FORMAT(@TodayDate, 'HHMMss') -- date
					DECLARE @HNumSecArc AS VARCHAR(6) = '000000' -- zeros for itau
					DECLARE @HVersArc AS VARCHAR(3) = '000' -- zeros for itau
					DECLARE @HDensid AS VARCHAR(5) = '00000' -- unit density (zeros)
					DECLARE @HResBanc AS VARCHAR(20) = SPACE(20) -- blank
					DECLARE @HResEmp AS VARCHAR(20) = SPACE(20) -- blank
					DECLARE @HCnab3 AS VARCHAR(14) = SPACE(14) -- blank
					DECLARE @HCnab4 AS VARCHAR(15) = SPACE(15) -- blank



					SET @Header = @HCodBanco + @HLoteServicio + @HTipoRegistro + @HC2nab + @HTipoInsEmpresa + @HNumInsEmpresa + @HCodConvenio + @HAgCuenta + @HDigVerifAg + 
								@HNumCuenta + @HDigVerifCtaAg + @HDigVerifCta + @HNomEmp + @HNomBanco + @HCnab2 + @HCodRet + @HDataArc + @HHoraArc + 
								@HNumSecArc + @HVersArc + @HDensid + @HResBanc + @HResEmp + @HCnab3 + @HCnab4

			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* FOOTER BLOCK: INI */
					
					DECLARE @Footer VARCHAR(MAX)

					DECLARE @FCodBanco AS VARCHAR(3) = @BankCode
					DECLARE @FLoteServ AS VARCHAR(4) = '9999'
					DECLARE @FTipoReg AS VARCHAR(1) = '9'
					DECLARE @FCnab AS VARCHAR(9) = SPACE(9)
					DECLARE @FCantLotes AS VARCHAR(6) = RIGHT('000000' + CAST(@LotCount AS VARCHAR), 6)
					DECLARE @FCantReg AS VARCHAR(6) = RIGHT('000000' + CAST((SELECT COUNT(1) + (@LotCount) * 2 + 2 FROM @TempRegDetalleA) AS VARCHAR(6)), 6)
					DECLARE @FCantCtas AS VARCHAR(6) = SPACE(6)
					DECLARE @FCnab2 AS VARCHAR(205) = SPACE(205)


					SET @Footer = @FCodBanco + @FLoteServ + @FTipoReg + @FCnab + @FCantLotes + @FCantReg + @FCantCtas + @FCnab2

			/* FOOTER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* INSERT LINES BLOCK: INI */
			-- inserting file header
			INSERT INTO @Lines VALUES(@Header)

			-- INSERT INTERNAL TXS
			IF(SELECT COUNT(1) FROM @TempRegDetalleA WHERE CodBancoBenef = @BankCode) > 0
			BEGIN
				-- inserting batch header
				INSERT INTO @Lines
				SELECT TOP 1 [LineComplete] FROM @TempLoteHeader
				WHERE SameBank = 1

				DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
					SELECT idTempRegDetalleA
					FROM @TempRegDetalleA
					Where CodBancoBenef = @BankCode

				OPEN tx_cursor;

				FETCH NEXT FROM tx_cursor INTO @txnum

				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- INSERTING REG A
					INSERT INTO @Lines
					SELECT [LineComplete] FROM @TempRegDetalleA WHERE idTempRegDetalleA = @txnum

					SET @IterationI = @IterationI + 1

					FETCH NEXT FROM tx_cursor INTO @txnum
				END

				CLOSE tx_cursor
				DEALLOCATE tx_cursor

				-- inserting batch footer
				INSERT INTO @Lines
				SELECT TOP 1 [LineComplete] FROM @TempLoteFooter
				WHERE SameBank = 1
			END



			-- INSERT EXTERNAL TXS
			IF(SELECT COUNT(1) FROM @TempRegDetalleA WHERE CodBancoBenef <> @BankCode) > 0
			BEGIN
				-- inserting batch header
				INSERT INTO @Lines
				SELECT TOP 1 [LineComplete] FROM @TempLoteHeader
				WHERE SameBank = 0

				DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
					SELECT idTempRegDetalleA
					FROM @TempRegDetalleA
					Where CodBancoBenef <> @BankCode

				OPEN tx_cursor;

				FETCH NEXT FROM tx_cursor INTO @txnum

				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- INSERTING REG A
					INSERT INTO @Lines
					SELECT [LineComplete] FROM @TempRegDetalleA WHERE idTempRegDetalleA = @txnum

					SET @IterationI = @IterationI + 1

					FETCH NEXT FROM tx_cursor INTO @txnum
				END

				CLOSE tx_cursor
				DEALLOCATE tx_cursor

				-- inserting batch footer
				INSERT INTO @Lines
				SELECT TOP 1 [LineComplete] FROM @TempLoteFooter
				WHERE SameBank = 0
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



