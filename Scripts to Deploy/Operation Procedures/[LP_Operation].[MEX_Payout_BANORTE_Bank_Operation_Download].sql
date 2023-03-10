CREATE OR ALTER PROCEDURE [LP_Operation].[MEX_Payout_BANORTE_Bank_Operation_Download]
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
			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BANORTE' AND [Active] = 1 )

			DECLARE @idBankBanorte	INT
			SET @idBankBanorte = ( SELECT [idBankCode] FROM [LP_Configuration].[BankCode] WHERE [SubCode] = 'BBANO' AND [idCountry] = @idCountry AND [Active] = 1 )

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
				idx							INT IDENTITY (1,1),
                OperationCode				VARCHAR(2), 
                BeneficiaryName 			VARCHAR(50),
				AccountNumber				VARCHAR(18), 
				BeneficiaryAccount		    VARCHAR(18),
                Amount						VARCHAR(13),
                ReferenceNumber 			VARCHAR(10), 
				Ticket						VARCHAR(35),
                Iva                         VARCHAR(29) DEFAULT REPLICATE('0',29),
				Email					    VARCHAR(60) DEFAULT SPACE(60),
                Description 				VARCHAR(100) DEFAULT SPACE(100), 
                ProcessDate 				VARCHAR(8),

				LineComplete				VARCHAR(MAX),
				idTransactionLot			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
				idTransaction				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],

				DecimalAmount				[LP_Common].[LP_F_DECIMAL],
				Acum						[LP_Common].[LP_F_DECIMAL] NULL,
				ToProcess					[LP_Common].[LP_F_BOOL]
			)

			DECLARE @TempPreRegister TABLE
			(
				idx							INT IDENTITY (1,1),
                BeneficiaryAlias			VARCHAR(20) DEFAULT SPACE(20),
                OperationCode				VARCHAR(2), --AC (FIJO)
                BeneficiaryName 			VARCHAR(50),
                BeneficiaryRFC   			VARCHAR(13),
                BeneficiaryEmail			VARCHAR(40) DEFAULT SPACE(40),
                AccountType				    VARCHAR(3), 
                BankCode					VARCHAR(4),
				BeneficiaryAccount			VARCHAR(MAX),

				AccountNumber				VARCHAR(20),
				idBank						INT,
				GeneratedAlias				VARCHAR(40),

				LineComplete				VARCHAR(MAX)
			)

			DECLARE @LinesPayout TABLE
			(
			    idLine			    INT IDENTITY(1,1),
		        Line				VARCHAR(MAX),
			    DecimalAmount   	[LP_Common].[LP_F_DECIMAL],
			    idTransaction   	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
			    idTransactionLot  	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			)

            DECLARE @LinesRegister TABLE
			(
				idLine			INT IDENTITY(1,1),
                LineRegister    VARCHAR(MAX)
			)

            DECLARE @LpBankAccountNumber AS VARCHAR(10)
            SET @LpBankAccountNumber = '1142131739'

			/* CONFIG BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */


            /* BODY BLOCK: INI */

			INSERT INTO @TempPayoutBody ([OperationCode],[BeneficiaryName],[AccountNumber],[BeneficiaryAccount],[Amount],[Ticket],[ProcessDate]
										,[idTransactionLot], [idTransaction], [DecimalAmount], [ToProcess])
			SELECT
				CASE WHEN @idBankBanorte = [BC].[idBankCode] THEN '02' ELSE '04' END AS [OperationCode],
                UPPER(LEFT([TRD].[Recipient] + '                                        ', 50)) AS [BeneficiaryName], 
                @LpBankAccountNumber AS [AccountNumber], 
                CASE WHEN @idBankBanorte = [BC].[idBankCode] THEN RIGHT(REPLICATE(0,18)+LEFT(RIGHT([TRD].[RecipientAccountNumber],11),10), 18) ELSE LEFT([TRD].[RecipientAccountNumber]+REPLICATE(' ',18), 18) END AS [BeneficiaryAccount],
                RIGHT(REPLICATE('0',13) + CAST([LP_Common].[fnConvertDecimalToIntToAmount]([TD].[NetAmount]) AS VARCHAR(13)), 13) AS [Amount],
                LEFT([T2].[Ticket]+'                                   ',35) AS [Ticket], 
                FORMAT(GETDATE(), 'ddMMyyyy') AS [ProcessDate],

				[TL].[idTransactionLot] AS [idTransactionLot], 
				[T].[idTransaction] AS [idTransaction],
				[TD].[NetAmount] AS [DecimalAmount], 
				0 AS [ToProcess]
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


			/* BODY BLOCK : FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

            /* PRE REGISTER BLOCK: INI */

			INSERT INTO @TempPreRegister ([BeneficiaryAlias],[OperationCode],[BeneficiaryName],[BeneficiaryRFC],[AccountType],[BankCode],[BeneficiaryAccount]
										,[AccountNumber], [idBank], [GeneratedAlias])
			SELECT
                LEFT(REPLICATE(' ', 40), 40) AS [BeneficiaryAlias], 
				'AC' AS [OperationCode], 
                UPPER(LEFT([TRD].[Recipient] + REPLICATE(' ',50), 50)) AS [BeneficiaryName], 
                REPLICATE(' ',50) AS [BeneficiaryRFC], 
                CASE WHEN @idBankBanorte = [BC].[idBankCode] THEN '001' ELSE '040' END AS [AccountType],
                RIGHT(REPLICATE('0',4) + [BC].[Code] , 4) AS [BankCode],
                CASE WHEN @idBankBanorte = [BC].[idBankCode] THEN RIGHT(REPLICATE(0,18)+LEFT(RIGHT([TRD].[RecipientAccountNumber],11),10), 18) ELSE LEFT([TRD].[RecipientAccountNumber]+REPLICATE(' ',18), 18) END AS [BeneficiaryAccount],
				CASE WHEN @idBankBanorte = [BC].[idBankCode] THEN LEFT(RIGHT([TRD].[RecipientAccountNumber],11),10) ELSE [TRD].[RecipientAccountNumber] END AS [AccountNumber], 
				[BC].[idBankCode] AS [idBank], 
				CASE WHEN @idBankBanorte = [BC].[idBankCode] THEN SUBSTRING(UPPER(REPLACE([TRD].[Recipient], ' ', '')), 1, 15) + '_' + RIGHT(LEFT(RIGHT([TRD].[RecipientAccountNumber],11),10),4) ELSE SUBSTRING(UPPER(REPLACE([TRD].[Recipient], ' ', '')), 1, 15) + '_' + RIGHT([TRD].[RecipientAccountNumber],4) END AS [GeneratedAlias]
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


			/* PRE REGISTER BLOCK: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

            /* UPDATE SECUENCIAL NUMBER AND GET CANT OF RECORDS : INI */

                UPDATE @TempPayoutBody
                SET [ReferenceNumber] = RIGHT(REPLICATE(0, 10) + CAST([idx] AS VARCHAR), 10)

                -- DECLARE @QtyRowsReg AS BIGINT = (SELECT COUNT(1) FROM @TempRegDetalle)
                -- DECLARE @TotalAmount AS DECIMAL = (SELECT SUM(DecimalAmount) FROM @TempRegDetalle)

			/* UPDATE SECUENCIAL NUMBER AND GET CANT OF RECORDS: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* MANAGE ALIAS ACCOUNTS: INI */

			DECLARE @BeneficiaryAccount 	VARCHAR(40),
					@GeneratedAlias		 	VARCHAR(40),
					@AliasFromDB		 	VARCHAR(40),
					@idBankOfBeneficiary 	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
					@idOfTrx 				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
					@idBankAliasAccount 	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

			BEGIN TRAN
			SET @idBankAliasAccount = NULL
			DECLARE alias_cursor CURSOR FORWARD_ONLY FOR
			SELECT idx,AccountNumber,idBank,GeneratedAlias FROM  @TempPreRegister


			OPEN alias_cursor;
			FETCH NEXT FROM alias_cursor INTO @idOfTrx,@BeneficiaryAccount,@idBankOfBeneficiary,@GeneratedAlias

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
                    BEGIN
                    UPDATE @TempPreRegister 
                        SET [BeneficiaryAlias] = LEFT(@GeneratedAlias + REPLICATE(' ', 20), 20)
                        WHERE idx = @idOfTrx
                    END
				END
				ELSE
				BEGIN
					-- DELETE RECORD FROM TEMPORAL REGISTER TABLE
                    BEGIN
                    DELETE FROM @TempPreRegister 
                        WHERE idx = @idOfTrx
                    END
				END
				
				SET @idBankAliasAccount = NULL

				FETCH NEXT FROM alias_cursor INTO @idOfTrx,@BeneficiaryAccount,@idBankOfBeneficiary,@GeneratedAlias
			END
			
			CLOSE alias_cursor;

			DEALLOCATE alias_cursor;
			COMMIT

			/* MANAGE ALIAS ACCOUNT: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */

			/* UPDATE PAYOUT AND PRE REGISTER BLOCK: INI */

			UPDATE @TempPayoutBody
			SET [LineComplete] = [OperationCode] + [BeneficiaryName] + [AccountNumber] + [BeneficiaryAccount] + [Amount] + [ReferenceNumber]  + [Ticket] + [Iva] + [Email] + [Description] + [ProcessDate]

            UPDATE @TempPreRegister
			SET [LineComplete] = [BeneficiaryAlias]	+ [OperationCode] + [BeneficiaryName]  + [BeneficiaryRFC] + [BeneficiaryEmail] + [AccountType] + [BankCode]	+ [BeneficiaryAccount]

			/* UPDATE PAYOUT AND PRE REGISTER: FIN */
			/* --------------------------------------------------------------------------------- x --------------------------------------------------------------------------------- */
			
			/* INSERT LINES BLOCK: INI */
			INSERT INTO @LinesPayout
			SELECT [LineComplete], [DecimalAmount], [idTransaction], [idTransactionLot] FROM @TempPayoutBody

			INSERT INTO @LinesRegister
			SELECT [LineComplete] FROM @TempPreRegister

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

			DECLARE @Rows INT
			SET @Rows = ((SELECT COUNT(*) FROM @TempPayoutBody))

			IF(@Rows > 0)
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