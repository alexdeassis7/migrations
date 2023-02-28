SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [LP_Configuration].[GetCurrencyExchange]
  @currencyBase   [LP_Common].[LP_F_Code]
  , @currencyTo   [LP_Common].[LP_F_Code]
  , @customerId   VARCHAR(12)
  , @transactionType  [LP_Common].[LP_F_Code]
  , @date       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]  = NULL
AS
BEGIN
  DECLARE
    @baseBuy          [LP_Common].[LP_F_DECIMAL]
    , @baseSell         [LP_Common].[LP_F_DECIMAL]
    , @idAdminType        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @idCurrencyBase     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @idCurrencyTo       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @idCountry        BIGINT
    , @idEntityUser       BIGINT
    , @idEntityType       BIGINT
    , @idTransactionOperation BIGINT
    , @Message          VARCHAR(50)
    , @Price          [LP_Common].[LP_F_DECIMAL]
    , @Status         BIT
    , @Timestamp        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @ValidFromDate      DATETIME
    , @ExpirationDate     DATETIME
    , @Value          [LP_Common].[LP_F_DECIMAL]

  SELECT TOP 1
    @idEntityUser = [eu].[idEntityUser]
    , @idEntityType = [eu].[idEntityType]
  FROM [LP_Security].[EntityAccount] ea
    INNER JOIN [LP_Entity].[EntityUser] eu ON [ea].[idEntityUser] = [eu].[idEntityUser]
  WHERE
    [ea].[Active] = 1
    AND [eu].[Active] = 1
    AND [ea].[Identification] = @customerId

  SELECT @idAdminType = [idEntityType] FROM [LP_Entity].[EntityType] WHERE [Code] = 'Admin'

  IF (@idEntityUser IS NOT NULL AND @idEntityType <> @idAdminType)
  BEGIN
    SELECT @idCountry = [LP_Location].[fnGetIdCountyByidEntityUser](@idEntityUser)
    SELECT @idTransactionOperation = [idTransactionOperation] FROM [LP_Configuration].[TransactionOperation] WHERE [Code] = @transactionType
  
    SELECT @idCurrencyBase = [idCurrencyType] FROM [LP_Configuration].[CurrencyType] WHERE [Code] = @currencyBase
    SELECT @idCurrencyTo = [idCurrencyType] FROM [LP_Configuration].[CurrencyType] WHERE [Code] = @currencyTo

    IF (@idCountry IS NOT NULL AND @idTransactionOperation IS NOT NULL)
    BEGIN
      IF (@date IS NOT NULL)
      BEGIN
        SELECT TOP 1
          @baseBuy  = [cb].[Base_Buy],
          @baseSell = [cb].[Base_Sell],
          @timestamp  = [ce].[Timestamp],
          @value    = [ce].[Value],
          @ValidFromDate  = [ce].[ProcessDate],
          @ExpirationDate = DATEADD(MINUTE, 10, [ce].[ProcessDate])
        FROM [LP_Location].[CountryCurrency] cc
          LEFT JOIN [LP_Configuration].[CurrencyType] ct ON [ct].[idCurrencyType] = [cc].[idCurrencyType]
          LEFT JOIN [LP_Configuration].[CurrencyExchange] ce ON [ce].[idCountry] = [cc].[idCountry]
          LEFT JOIN [LP_Configuration].[CurrencyBase] cb ON [cb].[idCountry] = [cc].[idCountry]
            AND [cb].[idCurrencyType] = [ct].[idCurrencyType]
        WHERE
          [ce].[CurrencyBase]     = @idCurrencyBase
          AND [ce].[CurrencyTo]   = @idCurrencyTo
          AND [cc].[idCountry]    = @idCountry
          AND [cb].[idEntityUser]   = @idEntityUser
          AND [cb].[idCurrencyType] = @idCurrencyTo
          AND [cc].[Active]     = 1
          AND [ct].[Active]     = 1
          AND [cb].[Active]     = 1
          AND [ce].[ProcessDate]    < DATEADD(SECOND, @date, '1970')
        ORDER BY [ce].[ProcessDate] DESC
      END
      ELSE
      BEGIN
        SELECT TOP 1
          @baseBuy    = [cb].[Base_Buy],
          @baseSell   = [cb].[Base_Sell],
          @timestamp    = [ce].[Timestamp],
          @value      = [ce].[Value],
          @ValidFromDate  = [ce].[ProcessDate],
          @ExpirationDate = DATEADD(MINUTE, 10, [ce].[ProcessDate])
        FROM [LP_Location].[CountryCurrency] cc
          LEFT JOIN [LP_Configuration].[CurrencyType] ct ON [ct].[idCurrencyType] = [cc].[idCurrencyType]
          LEFT JOIN [LP_Configuration].[CurrencyExchange] ce ON [ce].[idCountry] = [cc].[idCountry]
          LEFT JOIN [LP_Configuration].[CurrencyBase] cb ON [cb].[idCountry] = [cc].[idCountry]
            AND [cb].[idCurrencyType] = [ct].[idCurrencyType]
        WHERE
          [ce].[CurrencyBase]     = @idCurrencyBase
          AND [ce].[CurrencyTo]   = @idCurrencyTo
          AND [cc].[idCountry]    = @idCountry
          AND [cb].[idEntityUser]   = @idEntityUser
          AND [cb].[idCurrencyType] = @idCurrencyTo
          AND [cc].[Active]     = 1
          AND [ct].[Active]     = 1
          AND [ce].[Active]     = 1
          AND [cb].[Active]     = 1
      END

      IF (@value IS NOT NULL)
      BEGIN
        IF (@transactionType = 'PO') OR (@transactionType = 'RF')
        BEGIN
          SET @Price = ((100 - @baseSell) / 100 * @value)
          SET @Message = 'OK'
          SET @Status = 1
        END
        ELSE IF (@transactionType = 'PI')
        BEGIN
          SET @Price = ((100 + @baseBuy) / 100 * @value)
          SET @Message = 'OK'
          SET @Status = 1
        END
        ELSE
        BEGIN
          SET @Message = 'Tipo de transaccion no valida'
          SET @Status = 0
        END
      END
      ELSE
      BEGIN
        SET @Status = 0
        SET @Message = 'Moneda sin valor'
      END
    END
    ELSE
    BEGIN
      SET @Status = 0
      SET @Message = 'Pais no valida o tipo de transaccion no valida'
    END
  END
  ELSE
  BEGIN
    SET @Status = 0
    SET @Message = 'Usuario inexistente o no habilitado'
  END

  SELECT
    [Status] = @Status,
    [Message] = @Message,
    [Price] = @Price,
    [Timestamp] = @Timestamp,
    [SourceQuote] = @value,
    [ValidFromDate] = @ValidFromDate,
    [ExpirationDate] = @ExpirationDate

END
GO
