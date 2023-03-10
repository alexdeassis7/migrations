USE [LocalPaymentPROD]
GO
/****** Object:  StoredProcedure [LP_Operation].[PYG_Payout_ITAUPYG_Bank_Operation_Download]    Script Date: 8/18/2022 3:49:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LP_Operation].[PYG_Payout_ITAUPYG_Bank_Operation_Download]
(
	@JSON					VARCHAR(MAX)
)
AS
BEGIN

	--SET @JSON = '[16473983260001]'
	BEGIN TRY

			/* Bootstraping*/
			DECLARE @spacerChar CHAR(1) = CHAR(32); --   /* Change for Debug purpose to some printable character like # character or just put CHAR(32) as value if you need whitespaces */

			DECLARE @newLotId INT = (SELECT MAX([idLotOut]) + 1 FROM [LP_Operation].[Transaction]);

			DECLARE @BankCodePYG VARCHAR(3) = '017' -- BANCO ITAU PARAGUAY

			DECLARE @idCountry	INT
			SET @idCountry = (SELECT TOP(1) [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'PYG' AND [Active] = 1  ORDER BY idCountry)

			DECLARE @idProvider	INT
			SET @idProvider = ( SELECT TOP(1) [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'ITAUPYG' AND [idCountry] = @idCountry AND [Active] = 1  ORDER BY idProvider)

			-- Status Variable
			DECLARE @statusReceived INT =  [LP_Operation].[fnGetIdStatusByCode]('Received')

			-- DECLARING TABLE WITH SELECTED TICKETS TO DOWNLOAD
			DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
			
			INSERT INTO @TempTxsToDownload
			SELECT idTransaction FROM [LP_Operation].[Ticket]
			WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)
			
			
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

			DECLARE @FilePayout TABLE
			(
				[idx]							INT IDENTITY (1,1)
				,[ServiceCode]					VARCHAR(2) default '11'
				,[DebitAccount]					VARCHAR(6)
				,[DebitAmount]					VARCHAR(20)
				,[BankCode]						VARCHAR(3)
				,[DeliveryType]					VARCHAR(1) -- C si es ITAU opciones L, C

				,[AccountNumber]				VARCHAR(15)
				,[TransferCurrency]				VARCHAR(1) -- a ver 
				,[ChangesReferenceNumber]		CHAR(1) default '0'
				,[ChangeType]					CHAR(1)
				,[BenefName]					VARCHAR(50)
				,[DocumentType]					VARCHAR(1) -- "OBLIGATORIO PARA TRANSF. SIPAP
																--1 - CI
																--5 - RUC
																--4 - PASS
				,[DocumentNumber]				VARCHAR(12)
				,[PaymentDate]					VARCHAR(8)
				,[BillingNumber]				VARCHAR(1)
				,[BeneficiaryCity]				VARCHAR(1) default '1'
				,[BeneficiaryCountry]			VARCHAR(1)
				,[ConceptReason]				VARCHAR(2) default '20' 
				,[CompanyReference]				VARCHAR(1)
				,[DocumentNumberDebtColl]		VARCHAR(1)
				,[NameDebtColl]					VARCHAR(1)
				,[NotificationEmail]			VARCHAR(1)
				,[NotificationSMS]				VARCHAR(1)
				,[MessageToBeneficiary]			VARCHAR(1)
				,[IntermediaryBank]				VARCHAR(1)
				, [LineComplete]				VARCHAR(MAX)
				, [idTransactionLot]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransaction]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [DecimalAmount]				DECIMAL(18,2) NOT NULL
				, [Acum]						[LP_Common].[LP_F_DECIMAL] NULL
				, [ToProcess]					[LP_Common].[LP_F_BOOL]
				, [MerchanId]					VARCHAR(100)
				, [LotNumber]					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [Status]			VARCHAR(MAX)
			)

			DECLARE @LinesPayout TABLE
			(
				[idLine]		INT IDENTITY(1,1),
				[Line]			VARCHAR(MAX)
			)

			DECLARE @DebitAccount VARCHAR = '215559' 
			
			DECLARE @TodayDate as DATETIME
			SET @TodayDate = GETUTCDATE()


			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* BODY BLOCK: INI */
			INSERT INTO @FilePayout ([ServiceCode], [DebitAccount], [DebitAmount], [BankCode], [DeliveryType], [AccountNumber], [TransferCurrency]				
				,[ChangesReferenceNumber],[ChangeType],[BenefName],[DocumentType],[DocumentNumber],[PaymentDate],[BillingNumber],[BeneficiaryCity]				
				,[BeneficiaryCountry],[ConceptReason],[CompanyReference],[DocumentNumberDebtColl],[NameDebtColl],[NotificationEmail]			
				,[NotificationSMS],[MessageToBeneficiary],[IntermediaryBank]				
				,[idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess], [LotNumber], [Status])

			SELECT
			[ServiceCode] = '11', 
			[DebitAccount] = @DebitAccount, 
			--[DebitAmount] = LEFT(CAST(CAST([TD].[NetAmount] AS INT) AS VARCHAR(15))+ REPLICATE(@spacerChar,15),15),
			[DebitAmount] = CAST([TD].[NetAmount] AS DECIMAL(18,2)),
			--[BankCode] = LEFT((CAST(CAST([BC].[Code] AS INT) AS VARCHAR(3)))+ REPLICATE(@spacerChar,3),3),
			[BankCode] = LEFT((CAST([BC].[Code] AS VARCHAR(3))) + REPLICATE(@spacerChar,3),3),
			[DeliveryType] = IIF([BC].[Code] = @BankCodePYG, 'C', 'L'), 
			[AccountNumber] =  LEFT(LEFT(REPLACE(REPLACE([TRD].[RecipientAccountNumber],'.',''),'-',''), 11)+ REPLICATE(@spacerChar,15),15),   -- Account Number  [15]
			[TransferCurrency] = '0'				
				,[ChangesReferenceNumber] = @spacerChar,
				[ChangeType] = @spacerChar,
				[BenefName] = LEFT([TRD].[Recipient] + REPLICATE(@spacerChar,50),50),
				[DocumentType] = [LP_Operation].[fnDocumentTypeByProviderCountry](@idProvider, [TRD].[idEntityIdentificationType]),
				--[TRD].[idEntityIdentificationType],
				[DocumentNumber] = LEFT(TRD.RecipientCUIT + SPACE(20), 20),
				[PaymentDate] = FORMAT(@TodayDate, 'ddMMyyyy'),
				[BillingNumber] = @spacerChar,
				[BeneficiaryCity] = '1',
				[BeneficiaryCountry] = @spacerChar,
				[ConceptReason] = '20',
				[CompanyReference] = @spacerChar,
				[DocumentNumberDebtColl] = @spacerChar,
				[NameDebtColl] = @spacerChar,
				[NotificationEmail] = @spacerChar,
				[NotificationSMS] = @spacerChar,
				[MessageToBeneficiary] = @spacerChar,
				[IntermediaryBank] = @spacerChar,				
				 [idTransactionLot]	= [TL].[idTransactionLot]
				,[idTransaction] = [T].[idTransaction]
				,[DecimalAmount] = [TD].[NetAmount]
				,[ToProcess]					= 0
				,[LotNumber]					= @newLotId
				,[Status]				= [T].[idStatus]
			FROM
				[LP_Operation].[Transaction]									[T]
					INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]				= [TL].[idTransactionLot]
					INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]					= [TRD].[idTransaction]
					INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]					= [TD].[idTransaction]
					INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]			= [BAT].[idBankAccountType] 
																						AND [BAT].[idCountry]					= @idCountry
					INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]					= [T2].[idTransaction]
					INNER JOIN  [LP_Configuration].[BankCode]					[BC]	ON	[BC].[idBankCode]					= [TRD].[idBankCode]
																						AND [BC].[idCountry]					= @idCountry
					 LEFT JOIN  [LP_Entity].[EntityIdentificationType]			[EIT]	ON	[EIT].[idEntityIdentificationType]	= [TRD].[idEntityIdentificationType] AND [EIT].[idCountry] = @idCountry
					 LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]				= [T].[idTransaction]
					 LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant]			= [TESM].[idEntitySubMerchant]
					INNER JOIN	@TempTxsToDownload								[TEMP]	ON	[TEMP].[idTransaction]				= [T].[idTransaction]
			WHERE
			[T].[idStatus] = @statusReceived
			AND [TD].[NetAmount] > 0
			ORDER BY [T].[TransactionDate] ASC

			/* BODY BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			/* UPDATE PAYOUT BLOCK: INI */
			
			--UPDATE @TempPayoutBody
			--SET [LineComplete] = CONCAT(BenefRUT,Ticket,[BenefName],[PaymentType],[BenefAccountType],[Amount],[MerchanId], LOT);

			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			/* INSERT LINES BLOCK: INI */

			--DECLARE @FilePayout TABLE
			--( 
			--	 [idx]							INT IDENTITY (1,1)
			--	,[CUENTA BENEFICIARIO]			VARCHAR(20) NOT NULL
			--	,[CLAVE_RASTREO]				VARCHAR(30)
			--	,[NOMBRE_BENEFICIARIO]			VARCHAR(40)
			--	,[TIPO_PAGO]					VARCHAR(1)
			--	,[TIPO_CUENTA_BENEFICIARIO]     VARCHAR(2)
			--	,[MONTO]						DECIMAL(18,2) NOT NULL
			--	,[CONCEPTO_PAGO]				VARCHAR(40)
			--	,[REFERENCIA_NUMERICA]			VARCHAR(7)
			--	,[EMAIL_BENEFICIARIO]			VARCHAR(120)
			--	,[INSTITUCION_OPERANTE]			INT
			--	,[EMPRESA]						VARCHAR(15) --Vacio
			--)

			--INSERT INTO @FilePayout
			--	SELECT
			--		[BenefRUT],
			--		Ticket,
			--		[BenefName],
			--		[PaymentType],
			--		[BenefAccountType],
			--		[DecimalAmount],
			--		[MerchanId],
			--		[LotNumber],
			--		[BenefEmail],
			--		[OperatingInstitution],
			--		[CompanyName]
		 --   FROM @TempPayoutBody
			

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
				WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM @FilePayout)

				UPDATE	[LP_Operation].[Transaction]
				SET		[idStatus] = @idStatus
						,[idProviderPayWayService] = @idProviderPayWayService
						,[idTransactionTypeProvider] = @idTransactionTypeProvider
						,[idLotOut] = @idLotOut
						,[lotOutDate] = GETDATE()
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @FilePayout)

				UPDATE	[LP_Operation].[TransactionRecipientDetail]
				SET		[idStatus] = @idStatus
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @FilePayout)

				UPDATE	[LP_Operation].[TransactionDetail]
				SET		[idStatus] = @idStatus
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @FilePayout)

				UPDATE	[LP_Operation].[TransactionInternalStatus]
				SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
					   ,[Active] = 1
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @FilePayout)

			COMMIT TRANSACTION
			

			/* UPDATE TRANSACTIONS STATUS BLOCK: FIN */

			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* SELECT FINAL BLOCK: INI */

			DECLARE @Rows INT
			SET @Rows = ((SELECT COUNT(*) FROM @FilePayout))

			IF(@Rows > 0)
			BEGIN
				SELECT 
					[COD.DE SERVICIO] = [ServiceCode], 
					[CTA DEBITO] = '215559', 
					[IMPORTE DEBITO] = REPLACE([DebitAmount], '.', ','),
					[COD DE BANCO] = [BankCode], 
					[TIPO DE ENVIO] = [DeliveryType], 
					[NRO DE CTA CREDITO] = [AccountNumber], 
					[MONEDA DE CREDITO DE LA TRANSF] = [TransferCurrency],
					[NRO. REFERENCIA CAMBIOS] = [ChangesReferenceNumber],
					[TIPO DE CAMBIO] = [ChangeType],
					[BENEFICIARIO] = [BenefName],
					[TIPO DE DOC.] = [DocumentType],
					[NRO. DE DOC.] = [DocumentNumber],
					[FECHA DE PAGO] = [PaymentDate],
					[NRO DE FACTURA] = [BillingNumber],
					[CIUDAD DEL BENEF.] = [BeneficiaryCity],
					[Pais Beneficiario] = [BeneficiaryCountry],
					[CONCEPTO MOTIVO] = [ConceptReason],
					[REFERENCIA EMPRESA] = [CompanyReference],
					[NRO DE DOC. COBRADOR] = [DocumentNumberDebtColl],
					[NOMBRE COBRADOR] = [NameDebtColl],
					[NOTIFICACION MAIL] = [NotificationEmail],
					[NOTIFICACION SMS] = [NotificationSMS],
					[MENSAJE AL BENEFICIARIO] = [MessageToBeneficiary],
					[Banco Intermediario (SWIFT)] = [IntermediaryBank]
				FROM @FilePayout
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



