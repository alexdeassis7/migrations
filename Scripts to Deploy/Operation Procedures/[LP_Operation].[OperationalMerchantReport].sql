CREATE OR ALTER PROCEDURE [LP_Operation].[OperationalMerchantReport]
                          (
                            @json     [LP_Common].[LP_F_VMAX]
                            , @country_code [LP_Common].[LP_F_C3]
                          )
AS


BEGIN

	DECLARE @idEntityUser INT

	-- DECLARING TABLE WITH SELECTED TICKETS
	DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
	INSERT INTO @TempTxsToDownload
	SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)

	-- CREATING CURSOR FOR EVERY DIFFERENT MERCHANT
	DECLARE tx_cursor_merchant CURSOR FORWARD_ONLY FOR
	SELECT DISTINCT [idEntityUser]
	FROM [LP_Operation].[Transaction] [T]
	INNER JOIN [LP_Operation].[Ticket] [TI] ON [TI].[idTransaction] = [T].[idTransaction]
	INNER JOIN @TempTxsToDownload [TEMP] ON [TEMP].[idTransaction] = [T].[idTransaction]

	OPEN tx_cursor_merchant;

		FETCH NEXT FROM tx_cursor_merchant INTO @idEntityUser

		WHILE @@FETCH_STATUS = 0
		BEGIN

		DECLARE @ClientCurrencyCode AS VARCHAR(3),
				@LPCurrencyCode		AS VARCHAR(3)

		SELECT @ClientCurrencyCode	= [CT_CL].[Code],
				@LPCurrencyCode		= [CT_LP].[Code]
		FROM [LP_Entity].[EntityCurrencyExchange] [ECE]
		INNER JOIN [LP_Configuration].[CurrencyType] [CT_CL] ON [CT_CL].[idCurrencyType] = [ECE].[idCurrencyTypeClient]
		INNER JOIN [LP_Configuration].[CurrencyType] [CT_LP] ON [CT_LP].[idCurrencyType] = [ECE].[idCurrencyTypeLP]
		WHERE [ECE].[idEntityUser] = @idEntityUser


		---- temp status table for sorting
		--DECLARE @tStatus AS TABLE ([idStatus] INT, [Order] INT)
		--INSERT INTO @tStatus ([idStatus], [Order]) VALUES
		--(1, 3), -- RECEIVED
		--(3, 2), -- IN PROGRESS
		--(4, 1)	-- EXECUTED

		SELECT 
					[Transaction Date]  = [T].[TransactionDate],
					[Lot Out Date]		= [T].[lotOutDate],
					[Ticket]			= IIF([BCT].[Ticket] IS NOT NULL, [BCT].[Ticket], [TK].[Ticket]),
					[Alternative Ticket] =	CASE 
										WHEN [TK].[TicketAlternative] IS NOT NULL THEN [TK].[TicketAlternative]
										WHEN [TK].[TicketAlternative7] IS NOT NULL THEN [TK].[TicketAlternative7]
										WHEN [TK].[TicketAlternative8] IS NOT NULL THEN [TK].[TicketAlternative8]
										WHEN [TK].[TicketAlternative12] IS NOT NULL THEN [TK].[TicketAlternative12]
										ELSE NULL
									END,
					[Provider]			= [P].[Name],
					[Type of TX]         = [TT].[Name],
					[Automatic]         = IIF([TM].[Code] = 'MEC_AUTO', 1, 0),
					[Lot In]			= [T].[idTransactionLot],
					[Lot Out]			= [T].[idLotOut],
					[Status]			= [S].[Name],
					[Detail Status]		= CASE 
											WHEN [LPIE].[Name] IS NULL THEN 
																			CASE WHEN [T].[idStatus] = 1 THEN 'The tx was received and will be processed'
																			WHEN [T].[idStatus] = 3 THEN 'The tx is being processed. You cannot cancel any more'
																			WHEN [T].[idStatus] IN (4, 9) THEN 'Successfully executed'
																		END
											ELSE [LPIE].[Name]
										  END,
					[Merchant]			= [EU].[LastName],
					[SubMerchant]		= [ESM].[SubMerchantIdentification],
					[Merchant ID]		= IIF([TO].[Code] = 'PO', ISNULL([TRD].[InternalDescription], [BCT].[Invoice]), IIF([TO].[CODE] = 'PI', [TPID].[MerchantId],'')),
					[Amount]          = CASE
									WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
										[W].[GrossValueClient]
									ELSE
										[TD].[GrossAmount]
									END,
					[Payable]         = [TD].[NetAmount],
					[Fx Merchant]        = IIF
									(
									[S].[Code] NOT IN ('Rejected', 'Canceled'), 
									(
										CASE
										WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] IN('AddBalance', 'AddDebit', 'ReceivedCo') THEN
											0
										WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
											CAST([CE].[Value] AS DECIMAL(18,6))
										ELSE 
											CASE
											WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN
												0
											ELSE
											CAST([CE].[Value] * (1 - [CB].[Base_Buy] / 100)  AS DECIMAL(18,6))
											END
										END
									),
									0
									),
					[Pending]         = ISNULL(CASE
										WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN 
											IIF
											(
											[S].[Code] NOT IN ('Rejected', 'Canceled', 'Executed','PAID_FIRST'),
											IIF
											(
												[TO].[Code] = 'PO' OR [TO].[Code] = 'RF',
												-1 * [T].[GrossValueLP], 1 * [T].[GrossValueLP]
											),
											0
											)
										ELSE
											IIF
											(
											[S].[Code] NOT IN ('Rejected', 'Canceled', 'Executed','PAID_FIRST'),
											IIF
											(
												[TO].[Code] = 'PO' OR [TO].[Code] = 'RF',
												-1 * [T].[GrossValueClient] / ( [CE].[Value] * (1 - [CB].[Base_Buy] / 100)),
												1 * [T].[GrossValueClient] / ( [CE].[Value] * (1 - [CB].[Base_Buy] / 100))
											),
											0
											)
										END, 0),
					[Confirmed]         = IIF
											  (
												[S].[Code] IN ('Executed','PAID_FIRST'),
												IIF
												(
												  [TO].[Code] = 'PO' OR [TO].[Code] = 'RF',
												  ISNULL([W].[GrossValueClient], [W].[GrossValueLP]),
												  ISNULL([W].[GrossValueLP], [W].[GrossValueClient])
												),
												0
											  ),
					[LocalTax]        = [TD].[LocalTax] * -1, --IIF
											  --(
											  --  [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
											  --  [TD].[LocalTax] * -1, 
											  --  NULL
											  --),
					[Commission]          = CASE 
												WHEN [EU].[CommissionDeductsFromOtherAccount] = 1
													THEN 0 
													ELSE 
														IIF
														  (
															[S].[Code] NOT IN ('Rejected', 'Canceled'),
															IIF
															(
																[TO].[Code] = 'PI'
																,IIF
																(
																	[ECE].[idCurrencyTypeClient] != [ECE].[idCurrencyTypeLP]
																	,[TD].[Commission_With_VAT]*-1
																	,[LP_Operation].[fnGetCommisionExchange]([CEC].[idCurrencyExchange],[CB].[idCurrencyBase],[TD].[Commission_With_VAT],0)*-1
																)
																,[TD].[Commission_With_VAT]*-1
															),
															0
														  )
												END,
					[Account]			= CASE
											WHEN [EU].[CommissionDeductsFromOtherAccount] = 1
											THEN 
												IIF([ECE].[idCurrencyTypeClient] != [ECE].[idCurrencyTypeLP]
													,ROUND([W].[BalanceClientWithOutCommission], 2,1)
													,ROUND([W].[BalanceLPWithoutCommission], 2,1)
												) 
											ELSE
												IIF([ECE].[idCurrencyTypeClient] != [ECE].[idCurrencyTypeLP]
													,ROUND([W].[BalanceClient],2,1)
													,ROUND([W].[BalanceLP], 2,1)
												)
										  END,
					[Order]				= 1,
					[idTempTx]			= IDENTITY( int )
					--[StatusOrder]		= [TSTAT].[Order]

				INTO #TempTransactions
				FROM
					[LP_Operation].[Transaction]             [T] (NOLOCK)
					LEFT JOIN  [LP_Operation].[TransactionDetail]      [TD] (NOLOCK)                        ON [TD].[idTransaction]       = [T].[idTransaction]                       
					INNER JOIN [LP_Operation].[TransactionLot]            [TL] (NOLOCK)                                       ON [T].[idTransactionLot]     = [TL].[idTransactionLot]                       
					LEFT JOIN [LP_Operation].[TransactionRecipientDetail]       [TRD]  WITH(INDEX=IX_LP_Operation_TransactionRecipientDetail_idTransaction, NOLOCK)    ON [T].[idTransaction]        = [TRD].[idTransaction]
					LEFT JOIN [LP_Operation].[BarCodeTicket]            [BCT] WITH(INDEX=IX_LP_Operation_BarCodeTicket_idTransaction, NOLOCK)           ON [T].[idTransaction]        = [BCT].[idTransaction] AND [BCT].[Active] = 1
					LEFT JOIN [LP_Operation].[Ticket]               [TK]  WITH(INDEX=IX_LP_Operation_Ticket_idTransaction, NOLOCK)              ON [T].[idTransaction]        = [TK].[idTransaction]
					LEFT JOIN [LP_Operation].[TransactionProvider]          [TP]  WITH(INDEX=IX_LP_Operation_TransactionProvider_idTransaction, NOLOCK)       ON [T].[idTransaction]        = [TP].[idTransaction]
					LEFT JOIN [LP_Operation].[TransactionCollectedAndPaidStatus]  [TCAPS] WITH(INDEX=IX_LP_Operation_TransactionCollectedAndPaidStatus_idTransaction, NOLOCK) ON [T].[idTransaction]        = [TCAPS].[idTransaction]
					LEFT JOIN [LP_Operation].[TransactionInternalStatus]      [TIS] WITH(INDEX=IX_LP_Operation_TransactionInternalStatus_idTransaction, NOLOCK)     ON [T].[idTransaction]        = [TIS].[idTransaction] AND [TIS].[Active] = 1
					LEFT JOIN [LP_Operation].[Wallet]                 [W]   WITH(INDEX=IX_LP_Operation_Wallet_idTransaction, NOLOCK)              ON [T].[idTransaction]        = [W].[idTransaction] AND [W].[Active] = 1
					LEFT JOIN [LP_OPERATION].[TransactionDescription]       [TD2] WITH(INDEX=IX_LP_Operation_TransactionDescription_idTransaction, NOLOCK)      ON [T].[idTransaction]        = [TD2].[idTransaction]
					LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]     [TESM]  WITH(INDEX=IX_LP_Operation_TransactionEntitySubMerchant_idTransaction, NOLOCK)    ON [TESM].[idTransaction]     = [T].[idTransaction]
					LEFT JOIN [LP_Operation].[TransactionPayinDetail] [TPID] (NOLOCK)									ON [TPID].[idTransaction] = [T].[idTransaction] 
					LEFT JOIN [LP_Configuration].[CurrencyExchange]         [CE] (NOLOCK)                               ON [T].[idCurrencyExchange]     = [CE].[idCurrencyExchange]
					LEFT JOIN [LP_Configuration].[CurrencyExchange]         [CEC] (NOLOCK)                              ON [T].[idCurrencyExchangeClosed] = [CEC].[idCurrencyExchange]
					LEFT JOIN [LP_Common].[Status]                  [S] (NOLOCK)                                        ON [T].[idStatus]         = [S].[idStatus]
					LEFT JOIN [LP_Configuration].[InternalStatus]           [IS] (NOLOCK)                               ON [TIS].[idInternalStatus]     = [is].[idInternalStatus]
					LEFT JOIN [LP_Configuration].[LPInternalStatusClient] [LPIC] (NOLOCK)								ON [LPIC].[idInternalStatus] = [IS].idInternalStatus
					LEFT JOIN [LP_Configuration].[LPInternalError]        [LPIE] (NOLOCK)								ON [LPIE].[idLPInternalError] = [LPIC].[idLPInternalError]
					LEFT JOIN [LP_Security].[EntityAccount]             [EA] (NOLOCK)                                   ON [T].[idEntityAccount]      = [EA].[idEntityAccount]            
					LEFT JOIN [LP_Entity].[EntityUser]                [EU] (NOLOCK)                                     ON [T].[idEntityUser]       = [EU].[idEntityUser]
					LEFT JOIN [LP_Entity].[EntityMerchant]              [EM] (NOLOCK)                                   ON [EU].[idEntityMerchant]      = [EM].[idEntityMerchant]
					LEFT JOIN [LP_Configuration].[TransactionMechanism]       [TM] (NOLOCK)                             ON [T].[idTransactionMechanism]   = [TM].[idTransactionMechanism]
					LEFT JOIN [LP_Configuration].[TransactionTypeProvider]      [TTP] (NOLOCK)                          ON [T].[idTransactionTypeProvider]  = [TTP].[idTransactionTypeProvider]
					LEFT JOIN [LP_Configuration].[Provider]             [P] (NOLOCK)                                    ON [TTP].[idProvider]       = [P].[idProvider]
					LEFT JOIN [LP_Configuration].[TransactionType]          [TT] (NOLOCK)                               ON [TTP].[idTransactionType]    = [TT].[idTransactionType]
					LEFT JOIN [LP_Configuration].[TransactionGroup]         [TG] (NOLOCK)                               ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
					LEFT JOIN [LP_Configuration].[TransactionOperation]       [TO] (NOLOCK)                             ON [TG].[idTransactionOperation]  = [TO].[idTransactionOperation]
					LEFT JOIN [LP_Configuration].[CurrencyBase]           [CB] (NOLOCK)                                 ON [T].[idCurrencyBase]       = [CB].[idCurrencyBase]                       
					LEFT JOIN [LP_Entity].[EntityCurrencyExchange]          [ECE] (NOLOCK)                              ON [EU].[idEntityUser]        = [ECE].[idEntityUser]                        
					LEFT JOIN [LP_Configuration].[CurrencyType]           [CT_CL] (NOLOCK)                              ON [ECE].[idCurrencyTypeClient]     = [CT_CL].[idCurrencyType]
					LEFT JOIN [LP_Configuration].[CurrencyType]           [CT_LP] (NOLOCK)                              ON [ECE].[idCurrencyTypeLP]     = [CT_LP].[idCurrencyType]
					LEFT JOIN [LP_Entity].[EntitySubMerchant]           [ESM] (NOLOCK)                                  ON [ESM].[idEntitySubMerchant]    = [TESM].[idEntitySubMerchant]
					INNER JOIN [LP_Location].[Country]                [C] (NOLOCK)	                                    ON [C].[idCountry]          = [EU].[idCountry]
					INNER JOIN @TempTxsToDownload					[TEMP]												ON	[TEMP].[idTransaction]				= [T].[idTransaction]
				WHERE [T].[idEntityUser] = @idEntityUser
				ORDER BY [Transaction Date]

		/*
			OPENING AND CLOSING BALANCE
		*/

		-- SET TX DATE ALLOW NULL
		ALTER TABLE #TempTransactions
		ALTER COLUMN [Transaction Date] DATETIME NULL

		IF(EXISTS(SELECT TOP 1 [idWallet] FROM [LP_Operation].[Wallet] (NOLOCK) WHERE [idEntityUser] = @idEntityUser ORDER BY [idWallet] DESC ))
		BEGIN
			  INSERT INTO #TempTransactions ([Transaction Date], [Type of TX], Automatic, [Lot In],
												Amount, Payable, [Fx Merchant], Pending, Confirmed, LocalTax, Commission, Account,
												Ticket, Merchant, SubMerchant, [Merchant ID], Status, [Detail Status], [Order])
			  SELECT TOP 1
				FORMAT([T].[TransactionDate], 'yyyy-MM-dd'), -- TRANSACTION DATE
				'Opening Balance', -- TYPE OF TX
				0, -- Automatic
				0,	-- ID LOT
				0, -- AMOOUNT
				0, -- PAYABLE
				0, -- FX
				0, -- PENDING
				0, -- CONFIRMED
				0, -- LOCAL TAX
				0, -- COMMISSION
				CASE WHEN [W].[idCurrencyTypeClient] <> [W].[idCurrencyTypeLP] THEN
					CASE WHEN [EU].[CommissionDeductsFromOtherAccount] = 1 
					THEN ROUND(ISNULL([W].[BalanceClientWithOutCommission], 0), 2, 1)
					ELSE ROUND(ISNULL([W].[BalanceClient], 0), 2, 1) END
				ELSE 
					CASE WHEN [EU].[CommissionDeductsFromOtherAccount] = 1 
					THEN ROUND(ISNULL([W].[BalanceLPWithOutCommission], 0), 2, 1)
					ELSE ROUND(ISNULL([W].[BalanceLP], 0), 2, 1) END
				END, -- ACCOUNT,
				'', '', '', '', '' , '', 0
				FROM
				[LP_Operation].[Transaction]                [T] (NOLOCK)
				  LEFT JOIN [LP_Operation].[TransactionRecipientDetail] [TRD] (NOLOCK) ON  [TRD].[idTransaction] = [T].[idTransaction]
				  LEFT JOIN [LP_Configuration].[CurrencyType]       [CT] (NOLOCK) ON  [CT].[idCurrencyType] = [T].[CurrencyTypeClient]
				  INNER JOIN [LP_Operation].[Wallet]           [W] (NOLOCK)  ON  [W].[idTransaction]   = [T].[idTransaction]
				  LEFT JOIN [LP_Entity].[EntityUser]		[EU] (NOLOCK) ON [EU].[idEntityUser] = [W].[idEntityUser]
			  WHERE
				[W].[idEntityUser] = @idEntityUser
			  ORDER BY
			  [W].[idWallet] DESC
		END
		ELSE
		BEGIN
			INSERT INTO #TempTransactions ([Transaction Date], [Type of TX], Automatic, [Lot In], Amount, Payable, [Fx Merchant], Pending, Confirmed, LocalTax, Commission, Account,
											Ticket, Merchant, SubMerchant, [Merchant ID], Status, [Detail Status], [Order])
			VALUES ( FORMAT((SELECT MIN([Transaction Date]) FROM #TempTransactions), 'yyyy-MM-dd'), 'Opening Balance', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '' , '', 0)
		END

		DECLARE @lastDate AS DATETIME = (SELECT FORMAT(MAX([Transaction Date]), 'yyyy-MM-dd') FROM #TempTransactions)
		DECLARE @LastAmountValue  [LP_Common].[LP_F_DECIMAL]
		SET @lastDate = DATEADD(DAY, 1, @lastDate)
		SET @lastDate = DATEADD(SECOND, -1, @lastDate)

		SELECT TOP 1 
				@LastAmountValue = ISNULL([Account], 0)
		FROM #TempTransactions
		ORDER BY [Transaction Date]DESC

		INSERT INTO #TempTransactions ([Transaction Date], [Type of TX], Automatic, [Lot In], Amount, Payable, [Fx Merchant], Pending, Confirmed, LocalTax, Commission, Account, [Order])
		VALUES ( @lastDate, 'Closing Balance', 0, 0, 0, 0, 0, 0, 0, 0, 0, @LastAmountValue, 3)

		-- UPDATE ADD / DEBIT BALANCE ROWS VALUES
		UPDATE #TempTransactions SET
			[Amount] = 0.00,
			[Payable] = 0.00,
			[LocalTax] = 0.00,
			[Commission] = 0.00
		WHERE [Type of TX] IN ('Add Balance', 'Debit Balance')


		DECLARE @TempAccount AS DECIMAL(18,6) = 0
		DECLARE @txnum AS INT
		DECLARE @TempTypeOfTx AS VARCHAR(20)
		DECLARE @TxAccountValue AS DECIMAL(18,6) = 0
		DECLARE @TxPendingValue AS DECIMAL(18,6) = 0
		DECLARE @TxCommission AS DECIMAL (18,6) = 0
		DECLARE @TempCommissionAdd AS DECIMAL(18,6) = 0
		DECLARE @TxStatusOrder AS VARCHAR(20)
		DECLARE @TxLocalTax AS DECIMAL(18,6) = 0
		DECLARE @AuxCommissionDeductsFromOtherAccount AS INT

		SELECT @AuxCommissionDeductsFromOtherAccount = [CommissionDeductsFromOtherAccount]
		FROM [LP_Entity].[EntityUser]
		WHERE idEntityUser = @idEntityUser

		DECLARE tx_cursor CURSOR FORWARD_ONLY FOR
			SELECT idTempTx, [Account], [Type Of Tx], [Pending], [Commission], [LocalTax]
			FROM #TempTransactions
			WHERE [Type of TX] != 'Opening Balance'
			ORDER BY [Order], [Transaction Date] ASC

		-- SET TEMP AMOUNT TO OPENING BALANCE
		SELECT @TempAccount = Account
		FROM #TempTransactions
		Where [Type of TX] = 'Opening Balance'


		OPEN tx_cursor;

			FETCH NEXT FROM tx_cursor INTO @txnum, @TxAccountValue, @TempTypeOfTx, @TxPendingValue, @TxCommission, @TxLocalTax

			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- Set adding commission to 0
				SET @TempCommissionAdd = 0
				-- CHECK IF CURRENT TX ACCOUNT IS NULL
				IF( @TxAccountValue IS NULL OR @TempTypeOfTx = 'Closing Balance' )
				BEGIN
					-- if tx status is in progress/received, we have to add the commission to the amount (only if commissions are deducted from same acct)
					IF(@AuxCommissionDeductsFromOtherAccount = 0)
					BEGIN
						SET @TempCommissionAdd = @TxCommission
					END
			
					SET @TempAccount = @TempAccount - ISNULL(ABS(@TxPendingValue), 0) - ISNULL(ABS(@TempCommissionAdd), 0) - ISNULL(ABS(@TxLocalTax), 0)

					UPDATE #TempTransactions SET [Account] = @TempAccount WHERE idTempTx = @txnum
				END
				ELSE
				BEGIN
					-- IF ACCOUNT BAL HAS VALUE, UPDATE TEMP ACCOUNT VAR
					SET @TempAccount = @TxAccountValue
				END

				FETCH NEXT FROM tx_cursor INTO @txnum, @TxAccountValue, @TempTypeOfTx, @TxPendingValue, @TxCommission, @TxLocalTax
			END

			CLOSE tx_cursor
			DEALLOCATE tx_cursor



		DECLARE @AmountColumnName AS VARCHAR(30) = 'Amount (' + @LPCurrencyCode + ')'
		DECLARE @PayableColumnName AS VARCHAR(30) = 'Payable (' + @LPCurrencyCode + ')'
		DECLARE @PendingColumnName AS VARCHAR(30) = 'Pending (' + @ClientCurrencyCode + ')'
		DECLARE @ConfirmedColumnName AS VARCHAR(30) = 'Confirmed (' + @ClientCurrencyCode + ')'
		DECLARE @LocaltaxColumnName AS VARCHAR(30) = 'Localtax (' + @ClientCurrencyCode + ')'
		DECLARE @CommissionColumnName AS VARCHAR(30) = 'Commission (' + @ClientCurrencyCode + ')'
		DECLARE @AccountColumnName AS VARCHAR(30) = 'Account (' + @ClientCurrencyCode + ')'


		EXEC tempdb..sp_rename '#TempTransactions.Amount', @AmountColumnName, 'COLUMN'
		EXEC tempdb..sp_rename '#TempTransactions.Payable', @PayableColumnName, 'COLUMN'
		EXEC tempdb..sp_rename '#TempTransactions.Pending', @PendingColumnName, 'COLUMN'
		EXEC tempdb..sp_rename '#TempTransactions.Confirmed', @ConfirmedColumnName, 'COLUMN'
		EXEC tempdb..sp_rename '#TempTransactions.Localtax', @LocaltaxColumnName, 'COLUMN'
		EXEC tempdb..sp_rename '#TempTransactions.Commission', @CommissionColumnName, 'COLUMN'
		EXEC tempdb..sp_rename '#TempTransactions.Account', @AccountColumnName, 'COLUMN'

		DECLARE @SelectSQL AS VARCHAR(MAX)

		
		-- Creating string query to select fields except order and id
		SET @SelectSQL = '
		SELECT [Transaction Date], [Lot Out Date], [Ticket], [Alternative Ticket], [Provider], [Type Of Tx], [Automatic], [Lot In], [Lot Out], [Status], [Detail Status], [Merchant], [SubMerchant], [Merchant ID], [' + 
							@AmountColumnName + '], [' + @PayableColumnName + '], [Fx Merchant], [' + @PendingColumnName + '], [' + @ConfirmedColumnName + '], [' + @LocaltaxColumnName + '], [' + @CommissionColumnName
							+ '], [' + @AccountColumnName + '] 
		FROM #TempTransactions
		ORDER BY [Order], [Transaction Date]'

		EXECUTE(@SelectSQL)

		DROP TABLE IF EXISTS #TempTransactions

		FETCH NEXT FROM tx_cursor_merchant INTO @idEntityUser
	END

	CLOSE tx_cursor_merchant
	DEALLOCATE tx_cursor_merchant

END