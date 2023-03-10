USE [LocalPaymentPROD]
GO
/****** Object:  StoredProcedure [LP_Operation].[CHL_Payout_BANCOCHILE_822_Bank_Operation_Download]    Script Date: 4/6/2022 4:04:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LP_Operation].[CHL_Payout_BANCOCHILE_822_Bank_Operation_Download]
(
@TransactionMechanism	BIT
,@JSON					VARCHAR(MAX)
--SET @JSON = '[16464265520000]'
)
AS
BEGIN

BEGIN TRY


		DECLARE @idCountry	INT
		SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'CLP' AND [Active] = 1 )

		DECLARE @idProvider	INT
		SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BCHILE822' AND [idCountry] = @idCountry AND [Active] = 1 )

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
		
DECLARE @TempBody TABLE
(
	[idx]								INT IDENTITY (1,1)
	,[TipoRegistro]						varchar(2)
	,[RutEmpresa]						varchar(20)
	,[RutEmpresaDV]						varchar(1)
	,[CódigoConvenio]					varchar(3)
	,[Filler1]							varchar(2)
	,[NumeroNomina]   					varchar(5)
	,[MediodePago]						varchar(2)
	,[RutBeneficiario] 					varchar(20)
	,[RutBeneficiarioDV]				varchar(1)
	,[NombreBeneficiario]				varchar(60)
	,[TipodeDireccion] 					varchar(1)
	,[DireccionBeneficiario]			varchar(35)
	,[ComunaBeneficiario]				varchar(15)
	,[CiudadBeneficiario]				varchar(15)
	,[Filler2]							varchar(7)
	,[CodActEconomica]					varchar(2)
	,[CodBanco]							varchar(3)
	,[NumeroCuenta]						varchar(22)
	,[OficinaDestino]					varchar(3)
	,[MontoPago]						varchar(13)
	,[DescripcionPago]					varchar(119)
	,[NumeroMensaje]					varchar(4)
	,[ValeVistaAcumulado]				varchar(1)
	,[TipoDocumento]					varchar(3)
	,[NDocumento]						varchar(10)
	,[Signo]							varchar(1)
	,[CorrelativoImpresiónValeVista]	varchar(6)
	,[ValeVistaVirtual]					varchar(1)
	,[Filler3]							varchar(45)
	,[LineComplete]						VARCHAR(MAX)
	,[idTransactionLot]					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
	,[idTransaction]					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

	,[DecimalAmount]					[LP_Common].[LP_F_DECIMAL]
	,[Acum]								[LP_Common].[LP_F_DECIMAL] NULL
	,[ToProcess]						[LP_Common].[LP_F_BOOL]
)

DECLARE @LinesPayout TABLE
(
	[idLine]			INT IDENTITY(1,1)
	, [Line]			VARCHAR(MAX)
)

INSERT INTO @TempBody ([TipoRegistro],[RutEmpresa],[RutEmpresaDV],[CódigoConvenio],[Filler1],[NumeroNomina],[MediodePago],[RutBeneficiario],[RutBeneficiarioDV],[NombreBeneficiario],[TipodeDireccion]
									,[DireccionBeneficiario],[ComunaBeneficiario],[CiudadBeneficiario],[Filler2],[CodActEconomica],[CodBanco],[NumeroCuenta],[OficinaDestino],[MontoPago],[DescripcionPago]
									,[NumeroMensaje],[ValeVistaAcumulado],[TipoDocumento],[NDocumento],[Signo],[CorrelativoImpresiónValeVista],[ValeVistaVirtual],[Filler3],[LineComplete],[idTransactionLot]
									,[idTransaction],[DecimalAmount],[Acum],[ToProcess])

SELECT [TipoRegistro] = '02'
,[RutEmpresa] = '077175361'
,[RutEmpresaDV] = '2'
,[CódigoConvenio] = '822'
,[Filler1] = REPLICATE(' ',2)
,[NumeroNomina]	= '00001'
,[MediodePago] =  CASE WHEN [BC].[Code] = '001' THEN  -- BANCO CHILE
							CASE WHEN ([BAT].[Code] = 'C') THEN '01' -- CUENTA CORRIENTE  
							WHEN ([BAT].[Code] = 'A') THEN '06' -- CAJA DE AHORRO 
							WHEN ([BAT].[Code] = 'V') THEN '01' END -- CUENTA VISTA 
							ELSE -- OTROS BANCOS
							CASE WHEN ([BAT].[Code] = 'C') THEN '07'  -- CUENTA CORRIENTE 
							WHEN ([BAT].[Code] = 'A') THEN '08' -- CAJA DE AHORRO
							WHEN ([BAT].[Code] = 'V') THEN '07' END -- CUENTA VISTA 
				  END
--,[RutBeneficiario] = LEFT(REPLACE(REPLACE([TRD].[RecipientCUIT],'.',''),'-',''),11)
,[RutBeneficiario] = RIGHT(REPLICATE('0',9) + LEFT(REPLACE(REPLACE([TRD].[RecipientCUIT],'.',''),'-',''),8), 9) 
--,[RutBeneficiarioDV] = RIGHT(LEFT(REPLACE(REPLACE([TRD].[RecipientCUIT],'.',''),'-',''), 11), 1)
,[RutBeneficiarioDV] = RIGHT([TRD].[RecipientCUIT], 1)	
,[NombreBeneficiario] = [TRD].[Recipient] + REPLICATE(' ', 60 - LEN([TRD].[Recipient]))
,[TipodeDirección] = '0'
,[DirecciónBeneficiario] = REPLICATE(' ',35)
,[ComunaBeneficiario] = REPLICATE(' ',15)
,[CiudadBeneficiario] = REPLICATE(' ',15)
,[Filler2] = REPLICATE(' ',7)
,[CodActEconomica] = REPLICATE(' ',2) -- Obligatorio para Medios de Pago (“02” V. Vista Mesón, “04” V. V. Empresa. Asignar según Tabla)
,[CodBanco] = RIGHT([BC].[Code] , 3)
,[NumeroCuenta] = [TRD].[RecipientAccountNumber] + REPLICATE(' ', 22 - LEN([TRD].[RecipientAccountNumber]))
,[OficinaDestino] = '000' -- Oficina que entrega el V. Vista. según Tabla Nº 3
,[MontoPago] = CONCAT(REPLICATE('0', 13 - LEN(CAST(CAST([TD].[NetAmount] AS INT) AS varchar) + REPLICATE('0', 2))), CAST(CAST([TD].[NetAmount] AS INT) AS varchar) + REPLICATE('0', 2))
--,[MontoPago] =  RIGHT(REPLICATE('0',13) + CAST(CAST([TD].[NetAmount] AS INT) AS VARCHAR(13)),13) 
,[DescripcionPago] = REPLICATE(' ',119)
,[NumeroMensaje] = REPLICATE('0',4)
,[ValeVistaAcumulado] = 'N' -- “S”: Vale Vista Acumulado, “N”: Vale Vista Normal
,[TipoDocumento] = REPLICATE(' ',3)
,[NDocumento] = REPLICATE(' ',10)
,[Signo] = ' ' -- “+” o “-”
,[CorrelativoImpresiónValeVista] = REPLICATE('0',6)-- No encuentro definicion en ninguna tabla
,[ValeVistaVirtual] = 'S' -- “S”: vale Vista Virtual, “N”: Vale Vista Mesón
,[Filler3] = REPLICATE(' ',45)
,[LineComplete] = NULL
,[idTransactionLot] = [TL].[idTransactionLot]
,[idTransaction]	= [T].[idTransaction]
,[DecimalAmount]	= [TD].[NetAmount]
,[Acum] = NULL
,[ToProcess] = 0

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
		ORDER BY [T].[TransactionDate] ASC
/* HEADER BLOCK: INI */

		DECLARE @idStatus INT
		DECLARE @idLotOut INT
		SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('InProgress')
		SET @idLotOut =  ( SELECT MAX([idLotOut]) + 1 FROM [LP_Operation].[Transaction] )
		IF(@idLotOut IS NULL)
		BEGIN
			SET @idLotOut = 1
		END

				DECLARE @Header VARCHAR(MAX)
				
				DECLARE @TipoRegistro			Varchar(2)	-- Asignar “01”
				SET @TipoRegistro = '01'
				DECLARE @RutEmpresaNum			Varchar(9)	-- Obligatorio
				SET @RutEmpresaNum = '077175361' 
				DECLARE @RutEmpresaDV			Varchar(1)	-- Obligatorio
				SET @RutEmpresaDV = '2'
				DECLARE @CodigoConvenio			Varchar(3)	-- Lo asigna el Ejecutivo de Servicio ( Bco. Chile )
				SET @CodigoConvenio = '822' 
				DECLARE @NumeroNomina   		Varchar(5)	-- (*) Nº Único identificador de la Nómina
				SET @NumeroNomina = '00001'
				DECLARE @NombreNomina    		Varchar(25)	-- Lo asigna la Empresa
				SET @NombreNomina = CONCAT('LOTE', CAST(@idLotOut AS varchar), REPLICATE(' ', 25 - LEN(@idLotOut) - 4))
				DECLARE @CódigoMoneda 			Varchar(2)	-- Asignar “01” para Pesos
				SET @CódigoMoneda = '01'
				DECLARE @FechaPago  			Varchar(8)	-- Formato “AAAAMMDD”
				SET @FechaPago = CONCAT(YEAR(GETDATE()),FORMAT(MONTH(GETDATE()),'00'),FORMAT(DAY(GETDATE()),'00'))
				DECLARE @MontoTotalPago			Varchar(13)	-- Con dos decimales, sin coma ni punto separador
				SET @MontoTotalPago =  CONCAT(RIGHT(REPLICATE('0', 11) + CAST((SELECT SUM(CAST(DecimalAmount AS INT)) FROM @TempBody) AS varchar), 11), '00')
				DECLARE @Filler1					Varchar(3)	-- Llenar con espacios
				SET @Filler1 = REPLICATE(' ',3)
				DECLARE @TipoEndosoValevista	Varchar(1)	-- Asignar “E” si es Endosable, Asignar “N” si es nominativo; 
				SET @TipoEndosoValevista = 'N'
				DECLARE @Filler2					Varchar(322)	-- Llenar con espacios
				SET @Filler2 = REPLICATE(' ',322)
				DECLARE @TipoPago				Varchar(6)	-- Asignar según Tabla de Tipos de Pago 4
				SET @TipoPago = '010201'
				
				--DECLARE @Registers VARCHAR(MAX)
				--SET @Registers = (SELECT COUNT(*) FROM @TempBody)

				SET @Header = @TipoRegistro + @RutEmpresaNum + @RutEmpresaDV + @CodigoConvenio + @NumeroNomina + @NombreNomina + @CódigoMoneda + @FechaPago + @MontoTotalPago + @Filler1 + @TipoEndosoValevista + @Filler2 + @TipoPago --+ @Registers

				
		/* HEADER BLOCK: FIN */
		/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

		/* UPDATE PAYOUT BLOCK: INI */
		--SELECT [TipoRegistro], [RutEmpresa], [RutEmpresaDV], [CódigoConvenio], [Filler1], [NumeroNomina]	,[MediodePago], [RutBeneficiario], [RutBeneficiarioDV], [NombreBeneficiario], [TipodeDireccion], [DireccionBeneficiario], [ComunaBeneficiario], [CiudadBeneficiario], [Filler2], [CodActEconomica], [CodBanco]+[NumeroCuenta], [OficinaDestino], [MontoPago], [DescripcionPago], [NumeroMensaje], [ValeVistaAcumulado], [TipoDocumento], [NDocumento], [Signo], [CorrelativoImpresiónValeVista], [ValeVistaVirtual], [Filler3] FROM @TempBody

		UPDATE @TempBody
		SET [LineComplete] = [TipoRegistro] + [RutEmpresa] + [RutEmpresaDV] + [CódigoConvenio] + [Filler1] + [NumeroNomina]	+ [MediodePago] + [RutBeneficiario] + [RutBeneficiarioDV] + [NombreBeneficiario] + [TipodeDireccion] + [DireccionBeneficiario] + [ComunaBeneficiario] + [CiudadBeneficiario] + [Filler2] + [CodActEconomica] + [CodBanco]+[NumeroCuenta] + [OficinaDestino] + [MontoPago] + [DescripcionPago] + [NumeroMensaje] + [ValeVistaAcumulado] + [TipoDocumento] + [NDocumento] + [Signo] + [CorrelativoImpresiónValeVista] + [ValeVistaVirtual] + [Filler3] 

		/* UPDATE PAYOUT BLOCK: FIN */
		/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
		
		/* INSERT LINES BLOCK: INI */
		INSERT INTO @LinesPayout VALUES(@Header)
		INSERT INTO @LinesPayout
		SELECT [LineComplete] FROM @TempBody

		/* INSERT LINES BLOCK: FIN */
		/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


		--/* UPDATE TRANSACTIONS STATUS BLOCK: INI */

		BEGIN TRANSACTION

			UPDATE	[LP_Operation].[TransactionLot]
			SET		[idStatus] = @idStatus
			WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM @TempBody)

			UPDATE	[LP_Operation].[Transaction]
			SET		[idStatus] = @idStatus
					,[idProviderPayWayService] = @idProviderPayWayService
					,[idTransactionTypeProvider] = @idTransactionTypeProvider
					,[idLotOut] = @idLotOut
					,[lotOutDate] = GETDATE()
			WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempBody)

			UPDATE	[LP_Operation].[TransactionRecipientDetail]
			SET		[idStatus] = @idStatus
			WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempBody)

			UPDATE	[LP_Operation].[TransactionDetail]
			SET		[idStatus] = @idStatus
			WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempBody)

			UPDATE	[LP_Operation].[TransactionInternalStatus]
			SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
			WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempBody)

		COMMIT TRANSACTION
		

		/* UPDATE TRANSACTIONS STATUS BLOCK: FIN */

		/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

		/* SELECT FINAL BLOCK: INI */

			DECLARE @Rows INT
		SET @Rows = ((SELECT COUNT(*) FROM @TempBody))

		IF(@Rows > 0)
		BEGIN
			SELECT [Line] FROM @LinesPayout ORDER BY [idLine] ASC
		END

		/* SELECT FINAL BLOCK: FIN */

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()--'INTERNAL ERROR'
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

