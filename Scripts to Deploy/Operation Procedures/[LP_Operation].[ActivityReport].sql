USE [LocalPaymentProd]
GO
/****** Object:  StoredProcedure [LP_Operation].[ActivityReport]    Script Date: 16/07/2021 15:23:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [LP_Operation].[ActivityReport]
                          (
                            @json     [LP_Common].[LP_F_VMAX]
                            , @country_code [LP_Common].[LP_F_C3]
							, @returnAsJson INT = 0
                          )
AS


BEGIN


	DECLARE @idEntityUser 		[LP_Common].[LP_F_INT],
			@idEntityAccount 	[LP_Common].[LP_F_INT],
			@offset INT,
			@dateFrom 			[LP_Common].[LP_A_DB_INSDATETIME],
			@dateTo 			[LP_Common].[LP_A_DB_INSDATETIME],
			@id_transactioOper  [LP_Common].[LP_F_INT],
			@payMethod      	[LP_Common].[LP_F_C6],
			@pageSize      		[LP_Common].[LP_F_INT],
			@transactionType    [LP_Common].[LP_F_CODE],
			--@lotId        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
    		--@merchantId   [LP_Common].[LP_F_DESCRIPTION],
			--@ticket       [LP_Common].[LP_F_C150],
			@idStatus		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
			@idCountry 		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
			@orderBy 		[LP_Common].[LP_F_INT],
			@orderType 		[LP_Common].[LP_F_INT],
			@dateFilterBy 	[LP_Common].[LP_F_INT],
			@searchInput 	VARCHAR(60),
			@customer		[LP_Common].[LP_F_C50]

SELECT
		@idEntityUser     		= CAST(JSON_VALUE(@JSON, '$.idEntityUser') AS INT)
		,@idEntityAccount 		= CAST(JSON_VALUE(@JSON, '$.idEntityAccount') AS INT)
		,@dateFrom        		= CAST(JSON_VALUE(@JSON, '$.dateFrom') AS VARCHAR(8))
		,@dateTo        		= CAST(JSON_VALUE(@JSON, '$.dateTo') AS VARCHAR(8))
		,@id_transactioOper   	= CAST(JSON_VALUE(@JSON, '$.id_transactioOper') AS INT)
		,@payMethod       		= CAST(JSON_VALUE(@JSON, '$.payMethod') AS VARCHAR(6))
		,@pageSize        		= CAST(JSON_VALUE(@JSON, '$.pageSize') AS INT)
		,@offset        		= CAST(JSON_VALUE(@JSON, '$.offset') AS INT)
		,@transactionType   	= CAST(JSON_VALUE(@JSON, '$.transactionType') AS VARCHAR(10)) 
		--,@lotId         = CAST(JSON_VALUE(@JSON, '$.lotId') AS BIGINT)
		,@searchInput      		= CAST(JSON_VALUE(@JSON, '$.merchantId') AS VARCHAR(22))
		--,@ticket        = CAST(JSON_VALUE(@JSON, '$.ticket') AS VARCHAR(150))
		,@idStatus				= CAST(JSON_VALUE(@JSON, '$.id_status') AS INT)
		,@country_code			= CAST(JSON_VALUE(@JSON, '$.countryCode') AS VARCHAR(3))
		,@orderBy				= CAST(JSON_VALUE(@JSON, '$.orderBy') AS INT)
		,@orderType				= CAST(JSON_VALUE(@JSON, '$.orderType') AS INT)
		,@dateFilterBy			= CAST(JSON_VALUE(@JSON, '$.dateFilterBy') AS INT)
		,@customer				= CAST(JSON_VALUE(@JSON, '$.customer_id') AS VARCHAR(50))

DECLARE @ClientCurrencyCode AS VARCHAR(3),
		@LPCurrencyCode		AS VARCHAR(3)

SELECT @idCountry = [idCountry]
FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @country_code

BEGIN
	IF (@country_code IS NULL) OR (@idEntityUser IN (SELECT [idEntityUser] FROM [LP_Security].[EntityAccountUser]  WHERE idEntityAccount = @idEntityAccount))
	BEGIN
		SET @idEntityUser = NULL
	END
END

IF @customer LIKE '%localpayment%'  
BEGIN
	SET @idEntityAccount = NULL
END

SELECT 
            [Transaction Date]  = [T].[TransactionDate],
            [Processed Date]    = IIF([TO].[Code] = 'LP-Action', [T].[TransactionDate], [T].[ProcessedDate]),
			[Ticket]			= IIF([BCT].[Ticket] IS NOT NULL, [BCT].[Ticket], [TK].[Ticket]),
			[Alternative Ticket]= (CASE WHEN [TicketAlternative7] IS NOT NULL THEN [TicketAlternative7] 
								  WHEN [TicketAlternative8] IS NOT NULL THEN [TicketAlternative8]
								  WHEN [TicketAlternative12] IS NOT NULL THEN [TicketAlternative12]
								  ELSE [TicketAlternative] END),
			[Provider]			= [P].[Name],
            [Type of TX]         = [TT].[Name],
			[Automatic]         = IIF([TM].[Code] = 'MEC_AUTO', 1, 0),
			[Lot In]			= [T].[idTransactionLot],
			[Lot Out]			= [T].[idLotOut],
			[Lot Out Date]		= [T].[LotOutDate],
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
																	WHEN [T].[idStatus] = 18 THEN 'The payout has been put on hold'
																	WHEN [T].[idStatus] IN (4, 9) THEN 'Successfully executed'
																END
									ELSE [LPIE].[Name]
								  END,
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
        WHERE
            (
				(
					@dateFilterBy = 1 AND
					( ( CAST([T].[ProcessedDate] AS DATE) >= @dateFrom ) OR ( @dateFrom  IS NULL ) ) AND ( ( CAST([T].[ProcessedDate] AS DATE) <= @dateTo ) OR ( @dateTo IS NULL ) )
				)
				OR
				(
					@dateFilterBy = 2 AND
					( ( CAST([T].[TransactionDate] AS DATE) >= @dateFrom ) OR ( @dateFrom  IS NULL ) ) AND ( ( CAST([T].[TransactionDate] AS DATE) <= @dateTo ) OR ( @dateTo IS NULL ) )
				)
            )

            AND 
			(
				( [TO].[idTransactionOperation] = @id_transactioOper ) OR ( @id_transactioOper IS NULL )
            )
            
			AND (
				( [T].[idEntityUser] = @idEntityUser ) OR ( @idEntityUser IS NULL )
            )
			AND (
				( [EA].[idEntityAccount] = @idEntityAccount ) OR ( @idEntityAccount IS NULL )
            )

            AND (
				( [TT].[Code] = @transactionType ) OR ( @transactionType IS NULL )
            )	
			AND ((CAST(TK.Ticket AS VARCHAR(60)) = @searchInput OR CAST(TRD.InternalDescription AS VARCHAR(60)) = @searchInput OR CAST(T.idLotOut AS VARCHAR(60)) = @searchInput OR CAST(T.idTransactionLot AS VARCHAR(60)) = @searchInput ) OR (@searchInput IS NULL OR @searchInput = ''))
			AND (
				( [T].[idStatus] = @idStatus ) OR ( @idStatus IS NULL )
            )
			AND ( 
				([EU].[idCountry] = @idCountry ) OR (@idCountry IS NULL)
			)
        ORDER BY
			[T].[ProcessedDate] ASC

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

DECLARE @OrderByText AS VARCHAR(30)
DECLARE @OrderTypeText AS VARCHAR(5)


SET @OrderByText = CASE 
	WHEN @orderBy = 1 THEN '[Processed Date]'
	WHEN @orderBy = 2 THEN '[Transaction Date]'
	WHEN @orderBy = 3 THEN '[Type of TX]'
	WHEN @orderBy = 4 THEN '[Status]'
	ELSE '[Processed Date]'
END

SET @OrderTypeText = CASE
	WHEN @orderType = 1 THEN 'ASC'
	WHEN @orderType = 2 THEN 'DESC'
	ELSE 'ASC'
END

DECLARE @SQL AS VARCHAR(MAX)


IF @returnAsJson = 1
BEGIN
	SET @SQL = '
	DECLARE @RESP AS XML
	SET @RESP = CAST((
	SELECT *
	FROM #TempTransactions
	ORDER BY ' + @OrderByText + ' ' + @OrderTypeText + '
	FOR JSON PATH, INCLUDE_NULL_VALUES) AS XML)

	SELECT @RESP'

	EXECUTE(@SQL)
END
ELSE
BEGIN
	SET @SQL = '
	SELECT *
	FROM #TempTransactions
	ORDER BY ' + @OrderByText + ' ' + @OrderTypeText

	EXECUTE(@SQL)
END



END