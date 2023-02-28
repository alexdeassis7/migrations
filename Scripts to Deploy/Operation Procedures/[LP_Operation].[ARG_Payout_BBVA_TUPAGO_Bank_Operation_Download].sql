/****** Object:  StoredProcedure [LP_Operation].[ARG_Payout_GALICIA_Bank_Operation_Download]    Script Date: 3/11/2020 11:09:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER PROCEDURE [LP_Operation].[ARG_Payout_BBVA_TUPAGO_Bank_Operation_Download]
																			(
																				@TransactionMechanism		BIT
																				, @JSON						VARCHAR(MAX)
																			)
AS

--DECLARE	@TransactionMechanism BIT
--SET		@TransactionMechanism = 1
--DECLARE	@JSON VARCHAR(MAX)
--SET		@JSON = '{"PaymentType":2,"idMerchant":"12", "idSubMerchant":"5", "amount":"7000000000000500000"}'
----UPDATE [LP_Operation].[Transaction] SET idStatus = 1 WHERE idProviderPayWayService in (12,4) 


BEGIN

			BEGIN TRY

					/* CONFIG BLOCK: INI */

					DECLARE @idCountry	INT
					SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE Code = 'ARS' AND [Active] = 1 )

					DECLARE @idProvider INT
					SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BBBVATP' AND [idCountry] = @idCountry AND [Active] = 1 )

					-- DECLARING TABLE WITH SELECTED TICKETS TO DOWNLOAD
					DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
					INSERT INTO @TempTxsToDownload
					SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)

					DECLARE @idProviderPayWayService INT
					SET @idProviderPayWayService = ( SELECT [PPWS].[idProviderPayWayService] 
														FROM [LP_Configuration].[ProviderPayWayServices]		[PPWS]
															INNER JOIN [LP_Configuration].[Provider]			[PR]	ON	[PR].[idProvider]		= [PPWS].[idProvider]
															INNER JOIN [LP_Configuration].[PayWayServices]	[PWS]	ON	[PWS].[idPayWayService] = [PPWS].[idPayWayService]
														WHERE [PR].[Code] = 'BBBVA' AND [PR].[idCountry] = @idCountry
															AND [PWS].[Code] = 'BANKDEPO' AND [PWS].[idCountry] = @idCountry )

					DECLARE @idTransactionTypeProvider INT
					SET @idTransactionTypeProvider = ( SELECT [idTransactionTypeProvider]
														FROM [LP_Configuration].[TransactionTypeProvider] [TTP]
															INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [TTP].[idTransactionType]
														WHERE [TTP].[idProvider] = @idProvider AND [TT].[Code] = 'PODEPO' AND [TT].[idCountry] = @idCountry )
					DECLARE @TempReg2 TABLE
					(
						[idx2]					BIGINT IDENTITY(1,1),
						[IdentReg]				VARCHAR(4),
						[TipoReg]				VARCHAR(3),
						[TipoDocEmpre]			VARCHAR(4),
						[NroCuitEmpre]			VARCHAR(13),
						[Secuencia]				VARCHAR(6),
						[ProNroBeneficiario]	VARCHAR(15),
						[NroMinuta]				VARCHAR(8),
						[Importe]				VARCHAR(13),
						[NroCertRetGanancias]	VARCHAR(14),
						[RegimenGanancias]		VARCHAR(30),
						[ImpRetGanancias]		VARCHAR(13),
						[NroCertRetIva]			VARCHAR(14),
						[RegimenIva]			VARCHAR(30),
						[ProNroOrd]				VARCHAR(15),
						[Filler1]				VARCHAR(8),
						[AcredASusp]			VARCHAR(1),
						[IPermFin]				VARCHAR(1),
						[CliAje]				VARCHAR(1),
						[NCuitPago]				VARCHAR(13),
						[NomePago]				VARCHAR(40),
						[TipoDocumento]			VARCHAR(3),
						[NroDocumento]			VARCHAR(11),
						[SucEntrega]			VARCHAR(4),
						[FechaEntrega]			VARCHAR(8),
						[FechaPago]				VARCHAR(8),
						[FormaPago]				VARCHAR(2),
						[FormaCobro]			VARCHAR(1),
						[DisponP]				VARCHAR(1),
						[Deposito]				VARCHAR(1),
						[NroCheque]				VARCHAR(13),
						[CodDevolucion]			VARCHAR(6),
						[DescDevolucion]		VARCHAR(40),
						[Filler2]				VARCHAR(506),
						[DecimalAmount]			[LP_Common].[LP_F_DECIMAL],
						[idTransaction]			BIGINT,
						[iDTransactionLot]		BIGINT,
						[ToProcess]				[LP_Common].[LP_F_BOOL],
						[LineComplete]			VARCHAR(MAX)
					)

					DECLARE @TempReg9 TABLE
					(
						[idx9]					BIGINT IDENTITY(1,1),
						[idx2]					BIGINT,
						[IdentReg]				VARCHAR(4),
						[TipoReg]				VARCHAR(3),
						[TipoDocEmpre]			VARCHAR(4),
						[NroCuitEmpre]			VARCHAR(13),
						[Secuencia]				VARCHAR(6),
						[ProNroOrd]				VARCHAR(15),
						[ProNroBenef]			VARCHAR(15),
						[ProEstBenef]			VARCHAR(1),
						[ProDoctoTip]			VARCHAR(3),
						[ProDoctoNro]			VARCHAR(11),
						[ProDenomina]			VARCHAR(40),
						[ProCatego]				VARCHAR(2),
						[ProPermitFinan]		VARCHAR(1),
						[ProCusTip]				VARCHAR(2),
						[ProCusSuc]				VARCHAR(3),
						[ProCusNro]				VARCHAR(10),
						[ProCbuNro]				VARCHAR(22),
						[ProIngBrts]			VARCHAR(11),
						[ProCalle]				VARCHAR(24),
						[ProNumero]				VARCHAR(5),
						[ProDepto]				VARCHAR(3),
						[ProPiso]				VARCHAR(2),
						[ProLocalid]			VARCHAR(28),
						[ProCPostal]			VARCHAR(5),
						[ProCodProv]			VARCHAR(2),
						[ProCodPais]			VARCHAR(3),
						[ProEmail]				VARCHAR(40),
						[ProCalleEntrega]		VARCHAR(24),
						[ProNroEntrega]			VARCHAR(5),
						[ProDeptoEntrega]		VARCHAR(3),
						[ProPisoEntrega]		VARCHAR(2),
						[ProLocalidEntrega]		VARCHAR(28),
						[ProCPostalEntrega]		VARCHAR(5),
						[ProCodProvEntrega]		VARCHAR(2),
						[ProCodPaisEntrega]		varchaR(3),
						[ProTelefTip]			varchar(2),
						[ProTelefPre]			varchar(4),
						[ProTelefCar]			varchar(4),
						[ProTelefNro]			varchar(5),
						[ProTelefInt]			varchar(18),
						[ProTelefAlterTip]		varchar(2),
						[ProTelefAlterPre]		varchar(4),
						[ProTelefAlterCar]		varchar(4),
						[ProTelefAlterNro]		varchar(5),
						[ProTelefAlterInt]		varchar(18),
						[ProAutorizaNom1]		varchar(25),
						[ProAutorizaTip1]		varchar(3),
						[ProAutorizaDoc1]		varchar(8),
						[ProAutorizaNom2]		varchar(25),
						[ProAutorizaTip2]		varchar(3),
						[ProAutorizaDoc2]		varchar(8),
						[ProAutorizaNom3]		varchar(25),
						[ProAutorizaTip3]		varchar(3),
						[ProAutorizaDoc3]		varchar(8),
						[ProDatos]				varchar(100),
						[ProMinuta]				varchar(8),
						[Filler1]				varchar(218),
						[ToProcess]				[LP_Common].[LP_F_BOOL]
					)


					DECLARE @LpCUIT VARCHAR(11)
					SET @LpCUIT = '30716856042'

					DECLARE @NroSecuencia BIGINT
					SET @NroSecuencia = 1;

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


					INSERT INTO @TempReg2 ([IdentReg], [TipoReg], [TipoDocEmpre], [NroCuitEmpre], [Secuencia], [ProNroBeneficiario], [NroMinuta], [Importe], [NroCertRetGanancias], [RegimenGanancias], 
											[ImpRetGanancias], [NroCertRetIva], [RegimenIva], [ProNroOrd], [Filler1], [AcredASusp], [IPermFin], [CliAje], [NCuitPago], [NomePago], [TipoDocumento], [NroDocumento], 
											[SucEntrega], [FechaEntrega], [FechaPago], [FormaPago], [FormaCobro], [DisponP], [Deposito], [NroCheque], [CodDevolucion], [DescDevolucion], [Filler2], [DecimalAmount], 
											[idTransaction], [idTransactionLot], [ToProcess])
					SELECT 
						[IdentReg]				= '0306',
						[TipoReg]				= '020',
						[TipoDocEmpre]			= 'CUIT',
						[NroCuitEmpre]			= RIGHT(REPLICATE('0', 13) + @LpCUIT, 13),
						[Secuencia]				= REPLICATE('0', 6), -- TODO Logica Secuencia
						[ProNroBeneficiario]	= RIGHT(REPLICATE('0', 15) + [TRD].[RecipientCUIT], 15),
						[NroMinuta]				= REPLICATE('0', 8), -- TODO NRo Minuta?? ID INTERNO?
						[Importe]				= RIGHT(REPLICATE('0', 13) + REPLACE(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(13)), '.', ''), 13),
						[NroCertRetGanancias]	= SPACE(14),
						[RegimenGanancias]		= SPACE(30),
						[ImpRetGanancias]		= REPLICATE('0', 13),
						[NroCertRetIva]			= SPACE(14),
						[RegimenIva]			= SPACE(30),
						[ProNroOrd]				= LEFT('BBVA_' + FORMAT(@TodayDate, 'yyyyMMdd') + SPACE(15), 15),
						[Filler1]				= SPACE(8),
						[AcredASusp]			= SPACE(1),
						[IPermFin]				= SPACE(1),
						[CliAje]				= SPACE(1),
						[NCuitPago]				= REPLICATE('0', 13),
						[NomePago]				= SPACE(40),
						[TipoDocumento]			= 'CUI',
						[NroDocumento]			= [TRD].[RecipientCUIT],
						[SucEntrega]			= '0000',
						[FechaEntrega]			= REPLICATE('0', 8),
						[FechaPago]				= REPLICATE('0', 8),
						[FormaPago]				= SPACE(2),
						[FormaCobro]			= '0',
						[DisponP]				= '0',
						[Deposito]				= '0',
						[NroCheque]				= REPLICATE('0', 13),
						[CodDevolucion]			= SPACE(6),
						[DescDevolucion]		= SPACE(40),
						[Filler2]				= SPACE(506),
						[DecimalAmount]			= [TD].[NetAmount],
						[idTransaction]			= [T].[idTransaction],
						[idTransactionLot]		= [T].[idTransactionLot],
						[ToProcess]				= 0
					FROM
						[LP_Operation].[Transaction]									[T]
							INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]		= [TL].[idTransactionLot]
							INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]			= [TRD].[idTransaction]
							INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]			= [TD].[idTransaction]
							INNER JOIN	[LP_Operation].[TransactionFromTo]				[TFT]	ON	[T].[idTransaction]			= [TFT].[IdTransaction]
							INNER JOIN	[LP_Configuration].[PaymentType]				[PT]	ON	[TRD].[idPaymentType]		= [PT].[idPaymentType]
							INNER JOIN	[LP_Configuration].[CurrencyType]				[CT]	ON	[T].[CurrencyTypeLP]		= [CT].[idCurrencyType]
							INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]	= [BAT].[idBankAccountType]
							INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]			= [T2].[idTransaction]
							INNER JOIN	[LP_Common].[Status]							[S]		ON	[T].[idStatus]				= [S].[idStatus]
							INNER JOIN  [LP_Configuration].[TransactionTypeProvider]	[TTP]	ON	[TTP].[idTransactionTypeProvider] = [T].[idTransactionTypeProvider]
							LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]		= [T].[idTransaction]
							LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant] = [TESM].[idEntitySubMerchant]
							INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]
					WHERE
							[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
						AND [TD].[NetAmount] > 0
						AND [TTP].[idTransactionType] = 2
					ORDER BY [T].[TransactionDate] ASC


					DECLARE @IterationI AS BIGINT = 1
					DECLARE @QtyRowsReg2 AS BIGINT = (SELECT COUNT(1) FROM @TempReg2)
					DECLARE @idReg2Temp AS BIGINT

					WHILE(@QtyRowsReg2 >= @IterationI)
					BEGIN
						SET @idReg2Temp = (SELECT [idx2] FROM @TempReg2 WHERE [idx2] = @IterationI)

						INSERT INTO @TempReg9([idx2], [IdentReg], [TipoReg], [TipoDocEmpre], [NroCuitEmpre], [Secuencia], [ProNroOrd], [ProNroBenef], [ProEstBenef], [ProDoctoTip], [ProDoctoNro], [ProDenomina], 
												[ProCatego], [ProPermitFinan], [ProCusTip], [ProCusSuc], [ProCusNro], [ProCbuNro], [ProIngBrts], [ProCalle], [ProNumero], [ProDepto], [ProPiso], [ProLocalid], 
												[ProCPostal], [ProCodProv], [ProCodPais], [ProEmail], [ProCalleEntrega], [ProNroEntrega], [ProDeptoEntrega], [ProPisoEntrega], [ProLocalidEntrega], [ProCPostalEntrega], 
												[ProCodProvEntrega], [ProCodPaisEntrega], [ProTelefTip], [ProTelefPre], [ProTelefCar], [ProTelefNro], [ProTelefInt], [ProTelefAlterTip], [ProTelefAlterPre], 
												[ProTelefAlterCar], [ProTelefAlterNro], [ProTelefAlterInt], [ProAutorizaNom1], [ProAutorizaTip1], [ProAutorizaDoc1], [ProAutorizaNom2], [ProAutorizaTip2], 
												[ProAutorizaDoc2], [ProAutorizaNom3], [ProAutorizaTip3], [ProAutorizaDoc3], [ProDatos], [ProMinuta], [Filler1], [ToProcess])
						SELECT 
							[idx2]							= @idReg2Temp,
							[IdentReg]						= '0306',
							[TipoReg]						= '090',
							[TipoDocEmpre]					= 'CUIT',
							[NroCuitEmpre]					= [TR2].[NroCuitEmpre],
							[Secuencia]						= REPLICATE('0', 6), -- TODO Logica Secuencia
							[ProNroOrd]						= [TR2].[ProNroOrd],
							[ProNroBenef]					= [TR2].[ProNroBeneficiario],
							[ProEstBenef]					= '1',
							[ProDoctoTip]					= 'CUI',
							[ProDoctoNro]					= [TR2].[NroDocumento],
							[ProDenomina]					= LEFT([TRD].[Recipient] + SPACE(40), 40),
							[ProCatego]						= SPACE(2),
							[ProPermitFinan]				= 'N',
							[ProCusTip]						= REPLICATE('0', 2),
							[ProCusSuc]						= REPLICATE('0', 3),
							[ProCusNro]						= REPLICATE('0', 10),
							[ProCbuNro]						= RIGHT(REPLICATE('0', 22) + [TRD].[CBU], 22),
							[ProIngBrts]					= SPACE(11),
							[ProCalle]						= LEFT('calle' + SPACE(24), 24),
							[ProNumero]						= SPACE(5),
							[ProDepto]						= SPACE(3),
							[ProPiso]						= SPACE(2),
							[ProLocalid]					= SPACE(28),
							[ProCPostal]					= SPACE(5),
							[ProCodProv]					= '01',
							[ProCodPais]					= '080',
							[ProEmail]						= LEFT('info@localpayment.com' + SPACE(40), 40),
							[ProCalleEntrega]				= SPACE(24),
							[ProNroEntrega]					= SPACE(5),
							[ProDeptoEntrega]				= SPACE(3),
							[ProPisoEntrega]				= SPACE(2),
							[ProLocalidEntrega]				= SPACE(28),
							[ProCPostalEntrega]				= SPACE(5),
							[ProCodProvEntrega]				= SPACE(2),
							[ProCodPaisEntrega]				= SPACE(3),
							[ProTelefTip]					= '00',
							[ProTelefPre]					= SPACE(4),
							[ProTelefCar]					= SPACE(4),
							[ProTelefNro]					= SPACE(5),
							[ProTelefInt]					= SPACE(18),
							[ProTelefAlterTip]				= '00',
							[ProTelefAlterPre]				= SPACE(4),
							[ProTelefAlterCar]				= SPACE(4),
							[ProTelefAlterNro]				= SPACE(5),
							[ProTelefAlterInt]				= SPACE(18),
							[ProAutorizaNom1]				= SPACE(25),
							[ProAutorizaTip1]				= SPACE(3),
							[ProAutorizaDoc1]				= REPLICATE('0', 8),
							[ProAutorizaNom2]				= SPACE(25),
							[ProAutorizaTip2]				= SPACE(3),
							[ProAutorizaDoc2]				= REPLICATE('0', 8),
							[ProAutorizaNom3]				= SPACE(25),
							[ProAutorizaTip3]				= SPACE(3),
							[ProAutorizaDoc3]				= REPLICATE('0', 8),
							[ProDatos]						= SPACE(100),
							[ProMinuta]						= REPLICATE('0', 8), -- TODO id interno?
							[Filler1]						= SPACE(218),
							[ToProcess]						= 0
						FROM @TempReg2 [TR2]
						LEFT JOIN [LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[TR2].[idTransaction]			= [TRD].[idTransaction]
						WHERE [TR2].[idx2] = @idReg2Temp

						SET @IterationI = @IterationI + 1
					END






					DECLARE @GaliciaBankCode [LP_Common].[LP_F_C3]
					SET @GaliciaBankCode = (SELECT RIGHT([Code], 3) FROM [LP_Configuration].[BankCode] WHERE [Code] = '00007' AND [idCountry] = 1)


			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* UPDATING SEQUENCE NUMBER: INI */  

			DECLARE
				@qtyRowsTemp BIGINT
				, @idxRowsTemp BIGINT

			SET @idxRowsTemp = 1
			SET @qtyRowsTemp = (SELECT COUNT(*) FROM @TempReg2)

			IF(@qtyRowsTemp > 0)
			BEGIN
				WHILE(@idxRowsTemp <= @qtyRowsTemp)
				BEGIN
					UPDATE @TempReg2 SET [Secuencia] = RIGHT(REPLICATE('0', 6) + CAST(@Secuencia AS VARCHAR), 6) WHERE idx2 = @idxRowsTemp
					SET @Secuencia = @Secuencia + 1
					UPDATE @TempReg9 SET [Secuencia] = RIGHT(REPLICATE('0', 6) + CAST(@Secuencia AS VARCHAR), 6) WHERE idx2 = @idxRowsTemp
					SET @Secuencia = @Secuencia + 1
				END
			END


			/* UPDATING SEQUENCE NUMBER: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* UPDATE TICKET ALTERNATIVE WITH 8 CHARACTERS FOR BBVA SYSTEM BLOCK: INI */

			--DECLARE @count INT
			--DECLARE @i INT
			--SET @count = ( SELECT COUNT(*) FROM @TempReg2 )
			--SET @i = 1

			DECLARE @maxTicket VARCHAR(8)

			DECLARE @nextTicketCalculation BIGINT
			DECLARE @nextTicket VARCHAR(8) 

			DECLARE @NewTicketAlternative VARCHAR(8)
			DECLARE @txnum AS INT

			DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
			  SELECT idx2
			  FROM @TempReg2

			OPEN tx_cursor;

			FETCH NEXT FROM tx_cursor INTO @txnum

			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @maxTicket =  ( SELECT MAX([TicketAlternative8]) FROM [LP_Operation].[Ticket] )
					IF(@maxTicket IS NULL)
					BEGIN
						SET @nextTicket = REPLICATE('0', 8)
					END
					ELSE
					BEGIN
						SET @nextTicketCalculation =   ( SELECT CAST (@maxTicket AS BIGINT)  + 1  )
						SET @nextTicket = ( SELECT CAST (@nextTicketCalculation AS VARCHAR(8)) )
					END

					SET @NewTicketAlternative = RIGHT(REPLICATE('0', 8) + @nextTicket ,8)

						UPDATE [LP_Operation].[Ticket]
						SET
							[TicketAlternative8] = @NewTicketAlternative,
							[DB_UpdDateTime] = GETUTCDATE()
						FROM
							[LP_Operation].[Ticket] [T]
								INNER JOIN @TempReg2 [TEMP] ON [T].[idTransaction] = [TEMP].[idTransaction]
						WHERE
							[TEMP].[idx2] = @txnum

						UPDATE @TempReg2
						SET [NroMinuta] = @NewTicketAlternative
						WHERE [idx2] = @txnum

						UPDATE @TempReg9
						SET [ProMinuta] = @NewTicketAlternative
						WHERE [idx2] = @txnum

					FETCH NEXT FROM tx_cursor INTO @txnum
				END

			CLOSE tx_cursor
			DEALLOCATE tx_cursor

			/* UPDATE TICKET ALTERNATIVE WITH 10 CHARACTERS FOR SUPERVIELLE SYSTEM BLOCK: FIN */


			/* UPDATE PAYOUT BLOCK: INI */

			UPDATE @TempReg2
				SET [LineComplete] = [IdentReg] + [TipoReg] + [TipoDocEmpre] + [NroCuitEmpre] + [Secuencia] + [ProNroBeneficiario] + [NroMinuta] + [Importe] + [NroCertRetGanancias] + [RegimenGanancias] + 
										[ImpRetGanancias] + [NroCertRetIva] + [RegimenIva] + [ProNroOrd] + [Filler1] + [AcredASusp] + [IPermFin] + [CliAje] + [NCuitPago] + [NomePago] + [TipoDocumento] + 
										[NroDocumento] + [SucEntrega] + [FechaEntrega] + [FechaPago] + [FormaPago] + [FormaCobro] + [DisponP] + [Deposito] + [NroCheque] + [CodDevolucion] + [DescDevolucion] + [Filler2]

			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* HEADER BLOCK: INI */

					DECLARE @Header VARCHAR(MAX)

					DECLARE @HIdentRegistro AS VARCHAR(4) = '0306'
					DECLARE @HTipoReg AS VARCHAR(3) = '010'
					DECLARE @HTipoDocEmpre AS VARCHAR(4) = 'CUIT'
					DECLARE @HNroCuitEmpre AS VARCHAR(13) = RIGHT(REPLICATE('0', 13) + @LpCuit, 13)
					DECLARE @HSecuencia AS VARCHAR(6) = REPLICATE('0', 6)
					DECLARE @HMoneda AS VARCHAR(1) = '0'
					DECLARE @HImporte AS VARCHAR(13) =  RIGHT(REPLICATE('0', 13) + (SELECT CAST(SUM(CAST([Importe] AS BIGINT)) AS VARCHAR(13)) FROM @TempReg2), 13)
					DECLARE @HFormaPago AS VARCHAR(2) = 'AB'
					DECLARE @HFormaCobro AS VARCHAR(1) = '0'
					DECLARE @HDisponPago AS VARCHAR(1) = '2'
					DECLARE @HDeposito AS VARCHAR(1) = '0'
					DECLARE @HFechaEmision AS VARCHAR(8) = FORMAT(@TodayDate, 'yyyyMMdd')
					DECLARE @HFechaEntrega AS VARCHAR(8) = FORMAT(@TodayDate, 'yyyyMMdd')
					DECLARE @HFechaPago AS VARCHAR(8) = FORMAT(@TodayDate, 'yyyyMMdd')
					DECLARE @HEntidad AS VARCHAR(4) = '0017'
					DECLARE @HSucCtaDebito AS VARCHAR(4) = '0056'
					DECLARE @HDvCtaDebito AS VARCHAR(2) = '13'
					DECLARE @HTipoCtaDebito AS VARCHAR(2) = '01'
					DECLARE @HMonedaCtaDebito as varchar(1) = '0'
					DECLARE @HNroCtaDebito AS VARCHAR(7) = '0077083'
					DECLARE @HCantInst aS VARCHAR(7) = RIGHT(REPLICATE('0', 7) + (SELECT CAST(COUNT(1) AS VARCHAR) FROM @TempReg2), 7)
					DECLARE @HEntregaLote as varchar(1) = SPACE(1)
					DECLARE @HSucEntregaLote as varchar(4) = SPACE(4)
					DECLARE @HFiller1 AS VARCHAR(6) = SPACE(6)
					DECLARE @HLibreImpresion AS VARCHAR(1) = 'N'
					DECLARE @HNombreFichero AS VARCHAR(12) = SPACE(12)
					DECLARE @HFechaProceso as varchar(8) = FORMAT(@TodayDate, 'yyyyMMdd')
					DECLARE @HContratoProv AS VARCHAR(20) = '00170316192700000277'
					DECLARE @HFiller2 AS VARCHAR(698) = SPACE(698)


					SET @Header = @HIdentRegistro + @HTipoReg + @HTipoDocEmpre + @HNroCuitEmpre + @HSecuencia + @HMoneda + @HImporte + @HFormaPago + @HFormaCobro + @HDisponPago + @HDeposito + 
									@HFechaEmision + @HFechaEntrega + @HFechaPago + @HEntidad + @HSucCtaDebito + @HDvCtaDebito + @HTipoCtaDebito + @HMonedaCtaDebito + @HNroCtaDebito + @HCantInst + 
									@HEntregaLote + @HSucEntregaLote + @HFiller1 + @HLibreImpresion + @HNombreFichero + @HFechaProceso + @HContratoProv + @HFiller2

			/* HEADER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* FOOTER BLOCK: INI */

					DECLARE @Footer VARCHAR(MAX)

					DECLARE @FIdentReg AS VARCHAR(4) = '0306'
					DECLARE @FTipoReg AS VARCHAR(3) = '095'
					DECLARE @FTipoDocEmpre  AS VARCHAR(4) = @HTipoDocEmpre
					DECLARE @FNroCuitEmpre AS VARCHAR(13) = @HNroCuitEmpre
					DECLARE @FSecuencia AS VARCHAR(6) = RIGHT(REPLICATE('0', 6) + CAST(@Secuencia AS VARCHAR), 6)
					DECLARE @FSumaImporte AS VARCHAR(13) = @HImporte
					DECLARE @FCantPagos AS VARCHAR(7) = @HCantInst
					DECLARE @FTotReg AS VARCHAR(10) = RIGHT(REPLICATE('0', 10) + (SELECT CAST(COUNT(1) * 2 + 2 AS VARCHAR(10)) FROM @TempReg2), 10)
					DECLARE @FFiller1 AS VARCHAR(790) = SPACE(790)


					SET @Footer = @FIdentReg + @FTipoReg + @FTipoDocEmpre + @FNroCuitEmpre + @FSecuencia + @FSumaImporte + @FCantPagos + @FTotReg + @FFiller1

			/* FOOTER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


			/* INSERT LINES BLOCK: INI */
					INSERT INTO @Lines VALUES(@Header)
					DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
					  SELECT idx2
					  FROM @TempReg2

					OPEN tx_cursor;

					FETCH NEXT FROM tx_cursor INTO @txnum

					WHILE @@FETCH_STATUS = 0
					BEGIN
						-- INSERTING REG 2
						INSERT INTO @Lines
						SELECT [LineComplete] FROM @TempReg2 WHERE idx2 = @txnum

						-- INSERTING REG 9
						INSERT INTO @Lines
						SELECT [IdentReg] + [TipoReg] + [TipoDocEmpre] + [NroCuitEmpre] + [Secuencia] + [ProNroOrd] + [ProNroBenef] + [ProEstBenef] + [ProDoctoTip] + [ProDoctoNro] + [ProDenomina] + [ProCatego] + 
								[ProPermitFinan] + [ProCusTip] + [ProCusSuc] + [ProCusNro] + [ProCbuNro] + [ProIngBrts] + [ProCalle] + [ProNumero] + [ProDepto] + [ProPiso] + [ProLocalid] + [ProCPostal] + 
								[ProCodProv] + [ProCodPais] + [ProEmail] + [ProCalleEntrega] + [ProNroEntrega] + [ProDeptoEntrega] + [ProPisoEntrega] + [ProLocalidEntrega] + [ProCPostalEntrega] + [ProCodProvEntrega] + 
								[ProCodPaisEntrega] + [ProTelefTip] + [ProTelefPre] + [ProTelefCar] + [ProTelefNro] + [ProTelefInt] + [ProTelefAlterTip] + [ProTelefAlterPre] + [ProTelefAlterCar] + [ProTelefAlterNro] + 
								[ProTelefAlterInt] + [ProAutorizaNom1] + [ProAutorizaTip1] + [ProAutorizaDoc1] + [ProAutorizaNom2] + [ProAutorizaTip2] + [ProAutorizaDoc2] + [ProAutorizaNom3] + [ProAutorizaTip3] + 
								[ProAutorizaDoc3] + [ProDatos] + [ProMinuta] + [Filler1]
						FROM @TempReg9 WHERE idx2 = @txnum

						SET @IterationI = @IterationI + 1

						FETCH NEXT FROM tx_cursor INTO @txnum
					END

					CLOSE tx_cursor
					DEALLOCATE tx_cursor

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
						WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM @TempReg2)

						UPDATE	[LP_Operation].[Transaction]
						SET		[idStatus] = @idStatus
								,[idProviderPayWayService] = @idProviderPayWayService
								,[idTransactionTypeProvider] = @idTransactionTypeProvider
								,[idLotOut] = @idLotOut
								,[lotOutDate] = GETDATE()
						WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempReg2)

						UPDATE	[LP_Operation].[TransactionRecipientDetail]
						SET		[idStatus] = @idStatus
						WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempReg2)

						UPDATE	[LP_Operation].[TransactionDetail]
						SET		[idStatus] = @idStatus
						WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempReg2)

						UPDATE	[LP_Operation].[TransactionInternalStatus]
						SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
						WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempReg2)

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


