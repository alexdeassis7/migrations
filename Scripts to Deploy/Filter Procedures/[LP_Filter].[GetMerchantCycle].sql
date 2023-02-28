/****** Object:  StoredProcedure [LP_Filter].[GetMerchantCycle]    Script Date: 7/4/2020 11:14:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [LP_Filter].[GetMerchantCycle] 'ADMIN@LOCALPAYMENT.COM'
ALTER PROCEDURE [LP_Filter].[GetMerchantCycle]
                        (
                           @Customer    [LP_Common].[LP_F_C50]
                        )
AS
BEGIN

  --DECLARE
  --  @Customer [LP_Common].[LP_F_C50]

  --SET @Customer = '000000000001'
  --SET @Customer = 'test-dev@localpayment.com'

  DECLARE
    @RESP       XML
    , @idEntityUser   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @idEntityType   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @idAdminType    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @StartCycle   [LP_Common].[LP_A_DB_INSDATETIME]
    , @EndCycle     [LP_Common].[LP_A_DB_INSDATETIME]
    , @idStatus     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @idCountry    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @idCycle      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

  DECLARE @Merchant TABLE
  (
    [idEntityMerchant]  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , [Merchant]    [LP_Common].[LP_F_DESCRIPTION]
    , [Method]      [LP_Common].[LP_F_CODE]
    , [Gross]     [LP_Common].[LP_F_DECIMAL]          NULL
    , [Comission]   [LP_Common].[LP_F_DECIMAL]          NULL
    , [VAT]       [LP_Common].[LP_F_DECIMAL]          NULL
    , [ARS]       [LP_Common].[LP_F_DECIMAL]          NULL
    , [ExRate]      [LP_Common].[LP_F_DECIMAL]          NULL
    , [USD]       [LP_Common].[LP_F_DECIMAL]          NULL
    , [Cycle]     [LP_Common].[LP_F_DESCRIPTION]
    , [PayDate]     [LP_Common].[LP_A_DB_INSDATETIME]
    , [Exchange]    [LP_Common].[LP_F_DECIMAL]          NULL
    , [RevenueOper]   [LP_Common].[LP_F_DECIMAL]          NULL
    , [RevenueFx]   [LP_Common].[LP_F_DECIMAL]          NULL
    , [IdCycle]     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , [StartCycle]    [LP_Common].[LP_A_DB_INSDATETIME]
    , [EndCycle]    [LP_Common].[LP_A_DB_INSDATETIME]

  )
  DECLARE @Transactions TABLE
  ( 
    [idTransaction]   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , [idCycle]     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , [StartCycle]    [LP_Common].[LP_A_DB_INSDATETIME]
    , [EndCycle]    [LP_Common].[LP_A_DB_INSDATETIME]
    , [PayDate]     [LP_Common].[LP_A_DB_INSDATETIME]
    , [Gross]     [LP_Common].[LP_F_DECIMAL]          NULL
    , [Comission]   [LP_Common].[LP_F_DECIMAL]          NULL
    , [VAT]       [LP_Common].[LP_F_DECIMAL]          NULL
    , [ARS]       [LP_Common].[LP_F_DECIMAL]          NULL
    , [ExRate]      [LP_Common].[LP_F_DECIMAL]          NULL
    , [USD]       [LP_Common].[LP_F_DECIMAL]          NULL
    , [Exchange]    [LP_Common].[LP_F_DECIMAL]          NULL
    , [RevenueOper]   [LP_Common].[LP_F_DECIMAL]          NULL
    , [RevenueFx]   [LP_Common].[LP_F_DECIMAL]          NULL
  )

  --SELECT
  --  @idEntityUser = [eu].[idEntityUser]
  --  , @idEntityType = [eu].[idEntityType]
  --FROM 
  --  [LP_Security].[EntityAccount]     [EA]
  --    INNER JOIN [LP_Entity].[EntityUser] [EU] ON [EA].[idEntityUser] = [EU].[idEntityUser]
  --WHERE
  --  [EA].[Active] = 1
  --  AND [EU].[Active] = 1
  --  AND [EA].[UserSiteIdentification] = @Customer

  SELECT
    @idEntityUser   = [EU].[idEntityUser]
    , @idEntityType   = [eu].[idEntityType]
  FROM
    [LP_Entity].[EntityUser]              [EU]
      INNER JOIN [LP_Security].[EntityAccountUser]  [EAU] ON [EAU].[idEntityUser] = [EU].[idEntityUser]
      INNER JOIN [LP_Security].[EntityAccount]    [EA]  ON [EA].[idEntityAccount] = [EAU].[idEntityAccount]
      INNER JOIN [LP_Location].[Country]        [C]   ON [C].[idCountry] = [EU].[idCountry]
  WHERE
    [EU].[Active] = 1
    AND [EAU].[Active] = 1
    AND [EA].[Active] = 1
    AND [C].[Active] = 1
    AND [EA].[UserSiteIdentification] = @customer
    --AND [C].[ISO3166_1_ALFA003] = @country_code

  SET @idAdminType = ( SELECT [idEntityType] FROM [LP_Entity].[EntityType] WHERE [Code] = 'Admin' AND [Active] = 1)

  BEGIN TRY

    IF (@idEntityUser IS NOT NULL)
    BEGIN

      IF (@idEntityType = @idAdminType)
      BEGIN

        DECLARE
          @ID           [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
          , @IdUserMerchant   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
          , @Type         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
          , @idEntityMerchant   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
          , @MerchantDesc     [LP_Common].[LP_F_DESCRIPTION]
          , @Method       [LP_Common].[LP_F_CODE]
          , @Gross        [LP_Common].[LP_F_DECIMAL]
          , @Comission      [LP_Common].[LP_F_DECIMAL]
          , @VAT          [LP_Common].[LP_F_DECIMAL]
          , @ARS          [LP_Common].[LP_F_DECIMAL]
          , @ExRate       [LP_Common].[LP_F_DECIMAL]
          , @USD          [LP_Common].[LP_F_DECIMAL]
          , @Cycle        [LP_Common].[LP_F_DESCRIPTION]
          , @Date         [LP_Common].[LP_A_DB_INSDATETIME]
          , @Exchange       [LP_Common].[LP_F_DECIMAL]
          , @RevenueOper      [LP_Common].[LP_F_DECIMAL]
          , @RevenueFx      [LP_Common].[LP_F_DECIMAL]

        DECLARE @UsersId TABLE(
          [idUser]  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL
        )

        DECLARE @TypesId TABLE(
          [ID]    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL
        )

        INSERT INTO @UsersId ( [idUser] )
        SELECT [idEntityUser] FROM [LP_Entity].[EntityUser] WHERE [Active] = 1 AND [idEntityType] <> @idAdminType

        WHILE EXISTS( SELECT * FROM @UsersId )
        BEGIN 

          SET @ID = ( SELECT TOP 1 [idUser] FROM @UsersId )

          SELECT
            @idEntityMerchant = [U].[idEntityUser]
            , @MerchantDesc   = [U].[FirstName]
          FROM
            [LP_Entity].[EntityUser]          [U]
              INNER JOIN [LP_Entity].[EntityMerchant] [M] ON [M].[idEntityMerchant] = [U].[idEntityMerchant]
          WHERE
            [U].[idEntityUser] = @ID

          SET @idCountry = [LP_Location].[fnGetIdCountyByidEntityUser](@ID)

          INSERT INTO @TypesId ( [ID] )
          SELECT DISTINCT
            [TT].[idTransactionType]
          FROM
            [LP_Operation].[Transaction] [T]
              INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [T].[idTransactionTypeProvider] = [TTP].[idTransactionTypeProvider]
              INNER JOIN [LP_Configuration].[TransactionType]     [TT]  ON [TTP].[idTransactionType] = [TT].[idTransactionType]
              INNER JOIN [LP_Configuration].[TransactionGroup]    [TG]  ON [TG].[idTransactionGroup] = [TT].[idTransactionGroup]
              INNER JOIN [LP_Configuration].[TransactionOperation]  [TO]  ON [TO].[idTransactionOperation] = [TG].[idTransactionOperation]
              INNER JOIN [LP_Common].[Status]             [S]   ON [T].[idStatus]  = [S].[idStatus]
          WHERE 
            [T].[idEntityUser] = @ID
            AND [TT].[Active] = 1
            AND [TO].[Code] <> 'PO'
            AND [TT].[idTransactionType] NOT IN
                              (
                                SELECT
                                  [idTransactionType]
                                FROM
                                  [LP_Configuration].[TransactionType]
                                WHERE
                                  [Code] IN ('AddBalance', 'Conversion', 'AddDebit', 'ReceivedCo','PAYIN','Return','Recall')
                              )
            AND [S].[Code] IN ( 'Executed', 'PAID_FIRST' )

          WHILE EXISTS( SELECT * FROM @TypesId )
          BEGIN

            SET @Type = ( SELECT TOP 1 [ID] FROM @TypesId )

            SET @Method = ( SELECT [Description] FROM [LP_Configuration].[TransactionType] WHERE [idTransactionType] = @Type )

            DELETE FROM @Transactions

            INSERT INTO @Transactions ( [idTransaction], [idCycle], [startCycle], [endCycle], [PayDate], [Gross], [Comission], [VAT], [ARS], [ExRate], [USD], [Exchange], [RevenueOper], [RevenueFx] )
            SELECT
              [T].[idTransaction]
              , [C].[idCycle]
              , [C].[PeriodTypeDateIniOP]
              , [C].[PeriodTypeDateEndOP]
              , ISNULL([TPS].[RealPaidDate],[TPS].[FxPaidDate])
              , ISNULL( [T].[GrossValueLP], 0 )
              , ISNULL( [TD].[commission], 0 )
              , ISNULL( [TD].[VAT], 0 )
              , ISNULL( [TD].[NetAmount], 0 )
              , 0 --[CE].[Value]
              , 0 --ISNULL( [TD].[NetAmount] / [CE].[Value], 0 )
              , 0
              , TP.TotalCostRnd --ISNULL( [TD].[NetAmount] - ISNULL( [LP_Catalog].[fnGetProviderVariableValue]('VAR::ARG::BANK_DEPOSIT.COSTO_BANCO', @idCountry, [TP].[idProvider], @Type), 0 ), 0 )
              , 0 --ISNULL( ([CE2].[Value] - [CE].[Value]) * [TD].[NetAmount], 0 )
            FROM
              [LP_Operation].[Transaction]                    [T]         
                LEFT JOIN [LP_Operation].[TransactionDetail]          [TD]  ON [T].[idTransaction]        = [TD].[idTransaction]
                INNER JOIN [LP_Configuration].[CurrencyExchange]        [CE]  ON [CE].[idCurrencyExchange]    = [T].[idCurrencyExchange]
                LEFT JOIN [LP_Configuration].[CurrencyExchange]         [CE2] ON [CE2].[idCurrencyExchange]   = [T].[idCurrencyExchangeClosed]
                INNER JOIN [LP_Operation].[TransactionCollectedAndPaidStatus] [TPS] ON [TPS].[idTransaction]      = [T].[idTransaction]
                INNER JOIN [LP_Configuration].[TransactionTypeProvider]     [TTP] ON [T].[idTransactionTypeProvider]  = [TTP].[idTransactionTypeProvider]
                INNER JOIN [LP_Configuration].[TransactionType]         [TT]  ON [TTP].[idTransactionType]    = [TT].[idTransactionType]
                INNER JOIN [LP_Configuration].[TransactionGroup]        [TG]  ON [TG].[idTransactionGroup]    = [TT].[idTransactionGroup]
                INNER JOIN [LP_Configuration].[TransactionOperation]      [TO]  ON [TO].[idTransactionOperation]  = [TG].[idTransactionOperation]
                INNER JOIN [LP_Operation].[TransactionProvider]         [TP]  ON [T].[idTransaction]        = [TP].[idTransaction]
                INNER JOIN [LP_Entity].[EntityUser]               [U]   ON [U].[idEntityUser]       = [T].[idEntityUser]
                INNER JOIN [LP_Entity].[EntityMerchant]             [M]   ON [M].[idEntityMerchant]     = [U].[idEntityMerchant]
                INNER JOIN [LP_Configuration].[fnGetEntityCycles]()       [C]   ON [T].[idTransaction]        = [C].[idTransaction]
                INNER JOIN [LP_Common].[Status]                 [S]   ON [T].[idStatus]         = [S].[idStatus]
            WHERE
              [U].[idEntityUser] = @ID
              AND [TO].[Code] <> 'PO'
              AND [T].[Active] = 1
              AND [TTP].[idTransactionType] = @Type
              AND [S].[Code] IN ( 'Executed', 'PAID_FIRST' )

            SET @Gross      = NULL
            SET @Comission    = NULL
            SET @VAT      = NULL
            SET @ARS      = NULL
            SET @ExRate     = NULL
            SET @USD      = NULL
            SET @Cycle      = NULL
            SET @RevenueOper  = NULL
            SET @RevenueFx    = NULL
            SET @idCycle    = NULL

            SELECT
              @Gross      = SUM( ISNULL( [C].[Gross], 0 ) )
              , @Comission  = SUM( ISNULL( [C].[Comission], 0 ) )
              , @VAT      = SUM( ISNULL( [C].[VAT], 0 ) )
              , @ARS      = SUM( ISNULL( [C].[ARS], 0 ) )
              , @ExRate   = [C].[ExRate]
              , @USD      = SUM( ISNULL( [C].[USD], 0 ) )
              , @StartCycle = [C].[StartCycle]
              , @EndCycle   = [C].[EndCycle]
              , @Date     = [C].[PayDate]
              , @Exchange   = [C].[Exchange]
              , @RevenueOper  = SUM( [C].[RevenueOper] )
              , @RevenueFx  = SUM( [C].[RevenueFx] )
              , @idCycle    = [C].[idCycle] 
            FROM
              @Transactions [C]
            GROUP BY
              [C].[idCycle]
              , [C].[StartCycle]
              , [C].[EndCycle]
              , [C].[PayDate]
              , [C].[Exrate]
              , [C].[Exchange]

            IF(@StartCycle IS NULL OR @EndCycle IS NULL)
            BEGIN
              SET @Cycle = ''
            END
            ELSE
            BEGIN
              SET @Cycle= CONVERT( VARCHAR(5), @StartCycle, 5 ) + ' / ' + CONVERT( VARCHAR(5), @EndCycle, 5 )
            END

            INSERT INTO @Merchant( [idEntityMerchant], [Merchant], [Method], [Gross], [Comission], [VAT], [ARS], [ExRate], [USD], [Cycle], [PayDate], [Exchange], [RevenueOper], [RevenueFx] ,[IdCycle], [StartCycle], [EndCycle])
            VALUES ( @idEntityMerchant, @MerchantDesc, @Method, @Gross, @Comission, @VAT, @ARS, @ExRate, @USD, @Cycle, @Date, @Exchange, @RevenueOper, @RevenueFx, @idCycle, @StartCycle, @EndCycle)  

            DELETE FROM @TypesId WHERE [ID] = @Type

          END

          DELETE FROM @UsersId WHERE [idUser] = @ID

        END

        SET @RESP = CAST((SELECT * FROM @Merchant FOR JSON PATH) AS XML)

        SET @RESP =
              CAST
              (
                (
                  SELECT
                    [idEntityMerchant]
                    , [Merchant]
                    , [Gross] = SUM(ISNULL([Gross], 0))
                    , [Comission] = SUM(ISNULL([Comission], 0))
                    , [VAT] = SUM(ISNULL([VAT], 0))
                    , [ARS] = SUM(ISNULL([ARS], 0))
                    , [ExRate] = SUM(ISNULL([ExRate], 0))
                    , [USD] = SUM(ISNULL([USD], 0))
                    , [Cycle]
                    , [Exchange] = SUM(ISNULL([Exchange], 0))
                    , [RevenueOper] = SUM(ISNULL([RevenueOper], 0))
                    , [RevenueFx] = SUM(ISNULL([RevenueFx], 0))
                    , [StartCycle] = @StartCycle
                    , [EndCycle] = @EndCycle
                    , [PayDate] = MAX([PayDate])
                  FROM
                    @Merchant
                  GROUP BY
                    [idEntityMerchant]
                    , [Merchant]
                    , [Cycle]
                    , [StartCycle]
                    , [EndCycle]
                  FOR JSON PATH
                ) AS XML
              )

      END
      ELSE
      BEGIN

        SET @RESP = 'USER ERROR'

      END
    END
    ELSE
    BEGIN

      SET @RESP = 'USER ERROR'

    END

  END TRY 
  BEGIN CATCH

     SELECT @RESP = ERROR_MESSAGE()

  END CATCH

  SELECT @RESP

END
