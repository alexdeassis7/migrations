CREATE OR ALTER PROCEDURE [LP_Operation].[MerchantReport]
                          (
                            @json     [LP_Common].[LP_F_VMAX]
                            , @country_code [LP_Common].[LP_F_C3]
							, @returnAsJson INT = 0
                          )
AS


BEGIN


	DECLARE @idEntityUser [LP_Common].[LP_F_INT],
			@offset INT,
			@dateFrom [LP_Common].[LP_A_DB_INSDATETIME],
			@dateTo [LP_Common].[LP_A_DB_INSDATETIME],
			@id_transactioOper  [LP_Common].[LP_F_INT],
			@payMethod      [LP_Common].[LP_F_C6],
			@pageSize       [LP_Common].[LP_F_INT],
			@transactionType    [LP_Common].[LP_F_CODE],
			@lotId        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
    		@merchantId     [LP_Common].[LP_F_DESCRIPTION],
			@ticket       [LP_Common].[LP_F_C150]

SELECT
		@idEntityUser     = CAST(JSON_VALUE(@JSON, '$.idEntityAccount') AS INT)
		,@dateFrom        = CAST(JSON_VALUE(@JSON, '$.dateFrom') AS VARCHAR(8))
		,@dateTo        = CAST(JSON_VALUE(@JSON, '$.dateTo') AS VARCHAR(8))
		,@id_transactioOper   = CAST(JSON_VALUE(@JSON, '$.id_transactioOper') AS INT)
		,@payMethod       = CAST(JSON_VALUE(@JSON, '$.payMethod') AS VARCHAR(6))
		,@pageSize        = CAST(JSON_VALUE(@JSON, '$.pageSize') AS INT)
		,@offset        = CAST(JSON_VALUE(@JSON, '$.offset') AS INT)
		,@transactionType   = CAST(JSON_VALUE(@JSON, '$.transactionType') AS VARCHAR(10)) 
		,@lotId         = CAST(JSON_VALUE(@JSON, '$.lotId') AS BIGINT)
		,@merchantId      = CAST(JSON_VALUE(@JSON, '$.merchantId') AS VARCHAR(22))
		,@ticket        = CAST(JSON_VALUE(@JSON, '$.ticket') AS VARCHAR(150))

DECLARE @ClientCurrencyCode AS VARCHAR(3),
		@LPCurrencyCode		AS VARCHAR(3)

SELECT @ClientCurrencyCode	= [CT_CL].[Code],
		@LPCurrencyCode		= [CT_LP].[Code]
FROM [LP_Entity].[EntityCurrencyExchange] [ECE]
INNER JOIN [LP_Configuration].[CurrencyType] [CT_CL] ON [CT_CL].[idCurrencyType] = [ECE].[idCurrencyTypeClient]
INNER JOIN [LP_Configuration].[CurrencyType] [CT_LP] ON [CT_LP].[idCurrencyType] = [ECE].[idCurrencyTypeLP]
WHERE [ECE].[idEntityUser] = @idEntityUser


SELECT 
            [Transaction Date]  = [T].[TransactionDate],
            [Processed Date]    = IIF([TO].[Code] = 'LP-Action', [T].[TransactionDate], [T].[ProcessedDate]),
			[Ticket]			= IIF([BCT].[Ticket] IS NOT NULL, [BCT].[Ticket], [TK].[Ticket]),
            [Type of TX]         = [TT].[Name],
			[Automatic]         = IIF([TM].[Code] = 'MEC_AUTO', 1, 0),
			[ID Lot]			= [T].[idTransactionLot],
			[Merchant]			= [EU].[LastName],
			[SubMerchant]		= [ESM].[SubMerchantIdentification],
			[Merchant ID]		= CASE WHEN [TT].[Code] = 'Return' OR [TT].[Code] = 'Recall' THEN [T].[ReferenceTransaction]
									ELSE IIF([TO].[Code] = 'PO', ISNULL([TRD].[InternalDescription], [BCT].[Invoice]), IIF([TO].[CODE] = 'PI', [TPID].[MerchantId],''))
								END,
			[Status]			= [S].[Name],
			[Detail Status]		= CASE 
									WHEN [TO].[Code] = 'LP-Action' THEN REPLACE([TD2].[Description], '&', ' ')
									WHEN [LPIE].[Name] IS NULL THEN 
																CASE WHEN [T].[idStatus] = 1 THEN 'The tx was received and will be processed'
																WHEN [T].[idStatus] = 3 THEN 'The tx is being processed. You cannot cancel any more'
																WHEN [T].[idStatus] IN (4, 9) THEN 'Successfully executed'
																WHEN [T].[idStatus] = 15 THEN 'The payout has been returned'
																WHEN [T].[idStatus] = 16 THEN 'The payout has been recalled'
															END
									ELSE [LPIE].[Name]
								  END,
			[Amount]          = CASE
                            WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
                                [W].[GrossValueClient]
							WHEN [TT].[Code] = 'Return' OR [TT].[Code] = 'Recall' THEN
								[T].[GrossValueClient]
                            ELSE
                                [TD].[GrossAmount]
                            END,
            [Payable]         = CASE
							WHEN [TT].[Code] = 'Return' OR [TT].[Code] = 'Recall' THEN
								[T].[GrossValueClient]
                            ELSE
                                [TD].[NetAmount]
                            END,
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
									[S].[Code] NOT IN ('Rejected', 'Canceled', 'Executed','PAID_FIRST', 'Returned', 'Recalled'),
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
									[S].[Code] NOT IN ('Rejected', 'Canceled', 'Executed','PAID_FIRST', 'Returned', 'Recalled'),
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
                                        [S].[Code] IN ('Executed','PAID_FIRST', 'Returned', 'Recalled'),
                                        IIF
                                        (
                                          [TO].[Code] = 'PO' OR [TO].[Code] = 'RF',
                                          ISNULL([W].[GrossValueClient], [W].[GrossValueLP]),
                                          ISNULL([W].[GrossValueLP], [W].[GrossValueClient])
                                        ),
                                        NULL
                                      ),
			[LocalTax]        = --ISNULL([TD].[LocalTax] * -1, 0),
								IIF
								(
									[TT].[Name] = 'Return',
									ISNULL([TDR2].LocalTax, 0), 
									ISNULL([TD].[LocalTax] * -1, 0)
								),
			[Commission]      = IIF
								(
									[TT].[Name] = 'Return',
									ISNULL([TDR2].Commission, 0), 
									CASE 
										WHEN [EU].[CommissionDeductsFromOtherAccount] = 1
											THEN 0 
											ELSE 
												IIF
												(
													[S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
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
								),
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
			[idWallet]			= [W].[idWallet],
			[Order]				= 1

		INTO #TempTransactions
        FROM
			[LP_Operation].[Transaction]             [T]
            LEFT JOIN  [LP_Operation].[TransactionDetail]      [TD]                                        ON [TD].[idTransaction]       = [T].[idTransaction]                       
            INNER JOIN [LP_Operation].[TransactionLot]            [TL]                                        ON [T].[idTransactionLot]     = [TL].[idTransactionLot]                       
            LEFT JOIN [LP_Operation].[TransactionRecipientDetail]       [TRD] WITH(INDEX=IX_LP_Operation_TransactionRecipientDetail_idTransaction)    ON [T].[idTransaction]        = [TRD].[idTransaction]
			LEFT JOIN [LP_Operation].[TransactionRecipientDetail]       [TRD2]									ON [T].[ReferenceTransaction]        = 	[TRD2].[InternalDescription]
			LEFT JOIN [LP_Operation].[TransactionDetail]				[TDR2]									ON [TRD2].[idTransaction]        	 =	[TDR2].[idTransaction]
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
        WHERE
            (
            ( ( CAST([T].[ProcessedDate] AS DATE) >= @dateFrom ) OR ( @dateFrom  IS NULL ) ) AND ( ( CAST([T].[ProcessedDate] AS DATE) <= @dateTo ) OR ( @dateTo IS NULL ) )
            )

            AND (
				( [TO].[idTransactionOperation] = @id_transactioOper ) OR ( @id_transactioOper IS NULL )
            )
            
			AND (
				( [T].[idEntityUser] = @idEntityUser ) OR ( @idEntityUser IS NULL )
            )
            AND (
				( [TT].[Code] = @transactionType ) OR ( @transactionType IS NULL )
            )	
			AND ( [TL].[LotNumber] = @lotId OR @lotId IS NULL )
			AND ( [TK].[Ticket] = @ticket OR @ticket IS NULL )
			AND ( [TRD].[InternalDescription] = @merchantId OR @merchantId IS NULL)
			AND [T].[idStatus] IN (4,15,16)
        ORDER BY
			[T].[ProcessedDate] ASC

        OFFSET ISNULL(@offset,0) ROWS  

/*
	OPENING AND CLOSING BALANCE
*/

-- SET TX DATE ALLOW NULL
ALTER TABLE #TempTransactions
ALTER COLUMN [Transaction Date] DATETIME NULL

IF(EXISTS(SELECT TOP 1 [idWallet] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [OP_InsDateTime] < @dateFrom ORDER BY [idWallet] DESC ))
BEGIN
      INSERT INTO #TempTransactions ([Transaction Date], [Processed Date], [Type of TX], Automatic, [ID Lot],
										Amount, Payable, [Fx Merchant], Pending, Confirmed, LocalTax, Commission, Account,
										Ticket, Merchant, SubMerchant, [Merchant ID], Status, [Detail Status], [idWallet], [Order])
      SELECT TOP 1
		NULL, -- TRANSACTION DATE
		FORMAT(@dateFrom, 'yyyy-MM-dd'), -- PROCESSED DATE
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
		'', '', '', '', '' , '', [W].[idWallet], 0
		FROM
        [LP_Operation].[Transaction]                [T]
          LEFT JOIN [LP_Operation].[TransactionRecipientDetail] [TRD] ON  [TRD].[idTransaction] = [T].[idTransaction]
          LEFT JOIN [LP_Configuration].[CurrencyType]       [CT]  ON  [CT].[idCurrencyType] = [T].[CurrencyTypeClient]
          LEFT JOIN [LP_Operation].[Wallet]           [W]   ON  [W].[idTransaction]   = [T].[idTransaction]
		  LEFT JOIN [LP_Entity].[EntityUser]		[EU] ON [EU].[idEntityUser] = [W].[idEntityUser]
      WHERE
        [W].[idEntityUser] = @idEntityUser
        AND  [T].[ProcessedDate] < @dateFrom
      ORDER BY
	  [W].[idWallet] DESC
END
ELSE
BEGIN
    INSERT INTO #TempTransactions ([Transaction Date], [Processed Date], [Type of TX], Automatic, [ID Lot], Amount, Payable, [Fx Merchant], Pending, Confirmed, LocalTax, Commission, Account,
									Ticket, Merchant, SubMerchant, [Merchant ID], Status, [Detail Status], [idWallet], [Order])
    VALUES ( FORMAT(@dateFrom, 'yyyy-MM-dd'), FORMAT(@dateFrom, 'yyyy-MM-dd'), 'Opening Balance', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '' , '', 0, 0 )
END

DECLARE @lastDate AS DATETIME = FORMAT(@dateTo, 'yyyy-MM-dd')
DECLARE @LastAmountValue  [LP_Common].[LP_F_DECIMAL]
SET @lastDate = DATEADD(DAY, 1, @lastDate)
SET @lastDate = DATEADD(SECOND, -1, @lastDate)

SELECT TOP 1 
		@LastAmountValue = ISNULL([Account], 0)
FROM #TempTransactions
ORDER BY [Processed Date] DESC, [ID Lot] DESC, [Ticket] DESC

INSERT INTO #TempTransactions ([Transaction Date], [Processed Date], [Type of TX], Automatic, [ID Lot], Amount, Payable, [Fx Merchant], Pending, Confirmed, LocalTax, Commission, Account, [idWallet], [Order])
VALUES ( NULL, @lastDate, 'Closing Balance', 0, 0, 0, 0, 0, 0, 0, 0, 0, @LastAmountValue, 0, 2 )

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


--IF @returnAsJson = 1
--BEGIN
--	DECLARE @RESP AS XML
--	SET @RESP = CAST((
--	SELECT *
--	FROM #TempTransactions
--	ORDER BY [Processed Date]
--	FOR JSON PATH, INCLUDE_NULL_VALUES) AS XML)

--	SELECT @RESP
--END
--ELSE
--BEGIN
--	SELECT *
--	FROM #TempTransactions
--	ORDER BY [Processed Date]
--END


DECLARE @SelectSQL AS VARCHAR(MAX)


IF @returnAsJson = 1
BEGIN
	DECLARE @RESP AS XML
	-- Creating string query to select fields except order and id
	SET @SelectSQL = '
		DECLARE @RESP AS XML

		SET @RESP = CAST((
		SELECT [Transaction Date], [Processed Date], [Ticket], [Type Of Tx], [Automatic], [ID Lot], [Merchant], [SubMerchant], [Merchant ID], [Status], [Detail Status], [' + 
						@AmountColumnName + '], [' + @PayableColumnName + '], [Fx Merchant], [' + @PendingColumnName + '], [' + @ConfirmedColumnName + '], [' + @LocaltaxColumnName + '], [' + @CommissionColumnName
						+ '], [' + @AccountColumnName + '] 
		FROM #TempTransactions
		ORDER BY [Order], CAST(CONVERT(CHAR(16), [Processed Date],20) AS datetime), [idWallet]
		FOR JSON PATH, INCLUDE_NULL_VALUES) AS XML)
		
		SELECT @RESP'
	EXECUTE(@SelectSQL)

END
ELSE
BEGIN
	-- Creating string query to select fields except order and id
	SET @SelectSQL = '
	SELECT [Transaction Date], [Processed Date], [Ticket], [Type Of Tx], [Automatic], [ID Lot], [Merchant], [SubMerchant], [Merchant ID], [Status], [Detail Status], [' + 
						@AmountColumnName + '], [' + @PayableColumnName + '], [Fx Merchant], [' + @PendingColumnName + '], [' + @ConfirmedColumnName + '], [' + @LocaltaxColumnName + '], [' + @CommissionColumnName
						+ '], [' + @AccountColumnName + '] 
	FROM #TempTransactions
	ORDER BY [Order], CAST(CONVERT(CHAR(16), [Processed Date],20) AS datetime), [idWallet]'

	EXECUTE(@SelectSQL)
END



END