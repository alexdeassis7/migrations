CREATE OR ALTER PROCEDURE [LP_Operation].[OperationalReport]
                          (
                            @json     [LP_Common].[LP_F_VMAX]
                            , @country_code [LP_Common].[LP_F_C3]
                          )
AS


BEGIN


	-- DECLARING TABLE WITH SELECTED TICKETS
	DECLARE @TempTxsToDownload AS TABLE (idTransaction INT)
	INSERT INTO @TempTxsToDownload
	SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)
			


DECLARE @ClientCurrencyCode AS VARCHAR(3),
		@LPCurrencyCode		AS VARCHAR(3)


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
            [Type of TX]        = [TT].[Name],
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
                                        NULL
                                      ),
			[LocalTax]        = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TD].[LocalTax] * -1, 
                                        NULL
                                      ),
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
															,[TD].[Commission_With_VAT]
															,[LP_Operation].[fnGetCommisionExchange]([CEC].[idCurrencyExchange],[CB].[idCurrencyBase],[TD].[Commission_With_VAT],0)
														)
														,[TD].[Commission_With_VAT]
													),
													0
												  )
										END

		INTO #TempTransactions
        FROM
			[LP_Operation].[Transaction]             [T]
            LEFT JOIN  [LP_Operation].[TransactionDetail]      [TD]                                        ON [TD].[idTransaction]       = [T].[idTransaction]                       
            INNER JOIN [LP_Operation].[TransactionLot]            [TL]                                        ON [T].[idTransactionLot]     = [TL].[idTransactionLot]                       
            LEFT JOIN [LP_Operation].[TransactionRecipientDetail]       [TRD] WITH(INDEX=IX_LP_Operation_TransactionRecipientDetail_idTransaction)    ON [T].[idTransaction]        = [TRD].[idTransaction]
            LEFT JOIN [LP_Operation].[BarCodeTicket]            [BCT] WITH(INDEX=IX_LP_Operation_BarCodeTicket_idTransaction)           ON [T].[idTransaction]        = [BCT].[idTransaction] AND [BCT].[Active] = 1
            LEFT JOIN [LP_Operation].[Ticket]               [TK]  WITH(INDEX=IX_LP_Operation_Ticket_idTransaction)              ON [T].[idTransaction]        = [TK].[idTransaction]
            LEFT JOIN [LP_Operation].[TransactionProvider]          [TP]  WITH(INDEX=IX_LP_Operation_TransactionProvider_idTransaction)       ON [T].[idTransaction]        = [TP].[idTransaction]
            LEFT JOIN [LP_Operation].[TransactionCollectedAndPaidStatus]  [TCAPS] WITH(INDEX=IX_LP_Operation_TransactionCollectedAndPaidStatus_idTransaction) ON [T].[idTransaction]        = [TCAPS].[idTransaction]
            LEFT JOIN [LP_Operation].[TransactionInternalStatus]      [TIS] WITH(INDEX=IX_LP_Operation_TransactionInternalStatus_idTransaction)     ON [T].[idTransaction]        = [TIS].[idTransaction] AND [TIS].[Active] = 1
            LEFT JOIN [LP_Operation].[Wallet]                 [W]   WITH(INDEX=IX_LP_Operation_Wallet_idTransaction)              ON [T].[idTransaction]        = [W].[idTransaction] AND [W].[Active] = 1
            LEFT JOIN [LP_OPERATION].[TransactionDescription]       [TD2] WITH(INDEX=IX_LP_Operation_TransactionDescription_idTransaction)      ON [T].[idTransaction]        = [TD2].[idTransaction]
            LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]     [TESM]  WITH(INDEX=IX_LP_Operation_TransactionEntitySubMerchant_idTransaction)    ON [TESM].[idTransaction]     = [T].[idTransaction]
            LEFT JOIN [LP_Operation].[TransactionPayinDetail] [TPID]											ON [TPID].[idTransaction] = [T].[idTransaction] 
			LEFT JOIN [LP_Configuration].[CurrencyExchange]         [CE]                                        ON [T].[idCurrencyExchange]     = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyExchange]         [CEC]                                       ON [T].[idCurrencyExchangeClosed] = [CEC].[idCurrencyExchange]
            LEFT JOIN [LP_Common].[Status]                  [S]                                         ON [T].[idStatus]         = [S].[idStatus]
            LEFT JOIN [LP_Configuration].[InternalStatus]           [IS]                                        ON [TIS].[idInternalStatus]     = [is].[idInternalStatus]
            LEFT JOIN [LP_Configuration].[LPInternalStatusClient] [LPIC]										 ON [LPIC].[idInternalStatus] = [IS].idInternalStatus
            LEFT JOIN [LP_Configuration].[LPInternalError]        [LPIE]										ON [LPIE].[idLPInternalError] = [LPIC].[idLPInternalError]
			LEFT JOIN [LP_Security].[EntityAccount]             [EA]                                        ON [T].[idEntityAccount]      = [EA].[idEntityAccount]            
            LEFT JOIN [LP_Entity].[EntityUser]                [EU]                                        ON [T].[idEntityUser]       = [EU].[idEntityUser]
            LEFT JOIN [LP_Entity].[EntityMerchant]              [EM]                                        ON [EU].[idEntityMerchant]      = [EM].[idEntityMerchant]
            LEFT JOIN [LP_Configuration].[TransactionMechanism]       [TM]                                        ON [T].[idTransactionMechanism]   = [TM].[idTransactionMechanism]
            LEFT JOIN [LP_Configuration].[TransactionTypeProvider]      [TTP]                                       ON [T].[idTransactionTypeProvider]  = [TTP].[idTransactionTypeProvider]
            LEFT JOIN [LP_Configuration].[Provider]             [P]                                         ON [TTP].[idProvider]       = [P].[idProvider]
            LEFT JOIN [LP_Configuration].[TransactionType]          [TT]                                        ON [TTP].[idTransactionType]    = [TT].[idTransactionType]
            LEFT JOIN [LP_Configuration].[TransactionGroup]         [TG]                                        ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
            LEFT JOIN [LP_Configuration].[TransactionOperation]       [TO]                                        ON [TG].[idTransactionOperation]  = [TO].[idTransactionOperation]
            LEFT JOIN [LP_Configuration].[CurrencyBase]           [CB]                                        ON [T].[idCurrencyBase]       = [CB].[idCurrencyBase]                       
            LEFT JOIN [LP_Entity].[EntityCurrencyExchange]          [ECE]                                       ON [EU].[idEntityUser]        = [ECE].[idEntityUser]                        
            LEFT JOIN [LP_Configuration].[CurrencyType]           [CT_CL]                                       ON [ECE].[idCurrencyTypeClient]     = [CT_CL].[idCurrencyType]
			LEFT JOIN [LP_Configuration].[CurrencyType]           [CT_LP]                                       ON [ECE].[idCurrencyTypeLP]     = [CT_LP].[idCurrencyType]
            LEFT JOIN [LP_Entity].[EntitySubMerchant]           [ESM]                                       ON [ESM].[idEntitySubMerchant]    = [TESM].[idEntitySubMerchant]
			INNER JOIN [LP_Location].[Country]                [C]                                         ON [C].[idCountry]          = [EU].[idCountry]
			INNER JOIN @TempTxsToDownload					[TEMP]										ON	[TEMP].[idTransaction]				= [T].[idTransaction]
        ORDER BY
			[T].[TransactionDate] ASC

IF (SELECT COUNT(1) FROM #TempTransactions) = 0
BEGIN
	SELECT ''
	RETURN
END

-- TODO CHECK CURRENCY CODES
SELECT @ClientCurrencyCode	= [CT_CL].[Code],
		@LPCurrencyCode		= [CT_LP].[Code]
FROM [LP_Entity].[EntityCurrencyExchange] [ECE]
INNER JOIN [LP_Configuration].[CurrencyType] [CT_CL] ON [CT_CL].[idCurrencyType] = [ECE].[idCurrencyTypeClient]
INNER JOIN [LP_Configuration].[CurrencyType] [CT_LP] ON [CT_LP].[idCurrencyType] = [ECE].[idCurrencyTypeLP]
WHERE [ECE].[idEntityUser] = (
		SELECT TOP 1 [EU].[idEntityUser] 
		FROM #TempTransactions [TEMP] 
		INNER JOIN LP_Operation.[Transaction] [T] ON [T].[idTransactionLot] = [TEMP].[Lot In]
		INNER JOIN [LP_Entity].[EntityUser] [EU] ON [EU].[idEntityUser] = [T].[idEntityUser]
)
-- 

-- UPDATE ADD / DEBIT BALANCE ROWS VALUES
UPDATE #TempTransactions SET
	[Amount] = 0.00,
	[Payable] = 0.00,
	[LocalTax] = 0.00,
	[Commission] = 0.00
WHERE [Type of TX] IN ('Add Balance', 'Debit Balance')


DECLARE @AmountColumnName AS VARCHAR(30) = 'Amount (' + @LPCurrencyCode + ')'
DECLARE @PayableColumnName AS VARCHAR(30) = 'Payable (' + @LPCurrencyCode + ')'
DECLARE @PendingColumnName AS VARCHAR(30) = 'Pending (' + @ClientCurrencyCode + ')'
--DECLARE @ConfirmedColumnName AS VARCHAR(30) = 'Confirmed (' + @ClientCurrencyCode + ')'
DECLARE @LocaltaxColumnName AS VARCHAR(30) = 'Localtax (' + @ClientCurrencyCode + ')'
DECLARE @CommissionColumnName AS VARCHAR(30) = 'Commission (' + @ClientCurrencyCode + ')'

EXEC tempdb..sp_rename '#TempTransactions.Amount', @AmountColumnName, 'COLUMN'
EXEC tempdb..sp_rename '#TempTransactions.Payable', @PayableColumnName, 'COLUMN'
EXEC tempdb..sp_rename '#TempTransactions.Pending', @PendingColumnName, 'COLUMN'
--EXEC tempdb..sp_rename '#TempTransactions.Confirmed', @ConfirmedColumnName, 'COLUMN'
EXEC tempdb..sp_rename '#TempTransactions.Localtax', @LocaltaxColumnName, 'COLUMN'
EXEC tempdb..sp_rename '#TempTransactions.Commission', @CommissionColumnName, 'COLUMN'

-- RETURNING DATA
SELECT *
FROM #TempTransactions
ORDER BY [Transaction Date]

EXEC [LP_Operation].[OperationalReportCountryBalance] @country_code


END