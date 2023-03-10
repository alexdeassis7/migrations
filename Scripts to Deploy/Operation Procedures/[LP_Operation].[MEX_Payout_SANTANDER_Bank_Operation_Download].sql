CREATE OR ALTER PROCEDURE [LP_Operation].[MEX_Payout_SANTANDER_Bank_Operation_Download]
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
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'SRM' AND [Active] = 1 )

			DECLARE @idBankSRM	INT
			SET @idBankSRM = ( SELECT [idBankCode] FROM [LP_Configuration].[BankCode] WHERE [SubCode] = 'BANME' AND [idCountry] = @idCountry AND [Active] = 1 )

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
				,[Code]						    VARCHAR(5) --LTX05 (FIJO)
				,[AccountNumber]				VARCHAR(18) --65508490706 (FIJO)
				,[BeneficiaryAccount]		    VARCHAR(20)
				,[BankCode]						VARCHAR(5)
				,[BeneficiaryName]				VARCHAR(255)
				,[BankBranch]				    VARCHAR(4) --0000 (FIJO)
                ,[Amount]						VARCHAR(18)
                ,[BankBanxicoCode]				VARCHAR(5) -- 00000 (FIJO)
				,[Ticket]						VARCHAR(40)
				,[Description2]					VARCHAR(7) 
				,[Email]					    VARCHAR(40)
				, [LineComplete]				VARCHAR(MAX)
				, [idTransactionLot]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, [idTransaction]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

				, [DecimalAmount]					[LP_Common].[LP_F_DECIMAL]
				, [Acum]							[LP_Common].[LP_F_DECIMAL] NULL
				, [ToProcess]						[LP_Common].[LP_F_BOOL]
			)

			DECLARE @TempPayoutBodySRM TABLE
			(
				[idx]							INT IDENTITY (1,1)
				,[Code]						    VARCHAR(5) --LTX07 (FIJO)
				,[AccountNumber]				VARCHAR(18) --65508490706 (FIJO)
				,[BeneficiaryAccount]		    VARCHAR(20)
                ,[Amount]						VARCHAR(18)
				,[Ticket]						VARCHAR(40)
				,[Description2]					VARCHAR(8) 
				,[Email]					    VARCHAR(40)
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
                , [Code]						VARCHAR(5) --LA002 (FIJO)
                , [AccountType]				    VARCHAR(6) --EXTRNA (FIJO)
				, [BeneficiaryAccount]			VARCHAR(MAX)
				, [BeneficiaryAlias]			VARCHAR(MAX)
                , [BankCode]					VARCHAR(5)
                , [BankBanxicoCode]				VARCHAR(5) --00000 (FIJO)
                , [BankBranch]				    VARCHAR(5) --00000 (FIJO)
                , [AccountCode]				    VARCHAR(2) --40 (FIJO)
                , [BeneficiaryLastName]			VARCHAR(MAX) 
                , [BeneficiaryName]				VARCHAR(MAX)
				, [BeneficiaryAddress]			VARCHAR(MAX)
				, [BeneficiaryCity]			    VARCHAR(MAX) -- MEXICO (FIJO)

				, [AccountNumber]				VARCHAR(20)
				, [idBank]						INT
				, [GeneratedAlias]				VARCHAR(40)

				, [LineComplete]				VARCHAR(MAX)
			)

			DECLARE @TempPreRegisterSRM TABLE
			(
				[idx]							INT IDENTITY (1,1)
                , [Code]						VARCHAR(5) --LA001 (FIJO)
                , [AccountType]				    VARCHAR(6) --SANTAN (FIJO)
				, [BeneficiaryAccount]			VARCHAR(MAX)
                , [BeneficiaryAlias]			VARCHAR(MAX)

				, [AccountNumber]				VARCHAR(20)
				, [idBank]						INT
				, [GeneratedAlias]				VARCHAR(40)

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

			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


            /* BODY BLOCK: INI */

			INSERT INTO @TempPayoutBody ([Code],[AccountNumber],[BeneficiaryAccount],[BankCode],[BeneficiaryName],[BankBranch],[Amount],[BankBanxicoCode],[Ticket],[Description2],[Email]
										,[idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
			SELECT
				 [Code] = 'LTX05'
				,[AccountNumber] = '65508490706       '
				,[BeneficiaryAccount] = LEFT([TRD].[RecipientAccountNumber]+'                    ', 20)
				,[BankCode] = RIGHT('     ' + [BC].[SubCode] , 5)
				,[BeneficiaryName] = UPPER(LEFT([TRD].[Recipient] + '                                        ', 40))
				,[BankBranch] = LEFT('0000', 4)
                ,[Amount] = RIGHT('000000000000000000' + CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(18)), 18) 
                ,[BankBanxicoCode] = LEFT('00000', 5)
				,[Ticket] = LEFT([T2].[Ticket]+'                                        ',40)
                ,[Description2] = '0102030'
                ,[Email] = LEFT('                                        ',40)
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
				AND [BC].idBankCode != @idBankSRM
			ORDER BY [T].[TransactionDate] ASC


			/* BODY BLOCK : FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* BODY SRM BLOCK: INI */

			INSERT INTO @TempPayoutBodySRM ([Code],[AccountNumber],[BeneficiaryAccount],[Amount],[Ticket],[Description2],[Email],[idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
			SELECT
				 [Code] = 'LTX07'
				,[AccountNumber] = '65508490706       '
				,[BeneficiaryAccount] = LEFT(LEFT(RIGHT([TRD].[RecipientAccountNumber],12),11)+'                    ', 20)
                ,[Amount] = RIGHT('000000000000000000' + CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(18)), 18) 
				,[Ticket] = LEFT([T2].[Ticket]+'                                        ',40)
                ,[Description2] = FORMAT(GETDATE(), 'ddMMyyyy')
                ,[Email] = LEFT('                                        ',40)
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
				AND [BC].idBankCode = @idBankSRM
			ORDER BY [T].[TransactionDate] ASC


			/* BODY SRM BLOCK : FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

            /* PRE REGISTER BLOCK: INI */

			INSERT INTO @TempPreRegister ([Code],[AccountType],[BeneficiaryAccount],[BeneficiaryAlias],[BankCode],[BankBanxicoCode],[BankBranch],[AccountCode],[BeneficiaryLastName],[BeneficiaryName]
										,[BeneficiaryAddress], [BeneficiaryCity], [AccountNumber], [idBank], [GeneratedAlias])
			SELECT
				 [Code] = 'LA002'
				,[AccountType] = 'EXTRNA'
                ,[BeneficiaryAccount] = LEFT([TRD].[RecipientAccountNumber]+'                    ', 20)
                ,[BeneficiaryAlias] = LEFT('                                        ', 40)
				,[BankCode] = RIGHT('     ' + [BC].[SubCode] , 5)
                ,[BankBanxicoCode] = LEFT('     ', 5)
				,[BankBranch] = LEFT('     ', 5)
                ,[AccountCode] = '40'
                ,[BeneficiaryLastName] = LEFT('                                        ', 40)
                ,[BeneficiaryName] = UPPER(LEFT([TRD].[Recipient] + '                                                                                                                        ', 120))
                ,[BeneficiaryAddress] = LEFT('                                                                                                                                            ', 140)
                ,[BeneficiaryCity] = LEFT('MEXICO' + '                                   ', 35)
				,[AccountNumber] = [TRD].[RecipientAccountNumber]
				,[idBank] = [BC].[idBankCode]
				,[GeneratedAlias] = SUBSTRING(UPPER(REPLACE([TRD].[Recipient], ' ', '')), 1, 35) + '_' + RIGHT([TRD].[RecipientAccountNumber],4)
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
				AND [BC].idBankCode != @idBankSRM
			ORDER BY [T].[TransactionDate] ASC


			/* PRE REGISTER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* PRE REGISTER SRM BLOCK: INI */

			INSERT INTO @TempPreRegisterSRM ([Code],[AccountType],[BeneficiaryAccount],[BeneficiaryAlias],[AccountNumber],[idBank],[GeneratedAlias])
			SELECT
				 [Code] = 'LA001'
				,[AccountType] = 'SANTAN'
                ,[BeneficiaryAccount] = LEFT(LEFT(RIGHT([TRD].[RecipientAccountNumber],12),11)+'                    ', 20)
                ,[BeneficiaryAlias] = LEFT('                                        ', 40)
				,[AccountNumber] = LEFT(RIGHT([TRD].[RecipientAccountNumber],12),11)
				,[idBank] = [BC].[idBankCode]
				,[GeneratedAlias] = SUBSTRING(UPPER(REPLACE([TRD].[Recipient], ' ', '')), 1, 35) + '_' + RIGHT(LEFT(RIGHT([TRD].[RecipientAccountNumber],12),11),4)
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
				AND [BC].idBankCode = @idBankSRM
			ORDER BY [T].[TransactionDate] ASC


			/* PRE REGISTER SRM BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* MANAGE ALIAS ACCOUNTS: INI */

			DECLARE @BeneficiaryAccount 	VARCHAR(40),
					@GeneratedAlias		 	VARCHAR(40),
					@AliasFromDB		 	VARCHAR(40),
					@TypeOfTrx 				VARCHAR(6),
					@idBankOfBeneficiary 	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
					@idOfTrx 				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
					@idBankAliasAccount 	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

			BEGIN TRAN
			SET @idBankAliasAccount = NULL
			DECLARE alias_cursor CURSOR FORWARD_ONLY FOR
			SELECT idx,AccountNumber,idBank,GeneratedAlias,'EXTRNA' FROM  @TempPreRegister
			UNION
			SELECT idx,AccountNumber,idBank,GeneratedAlias,'SANTAN' FROM  @TempPreRegisterSRM

			OPEN alias_cursor;
			FETCH NEXT FROM alias_cursor INTO @idOfTrx,@BeneficiaryAccount,@idBankOfBeneficiary,@GeneratedAlias,@TypeOfTrx

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @idBankAliasAccount = [idBankCode], @AliasFromDB = [AccountAlias]
				FROM [LP_Operation].[BankAliasAccount] [BAA]
				WHERE 	[BAA].[AccountNumber] 	= @BeneficiaryAccount
				AND 	[BAA].[idBankCode] 		= @idBankOfBeneficiary
				AND     [BAA].[idProvider]      = @idProvider

				IF (@idBankAliasAccount IS NULL)
				BEGIN
					--INSERT into BankAliasAccount
					INSERT INTO [LP_Operation].[BankAliasAccount]([AccountNumber], [AccountAlias], [idBankCode], [Deleted], [idProvider])
					VALUES(@BeneficiaryAccount, @GeneratedAlias, @idBankOfBeneficiary, 0, @idProvider)

					-- UPDATE RECORD ON TEMPORAL REGISTER TABLE
					IF(@TypeOfTrx = 'EXTRNA')
						BEGIN
						UPDATE @TempPreRegister 
							SET [BeneficiaryAlias] = LEFT(@GeneratedAlias + '                                        ', 40)
							WHERE idx = @idOfTrx
						END
					ELSE
						BEGIN
						UPDATE @TempPreRegisterSRM 
							SET [BeneficiaryAlias] = LEFT(@GeneratedAlias + '                                        ', 40)
							WHERE idx = @idOfTrx
						END
				END
				ELSE
				BEGIN
					-- DELETE RECORD FROM TEMPORAL REGISTER TABLE
					IF(@TypeOfTrx = 'EXTRNA')
						BEGIN
						DELETE FROM @TempPreRegister 
							WHERE idx = @idOfTrx
						END
					ELSE
						BEGIN
						DELETE FROM @TempPreRegisterSRM 
							WHERE idx = @idOfTrx
						END
				END
				
				SET @idBankAliasAccount = NULL

				FETCH NEXT FROM alias_cursor INTO @idOfTrx,@BeneficiaryAccount,@idBankOfBeneficiary,@GeneratedAlias,@TypeOfTrx
			END
			
			CLOSE alias_cursor;

			DEALLOCATE alias_cursor;
			COMMIT

			/* MANAGE ALIAS ACCOUNT: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT AND PRE REGISTER BLOCK: INI */

			UPDATE @TempPayoutBodySRM
			SET [LineComplete] = [Code] + [AccountNumber] + [BeneficiaryAccount] + [Amount] + [Ticket] + [Description2] + [Email]

			UPDATE @TempPayoutBody
			SET [LineComplete] = [Code] + [AccountNumber] + [BeneficiaryAccount] + [BankCode] + [BeneficiaryName] + [BankBranch] + [Amount] +[BankBanxicoCode] + [Ticket] + [Description2] + [Email]

            UPDATE @TempPreRegister
			SET [LineComplete] = [Code] + [AccountType] + [BeneficiaryAccount] + [BeneficiaryAlias] + [BankCode] + [BankBanxicoCode] + [BankBranch] + [AccountCode] + [BeneficiaryLastName] + [BeneficiaryName] + [BeneficiaryAddress] + [BeneficiaryCity]

			UPDATE @TempPreRegisterSRM
			SET [LineComplete] = [Code] + [AccountType] + [BeneficiaryAccount] + [BeneficiaryAlias] 

			/* UPDATE PAYOUT AND PRE REGISTER: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			
			/* INSERT LINES BLOCK: INI */
			INSERT INTO @LinesPayout
			SELECT [LineComplete], [DecimalAmount], [idTransaction], [idTransactionLot] FROM @TempPayoutBody

			INSERT INTO @LinesPayout
			SELECT [LineComplete], [DecimalAmount], [idTransaction], [idTransactionLot] FROM @TempPayoutBodySRM

			INSERT INTO @LinesRegister
			SELECT [LineComplete] FROM @TempPreRegister

			INSERT INTO @LinesRegister
			SELECT [LineComplete] FROM @TempPreRegisterSRM

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

			DECLARE @Rows INT, @RowsSRM INT
			SET @Rows = ((SELECT COUNT(*) FROM @TempPayoutBody))
			SET @RowsSRM = ((SELECT COUNT(*) FROM @TempPayoutBodySRM))

			IF(@Rows > 0 OR @RowsSRM > 0)
			BEGIN
				SELECT [Line] FROM @LinesPayout ORDER BY [idLine] ASC
                SELECT DISTINCT([LineRegister]) FROM @LinesRegister ORDER BY [LineRegister]
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