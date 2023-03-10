SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [LP_Operation].[CHL_Payout_SECURITY_Bank_Operation_Download]
(
	@JSON					VARCHAR(MAX)
)
AS
BEGIN

	--SET @JSON = '[16473687930000]'
	BEGIN TRY

			/* Bootstraping*/
			DECLARE @spacerChar CHAR(1) = CHAR(32); --   /* Change for Debug purpose to some printable character like # character or just put CHAR(32) as value if you need whitespaces */
			DECLARE @newLotId INT = (SELECT MAX([idLotOut]) + 1 FROM [LP_Operation].[Transaction]);

			/* CONFIG BLOCK: INI */

			DECLARE @idCountry	INT
			SET @idCountry = ( SELECT TOP(1) [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'CLP' AND [Active] = 1  ORDER BY idCountry)

			DECLARE @idProvider	INT
			SET @idProvider = ( SELECT TOP(1) [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'SEC' AND [idCountry] = @idCountry AND [Active] = 1  ORDER BY idProvider)

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


			DECLARE @TempPayoutBody TABLE
			(
				[idx]							INT IDENTITY (1,1)
				,[RecordType]					CHAR(1) NOT NULL
				,[BenefRUT]						VARCHAR(10) NOT NULL
				,[BenefName]					VARCHAR(40)
				,[BenefEmail]					VARCHAR(50)
				,[PaymentMethod]				VARCHAR(30)
				,[BankCode]						VARCHAR(3)
				,[AccountType]					VARCHAR(1)
				,[AccountNumber]				VARCHAR(15)
				,[PaymentDate]					VARCHAR(10) --Vacio
				,[Amount]						VARCHAR(15)
				,[AccountTypeC]					VARCHAR(30)
				,[AccountNumberC]				VARCHAR(10)
				,[BankBranch]					VARCHAR(3) -- 001
				,[Ticket]						VARCHAR(60)
				, [LineComplete]				VARCHAR(MAX)
				, [idTransactionLot]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransaction]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [DecimalAmount]					[LP_Common].[LP_F_DECIMAL]
				, [Acum]							[LP_Common].[LP_F_DECIMAL] NULL
				, [ToProcess]						[LP_Common].[LP_F_BOOL]
			)

			DECLARE @LinesPayout TABLE
			(
				[idLine]		INT IDENTITY(1,1),
				[Line]			VARCHAR(MAX)
			)

			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* BODY BLOCK: INI */

			INSERT INTO @TempPayoutBody ([RecordType],[BenefRUT],[BenefName],[BenefEmail],[PaymentMethod],[BankCode],[AccountType],[AccountNumber],[PaymentDate],[Amount],[AccountTypeC],[AccountNumberC],[BankBranch],[Ticket]
										,[idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
			SELECT
				[RecordType] = '2',																		-- FIXED VALUE PREDEFINED BY SECURITY BANK (Value = '2')
				[BenefRUT] = LEFT(LEFT(REPLACE(REPLACE([TRD].[RecipientCUIT],'.',''),'-',''), 11) + REPLICATE(@spacerChar,1),11)
				,[BenefName] = LEFT([TRD].[Recipient] + REPLICATE(@spacerChar,40),40)
				,[BenefEmail] = LEFT(''+ REPLICATE(@spacerChar,50),50)
				,[PaymentMethod] = 'CAT_CSH_TRANSFER'
				,[BankCode] = LEFT((CAST(CAST([BC].[Code] AS INT) AS VARCHAR(3)))+ REPLICATE(@spacerChar,3),3)
				,[AccountType] = (CASE
									WHEN [BAT].[Code] = 'C' THEN '1'		--C	CC	Cuenta Corriente					(Security's Own Account Type Code = 1)
									WHEN [BAT].[Code] = 'A' THEN '3'		--A	CA	Caja de Ahorro						(Security's Own Account Type Code = 3)
									WHEN [BAT].[Code] = 'V' THEN '2'		--V		Vista Account	Cuenta Vista		(Security's Own Account Type Code = 2)
									ELSE '0'								-- THIS SHOULDN'T HAPPEN  (COULD BE AN UNEXPECTED CASE)
								END)
				,[AccountNumber] =  LEFT(LEFT(REPLACE(REPLACE([TRD].[RecipientAccountNumber],'.',''),'-',''), 11)+ REPLICATE(@spacerChar,15),15)  -- Account Number  [15]
				,[PaymentDate] = ''
				,[Amount] = LEFT(CAST(CAST([TD].[NetAmount] AS INT) AS VARCHAR(15))+ REPLICATE(@spacerChar,15),15)
				,[AccountTypeC] = 'CAT_CSH_CCTE'
				,[AccountNumberC] = '0220520021'
				,[BankCode] = LEFT((CAST(CAST([BC].[Code] AS INT) AS VARCHAR(3)))+ REPLICATE(@spacerChar,3),3)
				,[Ticket] = LEFT([T2].[Ticket],60)
				,[idTransactionLot]			= [TL].[idTransactionLot]
				,[idTransaction]				= [T].[idTransaction]
				,[DecimalAmount]				= [TD].[NetAmount]
				,[ToProcess]					= 0
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
				[T].[idStatus] = @statusReceived
				AND [TD].[NetAmount] > 0
			ORDER BY [T].[TransactionDate] ASC

			/* FOR DEBUG ONLY  [INICIO] */

			--SELECT
			--		'0' AS idx,
			--	   LEN(RecordType) AS LEN_RecordType,
			--	   LEN(BenefRUT) AS LEN_BenefRUT,
			--	   LEN(BenefName) AS LEN_BenefName,
			--	   LEN(AccountType) AS LEN_AccountType,
			--	   LEN(AccountNumber) AS LEN_AccountNumber,
			--	   LEN(Amount) AS LEN_Amount,
			--	   LEN(BankCode) AS LEN_BankCode,
			--	   LEN(BenefEmail) AS LEN_BenefEmail
			--	   FROM @TempPayoutBody

			--SELECT idx,
   --                RecordType,
   --                BenefRUT,
   --                BenefName,
   --                BenefEmail,
   --                BankCode,
   --                AccountType,
   --                AccountNumber,
   --                PaymentDate,
   --                Amount,
   --                AccountTypeC,
   --                AccountNumberC,
   --                BankBranch,
   --                Ticket,
   --                LineComplete,
   --                idTransactionLot,
   --                idTransaction,
   --                DecimalAmount,
   --                Acum,
   --                ToProcess 
			--	   FROM @TempPayoutBody

			/*  FOR DEBUG ONLY  [FIN] */

			/* BODY BLOCK: FIN */
			
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			/* UPDATE PAYOUT BLOCK: INI */
			
			UPDATE @TempPayoutBody
			SET [LineComplete] = CONCAT(RecordType,BenefRUT,BenefName, AccountType ,AccountNumber,Amount,BankCode,BenefEmail);

			/* UPDATE PAYOUT BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			
			/* INSERT LINES BLOCK: INI */
			INSERT INTO @LinesPayout
			SELECT [LineComplete] FROM @TempPayoutBody

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