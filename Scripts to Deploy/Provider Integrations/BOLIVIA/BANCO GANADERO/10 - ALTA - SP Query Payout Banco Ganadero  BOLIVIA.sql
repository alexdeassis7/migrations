/****** Object:  StoredProcedure [LP_Operation].[BOL_Payout_BANCO_GANADERO_Operation_Download]    Script Date: 8/9/2022 12:39:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [LP_Operation].[BOL_Payout_BANCO_GANADERO_Operation_Download]
(
	@JSON VARCHAR(MAX) 
)
AS

BEGIN	
	--SET @JSON = '[16576563260000]'

BEGIN TRY
	/* Bootstraping*/
	DECLARE @spacerChar CHAR(1) = CHAR(32); --   /* Change for Debug purpose to some printable character like # character or just put CHAR(32) as value if you need whitespaces */
	DECLARE @newLotId INT = (SELECT TOP(1) MAX([idLotOut]) + 1 FROM [LP_Operation].[Transaction]);

	/* CONFIG BLOCK: INI */
	DECLARE @idCountry	INT		
	SET @idCountry = ( SELECT TOP(1) [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'BOB' AND [Active] = 1  ORDER BY idCountry)

	DECLARE @idProvider	INT
	SET @idProvider = ( SELECT TOP(1) [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BGBOL' AND [idCountry] = @idCountry AND [Active] = 1  ORDER BY idProvider)

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
		 [idLine]		INT IDENTITY(1,1)
		,[Line]			VARCHAR(MAX)
	)

	-- INTERNAL BATCH NUMBER
	DECLARE @InternalBatchId VARCHAR(2)

	DECLARE @NextBatchId INT;

	EXEC LP_Operation.GetLastInternalBatchNumberByProviderId @ProviderId=@idProvider,
		@NextBatchId=@NextBatchId OUTPUT; -- int

	SET @InternalBatchId=RIGHT('0' + CONVERT(VARCHAR, @NextBatchId), 2);

	DECLARE @TempPayoutBody TABLE
	(
	--****************************************************************************************************************************************************************************************
	--  | CAMPO									| TIPO		  | ES NULL?  |	VALOR DEFAULT						   |   DESCRIPCION					| OBSERVACION / COMENTARIO DEL AUTOR
	--****************************************************************************************************************************************************************************************
		[idx_OrderNumber]						INT IDENTITY (1,1)													-- NUMERO DE ORDEN				NRO. SECUENCIAL 1 -> N (AUTONUMERICO)
		,[CustomerCode]							VARCHAR(10)		NOT NULL											-- CODIGO DE CLIENTE			CODIGO DE CLIENTE EN BANCO
		,[AccountNumber]						VARCHAR(14)		NOT NULL											-- Nro. de Cuenta Destino		Ninguna
		,[BeneficiaryName]						VARCHAR(100)	NOT NULL										    -- Nombre de Cliente Destino
		,[BenefRUT]								VARCHAR(20)		NOT NULL											-- Nro. de Identificacion Dest. DNI del cliente?
		,[Ammount]								DECIMAL(18,2)	NOT NULL											-- Importe
		,[PaymentDate]							VARCHAR(10)		NULL DEFAULT(FORMAT(GETUTCDATE(), 'dd/MM/yyyy'))		-- Fecha de Pago				FORMATO: DD/MM/YYYY
		,[PaymentMode]							VARCHAR(1)		NOT NULL											-- Forma de Pago			    1 TRF A Cuenta en Bco. 2, TX con Cheque, 3 Otro Banco
																																					-- SEGUN "Copia de Prueba(1183).xlsx" 3 si es otro Banco, 1 si es Banco Ganadero
		,[CurrencyTypeDestination]				VARCHAR(1)		NULL DEFAULT (1)									-- Moneda de Destino			1 - $ Bolivianos, 2 - Dolares
		,[EntitiyDestination]					VARCHAR(10)		NOT NULL											-- Entidad Destino				ver anexo doc
		,[EntityLocationBranch]					VARCHAR(5)		NOT NULL											-- Sucursal Destino				ver anexo
		,[Glosa]								VARCHAR(80)		NULL DEFAULT('PAGO A PROVEEDORES')					-- Una descripcion (Fijo)		
		,[UniqueCode]							VARCHAR(50)		NULL												-- Codigo Ref. del Cliente		esto hay que pregunta que 
		,[EmailNotification]					VARCHAR(50)		NULL DEFAULT('')									-- Email de Notificacion		por defecto, desactivado
		,[idTransactionLot]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		,[idTransaction]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
	)

	--DECLARE @Detail1 TABLE ([Detail1] VARCHAR(370))

	INSERT INTO @TempPayoutBody(
	[CustomerCode] 
	,[AccountNumber]
	,[BeneficiaryName]
	,[BenefRUT]
	,[Ammount] 
	,[PaymentMode]
	,[EntitiyDestination]
	,[EntityLocationBranch]
	,[UniqueCode]
	,[idTransactionLot]			
	,[idTransaction]				
	)
	SELECT 
		[CustomerCode] = LEFT(LP_Common.fnNormalizeToAlphaNumeric([TRD].[RecipientCUIT]),10)
		,[AccountNumber]= LEFT(LP_Common.fnNormalizeToAlphaNumeric([TRD].RecipientAccountNumber),14)
		,[BeneficiaryName] = LEFT(UPPER([TRD].[Recipient]),100)
		,[BenefRUT] =  LEFT(LP_Common.fnNormalizeToAlphaNumeric([TRD].[RecipientCUIT]),20)
		,[Amount] = CAST([TD].[NetAmount] AS decimal(18,2))
		,[PaymentMode] = CASE WHEN ([BC].[Code] = '009' OR [BC].[Code] = '055') THEN 1 ELSE 3 END
		-- [PaymentDate] tiene valor por defecto
		-- [CurrencyTypeDestination] tiene valor por defecto
		, ISNULL((SELECT CustomBankCode FROM LP_Configuration.BankCode_Lookup WHERE idProvider = @idProvider AND BankCode = [BC].[Code]),1)-- BUSCAR CODIGO CON TABLA LOOKUP
		, CASE WHEN ([BC].[Code] = '009' OR [BC].[Code] = '055') THEN '0' ELSE 'SCZ' END  -- FIJO SCZ si es otro banco 0 si es Ganadero
		 -- [Glosa] tiene valor por defecto
		, [UniqueCode] = T2.Ticket
		 --[EmailNotification] --tiene valor por defecto
		,[idTransactionLot] = [TL].[idTransactionLot]
		,[idTransaction] = [T].[idTransaction]
	FROM
		[LP_Operation].[Transaction]								[T]
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

	--SELECT * FROM @TempPayoutBody

	/* INSERT LINES BLOCK: FIN */
	/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

	/* UPDATE TRANSACTIONS STATUS BLOCK: INI */
	DECLARE @idStatus INT
	DECLARE @idLotOut INT
	SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('InProgress')
	SET @idLotOut =  (SELECT MAX([idLotOut]) + 1 FROM [LP_Operation].[Transaction])
	
	IF(@idLotOut IS NULL)
	BEGIN
		SET @idLotOut = 1
	END

	BEGIN TRANSACTION

		UPDATE	[LP_Operation].[TransactionLot]
		SET		[idStatus] = @idStatus
		WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM @TempPayoutBody)

		UPDATE	[LP_Operation].[Transaction]
		SET		[idStatus] = @idStatus
				,[idProviderPayWayService] = @idProviderPayWayService
				,[idTransactionTypeProvider] = @idTransactionTypeProvider
				,[idLotOut] = @idLotOut
				,[lotOutDate] = GETDATE()
		WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempPayoutBody)

		UPDATE	[LP_Operation].[TransactionRecipientDetail]
		SET		[idStatus] = @idStatus
		WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempPayoutBody)

		UPDATE	[LP_Operation].[TransactionDetail]
		SET		[idStatus] = @idStatus
		WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempPayoutBody)

		UPDATE	[LP_Operation].[TransactionInternalStatus]
		SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
		WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @TempPayoutBody)

	COMMIT TRANSACTION
	

	/* UPDATE TRANSACTIONS STATUS BLOCK: FIN */

	/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

	/* SELECT FINAL BLOCK: INI */

	DECLARE @Rows INT
	SET @Rows = ((SELECT COUNT(*) FROM @TempPayoutBody))

	IF(@Rows > 0)
	BEGIN
		SELECT	[NRO. DE ORDEN] = idx_OrderNumber,
				[CODIGO DE CLIENTE] = CustomerCode,
				[NRO. DE CUENTA] = AccountNumber,
				[NOMBRE DE CLIENTE] = BeneficiaryName,
				[DOC. DE IDENTIDAD] = BenefRUT,
				[IMPORTE] = Ammount,
				[FECHA DE PAGO] = PaymentDate,
				[FORMA DE PAGO] = PaymentMode,
				[MONEDA DESTINO] = CurrencyTypeDestination,
				[ENTIDAD DESTINO] = EntitiyDestination,
				[SUCURSAL DESTINO] = EntityLocationBranch,
				[GLOSA] = Glosa,
				[CODIGO UNICO] = UniqueCode,
				[EMAIL NOTIFICACION] = EmailNotification
		FROM @TempPayoutBody;
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
