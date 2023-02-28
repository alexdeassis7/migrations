ALTER PROCEDURE [LP_Operation].[ListAccountTransaction]
                          (
                            @customer   [LP_Common].[LP_F_C50]
                            , @json     [LP_Common].[LP_F_VMAX]
                            , @country_code [LP_Common].[LP_F_C3]
                          )
AS


BEGIN

  DECLARE
    @qtyAccount       [LP_Common].[LP_F_INT]
    , @idEntityAccount    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @Message        [LP_Common].[LP_F_C50]
    , @Status       [LP_Common].[LP_F_BOOL]
    , @transLot       [LP_Common].[LP_F_INT]
    , @idEntityAcc      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @idEntityUserLogued [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
	, @idEntityType		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

  SELECT
    @qtyAccount         = COUNT([EA].[idEntityAccount])
    , @idEntityAccount      = MAX([EA].[idEntityAccount])
    , @idEntityUserLogued   = MAX([EU].[idEntityUser])

  FROM
    [LP_Security].[EntityAccount] [EA]
      INNER JOIN [LP_Security].[EntityAccountUser] [EAU]  ON [EAU].[idEntityAccount] = [EA].[idEntityAccount]
      INNER JOIN [LP_Entity].[EntityUser] [EU] ON [EU].[idEntityUser] = [EAU].[idEntityUser]
      INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [EU].[idCountry]
  WHERE
    [EA].[UserSiteIdentification] = @customer
    AND [EA].[Active] = 1
    AND [EU].[Active] = 1
    AND [C].[Active] = 1
    AND [C].[ISO3166_1_ALFA003] = @country_code

	SET @idEntityType = (SELECT TOP(1) [EU].[idEntityType]
	  FROM
    [LP_Security].[EntityAccount] [EA]
      INNER JOIN [LP_Security].[EntityAccountUser] [EAU]  ON [EAU].[idEntityAccount] = [EA].[idEntityAccount]
      INNER JOIN [LP_Entity].[EntityUser] [EU] ON [EU].[idEntityUser] = [EAU].[idEntityUser]
      INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [EU].[idCountry]
	  WHERE
		[EA].[UserSiteIdentification] = @customer
		AND [EA].[Active] = 1
		AND [EU].[Active] = 1
		AND [C].[Active] = 1
		AND [C].[ISO3166_1_ALFA003] = @country_code)

  IF(@qtyAccount = 1)
  BEGIN 

    DECLARE
      @idEntityUser     [LP_Common].[LP_F_INT]
      , @dateFrom       [LP_Common].[LP_A_DB_INSDATETIME]
      , @dateTo       [LP_Common].[LP_A_DB_INSDATETIME]
      , @lotFrom        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @lotTo        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @grossSign      [LP_Common].[LP_F_INT]
      , @grossAmount      [LP_Common].[LP_F_INT]
      , @netSign        [LP_Common].[LP_F_INT]
      , @netAmount      [LP_Common].[LP_F_INT]
      , @cycle        [LP_Common].[LP_F_INT]
      , @id_status      [LP_Common].[LP_F_INT]
      , @id_transactioOper  [LP_Common].[LP_F_INT]
      , @payMethod      [LP_Common].[LP_F_C6]
      , @merchant       [LP_Common].[LP_F_INT]
      , @currency       [LP_Common].[LP_F_C4]
      , @pageSize       [LP_Common].[LP_F_INT]
      , @offset       [LP_Common].[LP_F_INT]
      , @transactionType    [LP_Common].[LP_F_CODE]
      , @VALUEGROSS     [LP_Common].[LP_F_DECIMAL]
      , @PRMSIGNGROSS     [LP_Common].[LP_F_INT]
      , @VALUENET       [LP_Common].[LP_F_DECIMAL]
      , @PRMSIGNNET     [LP_Common].[LP_F_INT]
    , @lotId        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @merchantId     [LP_Common].[LP_F_DESCRIPTION]
    , @ticket       [LP_Common].[LP_F_C150]

    DECLARE @TRANSDETAIL  AS TABLE
    (
      [idTransaction]     [LP_Common].[LP_F_INT]        NOT NULL
      , [TransactionDate]   [LP_Common].[LP_A_DB_INSDATETIME] NOT NULL
      , [GrossAmount]     [LP_Common].[LP_F_DECIMAL]      NULL
      , [TaxWithholdings]   [LP_Common].[LP_F_DECIMAL]      NULL
      , [TaxWithholdingsARBA] [LP_Common].[LP_F_DECIMAL]      NULL
      , [VAT]         [LP_Common].[LP_F_DECIMAL]      NULL
      , [Commission]      [LP_Common].[LP_F_DECIMAL]      NULL
      , [Commission_With_VAT] [LP_Common].[LP_F_DECIMAL]      NULL
      , [Balance]       [LP_Common].[LP_F_DECIMAL]      NULL
      , [Bank_Cost]     [LP_Common].[LP_F_DECIMAL]      NULL
      , [Bank_Cost_VAT]   [LP_Common].[LP_F_DECIMAL]      NULL
      , [DebitTax]      [LP_Common].[LP_F_DECIMAL]      NULL
      , [CreditTax]     [LP_Common].[LP_F_DECIMAL]      NULL
      , [TotalCostRdo]    [LP_Common].[LP_F_DECIMAL]      NULL
      , [Total_VAT]     [LP_Common].[LP_F_DECIMAL]      NULL
      , [NetAmount]     [LP_Common].[LP_F_DECIMAL]      NULL
      , [LocalTax]      [LP_Common].[LP_F_DECIMAL]      NULL
      , [idStatus]      [LP_Common].[LP_F_DECIMAL]      NULL
      , [Active]        [LP_Common].[LP_F_INT]        NULL
      , [Version]       [LP_Common].[LP_F_INT]        NULL
    )

    SELECT
      @idEntityUser     = CAST(JSON_VALUE(@JSON, '$.idEntityAccount') AS INT)
      ,@dateFrom        = CAST(JSON_VALUE(@JSON, '$.dateFrom') AS VARCHAR(8))
      ,@dateTo        = CAST(JSON_VALUE(@JSON, '$.dateTo') AS VARCHAR(8))
      ,@lotFrom       = CAST(JSON_VALUE(@JSON, '$.lotFrom') AS BIGINT)
      ,@lotTo         = CAST(JSON_VALUE(@JSON, '$.lotTo') AS BIGINT)
      ,@grossSign       = CAST(JSON_VALUE(@JSON, '$.grossSign') AS INT)
      ,@grossAmount     = CAST(JSON_VALUE(@JSON, '$.grossAmount') AS INT)
      ,@netSign       = CAST(JSON_VALUE(@JSON, '$.netSign') AS INT)
      ,@netAmount       = CAST(JSON_VALUE(@JSON, '$.netAmount') AS INT)
      ,@cycle         = CAST(JSON_VALUE(@JSON, '$.cycle') AS INT)
      ,@id_status       = CAST(JSON_VALUE(@JSON, '$.id_status') AS INT)
      ,@id_transactioOper   = CAST(JSON_VALUE(@JSON, '$.id_transactioOper') AS INT)
      ,@payMethod       = CAST(JSON_VALUE(@JSON, '$.payMethod') AS VARCHAR(6))
      ,@merchant        = CAST(JSON_VALUE(@JSON, '$.merchant') AS INT)
      ,@currency        = CAST(JSON_VALUE(@JSON, '$.currency')AS VARCHAR(4))
      ,@pageSize        = CAST(JSON_VALUE(@JSON, '$.pageSize') AS INT)
      ,@offset        = CAST(JSON_VALUE(@JSON, '$.offset') AS INT)
      ,@transactionType   = CAST(JSON_VALUE(@JSON, '$.transactionType') AS VARCHAR(10))
    ,@lotId         = CAST(JSON_VALUE(@JSON, '$.lotId') AS BIGINT)
    ,@merchantId      = CAST(JSON_VALUE(@JSON, '$.merchantId') AS VARCHAR(22))
    ,@ticket        = CAST(JSON_VALUE(@JSON, '$.ticket') AS VARCHAR(150))

    IF(@dateFrom IS NULL AND @dateTo IS NOT NULL)
      SET @dateTo = NULL

    IF(@dateFrom IS NOT NULL AND @dateTo IS NULL)
      SET @dateFrom = NULL

    IF(@dateTo IS NOT NULL)
    begin
      SET @dateTo = DATEADD(HOUR, 23, @dateTo)
      SET @dateTo = DATEADD(MINUTE, 59, @dateTo)
      SET @dateTo = DATEADD(SECOND, 59, @dateTo)
    END

    IF(@pageSize IS NULL)
      SET @pageSize = ( SELECT COUNT([idTransaction]) FROM [LP_Operation].[Transaction] WITH(NOLOCK) )

    SELECT @idEntityAcc = idEntityAccount FROM LP_Security.EntityAccount ea WHERE ea.idEntityUser = @idEntityUser

    --SELECT * FROM [LP_Operation].[TransactionLot] WHERE LotNumber >= @lotFrom AND LotNumber <= @lotTo

    SET @VALUEGROSS = [LP_COMMON].[fnConvertIntToDecimalAmount](@grossAmount)
    SET @PRMSIGNGROSS = @grossSign
    SET @VALUENET = [LP_COMMON].[fnConvertIntToDecimalAmount](@netAmount)
    SET @PRMSIGNNET = @netSign

    INSERT INTO @TRANSDETAIL ( [idTransaction] , [TransactionDate] , [GrossAmount] , [TaxWithholdings], [TaxWithholdingsARBA] , [VAT] , [Commission] , [Commission_With_VAT] , [Balance] , [Bank_Cost] , [Bank_Cost_VAT] , [DebitTax] , [CreditTax] , [TotalCostRdo] , [Total_VAT] , [NetAmount] , [LocalTax] , [idStatus] , [Active] , [Version] )
    SELECT 
      [T].[idTransaction]
      , [T].[TransactionDate]
      , [TD].[GrossAmount]
      , [TD].[TaxWithholdings]
      , [TD].[TaxWithholdingsArba]
      , [TD].[VAT]
      , [TD].[Commission]
      , [TD].[Commission_With_VAT]
      , NULL--[Balance]
      , NULL--[Bank_Cost]
      , NULL--[Bank_Cost_VAT]
      , NULL--[DebitTax]
      , NULL--[CreditTax]
      , NULL--[TotalCostRdo]
      , NULL--[Total_VAT]
      , [TD].[NetAmount]
      , [TD].[LocalTax]
      , [TD].[idStatus]
      , [TD].[Active]
      , [TD].[Version]      
    FROM
      [Lp_Operation].[Transaction]            [T]
        LEFT JOIN [LP_Operation].[TransactionDetail]  [TD]  ON [T].[idTransaction] = [TD].[idTransaction]
    WHERE
      (
        ( @PRMSIGNGROSS = 1 AND @VALUEGROSS IS NOT NULL AND ISNULL([TD].[GrossAmount], [T].[GrossValueLP]) < @VALUEGROSS ) OR
        ( @PRMSIGNGROSS = 2 AND @VALUEGROSS IS NOT NULL AND ISNULL([TD].[GrossAmount], [T].[GrossValueLP]) <= @VALUEGROSS ) OR
        ( @PRMSIGNGROSS = 3 AND @VALUEGROSS IS NOT NULL AND ISNULL([TD].[GrossAmount], [T].[GrossValueLP]) > @VALUEGROSS ) OR
        ( @PRMSIGNGROSS = 4 AND @VALUEGROSS IS NOT NULL AND ISNULL([TD].[GrossAmount], [T].[GrossValueLP]) >= @VALUEGROSS ) OR
        ( @PRMSIGNGROSS = 5 AND @VALUEGROSS IS NOT NULL AND ISNULL([TD].[GrossAmount], [T].[GrossValueLP]) = @VALUEGROSS ) OR
        ( @VALUEGROSS IS NULL )
      )
      AND 
      (      
        ( @PRMSIGNNET = 1 AND @VALUENET IS NOT NULL AND [TD].[NetAmount] < @VALUENET ) OR
        ( @PRMSIGNNET = 2 AND @VALUENET IS NOT NULL AND [TD].[NetAmount] <= @VALUENET ) OR
        ( @PRMSIGNNET = 3 AND @VALUENET IS NOT NULL AND [TD].[NetAmount] > @VALUENET ) OR
        ( @PRMSIGNNET = 4 AND @VALUENET IS NOT NULL AND [TD].[NetAmount] >= @VALUENET ) OR
        ( @PRMSIGNNET = 5 AND @VALUENET IS NOT NULL AND [TD].[NetAmount] = @VALUENET ) OR 
        ( @VALUENET IS NULL )
      )

    DECLARE @RESP xml

    IF(@idEntityType = 1 ) --Admin
    BEGIN

      SET @RESP =
            (
              SELECT
                CAST
                (
                  (

                    SELECT 
                      [idOrder]         = CASE
                                        WHEN [S].[Code] IN('Executed','PAID_FIRST') THEN 1
                                        WHEN [S].[Code] = 'Rejected' THEN 2
                                        WHEN [S].[Code] = 'InProgress' THEN 3
                                        WHEN [S].[Code] = 'Received' THEN 4
                                        WHEN [S].[Code] = 'Canceled' THEN 5
                                      END,
                      /****************************************************************************************************************************************************/
                      /*  GENERAL DETAIL                                                                  */
                      /****************************************************************************************************************************************************/
                      [CollectionDate]      = IIF
                                      (
                                        ([TO].[Code] = 'PO' OR ([TT].[Code] IN('RAPA', 'PAFA', 'BAPR', 'COEX') AND [S].[Code] = 'InProgress')),
                                        NULL,
                                        IIF
                                        (
                                          [TCAPS].[RealProviderCashingDate] IS NOT NULL,
                                          [TCAPS].[RealProviderCashingDate],
                                          [TCAPS].[fxProviderCashingDate]
                                        )
                                      ),
                      [PayMethod]         = [TT].[Name],
                      [ProcessedDate]       = IIF([TO].[Code] = 'LP-Action', [T].[TransactionDate], [T].[ProcessedDate]),
                      [PaymentDate]       = IIF
                                      (
                                        ([TO].[Code] = 'PO' OR ([TT].[Code] IN('RAPA', 'PAFA', 'BAPR', 'COEX') AND [S].[Code] = 'InProgress')),
                                        NULL,
                                        IIF
                                        (
                                          [TCAPS].[RealPaidDate] IS NOT NULL,
                                          [TCAPS].[RealPaidDate],
                                          [TCAPS].[fxPaidDate]
                                        )
                                      ),
                      [idTransaction]       = [T].[idTransaction],
                      --[Provider]          = [P].[Name],


                      [Provider]          = IIF([TO].[Name]='PayOut' AND [S].[Code] = 'Received', '-', [P].[Name]),

                      [TransactionOperation]    = [TO].[Name],
                      [Mechanism]         = [TM].[Code],
                      [LotNumber]         = [TL].[LotNumber],
                      [InternalClient_id]     = ISNULL([TRD].[InternalDescription], ISNULL([TPD].[MerchantId],[BCT].[Invoice])),
                      [Status]          = [S].[Code],
                      [DetailStatus]        = IIF([TO].[Code]='LP-Action', [TD2].[Description], ISNULL([LPIE].[Name], [IS].[Description])),
                      [Pay]           = IIF
                                      (
                                        [TO].[Code] = 'PO' OR ([TT].[Code] IN('RAPA', 'PAFA', 'BAPR', 'COEX') AND [S].[Code] = 'InProgress'),
                                        NULL,
                                        [TCAPS].[isPaid]
                                      ),
                      [Cashed]          = IIF
                                      (
                                        [TO].[Code] = 'PO' OR ([TT].[Code] IN('RAPA', 'PAFA', 'BAPR', 'COEX') AND [S].[Code] = 'InProgress'),
                                        NULL,
                                        [TCAPS].[isProviderCharged]
                                      ),
                      [Merchant]          = [EU].[FirstName],
                      [Identification]      = [EA].[Identification],
                      [GrossValue]        = [TD].[GrossAmount],
                      [Ticket]          = IIF([BCT].[Ticket] IS NOT NULL, [BCT].[Ticket], [TK].[Ticket]),
                      /****************************************************************************************************************************************************/
                      /*  MERCHANT DETAIL                                                                 */
                      /****************************************************************************************************************************************************/
                      [CurrencyAmount]      = [LP_Configuration].[fnGetCurrencyCodeOperation]('LOCAL', [T].[idEntityUser]),
                      --[Amount]          = [TD].[GrossAmount],
                      [Amount]          = CASE
                                        WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
                                          [W].[GrossValueClient]
                                        ELSE
                                          [TD].[GrossAmount]
                                        END,
                      [Withholding]   = [TD].[TaxWithholdings],
                      [WithholdingArba]   = [TD].[TaxWithholdingsArba],
                      [Payable]         = [TD].[NetAmount],
                      [CurrencyFxMER]       = CASE
                                        WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] IN('AddBalance', 'AddDebit', 'ReceivedCo') THEN
                                          NULL
                                        WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
                                          [LP_Configuration].[fnGetCurrencyCodeOperation]('BOTH', [T].[idEntityUser])
                                        ELSE 
                                          CASE
                                            WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN
                                              NULL
                                            ELSE
                                              [LP_Configuration].[fnGetCurrencyCodeOperation]('BOTH', [T].[idEntityUser])
                                          END
                                      END,
                      [FxMerchant]        = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled'), 
                                        (
                                          CASE
                                            WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] IN('AddBalance', 'AddDebit', 'ReceivedCo') THEN
                                              NULL
                                            WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
                                              CAST(CAST([CE].[Value] AS DECIMAL(18,6)) AS VARCHAR(10))
                                            ELSE 
                                              CASE
                                                WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN
                                                  NULL
                                                ELSE
                                                CAST(CAST([CE].[Value] * (1 - [CB].[Base_Buy] / 100)  AS DECIMAL(18,6)) AS VARCHAR(12))
                                              END
                                          END
                                        ),
                                        NULL
                                      ),
                      [CurrencyPending]     = [LP_Configuration].[fnGetCurrencyCodeOperation]('CLIENT', [T].[idEntityUser]),
                      [Pending]         = CASE
                                        WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN 
                                          IIF
                                          (
                                            [S].[Code] NOT IN ('Rejected', 'Canceled', 'Executed','PAID_FIRST'),
                                            IIF
                                            (
                                              [TO].[Code] = 'PO' OR [TO].[Code] = 'RF',
                                              -1 * [T].[GrossValueLP], 1 * [T].[GrossValueLP]
                                            ),
                                            NULL
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
                                            NULL
                                          )
                                      END,
                      [CurrencyConfirmed]     = CASE
                                        WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] IN('AddBalance', 'AddDebit', 'ReceivedCo') THEN 
                                          [LP_Operation].[fnGetCurrency]([T].[CurrencyTypeClient])
                                        ELSE
                                          IIF
                                          (
                                            [W].[GrossValueLP] IS NULL,
                                            [LP_Configuration].[fnGetCurrencyCodeOperation]('CLIENT', [T].[idEntityUser]),
                                            [LP_Configuration].[fnGetCurrencyCodeOperation]('LOCAL', [T].[idEntityUser])
                                          )
                                      END,    
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
                      [CurrencyCom]   = [LP_Configuration].[fnGetCurrencyCodeOperation]('CLIENT', [T].[idEntityUser]),
                      [NetCom]          = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        IIF
										(
											[TO].[Code] = 'PI'
											,IIF
											(
												[ECE].[idCurrencyTypeClient] != [ECE].[idCurrencyTypeLP]
												,[TD].[Commission]
												,[LP_Operation].[fnGetCommisionExchange]([CEC].[idCurrencyExchange],[CB].[idCurrencyBase],[TD].[Commission],0)
											)
											,[TD].[Commission]
										),
                                        NULL
                                      ),
                      [Com]           = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        IIF
										(
											[TO].[Code] = 'PI'
											,IIF
											(
												[ECE].[idCurrencyTypeClient] != [ECE].[idCurrencyTypeLP]
												,[TD].[Commission_With_VAT] - [TD].[Commission]
												,[LP_Operation].[fnGetCommisionExchange]([CEC].[idCurrencyExchange],[CB].[idCurrencyBase],([TD].[Commission_With_VAT] - [TD].[Commission]),0)
											)
											,[TD].[Commission_With_VAT] - [TD].[Commission]
										), 
                                        NULL
                                      ),
                      [TotCom]          = IIF
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
                                        NULL
                                      ),
                      [AccountArs]        = ROUND([W].[BalanceLP],2,1),
                      [AccountUsd]        = ROUND([W].[BalanceClient],2,1),
                      /****************************************************************************************************************************************************/
                      /*  ADMIN DETAIL                                                                  */
                      /****************************************************************************************************************************************************/
                      [CurrencyLocal]       = [LP_Configuration].[fnGetCurrencyCodeOperation]('LOCAL', [T].[idEntityUser]), --'ARS',          
                      [ProviderCost]        = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TP].[Commission],
                                        NULL
                                      ),
                      [VatCostProv]       = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TP].[Commission_With_VAT] - [TP].[Commission],
                                        NULL
                                      ),
                      [TotalCostProv]       = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TP].[Commission_With_VAT],
                                        NULL
                                      ),
                      [PercIIBB]          = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        IIF
                                        (
                                          [TP].[Gross_Revenue_Perception_CABA] <> NULL,
                                          [TP].[Commission],
                                          IIF
                                          (
                                            [TP].[Gross_Revenue_Perception_BSAS] <> NULL,
                                            [TP].[Gross_Revenue_Perception_BSAS],
                                            IIF
                                            (
                                              [TP].[Gross_Revenue_Perception_OTHER] <> NULL,
                                              [TP].[Gross_Revenue_Perception_OTHER],
                                              0
                                            )
                                          )
                                        ),
                                        NULL
                                      ),
                      [PercVat]         = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TP].[VAT_Perception],
                                        NULL
                                      ),
                      [PercProfit]        = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TP].[Profit_Perception],
                                        NULL
                                      ),
                      [PercOthers]        = NULL,
                      [Sircreb]         = NULL,
                      [TaxDebit]          = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TP].[DebitTax],
                                        NULL
                                      ),
                      [RdoOperative]        = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TP].[TotalCostRnd],
                                        NULL
                                      ),
                      [VatToPay]          = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TP].[TotalVAT],
                                        NULL
                                      ),
                      [CurrencyRdoFx]       = [LP_Configuration].[fnGetCurrencyCodeOperation]('CLIENT', [T].[idEntityUser]),
                      [FxLP]            = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled', 'Received','InProgress'),
                                        (
                                          CASE
                                            WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN
                                              NULL
                                            ELSE
                                              CAST(CAST([CEC].[Value] AS DECIMAL(18,6)) AS VARCHAR(20))
                                            END
                                        ),
                                        NULL
                                      ),
                      [PendingAtLPFx]       = IIF ([CEC].[Value] IS NULL OR [S].[Code] = 'Executed' ,NULL, CAST([TD].[GrossAmount]  /   CAST([CEC].[Value] AS DECIMAL(18,6))  AS DECIMAL (18,6))),
                      [RdoFx]           = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled', 'Received','InProgress'),
                                        (
                                          CASE
                                            WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN
                                              NULL
                                            ELSE
                                              CAST(CAST(-1 * [W].[GrossValueClient] AS DECIMAL(18, 6)) - CAST(([TD].[GrossAmount] / [CEC].[Value]) AS DECIMAL(18, 6)) AS DECIMAL(18,2))
                                            END
                                        ),
                                        NULL
                                      ),    
                      [CurrencyFxLP]        = CASE
                                        WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN
                                          NULL
                                        ELSE
                                          [LP_Configuration].[fnGetCurrencyCodeOperation]('BOTH', [T].[idEntityUser])
                                      END,
                      [SubMerchantIdentification] = [ESM].[SubMerchantIdentification],
                      [AccountWhitoutCommission]  = ROUND([W].[BalanceClientWithOutCommission],2,1)

                    FROM
                      @TRANSDETAIL                            [TD]
                        INNER JOIN [LP_Operation].[Transaction]             [T]                                         ON [TD].[idTransaction]       = [T].[idTransaction]                       
                        INNER JOIN [LP_Operation].[TransactionLot]            [TL]                                        ON [T].[idTransactionLot]     = [TL].[idTransactionLot]
						LEFT JOIN [LP_Operation].[TransactionPayinDetail]	[TPD]										ON [T].[idTransaction] = [TPD].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionRecipientDetail]       [TRD] WITH(INDEX=IX_LP_Operation_TransactionRecipientDetail_idTransaction)    ON [T].[idTransaction]        = [TRD].[idTransaction]
                        LEFT JOIN [LP_Operation].[BarCodeTicket]            [BCT] WITH(INDEX=IX_LP_Operation_BarCodeTicket_idTransaction)           ON [T].[idTransaction]        = [BCT].[idTransaction] AND [BCT].[Active] = 1
                        LEFT JOIN [LP_Operation].[Ticket]               [TK]  WITH(INDEX=IX_LP_Operation_Ticket_idTransaction)              ON [T].[idTransaction]        = [TK].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionProvider]          [TP]  WITH(INDEX=IX_LP_Operation_TransactionProvider_idTransaction)       ON [T].[idTransaction]        = [TP].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionCollectedAndPaidStatus]  [TCAPS] WITH(INDEX=IX_LP_Operation_TransactionCollectedAndPaidStatus_idTransaction) ON [T].[idTransaction]        = [TCAPS].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionInternalStatus]      [TIS] WITH(INDEX=IX_LP_Operation_TransactionInternalStatus_idTransaction)     ON [T].[idTransaction]        = [TIS].[idTransaction] AND [TIS].[Active] = 1
                        LEFT JOIN [LP_Operation].[Wallet]                 [W]   WITH(INDEX=IX_LP_Operation_Wallet_idTransaction)              ON [T].[idTransaction]        = [W].[idTransaction] AND [W].[Active] = 1
                        LEFT JOIN [LP_OPERATION].[TransactionDescription]       [TD2] WITH(INDEX=IX_LP_Operation_TransactionDescription_idTransaction)      ON [T].[idTransaction]        = [TD2].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]     [TESM]  WITH(INDEX=IX_LP_Operation_TransactionEntitySubMerchant_idTransaction)    ON [TESM].[idTransaction]     = [T].[idTransaction]
                        LEFT JOIN [LP_Configuration].[CurrencyExchange]         [CE]                                        ON [T].[idCurrencyExchange]     = [CE].[idCurrencyExchange]
                        LEFT JOIN [LP_Configuration].[CurrencyExchange]         [CEC]                                       ON [T].[idCurrencyExchangeClosed] = [CEC].[idCurrencyExchange]
                        LEFT JOIN [LP_Common].[Status]                  [S]                                         ON [T].[idStatus]         = [S].[idStatus]
                        LEFT JOIN [LP_Configuration].[InternalStatus]           [IS]                                        ON [TIS].[idInternalStatus]     = [is].[idInternalStatus]
						LEFT JOIN [LP_Configuration].[LPInternalStatusClient] [LPIC]	ON [LPIC].[idInternalStatus] = [IS].idInternalStatus
						LEFT JOIN [LP_Configuration].[LPInternalError]		[LPIE]		ON [LPIE].[idLPInternalError] = [LPIC].[idLPInternalError]
                        LEFT JOIN [LP_Security].[EntityAccount]             [EA]                                        ON [T].[idEntityAccount]      = [EA].[idEntityAccount]            
                        LEFT JOIN [LP_Entity].[EntityUser]                [EU]                                        ON [T].[idEntityUser]       = [EU].[idEntityUser]
                        LEFT JOIN [LP_Entity].[EntityMerchant]              [EM]                                        ON [EU].[idEntityMerchant]      = [EM].[idEntityMerchant]
                        LEFT JOIN [LP_Configuration].[TransactionMechanism]       [TM]                                        ON [T].[idTransactionMechanism]   = [TM].[idTransactionMechanism]
                        LEFT JOIN [LP_Configuration].[TransactionTypeProvider]      [TTP]                                       ON [T].[idTransactionTypeProvider]  = [TTP].[idTransactionTypeProvider]
                        LEFT JOIN [LP_Configuration].[Provider]             [P]                                         ON [TTP].[idProvider]       = [P].[idProvider]
                        LEFT JOIN [LP_Configuration].[TransactionType]          [TT]                                        ON [TTP].[idTransactionType]    = [TT].[idTransactionType]
                        LEFT JOIN [LP_Configuration].[TransactionGroup]         [TG]                                        ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
                        LEFT JOIN [LP_Configuration].[TransactionOperation]       [TO]                                        ON [TG].[idTransactionOperation]  = [TO].[idTransactionOperation]
                        LEFT JOIN [LP_Configuration].[CurrencyType]           [CT_CL]                                       ON [T].[CurrencyTypeClient]     = [CT_CL].[idCurrencyType]
                        LEFT JOIN [LP_Configuration].[CurrencyBase]           [CB]                                        ON [T].[idCurrencyBase]       = [CB].[idCurrencyBase]                       
                        LEFT JOIN [LP_Entity].[EntityCurrencyExchange]          [ECE]                                       ON [EU].[idEntityUser]        = [ECE].[idEntityUser]                        
                        LEFT JOIN [LP_Entity].[EntitySubMerchant]           [ESM]                                       ON [ESM].[idEntitySubMerchant]    = [TESM].[idEntitySubMerchant]
                        INNER JOIN [LP_Location].[Country]                [C]                                         ON [C].[idCountry]          = [EU].[idCountry]

                    WHERE
                      (
                        ( ( CAST([T].[ProcessedDate] AS DATE) >= @dateFrom ) OR ( @dateFrom  IS NULL ) ) AND ( ( CAST([T].[ProcessedDate] AS DATE) <= @dateTo ) OR ( @dateTo IS NULL ) )
                      )

                      AND (
                        ( [TL].[LotNumber] >= @lotFrom ) OR ( @lotFrom  IS NULL ) 
                      )
                      AND (
                        ( [TL].[LotNumber] <= @lotTo ) OR ( @lotTo IS NULL ) 
                      )
                      AND (
                        ( [T].[idStatus] = @id_status ) OR ( @id_status IS NULL )
                      )
                      AND (
                        ( [TO].[idTransactionOperation] = @id_transactioOper ) OR ( @id_transactioOper IS NULL )
                      )
                      AND (
                        ( [CT_CL].[Code] = @currency ) OR ( @currency IS NULL )
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
		  AND ( [TPD].[MerchantId] = @merchantId OR @merchantId IS NULL)
                    AND [T].[ProcessedDate] IS NOT NULL
                    ORDER BY
            [T].[ProcessedDate] ASC,
            [W].[idWallet],
            1 ASC
                    OFFSET ISNULL(@offset,0) ROWS  
                    FETCH NEXT ISNULL(@pageSize,100) ROWS ONLY
                    
          FOR JSON PATH

                  ) AS XML
                )
            )

    END
    ELSE
    BEGIN

      SET @RESP =
            (
              SELECT
                CAST
                (
                  (

                    SELECT
                      [idOrder]         = CASE
                                        WHEN [S].[Code] IN('Executed','PAID_FIRST') THEN 1
                                        WHEN [S].[Code] = 'Rejected' THEN 2
                                        WHEN [S].[Code] = 'InProgress' THEN 3
                                        WHEN [S].[Code] = 'Received' THEN 4
                                        WHEN [S].[Code] = 'Canceled' THEN 5
                                      END,
                      /****************************************************************************************************************************************************/
                      /*  GENERAL DETAIL                                                                  */
                      /****************************************************************************************************************************************************/
                      [CollectionDate]      = IIF
                                      (
                                        ([TO].[Code] = 'PO' OR ([TT].[Code] IN('RAPA', 'PAFA', 'BAPR', 'COEX') AND [S].[Code] = 'InProgress')),
                                        NULL,
                                        IIF
                                        (
                                          [TCAPS].[RealProviderCashingDate] IS NOT NULL,
                                          [TCAPS].[RealProviderCashingDate],
                                          [TCAPS].[fxProviderCashingDate]
                                        )
                                      ),
                      [PayMethod]         = [TT].[Name],  
                      [ProcessedDate]       = IIF([TO].[Code] = 'LP-Action', [T].[TransactionDate], [T].[ProcessedDate]),
                      [PaymentDate]       = IIF
                                      (
                                        [TO].[Code] = 'PO' OR ([TT].[Code] IN('RAPA', 'PAFA', 'BAPR', 'COEX') AND [S].[Code] = 'InProgress'),
                                        NULL,
                                        IIF
                                        (
                                          [TCAPS].[RealPaidDate] IS NOT NULL,
                                          [TCAPS].[RealPaidDate],
                                          [TCAPS].[fxPaidDate]
                                        )
                                      ),
                      [idTransaction]       = [T].[idTransaction],
                      [Provider]          = [P].[Name],
                      [TransactionOperation]    = [TO].[Name],
                      [Mechanism]         = [TM].[Code],
                      [LotNumber]         = [TL].[LotNumber],
                      [InternalClient_id]     = ISNULL([TRD].[InternalDescription], ISNULL([TPD].[MerchantId],[BCT].[Invoice])),
                      [Status]          = [S].[Code],
                      [DetailStatus]        = IIF([TO].[Code]='LP-Action', [TD2].[Description], ISNULL([LPIE].[Name], [IS].[Description])),
                      [Pay]           = IIF
                                      (
                                        [TO].[Code] = 'PO' OR ([TT].[Code] IN('RAPA', 'PAFA', 'BAPR', 'COEX') AND [S].[Code] = 'InProgress'),
                                        NULL,
                                        [TCAPS].[isPaid]
                                      ),
                      [Cashed]          = IIF
                                      (
                                        [TO].[Code] = 'PO' OR ([TT].[Code] IN('RAPA', 'PAFA', 'BAPR', 'COEX') AND [S].[Code] = 'InProgress'),
                                        NULL,
                                        [TCAPS].[isProviderCharged]
                                      ),
                      [Merchant]          = [EU].[FirstName],
                      [Identification]      = [EA].[Identification],
                      [GrossValue]        = [TD].[GrossAmount],
                      [Ticket]          = IIF([BCT].[Ticket] IS NOT NULL, [BCT].[Ticket], [TK].[Ticket]),
                      /****************************************************************************************************************************************************/
                      /*  MERCHANT DETAIL                                                                 */
                      /****************************************************************************************************************************************************/
                      [CurrencyAmount]      = [LP_Configuration].[fnGetCurrencyCodeOperation]('LOCAL', [T].[idEntityUser]),
                      --[Amount]          = [TD].[GrossAmount],
                      [Amount]          = CASE
                                        WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
                                          [W].[GrossValueClient]
                                        ELSE
                                          [TD].[GrossAmount]
                                        END,
                      [Withholding]       = [TD].[TaxWithholdings],
                      [WithholdingArba]     = [TD].[TaxWithholdingsArba],
                      [Payable]         = [TD].[NetAmount],
                      [CurrencyFxMER]       = CASE
                                        WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] IN('AddBalance', 'AddDebit', 'ReceivedCo') THEN
                                          NULL
                                        WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
                                          [LP_Configuration].[fnGetCurrencyCodeOperation]('BOTH', [T].[idEntityUser])
                                        ELSE 
                                          CASE
                                            WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN
                                              NULL
                                            ELSE
                                              [LP_Configuration].[fnGetCurrencyCodeOperation]('BOTH', [T].[idEntityUser])
                                          END
                                      END,
                      [FxMerchant]        = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled'), 
                                        (
                                          CASE
                                            WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] IN('AddBalance', 'AddDebit', 'ReceivedCo') THEN
                                              NULL
                                            WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] = 'Conversion' THEN 
                                              CAST(CAST([CE].[Value] AS DECIMAL(18,6)) AS VARCHAR(10))
                                            ELSE 
                                              CASE
                                                WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN
                                                  NULL
                                                ELSE
                                                CAST(CAST([CE].[Value] * (1 - [CB].[Base_Buy] / 100)  AS DECIMAL(18,6)) AS VARCHAR(12))
                                              END
                                          END
                                        ),
                                        NULL
                                      ),
                      [CurrencyPending]     = [LP_Configuration].[fnGetCurrencyCodeOperation]('CLIENT', [T].[idEntityUser]),
                      [Pending]         = CASE
                                        WHEN [ECE].[idCurrencyTypeClient] = [ECE].[idCurrencyTypeLP] THEN 
                                          IIF
                                          (
                                            [S].[Code] NOT IN ('Rejected', 'Canceled', 'Executed','PAID_FIRST'),
                                            IIF
                                            (
                                              [TO].[Code] = 'PO' OR [TO].[Code] = 'RF',
                                              -1 * [T].[GrossValueLP], 1 * [T].[GrossValueLP]
                                            ),
                                            NULL
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
                                            NULL
                                          )
                                      END,
                      [CurrencyConfirmed]     = CASE
                                        WHEN [TO].[Code] = 'LP-Action' AND [TT].[Code] IN('AddBalance', 'AddDebit', 'ReceivedCo') THEN 
                                          [LP_Operation].[fnGetCurrency]([T].[CurrencyTypeClient])
                                        ELSE
                                          IIF
                                          (
                                            [W].[GrossValueLP] IS NULL,
                                            [LP_Configuration].[fnGetCurrencyCodeOperation]('CLIENT', [T].[idEntityUser]),
                                            [LP_Configuration].[fnGetCurrencyCodeOperation]('LOCAL', [T].[idEntityUser])
                                          )
                                      END,
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
                      [CurrencyCom]   = [LP_Configuration].[fnGetCurrencyCodeOperation]('CLIENT', [T].[idEntityUser]),
                      [NetCom]          = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        IIF
										(
											[TO].[Code] = 'PI'
											,IIF
											(
												[ECE].[idCurrencyTypeClient] != [ECE].[idCurrencyTypeLP]
												,[TD].[Commission]
												,[LP_Operation].[fnGetCommisionExchange]([CEC].[idCurrencyExchange],[CB].[idCurrencyBase],[TD].[Commission],0)
											)
											,[TD].[Commission]
										),
                                        NULL
                                      ),
                      [Com]           = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        IIF
										(
											[TO].[Code] = 'PI'
											,IIF
											(
												[ECE].[idCurrencyTypeClient] != [ECE].[idCurrencyTypeLP]
												,[TD].[Commission_With_VAT] - [TD].[Commission]
												,[LP_Operation].[fnGetCommisionExchange]([CEC].[idCurrencyExchange],[CB].[idCurrencyBase],([TD].[Commission_With_VAT] - [TD].[Commission]),0)
											)
											,[TD].[Commission_With_VAT] - [TD].[Commission]
										), 
                                        NULL
                                      ),
                      [TotCom]          = IIF
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
                                        NULL
                                      ),
                      [TaxCountry]        = IIF
                                      (
                                        [S].[Code] NOT IN ('Rejected', 'Canceled','Received','InProgress'),
                                        [TD].[LocalTax], 
                                        NULL
                                      ), 
                      [AccountArs]        = ROUND([W].[BalanceLP],2,1),
                      [AccountUsd]        = ROUND([W].[BalanceClient],2,1),
                      [CurrencyLocal]       = [LP_Configuration].[fnGetCurrencyCodeOperation]('LOCAL', [T].[idEntityUser]),
                      [CurrencyRdoFx]       = [LP_Configuration].[fnGetCurrencyCodeOperation]('LOCAL', [T].[idEntityUser]),
                      [CurrencyFxLP]        = [LP_Configuration].[fnGetCurrencyCodeOperation]('BOTH', [T].[idEntityUser]),
                      [SubMerchantIdentification] = [ESM].[SubMerchantIdentification]   ,                     
                      [AccountWhitoutCommission]  = ROUND([W].[BalanceClientWithOutCommission],2,1)
                    FROM
                      @TRANSDETAIL                            [TD]
                        INNER JOIN [LP_Operation].[Transaction]             [T]                                         ON [TD].[idTransaction]       = [T].[idTransaction]                       
                        INNER JOIN [LP_Operation].[TransactionLot]            [TL]                                        ON [T].[idTransactionLot]     = [TL].[idTransactionLot]
												LEFT JOIN [LP_Operation].[TransactionPayinDetail]	[TPD]										ON [T].[idTransaction] = [TPD].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionRecipientDetail]       [TRD] WITH(INDEX=IX_LP_Operation_TransactionRecipientDetail_idTransaction)    ON [T].[idTransaction]        = [TRD].[idTransaction]
                        LEFT JOIN [LP_Operation].[BarCodeTicket]            [BCT] WITH(INDEX=IX_LP_Operation_BarCodeTicket_idTransaction)           ON [T].[idTransaction]        = [BCT].[idTransaction] AND [BCT].[Active] = 1
                        LEFT JOIN [LP_Operation].[Ticket]               [TK]  WITH(INDEX=IX_LP_Operation_Ticket_idTransaction)              ON [T].[idTransaction]        = [TK].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionProvider]          [TP]  WITH(INDEX=IX_LP_Operation_TransactionProvider_idTransaction)       ON [T].[idTransaction]        = [TP].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionCollectedAndPaidStatus]  [TCAPS] WITH(INDEX=IX_LP_Operation_TransactionCollectedAndPaidStatus_idTransaction) ON [T].[idTransaction]        = [TCAPS].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionInternalStatus]      [TIS] WITH(INDEX=IX_LP_Operation_TransactionInternalStatus_idTransaction)     ON [T].[idTransaction]        = [TIS].[idTransaction] AND [TIS].[Active] = 1
                        LEFT JOIN [LP_Operation].[Wallet]                 [W]   WITH(INDEX=IX_LP_Operation_Wallet_idTransaction)              ON [T].[idTransaction]        = [W].[idTransaction] AND [W].[Active] = 1
                        LEFT JOIN [LP_OPERATION].[TransactionDescription]       [TD2] WITH(INDEX=IX_LP_Operation_TransactionDescription_idTransaction)      ON [T].[idTransaction]        = [TD2].[idTransaction]
                        LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]     [TESM]  WITH(INDEX=IX_LP_Operation_TransactionEntitySubMerchant_idTransaction)    ON [TESM].[idTransaction]     = [T].[idTransaction]
                        LEFT JOIN [LP_Configuration].[CurrencyExchange]         [CE]                                        ON [T].[idCurrencyExchange]     = [CE].[idCurrencyExchange]
                        LEFT JOIN [LP_Configuration].[CurrencyExchange]         [CEC]                                       ON [T].[idCurrencyExchangeClosed] = [CEC].[idCurrencyExchange]
                        LEFT JOIN [LP_Common].[Status]                  [S]                                         ON [T].[idStatus]         = [S].[idStatus]
                        LEFT JOIN [LP_Configuration].[InternalStatus]           [IS]                                        ON [TIS].[idInternalStatus]     = [is].[idInternalStatus]
						LEFT JOIN [LP_Configuration].[LPInternalStatusClient] [LPIC]	ON [LPIC].[idInternalStatus] = [IS].idInternalStatus
						LEFT JOIN [LP_Configuration].[LPInternalError]		[LPIE]		ON [LPIE].[idLPInternalError] = [LPIC].[idLPInternalError]
                        LEFT JOIN [LP_Security].[EntityAccount]             [EA]                                        ON [T].[idEntityAccount]      = [EA].[idEntityAccount]
                        LEFT JOIN [LP_Entity].[EntityUser]                [EU]                                        ON [T].[idEntityUser]       = [EU].[idEntityUser]
                        LEFT JOIN [LP_Entity].[EntityMerchant]              [EM]                                        ON [EU].[idEntityMerchant]      = [EM].[idEntityMerchant]
                        LEFT JOIN [LP_Configuration].[TransactionMechanism]       [TM]                                        ON [T].[idTransactionMechanism]   = [TM].[idTransactionMechanism]
                        LEFT JOIN [LP_Configuration].[TransactionTypeProvider]      [TTP]                                       ON [T].[idTransactionTypeProvider]  = [TTP].[idTransactionTypeProvider]
                        LEFT JOIN [LP_Configuration].[Provider]             [P]                                         ON [TTP].[idProvider]       = [P].[idProvider]
                        LEFT JOIN [LP_Configuration].[TransactionType]          [TT]                                        ON [TTP].[idTransactionType]    = [TT].[idTransactionType]
                        LEFT JOIN [LP_Configuration].[TransactionGroup]         [TG]                                        ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
                        LEFT JOIN [LP_Configuration].[TransactionOperation]       [TO]                                        ON [TG].[idTransactionOperation]  = [TO].[idTransactionOperation]
                        LEFT JOIN [LP_Configuration].[CurrencyType]           [CT_CL]                                       ON [T].[CurrencyTypeClient]     = [CT_CL].[idCurrencyType]
                        LEFT JOIN [LP_Configuration].[CurrencyBase]           [CB]                                        ON [T].[idCurrencyBase]       = [CB].[idCurrencyBase]                       
                        LEFT JOIN [LP_Entity].[EntityCurrencyExchange]          [ECE]                                       ON [EU].[idEntityUser]        = [ECE].[idEntityUser]                        
                        LEFT JOIN [LP_Entity].[EntitySubMerchant]           [ESM]                                       ON [ESM].[idEntitySubMerchant]    = [TESM].[idEntitySubMerchant]
                        INNER JOIN [LP_Location].[Country]                [C]                                         ON [C].[idCountry]          = [EU].[idCountry]

                    WHERE  
                      (
                        ( ( CAST([T].[ProcessedDate] AS DATE) >= @dateFrom ) OR ( @dateFrom  IS NULL ) ) AND ( ( CAST([T].[ProcessedDate] AS DATE) <= @dateTo ) OR ( @dateTo IS NULL ) )
                      )
                      AND (
                        ( [TL].[LotNumber] >= @lotFrom ) OR ( @lotFrom  IS NULL ) 
                      )
                      AND (
                        ( [TL].[LotNumber] <= @lotTo ) OR ( @lotTo IS NULL )
                      )
                      AND (
                        ( [T].[idStatus] = @id_status ) OR ( @id_status IS NULL )
                      )
                      AND (
                        ( [TO].[idTransactionOperation] = @id_transactioOper ) OR ( @id_transactioOper IS NULL )
                      )
                      AND (
                        ( [CT_CL].[Code] = @currency ) OR ( @currency IS NULL )
                      )
                      AND (
                        ( [T].[idEntityUser] = @idEntityUserLogued ) OR ( @idEntityUserLogued IS NULL )
                      )
                      AND (
                        ( [TT].[Code] = @transactionType ) OR ( @transactionType IS NULL )
                      )
          AND ( [TL].[LotNumber] = @lotId OR @lotId IS NULL )
          AND ( [TK].[Ticket] = @ticket OR @ticket IS NULL )
          AND ( [TRD].[InternalDescription] = @merchantId OR @merchantId IS NULL)
		  AND ( [TPD].[MerchantId] = @merchantId OR @merchantId IS NULL)
          AND [T].[ProcessedDate] IS NOT NULL
                    ORDER BY
            [T].[ProcessedDate] ASC,
            [W].[idWallet],
            1 ASC
                    OFFSET ISNULL(@offset,0) ROWS  
                    FETCH NEXT ISNULL(@pageSize,100) ROWS ONLY

                    FOR JSON PATH

                  ) AS XML
                )
            )

    END

    SELECT @RESP

  END
  ELSE
  BEGIN
    SET @Status = 0
    SET @Message = 'CLIENTE INEXISTENTE. VERFIQUE SU CUSTOMER_ID'
  END

END
