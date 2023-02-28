/****** Object:  StoredProcedure [LP_Operation].[CreateGenericTransaction]    Script Date: 9/2/2020 8:39:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [LP_Operation].[CreateGenericTransaction]
                              (
                                @Customer       [LP_Common].[LP_F_C50]
                                , @JSON         NVARCHAR(MAX)
                                , @TransactionMechanism BIT
                              )
AS
BEGIN


BEGIN TRY
  --DECLARE
  --  @Customer       VARCHAR(12)
  --  , @JSON         NVARCHAR(MAX)
  --  , @TransactionMechanism BIT

  --SET @Customer = '000000000001'
  --SET @JSON = '{ "idTransactionType" : 15, "TransactionTypeCode" : "AddBalance", "Description" : "Esto es una prueba de depósito", "idEntityUser" : 5, "idCurrencyType" : 2350, "Amount" : 33100000 }'
  ----SET @JSON = '{ "idTransactionType" : 15, "TransactionTypeCode" : "AddBalance", "Description" : "Esto es una prueba de depósito", "idEntityUser" : 6, "idCurrencyType" : 2493, "Amount" : 420000 }'
  --SET @TransactionMechanism = 1

  DECLARE
    @Admin            [LP_Common].[LP_F_INT]
    , @Status         [LP_Common].[LP_F_BOOL]
    , @Message          [LP_Common].[LP_F_VMAX]

  SET @Admin =
        (
        SELECT
          [EA].[idEntityAccount]
            FROM
          [LP_Entity].[EntityUser]              [EU]
            INNER JOIN [LP_Security].[EntityAccountUser]  [EAU] ON [EAU].[idEntityUser] = [EU].[idEntityUser]
            INNER JOIN [LP_Security].[EntityAccount]    [EA]  ON [EA].[idEntityAccount] = [EAU].[idEntityAccount]
            INNER JOIN [LP_Location].[Country]        [C]   ON [C].[idCountry] = [EU].[idCountry]
            INNER JOIN [LP_Entity].[EntityType]       [ET]  ON [EU].[idEntityType] = [ET].[idEntityType]
        WHERE
          [ET].[Code] = 'Admin'
          AND [EU].[Active] = 1
          AND [EAU].[Active] = 1
          AND [EA].[Active] = 1
          AND [C].[Active] = 1
          AND [EA].[UserSiteIdentification] = @Customer
        --FROM
        --  [LP_Security].[EntityAccount] [EA]
        --    INNER JOIN [LP_Entity].[EntityUser] [EU] ON [EA].[idEntityUser] = [EU].[idEntityUser]
        --    INNER JOIN [LP_Entity].[EntityType] [ET] ON [EU].[idEntityType] = [ET].[idEntityType]
        --WHERE
        --  [ET].[Code] = 'Admin'
        --  AND [EU].[Active] = 1
        --  AND [EA].[Active] = 1
        --  AND [EA].[Identification] = @Customer
        )
begin tran
  IF(@Admin IS NOT NULL)
  BEGIN
    DECLARE
      @idTransactionType        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @TransactionTypeCode      [LP_Common].[LP_F_CODE]
      , @Description          [LP_Common].[LP_F_DESCRIPTION]
      , @idEntityUser         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idEntityAccountDefault   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idCurrencyType       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @Value            [LP_Common].[LP_F_DECIMAL]
      , @fxAutomatic          [LP_Common].[LP_F_BOOL]
      , @ValueFX            [LP_Common].[LP_F_DECIMAL]
      , @ActionType         [LP_Common].[LP_F_INT]
      , @idCurrencyClient       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idCurrencyLP         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idTransactionLot       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idTransaction        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @TransactionDate        [LP_Common].[LP_A_OP_INSDATETIME]
      , @idStatus           [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idCountry          [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idCurrencyBase       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @Base_Sell          [LP_Common].[LP_F_DECIMAL]
      , @Base_Buy           [LP_Common].[LP_F_DECIMAL]
      , @idCurrencyExchange     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @Value_Exchange_Auto      [LP_Common].[LP_F_DECIMAL]
      , @fxValue_Exchange_Auto    [LP_Common].[LP_F_DECIMAL]
      , @idTransactionMechanism   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idTransactionTypeProvider  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idProviderPayWayService    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idProvider         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @idTransactionOperation   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      , @ValueConverted       [LP_Common].[LP_F_DECIMAL]

    SET @TransactionDate = GETDATE()

    SELECT
      @idTransactionType      = [DJSON].[idTransactionType]
      , @TransactionTypeCode    = [DJSON].[TransactionTypeCode]
      , @Description        = [DJSON].[Description]
      , @idEntityUser       = [DJSON].[idEntityUser]
      , @idCurrencyType     = [DJSON].[idCurrencyType]
      , @Value          = CONVERT(DECIMAL(10,2), [DJSON].[Value])

      , @ValueFX          = CASE WHEN CAST([DJSON].[ValueFX] AS INT) > 0 THEN ISNULL([LP_Common].[fnConvertIntToDecimalAmount]([DJSON].[ValueFX]), NULL) ELSE NULL END
    FROM OPENJSON(@JSON)
    WITH
    (
      [idTransactionType]   VARCHAR(100) '$.idTransactionType' /* AddBalance | Conversion | AddDebit */
      , [TransactionTypeCode] VARCHAR(100) '$.TransactionTypeCode'
      , [Description]     VARCHAR(100) '$.Description'
      , [idEntityUser]    VARCHAR(100) '$.idEntityUser'
      , [idCurrencyType]    VARCHAR(100) '$.idCurrencyType'
      , [Value]       DECIMAL '$.Amount'

      /* IF TransactionType = Conversion */
      , [ValueFX]       VARCHAR(100) '$.ValueFX'
    ) DJSON
  
  SET @Value = CONVERT(DECIMAL(10,2), JSON_VALUE(@JSON, '$.Amount'))

      SELECT
          --@idEntityUser   = [EU].[idEntityUser]
           @idEntityAccountDefault  = [EA].[idEntityAccount]
        FROM
          [LP_Entity].[EntityUser]              [EU]
            --INNER JOIN [LP_Security].[EntityApiCredential]  [EAC] ON [EAC].[idEntityUser] = [EU].[idEntityUser]
            INNER JOIN [LP_SECURITY].[EntityAccountUser]    [EAU] on [EAU].idEntityUser=[EU].IdEntityUser
            INNER JOIN [LP_Security].[EntityAccount]    [EA]  ON [EA].[idEntityAccount] = [EAU].[idEntityAccount]
            --INNER JOIN [LP_Location].[Country]        [C]   ON [C].[idCountry] = [EAC].[idCountry]
        WHERE
          [EU].[Active] = 1
          --AND [EAC].[Active] = 1
          AND [EA].[Active] = 1
          --AND [C].[Active] = 1
          AND [EA].[IsAdmin] = 1
          AND [EU].[idEntityUser] = @idEntityUser
          --AND [C].[ISO3166_1_ALFA003] = @country_code

    IF(@TransactionMechanism = 1)
    BEGIN
      SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_MANUAL')
    END 
    ELSE
    BEGIN
      SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_AUTO')
    END

    --SET @idEntityAccountDefault = (SELECT TOP 1 [idEntityAccount] FROM [LP_Security].[EntityAccount] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [IsAdmin] = 1)
    --IF(@idEntityAccountDefault IS NULL)
    --BEGIN
    --  SET @idEntityAccountDefault = (SELECT TOP 1 [idEntityAccount] FROM [LP_Security].[EntityAccount] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1)
    --END

    SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('Executed')
    --SET @idCountry = [LP_Location].[fnGetIdCountyByidEntityUser](@idEntityUser)
    SET @idCountry = (SELECT idCountry FROM [Lp_entity].EntityUser  where idEntityUSer=@idEntityUser and Active=1)

    SELECT @idCurrencyLP = [idCurrencyTypeLP], @idCurrencyClient = [idCurrencyTypeClient] FROM [LP_Entity].[EntityCurrencyExchange] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1

    SELECT
      @idTransactionTypeProvider  = [TTP].[idTransactionTypeProvider]
      , @idProvider       = [P].[idProvider]
    FROM
      [LP_Configuration].[TransactionTypeProvider]  [TTP]
        INNER JOIN [LP_Configuration].[Provider]  [P]   ON  [TTP].[idProvider] = [P].[idProvider]
    WHERE
      [TTP].[idTransactionType] = @idTransactionType
      AND [P].[Code] = 'LP'
      AND [TTP].[Active] = 1
      AND [P].[Active] = 1
      --AND [P].[idCountry] = @idCountry

    SET @idProviderPayWayService =
                    (
                    SELECT
                      [PPWS].[idProviderPayWayService]
                    FROM
                      [LP_Configuration].[ProviderPayWayServices] [PPWS]
                        INNER JOIN [LP_Configuration].[PayWayServices] [PWS] ON [PPWS].[idPayWayService] = [PWS].[idPayWayService]
                    WHERE
                      [PPWS].[Active] = 1
                      AND [PWS].[Active] = 1
                      AND [PWS].[Code] = @TransactionTypeCode
                      AND [PPWS].[idProvider] = @idProvider
                    )

    DECLARE
        @BeforeBalanceValue                 [LP_Common].[LP_F_DECIMAL]
        , @BeforeBalanceValueFX               [LP_Common].[LP_F_DECIMAL]
        , @BeforeBalanceFinalValue              [LP_Common].[LP_F_DECIMAL]
        , @SignMultiply                   [LP_Common].[LP_F_INT]
        , @BeforeBalanceValueWithOutCommissionLP      [LP_Common].[LP_F_DECIMAL]
        , @BeforeBalanceValueWithOutCommissionClient    [LP_Common].[LP_F_DECIMAL]

    SET @SignMultiply = -1

    IF(@idTransactionType = 15 OR @idTransactionType = 18) /* AddBalance */
    BEGIN

      DECLARE
        @Credit_Tax_Porc  [LP_Common].[LP_F_DECIMAL]
        , @fxCreditTax    [LP_Common].[LP_F_DECIMAL]
        , @fxTotalCostRnd [LP_Common].[LP_F_DECIMAL]
        , @fxBalanceFinal [LP_Common].[LP_F_DECIMAL]

      SET @Credit_Tax_Porc = ISNULL([LP_Catalog].[fnGetProviderVariableValue]('VAR::ARG::GENERIC_TRANSACTION.CREDIT_TAX_PORC', @idCountry, @idProvider, @idTransactionType), 0)

      IF(@idCurrencyType = @idCurrencyLP)
      BEGIN

        SELECT @idCurrencyBase = [idCurrencyBase], @Base_Sell = [Base_Sell], @Base_Buy = [Base_Buy] 
        FROM [LP_Configuration].[CurrencyBase] 
        WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 
          AND [idCurrencyType] = @idCurrencyClient 
          AND [idCountry] = @idCountry

        SELECT @idCurrencyExchange = [idCurrencyExchange], @Value_Exchange_Auto = [Value] 
        FROM [LP_Configuration].[CurrencyExchange]
        WHERE [Active] = 1 AND [ActionType] = 'A' /*AND [idCountry] = @idCountry*/ AND [CurrencyTo] = @idCurrencyClient
        SET @fxValue_Exchange_Auto = @Value_Exchange_Auto * ( 1 - @Base_Buy / 100.0 )

        SET @ValueConverted = @Value

        SET @fxCreditTax = (@ValueConverted * @Credit_Tax_Porc)
        SET @fxTotalCostRnd = (@fxCreditTax * -1)
      END
      ELSE
      BEGIN
      --select @idEntityUser,@idCurrencyClient,@idCountry
        SELECT @idCurrencyBase = [idCurrencyBase], @Base_Sell = [Base_Sell], @Base_Buy = [Base_Buy] FROM [LP_Configuration].[CurrencyBase] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [idCurrencyType] = @idCurrencyClient AND [idCountry] = @idCountry
        --select @idcurrencybase
        SELECT @idCurrencyExchange = [idCurrencyExchange], @Value_Exchange_Auto = [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [Active] = 1 AND [ActionType] = 'A' /*AND [idCountry] = @idCountry*/ AND [CurrencyTo] = @idCurrencyLP
        SET @fxValue_Exchange_Auto = @Value_Exchange_Auto * ( 1 - @Base_Buy / 100.0 )

        SET @ValueConverted = @Value * @fxValue_Exchange_Auto

        SET @fxCreditTax = @ValueConverted * @Credit_Tax_Porc
        SET @fxTotalCostRnd = (@fxCreditTax * -1)
      END

      SET @idTransactionOperation =
                    (
                      SELECT
                        [TRO].[idTransactionOperation]
                      FROM
                        [LP_Configuration].[TransactionType]            [TT]
                          INNER JOIN [LP_Configuration].[TransactionGroup]    [TG]  ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
                          INNER JOIN [LP_Configuration].[TransactionOperation]  [TRO] ON [TG].[idTransactionOperation]  = [TRO].[idTransactionOperation]
                      WHERE
                        [TT].[idTransactionType] = @idTransactionType
                        AND [TT].[Active] = 1
                        AND [TG].[Active] = 1
                        AND [TRO].[Active] = 1
                    )

      /* INSERT INTO TRANSACTIONLOT */
      INSERT INTO [LP_Operation].[TransactionLot] ( [LotNumber], [LotCode], [Description], [LotDate], [GrossAmount], [NetAmount], [idStatus] )
      VALUES ( CONCAT('000', DATEDIFF(SECOND, '19700101', GETDATE()), @Admin, @idTransactionType), '', '', @TransactionDate, NULL, NULL, @idStatus )
      SELECT @idTransactionLot = @@IDENTITY 

      /* INSERT INTO TRANSACTION */
      IF(@idCurrencyType = @idCurrencyLP)
      BEGIN
        INSERT INTO [LP_Operation].[Transaction] ( [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [idCurrencyBase], [idCurrencyExchange], [Version], [idTransactionLot], [idEntityUser], [idEntityAccount], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idStatus], [Active], [ProcessedDate] )
        VALUES ( @TransactionDate, @Value, @idCurrencyClient, @ValueConverted, @idCurrencyLP, @idCurrencyBase, @idCurrencyExchange, 1, @idTransactionLot, @idEntityUser, @idEntityAccountDefault, @idTransactionMechanism, @idTransactionTypeProvider, @idProviderPayWayService, @idStatus, 1, @TransactionDate )
        SELECT @idTransaction = @@IDENTITY
      END
      ELSE
      BEGIN
        INSERT INTO [LP_Operation].[Transaction] ( [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [idCurrencyBase], [idCurrencyExchange], [Version], [idTransactionLot], [idEntityUser], [idEntityAccount], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idStatus], [Active], [ProcessedDate] )
        VALUES ( @TransactionDate, @Value, @idCurrencyType, @ValueConverted, @idCurrencyLP, @idCurrencyBase, @idCurrencyExchange, 1, @idTransactionLot, @idEntityUser, @idEntityAccountDefault, @idTransactionMechanism, @idTransactionTypeProvider, @idProviderPayWayService, @idStatus, 1, @TransactionDate )
        SELECT @idTransaction = @@IDENTITY
      END

      /* INSERT INTO  TRANSACTIONFROMTO */
      INSERT INTO [LP_Operation].[TransactionFromTo] ( [IdTransaction], [FromIdEntityAccount], [ToIdEntityAccount] )
      VALUES ( @idTransaction, @Admin, @idEntityAccountDefault )

      /* INSERT INTO TRANSACTIONPROVIDER */
      INSERT INTO [LP_Operation].[TransactionProvider] ( [idTransaction], [idProvider], [CreditTax], [TotalCostRnd], [idStatus], [Version] )
      VALUES ( @idTransaction, @idProvider, @fxCreditTax, @fxTotalCostRnd, @idStatus, 1 )

      /* INSERT INTO WALLET */      
      IF(@idCurrencyType = @idCurrencyLP)
      BEGIN

        SELECT TOP 1 @BeforeBalanceValue = [BalanceLP], @BeforeBalanceValueWithOutCommissionLP = [BalanceLPWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceLP] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceFinalValue = [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

        IF(@idTransactionType <> 18)
        BEGIN
          IF(@BeforeBalanceValue IS NULL)
          BEGIN
            SET @BeforeBalanceValue = @ValueConverted
            SET @BeforeBalanceValueWithOutCommissionLP = @ValueConverted
          END
          ELSE
          BEGIN
            SET @BeforeBalanceValue = @BeforeBalanceValue + @ValueConverted
            SET @BeforeBalanceValueWithOutCommissionLP = @BeforeBalanceValueWithOutCommissionLP + @ValueConverted
          END
        END
        ELSE
        BEGIN
          SET @BeforeBalanceValue = ISNULL(@BeforeBalanceValue, 0) + @Value
        END

        SET @fxBalanceFinal = ISNULL(@BeforeBalanceFinalValue, 0) + @ValueConverted - @fxCreditTax

        INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceLPWithOutCommission] )
        VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @idCurrencyLP, @Value, @Value, @BeforeBalanceValue, @idCurrencyClient, NULL, NULL, NULL, @fxBalanceFinal, @BeforeBalanceValueWithOutCommissionLP )
      END
      ELSE
      BEGIN

        SELECT TOP 1 @BeforeBalanceValue = [BalanceClient], @BeforeBalanceValueWithOutCommissionClient = [BalanceClientWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceClient] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceFinalValue = [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

        IF(@idTransactionType <> 18)
        BEGIN
          IF(@BeforeBalanceValue IS NULL)
          BEGIN
            SET @BeforeBalanceValue = @Value
            SET @BeforeBalanceValueWithOutCommissionClient = @Value
          END
          ELSE
          BEGIN
            SET @BeforeBalanceValue = @BeforeBalanceValue + @Value
            SET @BeforeBalanceValueWithOutCommissionClient = @BeforeBalanceValueWithOutCommissionClient + @Value
          END
        END
        ELSE
        BEGIN
          SET @BeforeBalanceValue = ISNULL(@BeforeBalanceValue, 0) + @Value
        END

        SET @fxBalanceFinal = ISNULL(@BeforeBalanceFinalValue, 0) + @ValueConverted - @fxCreditTax

        INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceClientWithOutCommission])
        VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @idCurrencyLP, NULL, NULL, NULL, @idCurrencyType, @Value, @Value, @BeforeBalanceValue, @fxBalanceFinal, @BeforeBalanceValueWithOutCommissionClient )
      END

      INSERT INTO [LP_Operation].[TransactionDescription] ([idTransaction], [Description]) VALUES(@idTransaction, @Description)

      SET @Status = 1
      SET @Message = 'LA TRANSACCION FUE UN EXITO.'
    END
    ELSE IF(@idTransactionType = 16) /* Conversion */
    BEGIN

      /*

      @idCurrencyType
      @Value
      @ValueFX

      */

      /*

      SOLO SI EL CLIENTE ES MONEDA LOCAL

      */

      DECLARE
        @CurrencyClose            [LP_Common].[LP_F_INT]
        , @Debt               [LP_Common].[LP_F_DECIMAL]
        , @DebtWithOutCommission      [LP_Common].[LP_F_DECIMAL]

      --IF(@idCurrencyClient = @idCurrencyLP)
      IF(@idCurrencyType = @idCurrencyLP)
      BEGIN

        SELECT TOP 1 @BeforeBalanceValue = [BalanceLP], @BeforeBalanceValueWithOutCommissionLP = [BalanceLPWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceLP] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceValueFX = BalanceClient, @BeforeBalanceValueWithOutCommissionClient = [BalanceClientWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceClient] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceFinalValue = [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

        IF(@BeforeBalanceValue IS NOT NULL)
        BEGIN
          IF(@BeforeBalanceValue >= @Value)
          BEGIN

            SELECT
              @idCurrencyLP   = [ECE].[idCurrencyTypeLP]
              , @idCurrencyClient = [ECE].[idCurrencyTypeClient]
            FROM
              [LP_Entity].[EntityCurrencyExchange] [ECE]
            WHERE [ECE].[idEntityUser] = @idEntityUser AND [ECE].[Active]=1

            SET @TransactionDate = GETDATE();

            INSERT INTO [LP_Configuration].[CurrencyExchange] ( [ProcessDate], [Timestamp], [CurrencyBase], [CurrencyTo], [idCountry], [Value], [ActionType] )
            VALUES
            (
                  @TransactionDate
              , DATEDIFF(SECOND, '1970', @TransactionDate)
              , @idCurrencyLP
              , @idCurrencyClient
              , 1
              , @ValueFX
              , 'M'
            ) 

            SET @idCurrencyExchange = @@IDENTITY;

            SELECT
              @idCurrencyBase = [idCurrencyBase]
              , @Base_Sell  = [Base_Sell]
              , @Base_Buy   = [Base_Buy]
            FROM
              [LP_Configuration].[CurrencyBase]
            WHERE
              [idEntityUser] = @idEntityUser
              AND [Active] = 1
              AND [idCurrencyType] = @idCurrencyClient
              AND [idCountry] = @idCountry

            SET @idTransactionOperation =
                          (
                            SELECT
                              [TRO].[idTransactionOperation]
                            FROM
                              [LP_Configuration].[TransactionType]            [TT]
                                INNER JOIN [LP_Configuration].[TransactionGroup]    [TG]  ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
                                INNER JOIN [LP_Configuration].[TransactionOperation]  [TRO] ON [TG].[idTransactionOperation]  = [TRO].[idTransactionOperation]
                            WHERE
                              [TT].[idTransactionType] = @idTransactionType
                              AND [TT].[Active] = 1
                              AND [TG].[Active] = 1
                              AND [TRO].[Active] = 1
                          )

            /* INSERT INTO TRANSACTIONLOT */
            INSERT INTO [LP_Operation].[TransactionLot] ( [LotNumber], [LotCode], [Description], [LotDate], [GrossAmount], [NetAmount], [idStatus] )
            VALUES ( CONCAT('000', DATEDIFF(SECOND, '19700101', GETDATE()), @Admin, @idTransactionType), '', '', @TransactionDate, NULL, NULL, @idStatus )
            SELECT @idTransactionLot = @@IDENTITY 

            /* INSERT INTO TRANSACTION */
            INSERT INTO [LP_Operation].[Transaction] ( [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [idCurrencyBase], [idCurrencyExchange], [Version], [idTransactionLot], [idEntityUser], [idEntityAccount], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idStatus], [Active], [ProcessedDate] )
            VALUES ( @TransactionDate, @Value, @idCurrencyClient, @ValueConverted, @idCurrencyLP, @idCurrencyBase, @idCurrencyExchange, 1, @idTransactionLot, @idEntityUser, @idEntityAccountDefault, @idTransactionMechanism, @idTransactionTypeProvider, @idProviderPayWayService, @idStatus, 1, @TransactionDate )
            SELECT @idTransaction = @@IDENTITY  

            /* INSERT INTO  TRANSACTIONFROMTO */
            INSERT INTO [LP_Operation].[TransactionFromTo] ( [IdTransaction], [FromIdEntityAccount], [ToIdEntityAccount] )
            VALUES ( @idTransaction, @Admin, @idEntityAccountDefault )

            /* INSERT INTO WALLET */
            SET @Debt = @BeforeBalanceValue - @Value /* RESTO QUE QUEDA EN MONEDA LOCAL */
            SET @DebtWithOutCommission = @BeforeBalanceValueWithOutCommissionLP - @Value

            SET @ValueConverted = @Value / @ValueFX /* CONVERSION CON VALOR FX INGRESADO DE FORMA MANUAL */

            IF(@BeforeBalanceValueFX IS NULL)
            BEGIN
              SET @BeforeBalanceValueFX = @ValueConverted
              SET @BeforeBalanceValueWithOutCommissionClient = @ValueConverted
            END
            ELSE
            BEGIN
              SET @BeforeBalanceValueFX = @BeforeBalanceValueFX + @ValueConverted
              SET @BeforeBalanceValueWithOutCommissionClient = @BeforeBalanceValueWithOutCommissionClient + @ValueConverted
            END

            INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceLPWithOutCommission], [BalanceClientWithOutCommission] )
            VALUES
            (
              DATEDIFF(SECOND, '19700101', @TransactionDate)
              , @idEntityUser
              , @idTransaction
              , @idTransactionOperation

              /* WALLET MONEDA LOCAL */
              , @idCurrencyLP
              , (@Value * @SignMultiply)
              , (@Value * @SignMultiply)
              , @Debt

              /* CAMPOS QUE SE LLENAN CON LA CONVERSION */
              , @idCurrencyType
              , @ValueConverted
              , @ValueConverted
              , @BeforeBalanceValueFX /* ?? */

              /* BALANCE FINAL LP */
              , @BeforeBalanceFinalValue
              , @DebtWithOutCommission
              , @BeforeBalanceValueWithOutCommissionClient
            )

            INSERT INTO [LP_Operation].[TransactionDescription] ([idTransaction], [Description]) VALUES(@idTransaction, @Description)

            SET @Status = 1
            SET @Message = 'LA TRANSACCION FUE UN EXITO.'
          END
          ELSE
          BEGIN
            SET @Status = 1
            SET @Message = 'LA TRANSACCION NO SE PUDO REALIZAR, EL MONTO INGRESADO SUPERA AL SALDO EN CUENTA.'
          END
        END
        ELSE
        BEGIN
          SET @Status = 1
          SET @Message = 'LA TRANSACCION NO SE PUDO REALIZAR, NO POSEE FONDOS SUFICIENTES.'
        END
      END
      ELSE
      BEGIN

        SELECT TOP 1 @BeforeBalanceValue = [BalanceClient], @BeforeBalanceValueWithOutCommissionClient = [BalanceClientWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceClient] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceValueFX = [BalanceLP], @BeforeBalanceValueWithOutCommissionLP = [BalanceLPWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceLP] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceFinalValue = [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

        IF(@BeforeBalanceValue IS NOT NULL)
        BEGIN
          IF(@BeforeBalanceValue >= @Value)
          BEGIN

            SELECT
              @idCurrencyLP   = [ECE].[idCurrencyTypeLP]
              , @idCurrencyClient = [ECE].[idCurrencyTypeClient]
            FROM
              [LP_Entity].[EntityCurrencyExchange] [ECE]
            WHERE
              [ECE].[idEntityUser] = @idEntityUser
              AND [ECE].[Active] = 1

            SET @TransactionDate = GETDATE();

            INSERT INTO [LP_Configuration].[CurrencyExchange] ( [ProcessDate], [Timestamp], [CurrencyBase], [CurrencyTo], [idCountry], [Value], [ActionType] )
            VALUES
            (
              @TransactionDate
              , DATEDIFF(SECOND, '1970', @TransactionDate)
              , @idCurrencyLP
              , @idCurrencyClient
              , 1
              , @ValueFX
              , 'M'
            )

            SET  @idCurrencyExchange = @@IDENTITY;

            SELECT
              @idCurrencyBase = [idCurrencyBase]
              , @Base_Sell  = [Base_Sell]
              , @Base_Buy   = [Base_Buy]
            FROM
              [LP_Configuration].[CurrencyBase]
            WHERE
              [idEntityUser] = @idEntityUser
              AND [Active] = 1
              AND [idCurrencyType] = @idCurrencyClient
              AND [idCountry] = @idCountry

            SET @idTransactionOperation =
                          (
                            SELECT
                              [TRO].[idTransactionOperation]
                            FROM
                              [LP_Configuration].[TransactionType]            [TT]
                                INNER JOIN [LP_Configuration].[TransactionGroup]    [TG]  ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
                                INNER JOIN [LP_Configuration].[TransactionOperation]  [TRO] ON [TG].[idTransactionOperation]  = [TRO].[idTransactionOperation]
                            WHERE
                              [TT].[idTransactionType] = @idTransactionType
                              AND [TT].[Active] = 1
                              AND [TG].[Active] = 1
                              AND [TRO].[Active] = 1
                          )

            /* INSERT INTO TRANSACTIONLOT */
            INSERT INTO [LP_Operation].[TransactionLot] ( [LotNumber], [LotCode], [Description], [LotDate], [GrossAmount], [NetAmount], [idStatus] )
            VALUES ( CONCAT('000', DATEDIFF(SECOND, '19700101', GETDATE()), @Admin, @idTransactionType), '', '', @TransactionDate, NULL, NULL, @idStatus )
            SELECT @idTransactionLot = @@IDENTITY 

            /* INSERT INTO TRANSACTION */
            INSERT INTO [LP_Operation].[Transaction] ( [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [idCurrencyBase], [idCurrencyExchange], [Version], [idTransactionLot], [idEntityUser], [idEntityAccount], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idStatus], [Active], [ProcessedDate] )
            VALUES ( @TransactionDate, @Value, @idCurrencyClient, @ValueConverted, @idCurrencyLP, @idCurrencyBase, @idCurrencyExchange, 1, @idTransactionLot, @idEntityUser, @idEntityAccountDefault, @idTransactionMechanism, @idTransactionTypeProvider, @idProviderPayWayService, @idStatus, 1, @TransactionDate )
            SELECT @idTransaction = @@IDENTITY  

            /* INSERT INTO  TRANSACTIONFROMTO */
            INSERT INTO [LP_Operation].[TransactionFromTo] ( [IdTransaction], [FromIdEntityAccount], [ToIdEntityAccount] )
            VALUES ( @idTransaction, @Admin, @idEntityAccountDefault )

            /* INSERT INTO WALLET */
            SET @Debt = @BeforeBalanceValue - @Value /* RESTO QUE QUEDA EN MONEDA LOCAL */
            SET @DebtWithOutCommission = @BeforeBalanceValueWithOutCommissionClient - @Value

            SET @ValueConverted = @Value * @ValueFX /* CONVERSION CON VALOR FX INGRESADO DE FORMA MANUAL */

            IF(@BeforeBalanceValueFX IS NULL)
            BEGIN
              SET @BeforeBalanceValueFX = @ValueConverted
              SET @BeforeBalanceValueWithOutCommissionLP = @ValueConverted
            END
            ELSE
            BEGIN
              SET @BeforeBalanceValueFX = @BeforeBalanceValueFX + @ValueConverted
              SET @BeforeBalanceValueWithOutCommissionLP = @BeforeBalanceValueWithOutCommissionLP + @ValueConverted
            END

            INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceLPWithOutCommission], [BalanceClientWithOutCommission] )
            VALUES
            (
              DATEDIFF(SECOND, '19700101', @TransactionDate)
              , @idEntityUser
              , @idTransaction
              , @idTransactionOperation

              /* WALLET MONEDA LOCAL */
              , @idCurrencyLP
              , @ValueConverted
              , @ValueConverted
              , @BeforeBalanceValueFX /* ?? */

              /* CAMPOS QUE SE LLENAN CON LA CONVERSION */
              , @idCurrencyType
              , (@Value * @SignMultiply)
              , (@Value * @SignMultiply)
              , @Debt

              /* BALANCE FINAL LP */
              , @BeforeBalanceFinalValue
              , @BeforeBalanceValueWithOutCommissionLP
              , @DebtWithOutCommission
            )

            INSERT INTO [LP_Operation].[TransactionDescription] ([idTransaction], [Description]) VALUES(@idTransaction, @Description)

            SET @Status = 1
            SET @Message = 'LA TRANSACCION FUE UN EXITO.'
          END
          ELSE
          BEGIN
            SET @Status = 1
            SET @Message = 'LA TRANSACCION NO SE PUDO REALIZAR, EL MONTO INGRESADO SUPERA AL SALDO EN CUENTA.'
          END
        END
        ELSE
        BEGIN
          SET @Status = 1
          SET @Message = 'LA TRANSACCION NO SE PUDO REALIZAR, NO POSEE FONDOS SUFICIENTES.'
        END
      END     
    END 
    ELSE IF(@idTransactionType = 17) /* AddDebit ==> DEBIT, ADD SE HACE CON ADDBALANCE */
    BEGIN

      /*

      @idCurrencyType
      @Value
      @ActionType

      */

      /*

      SI ES USD, EL DEBITO SE HACE SOBRE EL BALANCE CLIENT
      SI ES ARS, EL DEBITO SE HACE SOBRE EL BALANCE LP

      1.- VALIDAR SI HAY SALDO PARA DEBITAR
      2.- SI ES CUENTA DOLAR DEBITAR POR FX.

      */

      IF(@idCurrencyType = @idCurrencyLP)
      BEGIN
        SELECT @idCurrencyBase = [idCurrencyBase], @Base_Sell = [Base_Sell], @Base_Buy = [Base_Buy] FROM [LP_Configuration].[CurrencyBase] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [idCurrencyType] = @idCurrencyClient AND [idCountry] = @idCountry
        SELECT @idCurrencyExchange = [idCurrencyExchange], @Value_Exchange_Auto = [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [Active] = 1 AND [ActionType] = 'A' /* AND [idCountry] = @idCountry */ AND [CurrencyTo] = @idCurrencyClient
        SET @fxValue_Exchange_Auto = @Value_Exchange_Auto * ( 1 - @Base_Buy / 100.0 )

        SET @ValueConverted = @Value
      END
      ELSE
      BEGIN
        SELECT @idCurrencyBase = [idCurrencyBase], @Base_Sell = [Base_Sell], @Base_Buy = [Base_Buy] FROM [LP_Configuration].[CurrencyBase] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [idCurrencyType] = @idCurrencyClient AND [idCountry] = @idCountry
        SELECT @idCurrencyExchange = [idCurrencyExchange], @Value_Exchange_Auto = [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [Active] = 1 AND [ActionType] = 'A' /* AND [idCountry] = @idCountry */ AND [CurrencyTo] = @idCurrencyLP
        SET @fxValue_Exchange_Auto = @Value_Exchange_Auto * ( 1 - @Base_Buy / 100.0 )

        SET @ValueConverted = @Value * @fxValue_Exchange_Auto
      END

      SET @idTransactionOperation =
                    (
                      SELECT
                        [TRO].[idTransactionOperation]
                      FROM
                        [LP_Configuration].[TransactionType]            [TT]
                          INNER JOIN [LP_Configuration].[TransactionGroup]    [TG]  ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
                          INNER JOIN [LP_Configuration].[TransactionOperation]  [TRO] ON [TG].[idTransactionOperation]  = [TRO].[idTransactionOperation]
                      WHERE
                        [TT].[idTransactionType] = @idTransactionType
                        AND [TT].[Active] = 1
                        AND [TG].[Active] = 1
                        AND [TRO].[Active] = 1
                    )

      /* INSERT INTO TRANSACTIONLOT */
      INSERT INTO [LP_Operation].[TransactionLot] ( [LotNumber], [LotCode], [Description], [LotDate], [GrossAmount], [NetAmount], [idStatus] )
      VALUES ( CONCAT('000', DATEDIFF(SECOND, '19700101', GETDATE()), @Admin, @idTransactionType), '', '', @TransactionDate, NULL, NULL, @idStatus )
      SELECT @idTransactionLot = @@IDENTITY 

      /* INSERT INTO TRANSACTION */
      IF(@idCurrencyType = @idCurrencyLP)
      BEGIN
        INSERT INTO [LP_Operation].[Transaction] ( [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [idCurrencyBase], [idCurrencyExchange], [Version], [idTransactionLot], [idEntityUser], [idEntityAccount], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idStatus], [Active], [ProcessedDate] )
        VALUES ( @TransactionDate, @Value, @idCurrencyClient, @ValueConverted, @idCurrencyLP, @idCurrencyBase, @idCurrencyExchange, 1, @idTransactionLot, @idEntityUser, @idEntityAccountDefault, @idTransactionMechanism, @idTransactionTypeProvider, @idProviderPayWayService, @idStatus, 1, @TransactionDate )
        SELECT @idTransaction = @@IDENTITY
      END
      ELSE
      BEGIN
        INSERT INTO [LP_Operation].[Transaction] ( [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [idCurrencyBase], [idCurrencyExchange], [Version], [idTransactionLot], [idEntityUser], [idEntityAccount], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idStatus], [Active], [ProcessedDate] )
        VALUES ( @TransactionDate, @Value, @idCurrencyType, @ValueConverted, @idCurrencyLP, @idCurrencyBase, @idCurrencyExchange, 1, @idTransactionLot, @idEntityUser, @idEntityAccountDefault, @idTransactionMechanism, @idTransactionTypeProvider, @idProviderPayWayService, @idStatus, 1, @TransactionDate )
        SELECT @idTransaction = @@IDENTITY
      END


      /* INSERT INTO  TRANSACTIONFROMTO */
      INSERT INTO [LP_Operation].[TransactionFromTo] ( [IdTransaction], [FromIdEntityAccount], [ToIdEntityAccount] )
      VALUES ( @idTransaction, @Admin, @idEntityAccountDefault )

      SET @ValueConverted = @ValueConverted * @SignMultiply

      /* INSERT INTO WALLET */      
      IF(@idCurrencyType = @idCurrencyLP)
      BEGIN

        SELECT TOP 1 @BeforeBalanceValue = [BalanceLP], @BeforeBalanceValueWithOutCommissionLP = [BalanceLPWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceLP] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceFinalValue = [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

        IF(@BeforeBalanceValue IS NULL)
        BEGIN
          SET @BeforeBalanceValue = ( @Value * @SignMultiply )
          SET @BeforeBalanceValueWithOutCommissionLP = ( @Value * @SignMultiply )
        END
        ELSE
        BEGIN
          SET @BeforeBalanceValue = @BeforeBalanceValue + ( @Value * @SignMultiply )
          SET @BeforeBalanceValueWithOutCommissionLP = @BeforeBalanceValueWithOutCommissionLP + ( @Value * @SignMultiply )
        END

        SET @fxBalanceFinal = ISNULL(@BeforeBalanceFinalValue, 0) + @ValueConverted

        INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceLPWithOutCommission] )
        VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @idCurrencyLP, @Value * @SignMultiply, @Value * @SignMultiply, @BeforeBalanceValue, @idCurrencyClient, NULL, NULL, NULL, @fxBalanceFinal, @BeforeBalanceValueWithOutCommissionLP )
      END
      ELSE
      BEGIN

        SELECT TOP 1 @BeforeBalanceValue = [BalanceClient], @BeforeBalanceValueWithOutCommissionClient = [BalanceClientWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceClient] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceFinalValue = [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

        IF(@BeforeBalanceValue IS NULL)
        BEGIN
          SET @BeforeBalanceValue = ( @Value * @SignMultiply )
          SET @BeforeBalanceValueWithOutCommissionClient = ( @Value * @SignMultiply )
        END
        ELSE
        BEGIN
          SET @BeforeBalanceValue = @BeforeBalanceValue + ( @Value * @SignMultiply )
          SET @BeforeBalanceValueWithOutCommissionClient = @BeforeBalanceValueWithOutCommissionClient + ( @Value * @SignMultiply )
        END

        SET @fxBalanceFinal = ISNULL(@BeforeBalanceFinalValue, 0) + @ValueConverted

        INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceClientWithOutCommission])
        VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @idCurrencyLP, NULL, NULL, NULL, @idCurrencyType, @Value * @SignMultiply, @Value * @SignMultiply, @BeforeBalanceValue, @fxBalanceFinal, @BeforeBalanceValueWithOutCommissionClient )
      END

      INSERT INTO [LP_Operation].[TransactionDescription] ([idTransaction], [Description]) VALUES(@idTransaction, @Description)

      SET @Status = 1
      SET @Message = 'LA TRANSACCION FUE UN EXITO.'
    END

  END
  ELSE
  BEGIN
    SET @Status = 0
    SET @Message = 'NO TIENE PERMISOS PARA EJECUTAR LA INSTRUCCION.'
  END

  SELECT [Status] = ISNULL(@Status, 0), [Message] = ISNULL(@Message, 'ALGO SALIO MAL!')

commit tran

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRAN

    --DECLARE @ErrorMessage NVARCHAR(4000) = 'INTERNAL ERROR'
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
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