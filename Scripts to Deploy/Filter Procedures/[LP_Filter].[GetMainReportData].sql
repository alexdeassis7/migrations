/****** Object:  StoredProcedure [LP_Filter].[GetMainReportData]    Script Date: 13/4/2020 10:56:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [LP_Filter].[GetMainReportData]
                        (
                          @Customer [LP_Common].[LP_F_C50]
                          , @Type   [LP_Common].[LP_F_C6]
                        )
AS
BEGIN

  --DECLARE
  --  @Customer [LP_Common].[LP_F_C12]
  --  , @Type   [LP_Common].[LP_F_C6]

  --SET @Customer = '000000000001'
  --SET @Type = 'MONTH'

  DECLARE
    @RESP           XML
    , @Start          [LP_Common].[LP_A_OP_INSDATETIME]
    , @PreviousStart      [LP_Common].[LP_A_OP_INSDATETIME]
    , @PreviousEnd        [LP_Common].[LP_A_OP_INSDATETIME]
    , @OP           [LP_Common].[LP_F_VMAX]
    , @idEntityUser       [LP_Common].[LP_F_INT]
    , @idEntityType       [LP_Common].[LP_F_INT]
    , @idAdminType        [LP_Common].[LP_F_INT]
    , @Merchant         [LP_Common].[LP_F_VMAX]
    , @Gross          [LP_Common].[LP_F_DECIMAL]
    , @TXS            [LP_Common].[LP_F_INT]
    , @PreviousGross      [LP_Common].[LP_F_DECIMAL]
    , @PreviousTxs        [LP_Common].[LP_F_INT]
    , @GrossVar         [LP_Common].[LP_F_DECIMAL]
    , @txsVar         [LP_Common].[LP_F_DECIMAL]
    , @idStatus         [LP_Common].[LP_F_INT]

  DECLARE @Report TABLE 
  (
    [Merchant]          [LP_Common].[LP_F_VMAX]
    , [Gross]         [LP_Common].[LP_F_DECIMAL]        NULL
    , [txsQuantity]       [LP_Common].[LP_F_INT]
    , [GrossVariation]      [LP_Common].[LP_F_DECIMAL]        NULL
    , [txsQuantityVariation]  [LP_Common].[LP_F_DECIMAL]        NULL
  )

  SET @Start  =
        CASE
          WHEN @Type = 'WEEK' THEN
            DATEADD(DAY, DATEDIFF(DAY, 7, GETDATE()), 0)
          WHEN @Type = 'MONTH' THEN
            DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
        END

  SET @PreviousStart  =
            CASE
              WHEN @Type = 'WEEK' THEN
                DATEADD(DAY, DATEDIFF(DAY, 14, GETDATE()), 0)
              WHEN @Type = 'MONTH' THEN
                DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, -1, GETDATE())), 0)
            END

  SET @PreviousEnd  =
            CASE
              WHEN @Type = 'WEEK' THEN
                @Start
              WHEN @Type = 'MONTH' THEN
                DATEADD(DAY, DAY(GETDATE()) - 1, @PreviousStart)
            END

  SELECT
    @idEntityUser = [EU].[idEntityUser]
    , @idEntityType = [EU].[idEntityType]
  FROM
    [LP_Entity].[EntityUser]              [EU]
      INNER JOIN [LP_Security].[EntityAccount]    [EA]  ON [EA].[idEntityUser]  = [EU].[idEntityUser]
  WHERE
    [EU].[Active] = 1
    AND [EA].[Active] = 1
    AND [EA].[UserSiteIdentification] = @customer

  SET @idAdminType = ( SELECT [idEntityType] FROM [LP_Entity].[EntityType] WHERE [Code] = 'Admin' AND [Active] = 1 )

  BEGIN TRY

    IF (@idEntityUser IS NOT NULL)
    BEGIN

      IF (@idEntityType <> @idAdminType)
      BEGIN

        SET @Merchant = ( SELECT [FirstName] FROM [LP_Entity].[EntityUser] WHERE [idEntityUser] = @idEntityUser )

        SELECT
          @Gross  = ISNULL(SUM([TXS].[GrossValueLP]), 0)
          , @TXS  = COUNT([TXS].[idTransaction])
        FROM
          [LP_Operation].[Transaction]                [TXS]
            INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idTransactionTypeProvider]  = [TXS].[idTransactionTypeProvider]
            INNER JOIN [LP_Common].[Status]             [S]   ON [TXS].[idStatus]           = [S].[idStatus]
        WHERE
          [TXS].[idEntityUser] = @idEntityUser
          AND [TXS].[Active] = 1
          AND [TXS].[TransactionDate] > @start
          AND [TTP].[idTransactionType] NOT IN
                            (
                              SELECT
                                [idTransactionType]
                              FROM
                                [LP_Configuration].[TransactionType]
                              WHERE
                                [Code] IN ('AddBalance','Conversion','AddDebit', 'ReceivedCo')
                            )
          AND [S].[Code] IN ( 'Received', 'InProgress', 'Executed', 'PAID_FIRST' )

        SELECT
          @PreviousGross  = ISNULL(SUM([TXS].[GrossValueLP]), 0)
          , @PreviousTxs  = COUNT([TXS].[idTransaction])
        FROM
          [LP_Operation].[Transaction]                [TXS]
            INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idTransactionTypeProvider]  = [TXS].[idTransactionTypeProvider]
            INNER JOIN [LP_Common].[Status]             [S]   ON [TXS].[idStatus]           = [S].[idStatus]
        WHERE
          [TXS].[idEntityUser] = @idEntityUser
          AND [TXS].[Active] = 1
          AND [TXS].[TransactionDate] BETWEEN @PreviousStart AND @PreviousEnd
          AND [TTP].[idTransactionType] NOT IN
                            (
                              SELECT
                                [idTransactionType]
                              FROM
                                [LP_Configuration].[TransactionType]
                              WHERE
                                [Code] IN ('AddBalance','Conversion','AddDebit', 'ReceivedCo')
                            )
          AND [S].[Code] IN ( 'Received', 'InProgress', 'Executed', 'PAID_FIRST' )

        SET @GrossVar =
                CASE
                  WHEN @Gross = 0 THEN
                    CASE
                      WHEN @PreviousGross = 0 THEN
                        0
                      ELSE
                        -100
                    END
                  ELSE
                    CASE
                      WHEN @PreviousTxs = 0 THEN
                        100
                      ELSE
                        ( @PreviousGross * 100 / @Gross ) - 100
                    END
                END

        SET @txsVar =
                CASE
                  WHEN @txs =  0 THEN
                    CASE
                      WHEN @previousTXs = 0 THEN
                        0
                      ELSE
                        -100
                    END
                  ELSE 
                    CASE
                      WHEN @previousTXs = 0 THEN
                        100
                      ELSE
                        ( @PreviousTxs * 100 / @TXS ) - 100
                    END
                END

        INSERT INTO @Report ( [Merchant], [Gross], [txsQuantity], [GrossVariation], [txsQuantityVariation] )
        VALUES ( @Merchant, @Gross, @TXS, @GrossVar, @txsVar )

      END
      ELSE 
      BEGIN 

        DECLARE @ID [LP_Common].[LP_F_INT]

        DECLARE @UsersId TABLE
        (
          [idUser] INT NOT NULL
        )

        INSERT INTO @UsersId ( [idUser] )
        SELECT
          [idEntityUser]
        FROM
          [LP_Entity].[EntityUser]
        WHERE
          [Active] = 1
          AND [idEntityType] <> @idAdminType

        WHILE EXISTS( SELECT * FROM @UsersId )
        BEGIN

          SELECT TOP 1 @ID = [idUser] FROM @UsersId 

          SET @Merchant = ( SELECT [FirstName] FROM [LP_Entity].[EntityUser] WHERE [idEntityUser] = @ID )

          SELECT
            @Gross  = ISNULL(SUM([TXS].[GrossValueLP]), 0)
            , @TXS  = count([TXS].[idTransaction])
          FROM
            [LP_Operation].[Transaction]                [TXS]
              INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idTransactionTypeProvider]  = [TXS].[idTransactionTypeProvider]
              INNER JOIN [LP_Common].[Status]             [S]   ON [TXS].[idStatus]           = [S].[idStatus]
          WHERE
            [TXS].[idEntityUser] = @ID
            AND [TXS].[Active] = 1
            AND [TXS].[TransactionDate] > @Start
            AND [TTP].[idTransactionType] NOT IN
                              (
                                SELECT
                                  [idTransactionType]
                                FROM
                                  [LP_Configuration].[TransactionType]
                                WHERE
                                  [Code] IN ('AddBalance','Conversion','AddDebit', 'ReceivedCo')
                              )
            AND [S].[Code] IN ( 'Received', 'InProgress', 'Executed', 'PAID_FIRST' )

          SELECT
            @PreviousGross  = ISNULL(SUM([TXS].[GrossValueLP]),0)
            , @PreviousTxs  = COUNT([TXS].[idTransaction])
          FROM
            [LP_Operation].[Transaction]                [TXS]
              INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idTransactionTypeProvider]  = [TXS].[idTransactionTypeProvider]
              INNER JOIN [LP_Common].[Status]             [S]   ON [TXS].[idStatus]           = [S].[idStatus]
          WHERE
            [TXS].[idEntityUser] = @ID
            AND [TXS].[Active] = 1
            AND [TXS].[TransactionDate] BETWEEN @PreviousStart AND @PreviousEnd
            AND [TTP].[idTransactionType] NOT IN
                              (
                                SELECT
                                  [idTransactionType]
                                FROM
                                  [LP_Configuration].[TransactionType]
                                WHERE
                                  [Code] IN ('AddBalance','Conversion','AddDebit', 'ReceivedCo')
                              )
            AND [S].[Code] IN ( 'Received', 'InProgress', 'Executed', 'PAID_FIRST' )

          SET @GrossVar =
                  CASE
                    WHEN @Gross = 0 THEN
                      CASE
                        WHEN @PreviousGross = 0 THEN
                          0
                        ELSE
                          -100
                      END
                    ELSE
                      CASE
                        WHEN @PreviousGross = 0 THEN
                          100
                        ELSE
                          ( @PreviousGross * 100 / @Gross ) - 100
                      END
                  END

          SET @txsVar =
                  CASE
                    WHEN @TXS = 0 THEN
                      CASE
                        WHEN @PreviousTxs = 0 THEN
                          0
                        ELSE
                          -100
                      END
                    ELSE
                      CASE
                        WHEN @PreviousTxs = 0 THEN
                          100
                        ELSE
                          ( @PreviousTxs * 100 / @TXS ) -100
                      END
                  END

          INSERT INTO @Report ( [Merchant], [Gross], [txsQuantity], [GrossVariation], [txsQuantityVariation] )
          VALUES ( @Merchant, @Gross, @TXS, @GrossVar, @txsVar )

          DELETE FROM @UsersId WHERE [idUser] = @ID

        END
      END   

      SET @RESP = CAST((SELECT *, ROW_NUMBER() OVER(ORDER BY [Gross] DESC, [Merchant]) AS [Ranking] FROM @Report FOR JSON PATH) AS XML)
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