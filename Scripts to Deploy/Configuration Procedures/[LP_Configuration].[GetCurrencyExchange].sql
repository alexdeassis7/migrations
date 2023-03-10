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
	, @idCurrencyExchange       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
	, @fxPeriod INT
	, @currentHourProcess DATETIME
	, @processDate DATETIME

	 SELECT @idCountry = [LP_Location].fnGetIdCountyByCountryCode(@currencyTo)

  SELECT TOP 1
    @idEntityUser = [eu].[idEntityUser]
    , @idEntityType = [eu].[idEntityType]
	, @fxPeriod = eu.FxPeriod
  FROM [LP_Security].[EntityAccount] ea
    INNER JOIN [LP_Security].[EntityAccountUser] eaus ON ea.idEntityAccount = eaus.idEntityAccount
    INNER JOIN [LP_Entity].[EntityUser] eu ON [eaus].[idEntityUser] = [eu].[idEntityUser]
  WHERE
    [ea].[Active] = 1
    AND [eu].[Active] = 1
    AND [ea].[Identification] = @customerId
	AND [eu].idCountry = @idCountry

	SELECT @currentHourProcess = CAST(CAST(GETDATE() AS DATE) AS DATETIME)+CAST(DATEPART(HOUR,GETDATE()) AS FLOAT)/24

	SELECT @idCurrencyBase = [idCurrencyType] FROM [LP_Configuration].[CurrencyType] WHERE [Code] = @currencyBase
    SELECT @idCurrencyTo = [idCurrencyType] FROM [LP_Configuration].[CurrencyType] WHERE [Code] = @currencyTo

	SELECT @idCurrencyExchange = [LP_Configuration].[fnGetCurrencyExchangeByEnityUserId](@idEntityUser,@idCurrencyTo)

  SELECT @idAdminType = [idEntityType] FROM [LP_Entity].[EntityType] WHERE [Code] = 'Admin'

  IF (@idEntityUser IS NOT NULL AND @idEntityType <> @idAdminType)
  BEGIN
    SELECT @idTransactionOperation = [idTransactionOperation] FROM [LP_Configuration].[TransactionOperation] WHERE [Code] = @transactionType
  

    IF (@idCountry IS NOT NULL AND @idTransactionOperation IS NOT NULL)
    BEGIN
      IF (@date IS NOT NULL)
      BEGIN
		 SELECT TOP 1
          @baseBuy  = [cb].[Base_Buy],
          @baseSell = [cb].[Base_Sell],
          @timestamp  = [ce].[Timestamp],
          @value    = [ce].[Value],
		  @processDate = [ce].[ProcessDate]
		  FROM 
			[LP_Configuration].[CurrencyBase] cb
			INNER JOIN [LP_Configuration].CurrencyExchange ce ON ce.idCurrencyExchange = @idCurrencyExchange
		  WHERE 
				[cb].[Active]     = 1
				AND [cb].[idCountry]    = @idCountry
				AND [cb].idCurrencyType = @idCurrencyTo
				AND cb.idEntityUser = @idEntityUser
		   ORDER BY [ce].[ProcessDate] DESC
      END
      ELSE
      BEGIN
	  	SELECT top 1
            @baseBuy    = [cb].[Base_Buy],
            @baseSell   = [cb].[Base_Sell],
            @timestamp    = [ce].[Timestamp],
			@value      =[ce].[Value],
		  @processDate =[ce].[ProcessDate]
        FROM  [LP_Configuration].[CurrencyBase] cb
		INNER JOIN [LP_Configuration].CurrencyExchange ce ON ce.idCurrencyExchange = @idCurrencyExchange
		WHERE 
		[cb].[Active]     = 1
		AND [cb].[idCountry]    = @idCountry
		AND [cb].idCurrencyType = @idCurrencyTo
		AND cb.idEntityUser = @idEntityUser
		ORDER BY [ce].[ProcessDate] DESC
      END

      IF (@value IS NOT NULL)
      BEGIN

	  	SET @ValidFromDate  = @processDate

		IF @fxPeriod > 1 
			BEGIN
				SET @ExpirationDate = DATEADD(HOUR,1,@currentHourProcess)
			END
		ELSE
			BEGIN
				SET @ExpirationDate = DATEADD(MINUTE, 1, @ValidFromDate)
			END

        IF (@transactionType = 'PO') OR (@transactionType = 'RF')
        BEGIN
			SET @Price = @value * (100 - @baseBuy) / 100
          SET @Message = 'OK'
          SET @Status = 1
        END
        ELSE IF (@transactionType = 'PI')
        BEGIN
          SET @Price = @value * (100 + @baseSell) / 100
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
