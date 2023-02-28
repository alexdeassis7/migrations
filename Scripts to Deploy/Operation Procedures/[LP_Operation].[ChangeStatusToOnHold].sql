CREATE OR ALTER PROCEDURE [LP_Operation].[ChangeStatusToOnHold]
                                      (
										@JSON					NVARCHAR(MAX)
                                        ,@countryCode			NVARCHAR(3)
										,@expire_days			INT
                                      )
AS
BEGIN
BEGIN TRY
      DECLARE
         @idTicket           [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransaction        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransactionLot       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idStatusReceived       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idStatusOnHold		  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

        ,@idCountry           [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        ,@idProvider          [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		,@Ticket			  VARCHAR(14)
        ,@DetailStatus        [LP_Common].[LP_F_CODE]

	  DECLARE @ticketTable TABLE (
		ticket VARCHAR(20)
	  )

	  DECLARE @TxsDetail TABLE(
		Ticket VARCHAR(20)
		,TransactionDate DATETIME
		,Amount DECIMAL(18,6)
		,Currency VARCHAR(10)
		,LotNumber BIGINT
		,LotCode VARCHAR(MAX)
		,Recipient VARCHAR(MAX)
		,RecipientCUIT VARCHAR(MAX)
		,RecipientCBU VARCHAR(MAX)
		,RecipientAccountNumber VARCHAR(MAX)
		,AcreditationDate DATETIME
		,Description VARCHAR(MAX)
		,InternalDescription VARCHAR(MAX)
		,ConceptCode VARCHAR(MAX)
		,BankAccountType VARCHAR(MAX)
		,EntityIdentificationType VARCHAR(MAX)
		,InternalStatus VARCHAR(MAX)
		,InternalStatusDescription VARCHAR(MAX)
		,idEntityUser VARCHAR(MAX)
		,TransactionId VARCHAR(MAX)
		,StatusCode VARCHAR(MAX)
	  )

      SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @countryCode AND [Active] = 1)
      SET @idProvider = ( SELECT TOP(1)P.[idProvider] FROM [LP_Configuration].[Provider] P
							INNER JOIN [LP_Configuration].[ProviderPayWayServices] PPWS ON P.idProvider = PPWS.idProvider
							INNER JOIN [LP_Configuration].[PayWayServices] PWS On PWS.idPayWayService = PPWS.idPayWayService
							WHERE P.[idCountry] = @idCountry AND P.[Active] = 1 AND PWS.Code = 'BANKDEPO')

      SET @idStatusReceived = [LP_Operation].[fnGetIdStatusByCode]('Received')
	  SET @idStatusOnHold = [LP_Operation].[fnGetIdStatusByCode]('OnHold')

	  INSERT INTO @ticketTable
	  SELECT * FROM OPENJSON(@JSON)
	  WITH (   
              Ticket   varchar(20) '$'  
			) ;

			SELECT * FROM @ticketTable
	BEGIN TRAN

	DECLARE payout_cursor CURSOR FORWARD_ONLY FOR
	SELECT ticket FROM  @ticketTable

	OPEN payout_cursor;
	FETCH NEXT FROM payout_cursor INTO @ticket

	WHILE @@FETCH_STATUS = 0
	BEGIN

			SELECT
					@idTicket						= NULL
					, @idTransaction				= NULL


      DECLARE @TxIdStatus [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      SET @TxIdStatus = @idStatusOnHold

	  SELECT
			@idTicket           = [T].[idTicket]
			, @idTransaction        = [T2].[idTransaction]
			, @idTransactionLot  = [TL].[idTransactionLot]
		  FROM
			[LP_Operation].[Ticket]                   [T]
			  INNER JOIN [LP_Operation].[Transaction]         [T2]  ON [T].[idTransaction]    = [T2].[idTransaction]
			  INNER JOIN [LP_Operation].[TransactionLot]        [TL]  ON [T2].[idTransactionLot]  = [TL].[idTransactionLot]
		  WHERE
			[T].[Ticket] = @Ticket

        UPDATE  [LP_Operation].[Transaction]
        SET   
          [idStatus]          = @TxIdStatus
		  ,[ExpirationDate]    = DATEADD(day,@expire_days,TransactionDate)
        WHERE 
          [idTransaction] = @idTransaction

        UPDATE  [LP_Operation].[TransactionDetail]
        SET   
          [idStatus] = @TxIdStatus
        WHERE 
          [idTransaction] = @idTransaction

        UPDATE  [LP_Operation].[TransactionRecipientDetail]
        SET   
          [idStatus] = @TxIdStatus
        WHERE 
          [idTransaction] = @idTransaction

        UPDATE  [LP_Operation].[TransactionLot]
        SET   [idStatus] = @TxIdStatus
        WHERE [idTransactionLot] = @idTransactionLot

        UPDATE  [LP_Operation].[TransactionInternalStatus]
        SET   
          [idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'OnHold', 'SCM')
        WHERE 
          [idTransaction] = @idTransaction

		INSERT INTO @TxsDetail
        SELECT
          [Ticket]            = [T].[Ticket]
          , [TransactionDate]       = CONVERT(DATETIME2, [T2].[TransactionDate], 1)
          , [Amount]            = [T2].[GrossValueLP]
          , [Currency]          = [CT].[Code]
          , [LotNumber]         = [TL].[LotNumber]
          , [LotCode]           = [TL].[LotCode]
          , [Recipient]         = [TRD].[Recipient]
          , [RecipientCUIT]       = [TRD].[RecipientCUIT]
          , [RecipientCBU]        = [TRD].[CBU]
          , [RecipientAccountNumber]    = [TRD].[RecipientAccountNumber]
          , [AcreditationDate]      = CONVERT(DATETIME2, [TRD].[TransactionAcreditationDate], 1)
          , [Description]         = [TRD].[Description]
          , [InternalDescription]     = [TRD].[InternalDescription]
          , [ConceptCode]         = [TRD].[ConceptCode]
          , [BankAccountType]       = [BAT].[Code]
          , [EntityIdentificationType]  = [EIT].[Code]
          , [InternalStatus]        = [IS].[Code]
          , [InternalStatusDescription] = [IS].[Description]
          , [idEntityUser]        = [T2].[idEntityUser]
          , [idTransaction]       = @idTransaction
      , [StatusCode]      = [S].[Code]
        FROM
          [LP_Operation].[Ticket]                   [T]
            INNER JOIN [LP_Operation].[Transaction]         [T2]  ON [T].[idTransaction]          = [T2].[idTransaction]
            INNER JOIN [LP_Operation].[TransactionDetail]     [TD]  ON [T2].[idTransaction]         = [TD].[idTransaction]
            INNER JOIN [LP_Operation].[TransactionRecipientDetail]  [TRD] ON [T2].[idTransaction]         = [TRD].[idTransaction]
            INNER JOIN [LP_Operation].[TransactionLot]        [TL]  ON [T2].[idTransactionLot]        = [TL].[idTransactionLot]
            INNER JOIN [LP_Operation].[TransactionInternalStatus] [TIS] ON [T2].[idTransaction]         = [TIS].[idTransaction]
            INNER JOIN [LP_Configuration].[InternalStatus]      [IS]  ON [TIS].[idInternalStatus]       = [IS].[idInternalStatus]
            INNER JOIN [LP_Configuration].[CurrencyType]      [CT]  ON [T2].[CurrencyTypeLP]        = [CT].[idCurrencyType]
            INNER JOIN [LP_Configuration].[CurrencyType]      [CT2] ON [TRD].[idCurrencyType]       = [CT2].[idCurrencyType]
            INNER JOIN [LP_Configuration].[BankAccountType]     [BAT] ON [TRD].[idBankAccountType]      = [BAT].[idBankAccountType]
            INNER JOIN [LP_Entity].[EntityIdentificationType]   [EIT] ON [TRD].[idEntityIdentificationType] = [EIT].[idEntityIdentificationType]
      INNER JOIN [LP_Common].[Status]           [S]  ON [S].[idStatus] = [T2].[idStatus]
        WHERE
          [T].[Ticket] = @Ticket

	FETCH NEXT FROM payout_cursor INTO @ticket
	END
	
	CLOSE payout_cursor;

	DEALLOCATE payout_cursor;
	COMMIT
	SELECT [Ticket] FROM @TxsDetail
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
