/****** Object:  StoredProcedure [LP_Operation].[MEX_Payout_BBVA_Bank_Operation_Download]    Script Date: 12/6/2021 10:43:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [LP_Operation].[MEX_Payout_BBVA_Bank_Operation_Download]
																					(
																						@TransactionMechanism	BIT
																						, @JSON					VARCHAR(MAX)
																					)
AS
BEGIN

	BEGIN TRY

			/* CONFIG BLOCK: INI */

			DECLARE @idCountry	INT
			SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = 'MEX' AND [Active] = 1 )

			DECLARE @idProvider	INT
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BBVAMEX' AND [Active] = 1 )

			DECLARE @idBankBBVAMEX	INT
			SET @idBankBBVAMEX = ( SELECT [idBankCode] FROM [LP_Configuration].[BankCode] WHERE [SubCode] = 'BACOM' AND [idCountry] = @idCountry AND [Active] = 1 )

			-- DECLARING TABLE WITH SELECTED TICKETS TO DOWNLOAD
			DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
			INSERT INTO @TempTxsToDownload
			SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)

			DECLARE @idProviderPayWayService INT
			SET @idProviderPayWayService = (SELECT [PPWS].[idProviderPayWayService] 
                                            FROM [LP_Configuration].[ProviderPayWayServices]	[PPWS]
                                                INNER JOIN [LP_Configuration].[Provider]		[PR]	ON	[PR].[idProvider]		= [PPWS].[idProvider]
                                                INNER JOIN [LP_Configuration].[PayWayServices]	[PWS]	ON	[PWS].[idPayWayService] = [PPWS].[idPayWayService]
                                            WHERE [PR].[idProvider] = @idProvider 
                                                AND [PR].[idCountry] = @idCountry
                                                AND [PWS].[Code] = 'BANKDEPO' 
                                                AND [PWS].[idCountry] = @idCountry )

			DECLARE @idTransactionTypeProvider INT
			SET @idTransactionTypeProvider =   (SELECT [idTransactionTypeProvider]
                                                FROM [LP_Configuration].[TransactionTypeProvider]   [TTP]
                                                    INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [TTP].[idTransactionType]
                                                WHERE [TTP].[idProvider] = @idProvider 
                                                    AND [TT].[Code] = 'PODEPO')


			DECLARE @TempPayoutBody TABLE
			(
				[idx]							INT IDENTITY (1,1)
				,[Code]						    VARCHAR(3) -- Clave de pago (PSC)
				,[BeneficiaryAccount]		    VARCHAR(18) -- cuenta del beneficiario
				,[AccountNumber]				VARCHAR(18) -- cuenta para el cargo
				,[Currency]						VARCHAR(3) -- divida de la operacion
				,[Amount]						VARCHAR(16) -- importe de la operacion
				,[BeneficiaryName]				VARCHAR(30) -- nombre del beneficiario
				,[AccountType]				    VARCHAR(2) -- siempre 40
				,[BankNumber]				    VARCHAR(3) -- primeros tres numeros del banco beneficiario
				,[PaymentReason]				VARCHAR(30) -- motivo del pago
				,[ReferenceNumber]				CHAR(7) -- info enviada al que envia y al que recibe
				,[Availability]					VARCHAR(1) -- siempre H
				, [LineComplete]				VARCHAR(MAX)
				, [idTransactionLot]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransaction]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

				, [DecimalAmount]					[LP_Common].[LP_F_DECIMAL]
				, [Acum]							[LP_Common].[LP_F_DECIMAL] NULL
				, [ToProcess]						[LP_Common].[LP_F_BOOL]
			)

			DECLARE @TempPayoutBodyBBVAMEX TABLE
			(
				[idx]							INT IDENTITY (1,1)
				,[Code]						    VARCHAR(3) -- Clave de pago (PTC)
				,[AccountNumber]				VARCHAR(18) -- cuenta para el cargo
				,[BeneficiaryAccount]		    VARCHAR(18) -- cuenta del beneficiario
				,[Currency]						VARCHAR(3) -- divida de la operacion
				,[Amount]						VARCHAR(16) -- importe de la operacion
				,[BeneficiaryName]				VARCHAR(30) -- nombre del beneficiario
				, [LineComplete]				VARCHAR(MAX)
				, [idTransactionLot]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransaction]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

				, [DecimalAmount]					[LP_Common].[LP_F_DECIMAL]
				, [Acum]							[LP_Common].[LP_F_DECIMAL] NULL
				, [ToProcess]						[LP_Common].[LP_F_BOOL]
			)

			DECLARE @TempPreRegister TABLE
			(
				[idx]							INT IDENTITY (1,1)
                , [BankCode]				    VARCHAR(3) -- ABM del banco destino (primeros 3 numeros)
				, [BeneficiaryAccount]			VARCHAR(18) -- CLABE
				, [Currency]					VARCHAR(3) -- divisa de la operacion
				, [MaxAmount]				    VARCHAR(16) -- importe maximo de pago
				, [BeneficiaryName]				VARCHAR(30) -- titular de la cuenta
				, [BeneficiaryAlias]			VARCHAR(30) -- alias de la cuenta
				, [AccountType]				    VARCHAR(2) -- siempre 40
				, [LineComplete]				VARCHAR(MAX)
			)

			DECLARE @TempPreRegisterBBVAMEX TABLE
			(
				[idx]							INT IDENTITY (1,1)
				, [BeneficiaryAccount]			VARCHAR(18) -- CLABE
				, [Currency]					VARCHAR(3) -- divisa de la operacion
				, [MaxAmount]				    VARCHAR(16) -- importe maximo de pago
				, [BeneficiaryName]				VARCHAR(30) -- titular de la cuenta
				, [BeneficiaryAlias]			VARCHAR(30) -- alias de la cuenta
				, [LineComplete]				VARCHAR(MAX)
			)

			DECLARE @LinesPayout TABLE
			(
				[idLine]				INT IDENTITY(1,1)
				, [Line]				VARCHAR(MAX)
				, [DecimalAmount]   	[LP_Common].[LP_F_DECIMAL]
				, [idTransaction]   	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransactionLot]  	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			)

            DECLARE @LinesRegister TABLE
			(
				[idLine]			INT IDENTITY(1,1)
                , [LineRegister]    VARCHAR(MAX)
			)

			DECLARE @LinesRegisterBBVAMEX TABLE
			(
				[idLine]			INT IDENTITY(1,1)
                , [LineRegisterOwnBank]    VARCHAR(MAX)
			)

			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


            /* BODY BLOCK: INI */

			INSERT INTO @TempPayoutBody ([Code],[BeneficiaryAccount],[AccountNumber],[Currency],[Amount],[BeneficiaryName],[AccountType],[BankNumber],[PaymentReason],[ReferenceNumber],[Availability]
										,[idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
			SELECT
				 [Code] = 'PSC'
				,[BeneficiaryAccount] = RIGHT('000000000000000000' + [TRD].[RecipientAccountNumber], 18)
				,[AccountNumber] = '000000000116091237'
				,[Currency] = 'MXP'
				,[Amount] = RIGHT('000000000000000000' + LEFT(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(15)), 13) + '.' + RIGHT(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(15)), 2), 16) 
				,[BeneficiaryName] = UPPER(LEFT([TRD].[Recipient] + '                              ', 30))
				,[AccountType] = '40'
				,[BankNumber] = LEFT([TRD].[RecipientAccountNumber], 3)
				,[PaymentReason] = LEFT('PAYOUT ' + UPPER([TRD].[Recipient]) + CAST([TL].[idTransactionLot] as varchar(max)) + '                               ', 30) -- PAYOUT + NAME + TICKETW
				,[ReferenceNumber] = RIGHT('       ' + [TL].[idTransactionLot], 7)
				,[Availability] = 'H'

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
				[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
				AND [TD].[NetAmount] > 0 
				AND [BC].idBankCode != @idBankBBVAMEX
			ORDER BY [T].[TransactionDate] ASC


			/* BODY BLOCK : FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* BODY BBVAMEX BLOCK: INI */

			INSERT INTO @TempPayoutBodyBBVAMEX ([Code],[BeneficiaryAccount],[AccountNumber],[Currency],[Amount],[BeneficiaryName]
										,[idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
			SELECT
				 [Code] = 'PTC'
				,[BeneficiaryAccount] = RIGHT('000000000000000000' + [TRD].[RecipientAccountNumber], 18)
				,[AccountNumber] = '000000000116091237'
				,[Currency] = 'MXP'
				,[Amount] = RIGHT('000000000000000000' + LEFT(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(15)), 13) + '.' + RIGHT(CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(15)), 2), 16) 
				,[BeneficiaryName] = UPPER(LEFT([TRD].[Recipient] + '                              ', 30))
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
				[T].[idStatus] = [LP_Operation].[fnGetIdStatusByCode]('Received')
				AND [TD].[NetAmount] > 0 
				AND [BC].idBankCode = @idBankBBVAMEX
			ORDER BY [T].[TransactionDate] ASC


			/* BODY BBVAMEX BLOCK : FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

            /* PRE REGISTER BLOCK: INI */

			INSERT INTO @TempPreRegister ([BankCode],[BeneficiaryAccount],[Currency],[MaxAmount],[BeneficiaryName],[BeneficiaryAlias],[AccountType])
			SELECT
				 [BankCode] = LEFT([TRD].[RecipientAccountNumber], 3)
                ,[BeneficiaryAccount] = RIGHT('                  ' + [TRD].[RecipientAccountNumber], 18)
				,[Currency] = 'MXP'
				,[MaxAmount] = '0000000100000.00'
				,[BeneficiaryName] = UPPER(LEFT([TRD].[Recipient] + '                              ', 30))
                ,[BeneficiaryAlias] = LEFT([TRD].[RecipientAccountNumber] + '                              ', 30)
				,[AccountType] = '40'
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
				AND [BC].idBankCode != @idBankBBVAMEX
			ORDER BY [T].[TransactionDate] ASC


			/* PRE REGISTER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* PRE REGISTER BBVAMEX BLOCK: INI */

			INSERT INTO @TempPreRegisterBBVAMEX ([BeneficiaryAccount],[Currency],[MaxAmount],[BeneficiaryName],[BeneficiaryAlias])
			SELECT
                [BeneficiaryAccount] = RIGHT('                  ' + [TRD].[RecipientAccountNumber], 18)
				,[Currency] = 'MXP'
				,[MaxAmount] = '0000000100000.00'
				,[BeneficiaryName] = UPPER(LEFT([TRD].[Recipient] + '                              ', 30))
                ,[BeneficiaryAlias] = LEFT([TRD].[RecipientAccountNumber] + '                              ', 30)
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
				AND [BC].idBankCode = @idBankBBVAMEX
			ORDER BY [T].[TransactionDate] ASC


			/* PRE REGISTER BBVAMEX BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			--/* MANAGE ALIAS ACCOUNTS: INI */

			--DECLARE @BeneficiaryAccount 	VARCHAR(40),
			--		@GeneratedAlias		 	VARCHAR(40),
			--		@AliasFromDB		 	VARCHAR(40),
			--		@TypeOfTrx 				VARCHAR(6),
			--		@idBankOfBeneficiary 	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
			--		@idOfTrx 				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
			--		@idBankAliasAccount 	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

			--BEGIN TRAN
			--SET @idBankAliasAccount = NULL
			--DECLARE alias_cursor CURSOR FORWARD_ONLY FOR
			--SELECT idx,AccountNumber,idBank,GeneratedAlias,'EXTRNA' FROM  @TempPreRegister
			--UNION
			--SELECT idx,AccountNumber,idBank,GeneratedAlias,'SANTAN' FROM  @TempPreRegisterBBVAMEX

			--OPEN alias_cursor;
			--FETCH NEXT FROM alias_cursor INTO @idOfTrx,@BeneficiaryAccount,@idBankOfBeneficiary,@GeneratedAlias,@TypeOfTrx

			--WHILE @@FETCH_STATUS = 0
			--BEGIN
			--	SELECT @idBankAliasAccount = [idBankCode], @AliasFromDB = [AccountAlias]
			--	FROM [LP_Operation].[BankAliasAccount] [BAA]
			--	WHERE 	[BAA].[AccountNumber] 	= @BeneficiaryAccount
			--	AND 	[BAA].[idBankCode] 		= @idBankOfBeneficiary
			--	AND     [BAA].[idProvider]      = @idProvider

			--	IF (@idBankAliasAccount IS NULL)
			--	BEGIN
			--		--INSERT into BankAliasAccount
			--		INSERT INTO [LP_Operation].[BankAliasAccount]([AccountNumber], [AccountAlias], [idBankCode], [Deleted], [idProvider])
			--		VALUES(@BeneficiaryAccount, @GeneratedAlias, @idBankOfBeneficiary, 0, @idProvider)

			--		-- UPDATE RECORD ON TEMPORAL REGISTER TABLE
			--		IF(@TypeOfTrx = 'EXTRNA')
			--			BEGIN
			--			UPDATE @TempPreRegister 
			--				SET [BeneficiaryAlias] = LEFT(@GeneratedAlias + '                                        ', 40)
			--				WHERE idx = @idOfTrx
			--			END
			--		ELSE
			--			BEGIN
			--			UPDATE @TempPreRegisterBBVAMEX 
			--				SET [BeneficiaryAlias] = LEFT(@GeneratedAlias + '                                        ', 40)
			--				WHERE idx = @idOfTrx
			--			END
			--	END
			--	ELSE
			--	BEGIN
			--		-- DELETE RECORD FROM TEMPORAL REGISTER TABLE
			--		IF(@TypeOfTrx = 'EXTRNA')
			--			BEGIN
			--			DELETE FROM @TempPreRegister 
			--				WHERE idx = @idOfTrx
			--			END
			--		ELSE
			--			BEGIN
			--			DELETE FROM @TempPreRegisterBBVAMEX 
			--				WHERE idx = @idOfTrx
			--			END
			--	END
				
			--	SET @idBankAliasAccount = NULL

			--	FETCH NEXT FROM alias_cursor INTO @idOfTrx,@BeneficiaryAccount,@idBankOfBeneficiary,@GeneratedAlias,@TypeOfTrx
			--END
			
			--CLOSE alias_cursor;

			--DEALLOCATE alias_cursor;
			--COMMIT

			--/* MANAGE ALIAS ACCOUNT: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT AND PRE REGISTER BLOCK: INI */

			UPDATE @TempPayoutBodyBBVAMEX
			SET [LineComplete] = [Code] + [BeneficiaryAccount] + [AccountNumber] + [Currency] + [Amount] + [BeneficiaryName]

			UPDATE @TempPayoutBody
			SET [LineComplete] = [Code] + [BeneficiaryAccount] + [AccountNumber] + [Currency] + [Amount] + [BeneficiaryName] + [AccountType] + [BankNumber] + [PaymentReason] + [ReferenceNumber] + [Availability]

            UPDATE @TempPreRegister
			SET [LineComplete] = [BankCode] + [BeneficiaryAccount] + [Currency] + [MaxAmount] + [BeneficiaryName] + [BeneficiaryAlias] + [AccountType]

			UPDATE @TempPreRegisterBBVAMEX
			SET [LineComplete] = [BeneficiaryAccount] + [Currency] + [MaxAmount] + [BeneficiaryName] + [BeneficiaryAlias]

			/* UPDATE PAYOUT AND PRE REGISTER: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			
			/* INSERT LINES BLOCK: INI */
			INSERT INTO @LinesPayout
			SELECT [LineComplete], [DecimalAmount], [idTransaction], [idTransactionLot] FROM @TempPayoutBody

			INSERT INTO @LinesPayout
			SELECT [LineComplete], [DecimalAmount], [idTransaction], [idTransactionLot] FROM @TempPayoutBodyBBVAMEX

			INSERT INTO @LinesRegister
			SELECT [LineComplete] FROM @TempPreRegister

			INSERT INTO @LinesRegisterBBVAMEX
			SELECT [LineComplete] FROM @TempPreRegisterBBVAMEX

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
				WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM @LinesPayout)

				UPDATE	[LP_Operation].[Transaction]
				SET		[idStatus] = @idStatus
						,[idProviderPayWayService] = @idProviderPayWayService
						,[idTransactionTypeProvider] = @idTransactionTypeProvider
						,[idLotOut] = @idLotOut
						,[lotOutDate] = GETDATE()
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @LinesPayout)

				UPDATE	[LP_Operation].[TransactionRecipientDetail]
				SET		[idStatus] = @idStatus
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @LinesPayout)

				UPDATE	[LP_Operation].[TransactionDetail]
				SET		[idStatus] = @idStatus
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @LinesPayout)

				UPDATE	[LP_Operation].[TransactionInternalStatus]
				SET		[idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'PEND', 'SCM')
				WHERE	[idTransaction] IN(SELECT [idTransaction] FROM @LinesPayout)

			COMMIT TRANSACTION
			

			/* UPDATE TRANSACTIONS STATUS BLOCK: FIN */

			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* SELECT FINAL BLOCK: INI */

			DECLARE @Rows INT, @RowsBBVAMEX INT
			SET @Rows = ((SELECT COUNT(*) FROM @TempPayoutBody))
			SET @RowsBBVAMEX = ((SELECT COUNT(*) FROM @TempPayoutBodyBBVAMEX))

			IF(@Rows > 0 OR @RowsBBVAMEX > 0)
			BEGIN
				SELECT [Line] FROM @LinesPayout ORDER BY [idLine] ASC
                SELECT DISTINCT([LineRegister]) FROM @LinesRegister ORDER BY [LineRegister]
				SELECT DISTINCT([LineRegisterOwnBank]) FROM @LinesRegisterBBVAMEX ORDER BY [LineRegisterOwnBank]
				SELECT SUM([LP_Common].[fnConvertDecimalToIntToAmount]([DecimalAmount])) as Total FROM @LinesPayout
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