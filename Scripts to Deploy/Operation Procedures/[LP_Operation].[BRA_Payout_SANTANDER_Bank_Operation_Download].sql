
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER PROCEDURE [LP_Operation].[BRA_Payout_SANTANDER_Bank_Operation_Download]
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
					SET @BankCode = '033'

					DECLARE @idProvider INT
					SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'SANTBR' AND [idCountry] = @idCountry AND [Active] = 1 )

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
						NroLayoutLote		VARCHAR(3) DEFAULT '020',
						CNAB				VARCHAR(1) DEFAULT ' ',
						TipoSuscripEmpresa	VARCHAR(1),
						NroSuscripEmpresa	VARCHAR(14),
						CodigoConvenio		VARCHAR(20),
						AgMantenimCta		VARCHAR(5),
						DigVerificAgencia	VARCHAR(1),
						NroCtaCorriente		VARCHAR(12),
						DigVerificCuenta	VARCHAR(1),
						DigVerifAgciaCta	VARCHAR(1),
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
						LineComplete		VARCHAR(MAX)
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
						FormaLanzamiento	VARCHAR(2)
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
						DigVerificCuenta	VARCHAR(1),
						DigVerifAgciaCta	VARCHAR(1),
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


					DECLARE @TempRegDetalleB TABLE
					(
						idTempRegDetalleB	INT IDENTITY(1,1),
						CodBanco			VARCHAR(3),
						LoteServicio		VARCHAR(4),
						TipoRegistro		VARCHAR(1) DEFAULT '3',
						NroSecuenciaReg		VARCHAR(5),
						CodSegmento			VARCHAR(1) DEFAULT 'B',
						CNAB				VARCHAR(3) DEFAULT SPACE(3),
						TipoInscripBenef	VARCHAR(1),
						NumInscripBenef		VARCHAR(14),
						DireccionBenef		VARCHAR(30),
						NroDireccionBenef	VARCHAR(5),
						NroDeptoBenef		VARCHAR(15),
						BarrioBenef			VARCHAR(15),
						CiudadBenef			VARCHAR(20),
						CEPBenef			VARCHAR(5),
						ComplementoCEP		VARCHAR(3),
						EstadoBenef			VARCHAR(2),
						VencimientoPago		VARCHAR(8),
						ValorDocumento		VARCHAR(15),
						MontoAsignacion		VARCHAR(15),
						MontoDescuento		VARCHAR(15),
						MontoMora			VARCHAR(15),
						MontoMulta			VARCHAR(15),
						NroDocBeneficiario	VARCHAR(15),
						AvisoBenef			VARCHAR(1),
						CodigoUG			VARCHAR(6) DEFAULT SPACE(6),
						CodigoISPB			VARCHAR(8) DEFAULT SPACE(8),
						idTransaction		BIGINT,
						idTempRegDetalleA	INT,
						ToProcess			BIT DEFAULT 1,
						LineComplete		VARCHAR(MAX)
					)


					DECLARE @LpCUIT VARCHAR(11)
					SET @LpCUIT = '30716132028'

					DECLARE @LPBankBranch AS VARCHAR(5)
					SET @LPBankBranch = '01677'

					DECLARE @LPBankAccountNumber AS VARCHAR(12)
					SET @LPBankAccountNumber = '000013000969'

					DECLARE @LPBankAccountVerifier AS CHAR(1)
					SET @LPBankAccountVerifier = '1'

					DECLARE @LPCodigoConvenio AS VARCHAR(20)
					SET @LPCodigoConvenio = '00331677004906479261'

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
						[CodCamara], [CodBancoBenef], [AgMantenimCta], [DigVerificAgencia], [NroCtaCorriente], [DigVerificCuenta], 
						[DigVerifAgciaCta], [NombreBenef], [DocDeEmpresa], [DataDePago], [TipoMoneda], [MontoMoneda], [MontoPago], 
						[DocDeBanco], [FechaEfectiva], [MontoPagoReal], [Informacion], [CodTipoServicio], [CodTED], [CodComplementario], 
						[AvisoBenef], [CodigoDevolucion], [idTransaction], [DecimalAmount])
					SELECT 
						@BankCode AS [CodBanco],
						'0001' AS [LoteServicio],
						'' AS [NroSecuenciaReg],
						'0' AS [TipoMovimiento],
						'00' AS [CodInstruccion],
						'018' AS [CodCamara],
						[BC].[Code] AS [CodBancoBenef],
						RIGHT(REPLICATE('0', 5) + LEFT([TRD].[BankBranch], 4), 5) AS [AgMantenimCta],
						' ',
						RIGHT(REPLICATE('0', 12) + LEFT(REPLACE(REPLACE(REPLACE(REPLACE([TRD].[RecipientAccountNumber],'.',''), '-', ''),'X','0'),'/',''), LEN(REPLACE(REPLACE(REPLACE(REPLACE([TRD].[RecipientAccountNumber],'.',''), '-', ''),'X','0'),'/','')) -1), 12) AS [NroCtaCorriente],
						RIGHT(REPLACE([TRD].[RecipientAccountNumber], 'X', '0'), 1) AS [DigVerificCuenta],
						' ' AS [DigVerifAgciaCta],
						LEFT(TRD.Recipient + SPACE(30), 30) AS [NombreBenef],
						LEFT(TRD.RecipientCUIT + SPACE(20), 20) AS [DocDeEmpresa],
						FORMAT(@TodayDate, 'ddMMyyyy') AS [DataDePago],
						'BRL' AS [TipoMoneda],
						REPLICATE('0', 15) AS [MontoMoneda],
						RIGHT(REPLICATE('0', 15) + CAST(REPLACE(CAST(TD.NetAmount as decimal(13,2)), '.', '') AS VARCHAR), 15) AS [MontoPago],
						SPACE(20) AS [DocDeBanco],
						REPLICATE('0', 8) AS [FechaEfectiva],
						REPLICATE('0', 15) AS [MontoPagoReal],
						SPACE(40) AS [Informacion],
						SPACE(2) AS [CodTipoServicio],
						SPACE(5) AS [CodTED],
						SPACE(2) AS [CodComplementario],
						'0' AS [AvisoBenef],
						REPLICATE('0', 10) AS [CodigoDevolucion],
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

					WHILE(@QtyRowsReg2 >= @IterationI)
					BEGIN
						SET @idRegDetalleATemp = (SELECT idTempRegDetalleA FROM @TempRegDetalleA WHERE idTempRegDetalleA = @IterationI)

						INSERT INTO @TempRegDetalleB ([CodBanco], [LoteServicio], [TipoInscripBenef], [NumInscripBenef], [DireccionBenef], 
								[NroDireccionBenef], [NroDeptoBenef], [BarrioBenef], [CiudadBenef], [CEPBenef], [ComplementoCEP], [EstadoBenef], 
								[VencimientoPago], [ValorDocumento], [MontoAsignacion], [MontoDescuento], [MontoMora], [MontoMulta], [NroDocBeneficiario], 
								[AvisoBenef], [idTempRegDetalleA], [idTransaction], [NroSecuenciaReg])
						SELECT 
							[TR2].CodBanco AS [CodBanco],
							[TR2].LoteServicio AS [LoteServicio],
							CASE 
								WHEN LEN([TRD].[RecipientCUIT]) > 11 THEN '2' 
								ELSE '1' 
							END AS [TipoInscripBenef],
							RIGHT(REPLICATE('0', 14) + [TRD].[RecipientCUIT], 14) AS [NumInscripBenef],
							SPACE(30) AS [DireccionBenef],
							REPLICATE('0', 5) AS [NroDireccionBenef],
							SPACE(15) AS [NroDeptoBenef],
							SPACE(15) AS [BarrioBenef],
							SPACE(20) AS [CiudadBenef],
							REPLICATE('0', 5) AS [CEPBenef],
							SPACE(3) AS [ComplementoCEP],
							SPACE(2) AS [EstadoBenef],
							FORMAT(DATEADD(DAY, 1, @TodayDate), 'ddMMyyyy') AS [VencimientoPago],
							[TR2].MontoPago AS [ValorDocumento],
							REPLICATE('0', 15) AS [MontoAsignacion],
							REPLICATE('0', 15) AS [MontoDescuento],
							REPLICATE('0', 15) AS [MontoMora],
							REPLICATE('0', 15) AS [MontoMulta],
							RIGHT(REPLICATE('0', 15) + [TRD].[RecipientCUIT], 15) AS [NroDocBeneficiario],
							'0' AS [AvisoBenef],
							[TR2].[idTempRegDetalleA] AS [idTempRegDetalleA],
							[TR2].[idTransaction] AS [idTransaction],
							''
						FROM @TempRegDetalleA [TR2]
						INNER JOIN [LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[TR2].[idTransaction]	= [TRD].[idTransaction]
						INNER JOIN [LP_Operation].[Ticket]							[TI]	ON	[TI].[idTransaction]	= [TRD].[idTransaction]
						WHERE [TR2].[idTempRegDetalleA] = @idRegDetalleATemp

						SET @IterationI = @IterationI + 1
					END


					/* UPDATING SEQUENCE NUMBER: INI */  

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
							UPDATE @TempRegDetalleB SET NroSecuenciaReg = RIGHT(REPLICATE('0', 5) + CAST(@Secuencia AS VARCHAR), 5) WHERE idTempRegDetalleA = @idxRowsTemp
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
							SET [DocDeEmpresa] = LEFT(@NewTicketAlternative + REPLICATE('0', 20), 20)
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
						[DigVerificCuenta], [DigVerifAgciaCta], [NombreEmpresa], [MensajeInfo1], [DirEmpresa], [NumLocal], 
						[NroDepto], [Ciudad], [CEP], [ComplementoCEP], [Estado], [FormaPago], [CodigoDevolucion])
						SELECT 
							@BankCode AS [CodBanco],
							RIGHT('000' + CAST(@LotCount as VARCHAR), 4) AS [LoteServicio],
							'20' AS [TipoServicio],
							'01' AS [FormaLanzamiento],
							'2' AS [TipoSuscripEmpresa],
							'34669130000133' AS [NroSuscripEmpresa],
							@LPCodigoConvenio AS [CodigoConvenio],
							@LPBankBranch AS [AgMantenimCta],
							' ' AS [DigVerificAgencia],
							@LPBankAccountNumber AS [NroCtaCorriente],
							@LPBankAccountVerifier AS [DigVerificCuenta],
							'0' AS [DigVerifAgciaCta],
							'Local Paym                    ' AS [NombreEmpresa],
							SPACE(40) AS [MensajeInfo1],
							'RUA JOSE PAULINO              ' AS [DirEmpresa],
							'00229' AS [NumLocal],
							LEFT('SALA 401' + SPACE(15), 15) AS [NroDepto],
							LEFT('CAMPINAS' + SPACE(20), 20) AS [Ciudad],
							'13026' AS [CEP],
							'515' AS [ComplementoCEP],
							'SP' AS [Estado],
							'01' AS [FormaPago],
							REPLICATE('0', 10) AS [CodigoDevolucion]

						INSERT INTO @TempLoteFooter (CodBanco, LoteServicio, CantidadRegistros, SumaMontos, SumaMonedas, NumAvisoDebito, CodigoDevolucion, FormaLanzamiento)
						SELECT
							@BankCode AS [CodBanco],
							RIGHT('000' + CAST(@LotCount as VARCHAR), 4) AS [LoteServicio],
							RIGHT('000000' + CAST((COUNT(1) * 2) + 2 AS VARCHAR), 6) AS [CantidadRegistros],
							RIGHT(REPLICATE('0', 18) + REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount](SUM(DecimalAmount)) AS VARCHAR(18)), '.', ''), 18) AS [SumaMontos],
							REPLICATE('0', 18) AS [SumaMonedas],
							REPLICATE('0', 6) AS [NumAvisoDebito],
							REPLICATE('0', 10) AS [CodigoDevolucion],
							'01'
						FROM @TempRegDetalleA
						WHERE CodBancoBenef = @BankCode

						UPDATE @TempRegDetalleA SET [LoteServicio] = RIGHT('000' + CAST(@LotCount as VARCHAR), 4)
						WHERE CodBancoBenef = @BankCode

						UPDATE @TempRegDetalleB SET [LoteServicio] = RIGHT('000' + CAST(@LotCount as VARCHAR), 4)
						WHERE idTempRegDetalleA IN (SELECT idTempRegDetalleA FROM @TempRegDetalleA WHERE CodBancoBenef = @BankCode)

					END

					IF (SELECT COUNT(1) FROM @TempRegDetalleA WHERE [CodBancoBenef] <> @BankCode ) > 0
					BEGIN
						SET @LotCount = @LotCount + 1

						INSERT INTO @TempLoteHeader ([CodBanco], [LoteServicio], [TipoServicio], [FormaLanzamiento], [TipoSuscripEmpresa], 
						[NroSuscripEmpresa], [CodigoConvenio], [AgMantenimCta], [DigVerificAgencia], [NroCtaCorriente], 
						[DigVerificCuenta], [DigVerifAgciaCta], [NombreEmpresa], [MensajeInfo1], [DirEmpresa], [NumLocal], 
						[NroDepto], [Ciudad], [CEP], [ComplementoCEP], [Estado], [FormaPago], [CodigoDevolucion])
						SELECT 
							@BankCode AS [CodBanco],
							RIGHT('000' + CAST(@LotCount as VARCHAR), 4) AS [LoteServicio],
							'20' AS [TipoServicio],
							'41' AS [FormaLanzamiento],
							'2' AS [TipoSuscripEmpresa],
							'34669130000133' AS [NroSuscripEmpresa],
							@LPCodigoConvenio AS [CodigoConvenio],
							@LPBankBranch AS [AgMantenimCta],
							' ' AS [DigVerificAgencia],
							@LPBankAccountNumber AS [NroCtaCorriente],
							@LPBankAccountVerifier AS [DigVerificCuenta],
							'0' AS [DigVerifAgciaCta],
							'Local Paym                    ' AS [NombreEmpresa],
							SPACE(40) AS [MensajeInfo1],
							'RUA JOSE PAULINO              ' AS [DirEmpresa],
							'00229' AS [NumLocal],
							LEFT('SALA 401' + SPACE(15), 15) AS [NroDepto],
							LEFT('CAMPINAS' + SPACE(20), 20) AS [Ciudad],
							'13026' AS [CEP],
							'515' AS [ComplementoCEP],
							'SP' AS [Estado],
							'01' AS [FormaPago],
							REPLICATE('0', 10) AS [CodigoDevolucion]

						INSERT INTO @TempLoteFooter (CodBanco, LoteServicio, CantidadRegistros, SumaMontos, SumaMonedas, NumAvisoDebito, CodigoDevolucion, FormaLanzamiento)
						SELECT
							@BankCode AS [CodBanco],
							RIGHT('000' + CAST(@LotCount as VARCHAR), 4) AS [LoteServicio],
							RIGHT('000000' + CAST((COUNT(1) * 2) + 2 AS VARCHAR), 6) AS [CantidadRegistros],
							RIGHT(REPLICATE('0', 18) + REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount](SUM(DecimalAmount)) AS VARCHAR(18)), '.', ''), 18) AS [SumaMontos],
							REPLICATE('0', 18) AS [SumaMonedas],
							REPLICATE('0', 6) AS [NumAvisoDebito],
							REPLICATE('0', 10) AS [CodigoDevolucion],
							'41'
						FROM @TempRegDetalleA
						WHERE CodBancoBenef <> @BankCode

						UPDATE @TempRegDetalleA SET [LoteServicio] = RIGHT('000' + CAST(@LotCount as VARCHAR), 4)
						WHERE CodBancoBenef <> @BankCode

						UPDATE @TempRegDetalleB SET [LoteServicio] = RIGHT('000' + CAST(@LotCount as VARCHAR), 4)
						WHERE idTempRegDetalleA IN (SELECT idTempRegDetalleA FROM @TempRegDetalleA WHERE CodBancoBenef <> @BankCode)

						
					END

					-- LINE
					UPDATE @TempLoteHeader 
					SET [LineComplete] = [CodBanco] + [LoteServicio] + [TipoRegistro] + [TipoOperacion] + [TipoServicio] + [FormaLanzamiento] + [NroLayoutLote] + [CNAB] + 
						[TipoSuscripEmpresa] + [NroSuscripEmpresa] + [CodigoConvenio] + [AgMantenimCta] + [DigVerificAgencia] + [NroCtaCorriente] + [DigVerificCuenta] + 
						[DigVerifAgciaCta] + [NombreEmpresa] + [MensajeInfo1] + [DirEmpresa] + [NumLocal] + [NroDepto] + [Ciudad] + [CEP] + [ComplementoCEP] + [Estado] + 
						[FormaPago] + [CNAB2] + [CodigoDevolucion]

					UPDATE @TempLoteFooter
					SET [LineComplete] = CodBanco + LoteServicio + TipoRegistro + CNAB + CantidadRegistros + SumaMontos + SumaMonedas + NumAvisoDebito + CNAB2 + CodigoDevolucion 

			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */



			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempRegDetalleA
			SET [LineComplete] = [CodBanco] + [LoteServicio] + [TipoRegistro] + [NroSecuenciaReg] + [CodSegmento] + [TipoMovimiento] + [CodInstruccion] + 
				[CodCamara] + [CodBancoBenef] + [AgMantenimCta] + [DigVerificAgencia] + [NroCtaCorriente] + [DigVerificCuenta] + [DigVerifAgciaCta] + [NombreBenef] + 
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

					DECLARE @HCodBanco AS VARCHAR(3) = @BankCode
					DECLARE @HLoteServicio as varchar(4) = '0000'
					DECLARE @HTipoRegistro AS VARCHAR(1) = '0'
					DECLARE @HC2nab AS VARCHAR(9) = SPACE(9)
					DECLARE @HTipoInsEmpresa AS VARCHAR(1) = '2'
					DECLARE @HNumInsEmpresa AS VARCHAR(14) = '34669130000133'
					DECLARE @HCodConvenio AS VARCHAR(20) = @LPCodigoConvenio
					DECLARE @HAgCuenta AS VARCHAR(5) = @LPBankBranch
					DECLARE @HDigVerifAg AS VARCHAR(1) = ' '
					DECLARE @HNumCuenta AS VARCHAR(12) = @LPBankAccountNumber
					DECLARE @HDigVerifCta AS VARCHAR(1) = @LPBankAccountVerifier
					DECLARE @HDigVerifCtaAg AS VARCHAR(1) = ' '
					DECLARE @HNomEmp AS VARCHAR(30) = 'Local Paym                    '
					DECLARE @HNomBanco AS VARCHAR(30) = LEFT('BANCO SANTANDER BRASIL S.A.' + SPACE(30), 30)
					DECLARE @HCnab2 AS VARCHAR(10) = SPACE(10)
					DECLARE @HCodRet AS VARCHAR(1) = '1'
					DECLARE @HDataArc AS VARCHAR(8) = FORMAT(@TodayDate, 'ddMMyyyy')
					DECLARE @HHoraArc AS VARCHAR(6) = FORMAT(@TodayDate, 'HHMMss')
					DECLARE @HNumSecArc AS VARCHAR(6) = RIGHT(REPLICATE('0', 6) + CAST(@FileControlNumber AS VARCHAR), 6)
					DECLARE @HVersArc AS VARCHAR(3) = '103'
					DECLARE @HDensid AS VARCHAR(5) = '00000'
					DECLARE @HResBanc AS VARCHAR(20) = SPACE(20)
					DECLARE @HResEmp AS VARCHAR(20) = SPACE(20)
					DECLARE @HCnab3 AS VARCHAR(14) = SPACE(14)
					DECLARE @HCnab4 AS VARCHAR(15) = SPACE(15)



					SET @Header = @HCodBanco + @HLoteServicio + @HTipoRegistro + @HC2nab + @HTipoInsEmpresa + @HNumInsEmpresa + @HCodConvenio + @HAgCuenta + @HDigVerifAg + 
								@HNumCuenta + @HDigVerifCta + @HDigVerifCtaAg + @HNomEmp + @HNomBanco + @HCnab2 + @HCodRet + @HDataArc + @HHoraArc + 
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
					DECLARE @FCantReg AS VARCHAR(6) = RIGHT('000000' + CAST((SELECT COUNT(1) * 2 + (@LotCount * 2) + 2 FROM @TempRegDetalleA) AS VARCHAR(6)), 6)
					DECLARE @FCantCtas AS VARCHAR(6) = REPLICATE('0', 6)
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
				WHERE FormaLanzamiento = '01'

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

					-- INSERTING REG B
					INSERT INTO @Lines
					SELECT [CodBanco] + [LoteServicio] + [TipoRegistro] + [NroSecuenciaReg] + [CodSegmento] + [CNAB] + [TipoInscripBenef] + 
							[NumInscripBenef] + [DireccionBenef] + [NroDireccionBenef] + [NroDeptoBenef] + [BarrioBenef] + [CiudadBenef] + [CEPBenef] + 
							[ComplementoCEP] + [EstadoBenef] + [VencimientoPago] + [ValorDocumento] + [MontoAsignacion] + [MontoDescuento] + [MontoMora] + 
							[MontoMulta] + [NroDocBeneficiario] + [AvisoBenef] + [CodigoUG] + [CodigoISPB]
					FROM @TempRegDetalleB WHERE idTempRegDetalleA = @txnum

					SET @IterationI = @IterationI + 1

					FETCH NEXT FROM tx_cursor INTO @txnum
				END

				CLOSE tx_cursor
				DEALLOCATE tx_cursor

				-- inserting batch footer
				INSERT INTO @Lines
				SELECT TOP 1 [LineComplete] FROM @TempLoteFooter
				WHERE FormaLanzamiento = '01'
			END



			-- INSERT EXTERNAL TXS
			IF(SELECT COUNT(1) FROM @TempRegDetalleA WHERE CodBancoBenef <> @BankCode) > 0
			BEGIN
				-- inserting batch header
				INSERT INTO @Lines
				SELECT TOP 1 [LineComplete] FROM @TempLoteHeader
				WHERE FormaLanzamiento = '41'

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

					-- INSERTING REG B
					INSERT INTO @Lines
					SELECT [CodBanco] + [LoteServicio] + [TipoRegistro] + [NroSecuenciaReg] + [CodSegmento] + [CNAB] + [TipoInscripBenef] + 
							[NumInscripBenef] + [DireccionBenef] + [NroDireccionBenef] + [NroDeptoBenef] + [BarrioBenef] + [CiudadBenef] + [CEPBenef] + 
							[ComplementoCEP] + [EstadoBenef] + [VencimientoPago] + [ValorDocumento] + [MontoAsignacion] + [MontoDescuento] + [MontoMora] + 
							[MontoMulta] + [NroDocBeneficiario] + [AvisoBenef] + [CodigoUG] + [CodigoISPB]
					FROM @TempRegDetalleB WHERE idTempRegDetalleA = @txnum

					SET @IterationI = @IterationI + 1

					FETCH NEXT FROM tx_cursor INTO @txnum
				END

				CLOSE tx_cursor
				DEALLOCATE tx_cursor

				-- inserting batch footer
				INSERT INTO @Lines
				SELECT TOP 1 [LineComplete] FROM @TempLoteFooter
				WHERE FormaLanzamiento = '41'
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


