SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [LP_Operation].[ListReconciliationReport]
                            (
                              @customer [LP_Common].[LP_F_C50],
                              @JSON   NVARCHAR(MAX)
                            )
AS
BEGIN
  DECLARE
    @qtyAccount         [LP_Common].[LP_F_INT]
    , @Message          [LP_Common].[LP_F_C50]
    , @Status         [LP_Common].[LP_F_BOOL]
    , @transLot         [LP_Common].[LP_F_INT]
    , @idEntityUser       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @BIC_Description      [LP_Common].[LP_F_C50]
    , @Provider_Description   [LP_Common].[LP_F_C50]

  SET @qtyAccount =
          (
            SELECT
              COUNT([idEntityAccount])
            FROM
              [LP_Security].[EntityAccount]
            WHERE
              [UserSiteIdentification] = @customer
              AND [Active] = 1
            )

  IF(@qtyAccount = 1)
  BEGIN

    DECLARE
      @jsonResult       XML
      ,@dateFrom        [LP_Common].[LP_A_DB_INSDATETIME]
      ,@dateTo        [LP_Common].[LP_A_DB_INSDATETIME]
      ,@pageSize        [LP_Common].[LP_F_INT]
      ,@offset        [LP_Common].[LP_F_INT]
	  ,@date		[LP_Common].[LP_A_DB_INSDATETIME]

    SELECT
      @dateFrom       = CAST(JSON_VALUE(@JSON, '$.date') AS VARCHAR(8))
      , @idEntityUser     = CAST(JSON_VALUE(@JSON, '$.idEntityAccount') AS BIGINT)
      , @pageSize       = CAST(JSON_VALUE(@JSON, '$.pageSize') AS INT)
      , @offset       = CAST(JSON_VALUE(@JSON, '$.offset') AS INT)
	  , @dateTo			= JSON_VALUE(@JSON, '$.dateTo')
	  , @date			= JSON_VALUE(@JSON, '$.dateFrom')


	IF(@date IS NOT NULL)
		SET @dateFrom = @date

    IF(@dateFrom IS NULL)
      SET @dateFrom = CONVERT( VARCHAR(8), GETDATE(), 112 )

    DECLARE
      @initialBalance     [LP_Common].[LP_F_DECIMAL]  = 0
      , @debit        [LP_Common].[LP_F_DECIMAL]  = 0
      , @credit       [LP_Common].[LP_F_DECIMAL]  = 0

    IF(@dateFrom IS NULL)
      RAISERROR ('Parameter @date is null.', 16, 0)

    IF(@idEntityUser IS NULL)
      RAISERROR ('Parameter @idEntityUser is null.', 16, 0)

	IF(@dateTo IS NULL)
		SET @dateTo = DATEADD(DAY, 1, @dateFrom)

    IF(@pageSize IS NULL)
      SET @pageSize = (SELECT COUNT(*) FROM [LP_Operation].[Transaction] [T] WHERE [T].[idEntityUser] = @idEntityUser AND CAST([T].[ProcessedDate] AS DATE) >= @dateFrom AND CAST([T].[ProcessedDate] AS DATE) <= @dateTo) + 2

    --SET @BIC_Description = 'LPAYARBA'
    SET @BIC_Description =
                (
                  SELECT
                    [EU].[MerchantAlias]
                  FROM
                    [LP_Entity].[EntityUser]  [EU]
                  WHERE
                    [EU].[idEntityUser] = @idEntityUser
                )

    SET @Provider_Description = 'LocalPayment'

    DECLARE @tStatus TABLE
    (
      [idxStatus]   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]  IDENTITY(1, 1)
      , [Code]    [LP_Common].[LP_F_CODE]           NOT NULL
      , [Order]   [LP_Common].[LP_F_INT]            NOT NULL
      , [idStatus]  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]  NOT NULL
    )

    INSERT INTO @tStatus ( [Code] , [Order], [idStatus] )
    SELECT
      [Code]
      , [Order] = 
            CASE
              WHEN [Code] IN ( 'Executed', 'PAID_FIRST', 'Returned', 'Recalled' ) THEN 1
              WHEN [Code] IN ( 'Rejected' ) THEN 2
              WHEN [Code] IN ( 'InProgress' ) THEN 3
              WHEN [Code] IN ( 'Received' ) THEN 4
              WHEN [Code] IN ( 'Canceled' ) THEN 5
            END
      , [idStatus]
    FROM
      [LP_Common].[Status]
    WHERE
      [Active] = 1
	  AND [Code] NOT IN ('Expired', 'OnHold')

    DECLARE @tbl TABLE
    (
      [IDX]         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]  IDENTITY(1,1)
      , [providerName]    [LP_Common].[LP_F_C100]
      , [ccy]         [LP_Common].[LP_F_C100]
      , [date]        [LP_Common].[LP_F_C100]           NULL
      , [accountNumber]   [LP_Common].[LP_F_C100]
      , [bic]         [LP_Common].[LP_F_C50]
      , [trxType]       [LP_Common].[LP_F_C100]
      , [description]     [LP_Common].[LP_F_VMAX]
      , [payoneerId]      [LP_Common].[LP_F_VMAX]
      , [internalId]      [LP_Common].[LP_F_VMAX]
      , [debit]       [LP_Common].[LP_F_DECIMAL]          NULL
      , [credit]        [LP_Common].[LP_F_DECIMAL]          NULL
      , [availableBalance]  [LP_Common].[LP_F_DECIMAL]          NULL
      , [idTransaction]   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]  NULL
    ) 

    --Setting client vars
    DECLARE @ccy      AS [LP_Common].[LP_F_C100]
    DECLARE @accountNumber  AS [LP_Common].[LP_F_C100]

    SELECT 
      @ccy        = [CT2].[Code]
      , @accountNumber  = ISNULL([EU].[AccountNumberLP], '')
    FROM [LP_Entity].[EntityUser]               [EU]  (NOLOCK)
    INNER JOIN [LP_Entity].[EntityCurrencyExchange]       [ECE] ON  [EU].[idEntityUser]         = [ECE].[idEntityUser]
    INNER JOIN [LP_Configuration].[CurrencyType]        [CT2] ON  [CT2].[idCurrencyType]        = [ECE].[idCurrencyTypeClient]
    WHERE [EU].[idEntityUser] = @idEntityUser

    --Opening balance
    IF(EXISTS(SELECT TOP 1 [idWallet] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [OP_InsDateTime] < @dateFrom ORDER BY [idWallet] DESC ))
    BEGIN
      INSERT INTO @tbl ( [providerName], [ccy], [date], [accountNumber], [bic], [trxType], [description], [payoneerId], [internalId], [availableBalance], [idTransaction])
      SELECT TOP 1
         [providerName]     = @Provider_Description 
        , [ccy]         = @ccy
        , [date]        = FORMAT(@dateFrom, 'yyyy-MM-dd')
        , [accountNumber]   = @accountNumber
        , [bic]         = @BIC_Description
        , [trxType]       = 'Opening Balance'
        , [description]     = ''
        , [payoneerId]      = '' 
        , [internalId]      = '' 
        --, [debit]       = ''
        --, [credit]      = ''
        , [availableBalance]  = CASE WHEN ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
							  THEN
								ISNULL([BalanceClientWithOutCommission], 0) 
							  ELSE
								ISNULL([BalanceLPWithOutCommission], 0)
							END 
        , [idTransaction]   = ISNULL([W].[idTransaction], NULL)
      FROM
        [LP_Operation].[Transaction]                [T]
          LEFT JOIN [LP_Operation].[TransactionRecipientDetail] [TRD] ON  [TRD].[idTransaction] = [T].[idTransaction]
          LEFT JOIN [LP_Configuration].[CurrencyType]       [CT]  ON  [CT].[idCurrencyType] = [T].[CurrencyTypeClient]
          LEFT JOIN [LP_Operation].[Wallet]           [W]   ON  [W].[idTransaction]   = [T].[idTransaction]
		  INNER JOIN [LP_Entity].[EntityUser]             [EU]  ON  [EU].[idEntityUser]         = [T].[idEntityUser]
		  INNER JOIN [LP_Entity].[EntityCurrencyExchange]       [ECE] ON  [EU].[idEntityUser]         = [ECE].[idEntityUser]
      WHERE
        [W].[idEntityUser] = @idEntityUser
        AND  [T].[ProcessedDate] < @dateFrom
      ORDER BY
        [W].[idWallet] DESC
    END
    ELSE
    BEGIN
      INSERT INTO @tbl ( [providerName], [ccy], [date], [accountNumber], [bic], [trxType], [description], [payoneerId], [internalId], [availableBalance], [idTransaction] )
      VALUES ( @Provider_Description, @ccy, FORMAT(@dateFrom, 'yyyy-MM-dd'), @accountNumber, @BIC_Description, 'Opening Balance', '', '', '', 0, 0 )
    END

    --Transactions

    /*

    TransactionOperation
    1 = PI
    2 = PO
    5 = RF
    6 = LP-Action

    */

    INSERT INTO @tbl
    SELECT 
       [providerName]   = @Provider_Description
      ,[ccy]        = [CT_CL].[Code]
      ,[date]       = [T].[ProcessedDate]
      ,[accountNumber]  = ISNULL([EU].[AccountNumberLP], '')
      ,[bic]        = @BIC_Description
      ,[trxType]      = [TT].[Name]
      ,[description]    = ISNULL([S].[Code], '')
      ,[payoneerId]   = ISNULL([TRD].[InternalDescription], '')
      ,[internalId]   = CASE WHEN [TT].[Code] IN ('Return', 'Recall') THEN ISNULL([T].[ReferenceTransaction], '')
						ELSE ISNULL([TK].[Ticket], ISNULL([BCT].[Ticket], ''))
						END
      ,[debit]      =
                  ISNULL
                  (
                    IIF
                    (
                      [TO].[idTransactionOperation] = 2,
                      IIF
                      (
                        [T].[idCurrencyExchangeClosed] IS NULL,
                        ABS(ISNULL([W].[GrossValueClient], [W].[GrossValueLP])) + ISNULL([TD].[LocalTax], 0),
                        ABS(ISNULL([W].[GrossValueClient], [W].[GrossValueLP])) + ISNULL([TD].[LocalTax], 0) 
                      ),
                      IIF
                      (
                        [TO].[idTransactionOperation] = 6 AND [TT].[Code] IN ('AddDebit'),
                        ABS(ISNULL([W].[GrossValueClient], [W].[GrossValueLP])),
                        0
                      )
                    ),
                    0
                  )
      ,[credit]     = 
                  IIF
                  (
                    [TO].[idTransactionOperation] = 1,
                    ABS([TD].[NetAmount] / ( [CE].[Value] * (1 - [CB].[Base_Sell] / 100))),
                    IIF
                    (
                      [TO].[idTransactionOperation] = 6 AND [TT].[Code] IN ('AddBalance', 'Return', 'Recall'),
                      ABS(ISNULL([W].[GrossValueClient], [W].[GrossValueLP])),
                      0
                    )
                  )
      ,[availableBalance] = CASE WHEN ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
							  THEN
								[BalanceClientWithOutCommission] 
							  ELSE
								[BalanceLPWithOutCommission]
							END
      ,[idTransaction]  = [T].[idTransaction]




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
			--INNER JOIN @tStatus [TSTAT]																			ON [TSTAT].[idStatus] = [T].[idStatus]
    WHERE
      [EU].[idEntityUser] = @idEntityUser AND CAST([T].[ProcessedDate] AS DATE) >= @dateFrom AND CAST([T].[ProcessedDate] AS DATE) <= @dateFrom
	  AND [T].[idStatus] <> 10
    ORDER BY
      --[TSTAT].[Order] ASC,
      CONVERT(VARCHAR(16), [T].[ProcessedDate], 20),
      ISNULL([W].[idWallet], [T].[idTransaction])

    DECLARE
      @LastAmountValue  [LP_Common].[LP_F_DECIMAL]
      , @idTransaction  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

    SELECT TOP 1
      @LastAmountValue = ISNULL( [availableBalance], 0 )
      , @idTransaction = ISNULL( [idTransaction], NULL )
    FROM
      @tbl
    WHERE
      [availableBalance] IS NOT NULL
    ORDER BY
      [IDX] DESC

    UPDATE @tbl
    SET
      [availableBalance] = @LastAmountValue
    WHERE
      [availableBalance] IS NULL  

    --Closing balance
    INSERT INTO @tbl ( [providerName], [ccy], [date], [accountNumber], [bic], [trxType], [description], [payoneerId], [internalId], [availableBalance], [idTransaction])
    SELECT
       [providerName]     = @Provider_Description
      ,[ccy]          = @ccy
      ,[date]         = FORMAT(@dateFrom, 'yyyy-MM-dd')
      ,[accountNumber]    = @accountNumber
      ,[bic]          = @BIC_Description
      ,[trxType]        = 'Closing Balance'
      ,[description]      = '' 
      ,[payoneerId]     = ''
      ,[internalId]     = '' 
      --,[debit]        = ''
      --,[credit]       =   '' 
      ,[availableBalance]   = @LastAmountValue
      ,[idTransaction]    = @idTransaction

    SET @jsonResult =
            (
              SELECT
                CAST
                (
                  (
                    SELECT
                      [providerName]
                      , [ccy]
                      , [date] = CONVERT(VARCHAR(10), [date])
                      --, [date]
                      , [accountNumber]
                      , [bic]
                      , [trxType]
                      , [description]
                      , [payoneerId]
                      , [internalId]
                      , [debit] 
                      , [credit] 
                      , [availableBalance]
                    FROM
                      @tbl
                    ORDER BY
                      [IDX] ASC
                    OFFSET ISNULL(@offset,0) ROWS
                    FETCH NEXT ISNULL(@pageSize,100) ROWS ONLY
                    FOR JSON PATH 
                  )
                  AS XML
                )
            )

    SELECT @jsonResult
  END
END
