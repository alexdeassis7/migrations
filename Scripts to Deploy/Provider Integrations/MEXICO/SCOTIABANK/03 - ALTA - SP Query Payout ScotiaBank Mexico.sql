USE [LocalPaymentPROD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LP_Operation].[MEX_Payout_ScotiaBank_Bank_Operation_Download]
(
	@JSON VARCHAR(MAX)
)
AS
BEGIN

	--SET @JSON = '[16542790350000,16542732840000,16542709740000]'
	BEGIN TRY
	
	/* Bootstraping*/
	DECLARE @spacerChar CHAR(1) = CHAR(32); --   /* Change for Debug purpose to some printable character like # character or just put CHAR(32) as value if you need whitespaces */
	DECLARE @newLotId INT = (SELECT TOP(1) MAX([idLotOut]) + 1 FROM [LP_Operation].[Transaction]);

	/* CONFIG BLOCK: INI */
	DECLARE @idCountry	INT
	SET @idCountry = ( SELECT TOP(1) [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'MXN' AND [Active] = 1  ORDER BY idCountry)

	DECLARE @idProvider	INT
	SET @idProvider = ( SELECT TOP(1) [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'SCOTMEX' AND [idCountry] = @idCountry AND [Active] = 1  ORDER BY idProvider)

	-- Status Variable
	DECLARE @statusReceived INT =  [LP_Operation].[fnGetIdStatusByCode]('Received')

	-- DECLARING TABLE WITH SELECTED TICKETS TO DOWNLOAD
	DECLARE @TempTxsToDownload AS TABLE (idTransaction INT NOT NULL)
			
	INSERT INTO @TempTxsToDownload
	SELECT idTransaction FROM [LP_Operation].[Ticket]
	WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)
	
	DECLARE @idProviderPayWayService INT

	SET @idProviderPayWayService=(SELECT [PPWS].[idProviderPayWayService]
                        FROM [LP_Configuration].[ProviderPayWayServices] [PPWS]
                            INNER JOIN [LP_Configuration].[Provider] [PR] ON [PR].[idProvider]=[PPWS].[idProvider]
                            INNER JOIN [LP_Configuration].[PayWayServices] [PWS] ON [PWS].[idPayWayService]=[PPWS].[idPayWayService]
                        WHERE [PR].[idProvider]=@idProvider 
							AND [PR].[idCountry]=@idCountry 
							AND [PWS].[Code]='BANKDEPO' 
							AND [PWS].[idCountry]=@idCountry);

	DECLARE @idTransactionTypeProvider INT

	SET @idTransactionTypeProvider=(SELECT [idTransactionTypeProvider]
                        FROM [LP_Configuration].[TransactionTypeProvider] [TTP]
                                INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType]=[TTP].[idTransactionType]
                        WHERE [TTP].[idProvider]=@idProvider AND [TT].[Code]='PODEPO');
							
	DECLARE @Lines TABLE
	(
		 [idLine]			INT IDENTITY(1,1)
		,[Line]			VARCHAR(MAX)
	)

	-- INTERNAL BATCH NUMBER
	DECLARE @InternalBatchId VARCHAR(2)

	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ INICIO HEADER #1 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
	DECLARE @TempHeader1 TABLE
	(
	--****************************************************************************************************************************************************************************************
	--  | CAMPO									| TIPO		  | ES NULL?  |	VALOR DEFAULT						   |   DESCRIPCION					| OBSERVACION / COMENTARIO DEL AUTOR
	--****************************************************************************************************************************************************************************************
		 [FT] 								    VARCHAR(2)		NULL		DEFAULT('EE')							-- TIPO DE ARCHIVO				(FIJO X DOC)
		,[RT]									VARCHAR(2)		NULL		DEFAULT('HA')							-- TIPO DE REGISTRO				(FIJO X DOC)
		,[NC]									VARCHAR(5)		NULL		DEFAULT(47172)							-- NUMERO DE CONVENIO			(FIJO PREASIGNADO DE SCOTIABANK PARA LP)
		,[InternalSequenceNumber]				VARCHAR(2)		NOT NULL											-- NUMERO DE SECUENCIA LP		(DINAMICO, VIENE DE TABLA Y SE REINICIA CADA DIA)
		,[SCOT_DATA]							VARCHAR(27)	    NULL		DEFAULT(REPLICATE('0',27))				-- DATA DE SCOTIABANK			(DATO QUE SCOTIABANK RELLENA DE SU LADO) 
		,[FILLER]								VARCHAR(332)	NOT NULL											-- CARACTER DE RELLENO			(CHARACTER DE RELLENO PARA LLENAR TODO EL LARGO REQUERIDO
	)
			
	DECLARE @NextBatchId INT;

	EXEC LP_Operation.GetLastInternalBatchNumberByProviderId @ProviderId=@idProvider,
		@NextBatchId=@NextBatchId OUTPUT; -- int

	SET @InternalBatchId=RIGHT('0' + CONVERT(VARCHAR, @NextBatchId), 2);

	INSERT INTO @TempHeader1(InternalSequenceNumber,FILLER)VALUES(@InternalBatchId, REPLICATE(@spacerChar,332));

	DECLARE @Header1 TABLE 
	(
		[Header1] VARCHAR(370) NOT NULL
	)
			
	INSERT INTO @Lines(Line)
	VALUES((SELECT CONCAT(FT,RT,NC,InternalSequenceNumber,SCOT_DATA,FILLER) FROM @TempHeader1))

	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ FIN HEADER #1 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ INICIO HEADER #2 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
	DECLARE @Header2 TABLE 
	(
		[Header2] VARCHAR(370) NOT NULL
	)

	DECLARE @fixed_Header_2 VARCHAR(34) = 'EEHB000000256043218214315340001000'
	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ FIN HEADER #2 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

	DECLARE @TempDetail1 TABLE
	(
	--****************************************************************************************************************************************************************************************
	--  | CAMPO									| TIPO		  | ES NULL?  |	VALOR DEFAULT						   |   DESCRIPCION					| OBSERVACION / COMENTARIO DEL AUTOR
	--****************************************************************************************************************************************************************************************
		[idx]									INT IDENTITY (1,1)													-- AUTONUMERICO
		,[FT]									VARCHAR(2)		NULL		DEFAULT('EE')							-- TIPO DE ARCHIVO				(FIJO X DOC)
		,[RT]									VARCHAR(2)		NULL		DEFAULT('DA')							-- TIPO DE REGISTRO				(FIJO X DOC)
		,[MT]									VARCHAR(2)		NULL		DEFAULT('04')							-- TIPO DE MOVIMIENTTO			(FIJO X DOC) ABONO EN CUENTA SBI O DE OTRO BANCO	
		,[CurrencyType]							VARCHAR(2)		NULL		DEFAULT('00')							-- TIPO MONEDA					00 Pesos MEX, 01 Dolares Americanos (USD)
		,[Amount]							    VARCHAR(15)		NOT NULL	DEFAULT('00')							-- MONTO						Dos Decimales (RELLENO LADO IZQ con 0
		,[DateToPay]							VARCHAR(8)		NULL		DEFAULT(CONVERT(CHAR(8),GETDATE(),112)) -- FECHA DE PAG					FECHA DE DOWNLOAD en formato AAAAMMDD	
		,[Concept]								VARCHAR(2)		NULL		DEFAULT('03')							-- CONCEPTO / SERVICIO			(VALOR FIJO)  03- OTRAS TRANSFERENCIAS
		,[BeneficiaryNickName]					VARCHAR(20)		NOT NULL											-- NickName (Nombre Cuenta)		Parte de Nombre y del Apellido
		,[BenefRUT]								VARCHAR(13)		NOT NULL											-- RFC-Beneficiario				CUIT ([TRD].[RecipientCUIT])
		,[BeneficiaryName]						VARCHAR(40)		NOT NULL											-- NOMBRE-BENEFICIARIO			
		,[PaymentReference]						VARCHAR(16)		NOT NULL											-- REFERENCIA DE PAGO			
		,[PlazaPago]							VARCHAR(5)		NULL		DEFAULT(REPLICATE('0',5))				-- CARACTER DE RELLENO			( relleno con 0)
		,[SucursalPago]							VARCHAR(5)		NULL		DEFAULT(REPLICATE('0',5))				-- CARACTER DE RELLENO			( relleno con 0)
		,[BeneficiaryAccountNumber]				VARCHAR(20)		NOT NULL											-- NUMERO DE CUENTA				( justificando con 0 )
		,[CountryCode]							VARCHAR(5)		NULL		DEFAULT(REPLICATE('0',5))				-- PAIS							( relleno 0)
		,[CityStates]							VARCHAR(40)		NULL		DEFAULT(REPLICATE(CHAR(32),40))			-- CIUDAD						( relleno con espacios en blanco)
		,[BankAccountType]						VARCHAR(1)		NULL		DEFAULT('9')							-- TIPO CUENTA					( VALOR DEFAULT  = 9, CUENTA DE CHEQUES CLABE)
		,[DigitInterchange]						VARCHAR(1)		NULL		DEFAULT(CHAR(32))						-- DIGITO INTERCAMBIO			( VALOR DEFAULT  = 9, CUENTA DE CHEQUES CLABE)
		,[PlazaAccountBank]						VARCHAR(5)		NULL		DEFAULT(REPLICATE('0',5))				-- PLAZA CUENTA BANCO			( VALOR DEFAULT  = 0, TODOS CEROS)
		,[BankSenderNumber]						VARCHAR(3)		NULL		DEFAULT('044')							-- NUM BANCO EMISOR				( VALOR DEFAULT  = 044, Scotiabank Inverlat)
		,[BankSenderReceptor]					VARCHAR(3)		NOT NULL											-- NUM BANCO RECEPTOR			(Sin valor default, 3 digitos)
		,[AvailabilityTermDays]					VARCHAR(3)		NULL		DEFAULT('001')							-- DIAS-VIGENCIA				Numero de Dias que estara vigente el pago (Por defecto segun ejemplo, es 001)
		,[PaymentConcept]						VARCHAR(50)		NOT NULL											-- CONCEPTO PAGO				OBLIGATORIO
		,[CAMPO-USO-EMPRESA1]					VARCHAR(20)		NULL		DEFAULT(REPLICATE(CHAR(32),20))			-- CAMPO-USO-EMPRESA-1			(Espacios en blanco)
		,[CAMPO-USO-EMPRESA2]					VARCHAR(20)		NULL		DEFAULT(REPLICATE(CHAR(32),20))			-- CAMPO-USO-EMPRESA-2			(Espacios en blanco)
		,[CAMPO-USO-EMPRESA3]					VARCHAR(20)		NULL		DEFAULT(REPLICATE(CHAR(32),20))			-- CAMPO-USO-EMPRESA-3			(Espacios en blanco)
		,[Filler324To370]						VARCHAR(47)		NULL		DEFAULT(REPLICATE('0',47))				-- RELLENO DEL 324 A 370		(Rellenado con 0)
		,[DecimalAmount]						LP_COMMON.LP_F_DECIMAL    NOT NULL
		,[idTransactionLot]						LP_Common.LP_I_UNIQUE_IDENTIFIER_INT	NOT NULL
		,[idTransaction]						LP_Common.LP_I_UNIQUE_IDENTIFIER_INT	NOT NULL
	)

	DECLARE @Detail1 TABLE (
		[Detail1] VARCHAR(370)
	)

	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ FIN DETALLE #1 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

			
	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ INICIO DETALLE #2 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
	DECLARE @Detail2 TABLE ([Detail2] VARCHAR(370))
	DECLARE @inlineDetail2 VARCHAR(370)= RIGHT('EEDM' + REPLICATE(@spacerChar, (370 - LEN('EEDM'))),370)

	INSERT INTO @Detail2(Detail2) VALUES(@inlineDetail2)
			
	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ FIN DETALLE #2 ]    °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ INICIO FOOTER #1 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

	DECLARE @TempFooter1 TABLE
	(
	--****************************************************************************************************************************************************************************************
	--  | CAMPO									| TIPO		  | ES NULL?  |	VALOR DEFAULT						   |   DESCRIPCION					| OBSERVACION / COMENTARIO DEL AUTOR
	--****************************************************************************************************************************************************************************************
			[idx]									INT IDENTITY (1,1)													-- AUTONUMERICO
				
		,[FT]									VARCHAR(2)		NULL		DEFAULT('EE')							-- TIPO DE ARCHIVO				(FIJO X DOC)
		,[RT]									VARCHAR(2)		NULL		DEFAULT('TB')							-- TIPO DE REGISTRO				(FIJO X DOC)
		,[UpQuantity]							VARCHAR(7)		NOT NULL											-- CANTIDAD DE ALTAS			(Cantidad de Movimientos que hace el beneficiario,  Ej. 0000001 (1 Movimiento)
		,[UpAmmount]							VARCHAR(17)		NOT NULL											-- MONTO DE LA OP				(Monto de Operacion relleno con 0,  si fuera ej. 1000 pesos seria '00000000000001000'
		,[DownQuantity]							VARCHAR(7)		NULL		DEFAULT(REPLICATE('0',7))				-- CANTIDAD DE BAJAS			(Cantidad de Movimientos de BAJA que hace el beneficiario,  Ej. 0000000 (0 Movimiento)
		,[DownAmmount]							VARCHAR(17)		NULL		DEFAULT(REPLICATE('0',17))				-- MONTO DE LA OP				(Monto de Operacion relleno con 0,  si fuera ej. 1000 pesos seria '00000000000000000'
		,[SCOTIA_FILLER_ZERO]					VARCHAR(195)	NULL		DEFAULT(REPLICATE(0,195))				-- RELLENO DEL 53 A 247			(Rellenado con 0)
		,[FILLER]								VARCHAR(123)	NULL		DEFAULT(REPLICATE(CHAR(32),123))		-- RELLENO DEL 248 A 370		(Rellenado con ESPACIO EN BLANCO)
	)

	DECLARE @Footer1 TABLE
	(
		Footer1 VARCHAR(370)
	)

	
	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ FIN FOOTER #1 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ INICIO FOOTER #2 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
	DECLARE @TempFooter2 TABLE
	(
	--****************************************************************************************************************************************************************************************
	--  | CAMPO									| TIPO		  | ES NULL?  |	VALOR DEFAULT						   |   DESCRIPCION					| OBSERVACION / COMENTARIO DEL AUTOR
	--****************************************************************************************************************************************************************************************
		[idx]									INT IDENTITY (1,1)													-- AUTONUMERICO
		,[FT]									VARCHAR(2)		NULL		DEFAULT('EE')							-- TIPO DE ARCHIVO				(FIJO X DOC)
		,[RT]									VARCHAR(2)		NULL		DEFAULT('TA')							-- TIPO DE REGISTRO				(FIJO X DOC)
		,[UpQuantity]							VARCHAR(7)		NOT NULL											-- CANTIDAD DE ALTAS			(Cantidad de Movimientos que hace el beneficiario,  Ej. 0000001 (1 Movimiento)
		,[UpAmmount]							VARCHAR(17)		NOT NULL											-- MONTO DE LA OP				(Monto de Operacion relleno con 0,  si fuera ej. 1000 pesos seria '00000000000001000'
		,[DownQuantity]							VARCHAR(7)		NULL		DEFAULT(REPLICATE('0',7))				-- CANTIDAD DE BAJAS			(Cantidad de Movimientos de BAJA que hace el beneficiario,  Ej. 0000000 (0 Movimiento)
		,[DownAmmount]							VARCHAR(17)		NULL		DEFAULT(REPLICATE('0',17))				-- MONTO DE LA OP				(Monto de Operacion relleno con 0,  si fuera ej. 1000 pesos seria '00000000000000000'
		,[SCOTIA_FILLER_ZERO]					VARCHAR(195)	NULL		DEFAULT(REPLICATE(0,195))				-- RELLENO DEL 53 A 250			(Rellenado con 0)
		,[FILLER]								VARCHAR(123)	NULL		DEFAULT(REPLICATE(CHAR(32),123))		-- RELLENO DEL 251 A 370		(Rellenado con ESPACIO EN BLANCO)
	)

	DECLARE @Footer2 TABLE
	(
		Footer2 VARCHAR(370)
	)
			
	-- °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° [ FIN FOOTER #2 ] °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° x °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
	-- /* CONFIG BLOCK: FIN */
	-- /* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

	INSERT INTO @TempDetail1(Amount, BeneficiaryNickName, BenefRUT, BeneficiaryName, PaymentReference, BeneficiaryAccountNumber, CityStates, BankSenderReceptor, PaymentConcept, 
				[CAMPO-USO-EMPRESA1],[CAMPO-USO-EMPRESA2],[CAMPO-USO-EMPRESA3], [DecimalAmount], [idTransactionLot], [idTransaction])
	SELECT 
		 [Amount] = RIGHT(REPLICATE('0',15) + CAST(CAST([TD].[NetAmount] AS INT) AS VARCHAR(15)),15)
		,[BeneficiaryNickName] = LEFT(SUBSTRING(UPPER(REPLACE ([TRD].[Recipient], ' ', '' )), 0, 20) + REPLICATE(@spacerChar,20),20)
		,[BenefRUT] =  LEFT(LP_Common.fnNormalizeToAlphaNumeric([TRD].[RecipientCUIT]) + REPLICATE(@spacerChar,13),13)
		,[BeneficiaryName]  = LEFT([TRD].[Recipient] + REPLICATE(@spacerChar,40),40)
		,[PaymentReference] = RIGHT(REPLICATE('0',16) + CAST(@newLotId AS VARCHAR),16)
		,[BeneficiaryAccountNumber] =   RIGHT(CONCAT(REPLICATE('0',20),LP_Common.fnNormalizeToAlphaNumeric(TRD.RecipientAccountNumber)),20)
		,[CityStates]  = REPLICATE(@spacerChar,40)
		,[BankSenderReceptor] = LEFT((CAST(CAST([BC].[Code] AS INT) AS VARCHAR(3)))+ REPLICATE('0',3),3)
		,[PaymentConcept] = LEFT([T2].[Ticket] + REPLICATE(@spacerChar,50),50)
		,[CAMPO-USO-EMPRESA1]   = REPLICATE(@spacerChar,20)
		,[CAMPO-USO-EMPRESA2]   = REPLICATE(@spacerChar,20)
		,[CAMPO-USO-EMPRESA3]   = REPLICATE(@spacerChar,20)
		,[DECIMALAMOUNT]		= [TD].NetAmount
		,[idTransactionLot]		= [TL].[idTransactionLot]
		,[idTransaction]		= [T].[idTransaction]
	FROM
		[LP_Operation].[Transaction]									[T]
		INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]				= [TL].[idTransactionLot]
		INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]					= [TRD].[idTransaction]
		INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]					= [TD].[idTransaction]
		INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]			= [BAT].[idBankAccountType] 
																			AND [BAT].[idCountry]					= @idCountry
		INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]					= [T2].[idTransaction]
		INNER JOIN  [LP_Configuration].[BankCode]					[BC]	ON	[BC].[idBankCode]					= [TRD].[idBankCode]
		LEFT JOIN	[LP_Entity].[EntityIdentificationType]			[EIT]	ON	[EIT].[idEntityIdentificationType]	= [TRD].[idEntityIdentificationType]
		LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]				= [T].[idTransaction]
		LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant]			= [TESM].[idEntitySubMerchant]
		INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]
	WHERE
		[T].[idStatus] = @statusReceived
		AND [TD].[NetAmount] > 0
		AND BAT.idCountry = @idCountry
		AND LEN(TRD.RecipientCUIT) > 0
	ORDER BY [T].[TransactionDate] ASC

	--SELECT * FROM @TempDetail1
	DECLARE @LineDetail1 VARCHAR(370)
	DECLARE @IterationI INT = 1
	DECLARE @txnum AS INT	
	DECLARE @amount VARCHAR(17)
	DECLARE @total_amount VARCHAR(17)
	DECLARE @amount_filled VARCHAR(17)

	DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
	SELECT idx FROM @TempDetail1
					
		OPEN tx_cursor;

		FETCH NEXT FROM tx_cursor INTO @txnum
		WHILE @@FETCH_STATUS = 0
		BEGIN

			INSERT INTO @Lines(Line) VALUES(RIGHT(@fixed_Header_2 + REPLICATE(@spacerChar, (370 - LEN(@fixed_Header_2))),370)) -- Header 2

			-- Detail 1
			SELECT @LineDetail1= CONCAT(FT, RT, MT, CurrencyType, Amount, DateToPay, Concept, BeneficiaryNickName, BenefRUT, BeneficiaryName, PaymentReference, PlazaPago, SucursalPago, BeneficiaryAccountNumber, CountryCode, CityStates, BankAccountType, DigitInterchange, PlazaAccountBank, BankSenderNumber, BankSenderReceptor, AvailabilityTermDays, PaymentConcept, [CAMPO-USO-EMPRESA1], [CAMPO-USO-EMPRESA2], [CAMPO-USO-EMPRESA3], Filler324To370)
			FROM @TempDetail1 WHERE idx = @txnum

			SELECT @amount = Amount FROM @TempDetail1 WHERE idx = @txnum

			INSERT INTO @Lines(Line) VALUES(@LineDetail1)
			INSERT INTO @Lines(Line) VALUES(@inlineDetail2)

			DECLARE @quantityMovs VARCHAR(3) = 1;
			DECLARE @quantityMovs_filled VARCHAR(7);

			SET @quantityMovs = 1
			SET @quantityMovs_filled =  RIGHT(REPLICATE('0', (7 - LEN(@quantityMovs))) + @quantityMovs ,7)
			SET @amount_filled =  RIGHT(REPLICATE('0', (17 - LEN(@amount))) +  @amount ,17)

			INSERT @TempFooter1(UpQuantity, UpAmmount)
			VALUES(@quantityMovs_filled, @amount_filled )
			
			DECLARE @inlineFooter1 VARCHAR(370)
			
			SELECT @inlineFooter1 = CONCAT(FT, RT, [UpQuantity], [UpAmmount],[DownQuantity], [DownAmmount], SCOTIA_FILLER_ZERO, FILLER) FROM @TempFooter1
			INSERT INTO @Lines(Line) VALUES(@inlineFooter1)

			SET @IterationI = @IterationI + 1

			FETCH NEXT FROM tx_cursor INTO @txnum
		END

		CLOSE tx_cursor
		DEALLOCATE tx_cursor

	SET @total_amount = RIGHT(REPLICATE('0',15)+CAST(CAST((SELECT SUM(DecimalAmount) FROM @TempDetail1) AS INT) AS VARCHAR(15)),15)
	SET @quantityMovs_filled =  RIGHT(REPLICATE('0', (7 - LEN(@IterationI))) + @IterationI ,7)
	SET @amount_filled =  RIGHT(REPLICATE('0', (17 - LEN(@total_amount))) +  @total_amount ,17)

	INSERT @TempFooter2(UpQuantity, UpAmmount)
	VALUES(@quantityMovs_filled, @amount_filled)
			
	DECLARE @inlineFooter2 VARCHAR(370)

	SELECT @inlineFooter2 = CONCAT(FT, RT, [UpQuantity], [UpAmmount],[DownQuantity], [DownAmmount], SCOTIA_FILLER_ZERO, FILLER) FROM @TempFooter2
	INSERT INTO @Lines(Line) VALUES(@inlineFooter2)
			
	-- /* INSERT LINES BLOCK: FIN */
	-- /* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
	-- /* UPDATE TRANSACTIONS STATUS BLOCK: INI */

	DECLARE @idStatus INT
	DECLARE @idLotOut INT

	SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('InProgress')
	SET @idLotOut = @newLotId;
			
	IF(@idLotOut IS NULL)
	BEGIN
		SET @idLotOut = 1
	END

	BEGIN TRANSACTION

		UPDATE	[LP_Operation].[TransactionLot]
		SET		[idStatus] = @idStatus
		WHERE	[idTransactionLot] IN (SELECT [idTransactionLot] FROM @TempDetail1)

		UPDATE	[LP_Operation].[Transaction]
		SET		[idStatus] = @idStatus
				,[idProviderPayWayService] = @idProviderPayWayService
				,[idTransactionTypeProvider] = @idTransactionTypeProvider
				,[idLotOut] = @idLotOut
				,[lotOutDate] = GETDATE()
		WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempDetail1)

		UPDATE	[LP_Operation].[TransactionRecipientDetail]
		SET		[idStatus] = @idStatus
		WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempDetail1)

		UPDATE	[LP_Operation].[TransactionDetail]
		SET		[idStatus] = @idStatus
		WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempDetail1)

		UPDATE	[LP_Operation].[TransactionInternalStatus]
		SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
		WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempDetail1)

	COMMIT TRANSACTION
			

	--/* UPDATE TRANSACTIONS STATUS BLOCK: FIN */
	--/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
	--/* SELECT FINAL BLOCK: INI */

	DECLARE @Rows INT
	SET @Rows = ((SELECT COUNT(*) FROM @TempDetail1))

	IF(@Rows > 0)
	BEGIN
		SELECT Line FROM @Lines
	END

	-- /* SELECT FINAL BLOCK: FIN */

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
