CREATE OR ALTER PROCEDURE [LP_Operation].[Return_Transactions]
                                      (
                                        @Ticket			VARCHAR(15),
										@country_code VARCHAR(3),
										@provider VARCHAR(100),
										@statusName VARCHAR(100)
                                      )
AS
BEGIN

  BEGIN TRY

    DECLARE
        @idStatus           [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransactionMechanism   [LP_Common].[LP_F_INT]
        , @idTicket           [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransaction        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransactionDetail      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransactionRecipientDetail [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransactionLot       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idStatusReturned       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @isError            [LP_Common].[LP_F_BOOL]
        , @idEntityUser         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idCurrencyExchange     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idCurrencyBase       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

        , @GrossAmount          [LP_Common].[LP_F_DECIMAL]
        , @NetAmount          [LP_Common].[LP_F_DECIMAL]
        , @CommissionWithVAT      [LP_Common].[LP_F_DECIMAL]
        , @LocalTax           [LP_Common].[LP_F_DECIMAL]

        , @TransactionDate        [LP_Common].[LP_A_OP_INSDATETIME]
        , @idTransactionOperation   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        
        ,@idCountry           [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        ,@idProvider          [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

        , @ProvVAT            [LP_Common].[LP_F_DECIMAL]
        , @ProvCommission       [LP_Common].[LP_F_DECIMAL]
        , @ProvGrossRevenue       [LP_Common].[LP_F_DECIMAL]
        , @ProvDebitTax         [LP_Common].[LP_F_DECIMAL]
        , @ProvCreditTax        [LP_Common].[LP_F_DECIMAL]

        , @idCurrencyLP         [LP_Common].[LP_F_INT]
        , @idCurrencyClient       [LP_Common].[LP_F_INT]
        , @CurrencyClose        [LP_Common].[LP_F_INT]

        , @StatusTransaction      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @accountNumber VARCHAR(100)
		, @DetailStatus VARCHAR(100)

      SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('Executed')
      SET @idStatusReturned = [LP_Operation].[fnGetIdStatusByCode](@statusName)

      SET @TransactionDate = GETDATE()

      SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @country_code AND [Active] = 1 )
      SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = @provider AND [idCountry] = @idCountry AND [Active] = 1 )
	 SET @DetailStatus = (SELECT  TOP(1) [IS].[Code]
							FROM [LP_Configuration].[InternalStatus] [IS]
							INNER JOIN [LP_Configuration].[Provider] [P] ON [P].[idProvider] = [IS].[idProvider]
							--INNER JOIN [LP_Configuration].[LPInternalStatusClient] [ISC] ON [ISC].[idInternalStatus] = [IS].[idInternalStatus]
							--INNER JOIN [LP_Configuration].[LPInternalError] [IE] ON [ISC].[idLPInternalError] = [IE].[idLPInternalError]
							WHERE [IS].[Code] = @statusName AND [P].[idCountry] = @idCountry AND [P].[idProvider] = @idProvider)
	  

      DECLARE @TxIdStatus [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


		SET @TxIdStatus = @idStatusReturned
     

        SELECT
          @idTicket           = [T].[idTicket]
          , @idTransaction        = [T2].[idTransaction]
          , @idTransactionDetail      = [TD].[idTransactionDetail]
          , @idTransactionRecipientDetail = [TRD].[idTransactionRecipientDetail]
          , @idTransactionLot       = [TL].[idTransactionLot]
          , @idEntityUser         = [T2].[idEntityUser]

          , @idCurrencyExchange     = [T2].[idCurrencyExchange]
          , @idCurrencyBase       = [T2].[idCurrencyBase]

          , @GrossAmount          = ISNULL([TD].[GrossAmount], 0)
          , @NetAmount          = ISNULL([TD].[NetAmount], 0)
          , @CommissionWithVAT      = ISNULL([TD].[Commission_With_VAT], 0)
          , @LocalTax           = ISNULL([TD].[LocalTax], 0)

          , @ProvVAT            = ISNULL(TP.VAT, 0)
          , @ProvCommission       = ISNULL(TP.Commission, 0)
          , @ProvGrossRevenue       = ISNULL(TP.Gross_Revenue_Perception_CABA, 0) --Ver
          , @ProvDebitTax         = ISNULL(TP.DebitTax, 0)
          , @ProvCreditTax        = ISNULL(TP.CreditTax, 0)

          , @StatusTransaction      = [T2].[idStatus]
		  , @Ticket					= [T].[Ticket]
		  , @accountNumber			= [TRD].[RecipientAccountNumber]
        FROM
          [LP_Operation].[Ticket]                   [T]
            INNER JOIN [LP_Operation].[Transaction]         [T2]  ON  [T].[idTransaction]   = [T2].[idTransaction]
            INNER JOIN [LP_Operation].[TransactionDetail]     [TD]  ON  [T2].[idTransaction]  = [TD].[idTransaction]
            INNER JOIN [LP_Operation].[TransactionRecipientDetail]  [TRD] ON  [T2].[idTransaction]  = [TRD].[idTransaction]
            INNER JOIN [LP_Operation].[TransactionLot]        [TL]  ON  [T2].[idTransactionLot] = [TL].[idTransactionLot]
            INNER JOIN [LP_Operation].[TransactionProvider]     [TP]  ON  [T2].[idTransaction]  = [TP].[idTransaction]
			LEFT JOIN [LP_Operation].[BankPreRegisterBankAccount] [BT] ON [BT].AccountNumber = [TRD].[RecipientAccountNumber]
        WHERE
			[T].[Ticket] = @Ticket
			AND T2.idStatus = @idStatus


        IF(@StatusTransaction = @idStatus)
        BEGIN

          BEGIN TRANSACTION

          SELECT
            @idCurrencyLP   = [ECE].[idCurrencyTypeLP]
            , @idCurrencyClient = [ECE].[idCurrencyTypeClient]
          FROM
            [LP_Entity].[EntityCurrencyExchange] [ECE]
          WHERE
            [ECE].[idEntityUser] = @idEntityUser
            AND [ECE].[Active] = 1
  
        SET @CurrencyClose = ( SELECT TOP 1 [CE].[idCurrencyExchange] FROM [LP_Configuration].[CurrencyExchange] [CE] WHERE [CE].[Active] = 1 AND [CE].[ActionType] = 'A' AND [CE].[CurrencyTo] = @idCurrencyClient ORDER BY idCurrencyExchange DESC )

          UPDATE  [LP_Operation].[Transaction]
          SET   
            [idStatus]          = @TxIdStatus
            ,[idCurrencyExchangeClosed] = @CurrencyClose
          WHERE 
            [idTransaction] = @idTransaction

          UPDATE  [LP_Operation].[TransactionDetail]
          SET   
            [idStatus] = @TxIdStatus
                
          WHERE 
            [idTransactionDetail] = @idTransactionDetail

          UPDATE  [LP_Operation].[TransactionRecipientDetail]
          SET   
            [idStatus] = @TxIdStatus
          WHERE 
            [idTransactionRecipientDetail] = @idTransactionRecipientDetail
    
          UPDATE  [LP_Operation].[TransactionLot]
          SET   
            [idStatus] = @TxIdStatus
          WHERE 
            [idTransactionLot] = @idTransactionLot

          UPDATE  [LP_Operation].[TransactionInternalStatus]
          SET   
            [idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, @DetailStatus, 'SCM')
          WHERE 
            [idTransaction] = @idTransaction
			-- CREAR RETURN TXS
			EXEC [LP_Operation].[CreateReturnTransaction] @idTransaction, @statusName

          COMMIT TRAN

          SELECT
            [Ticket]            = [T].[Ticket]
            , [TransactionDate]       = CONVERT(DATETIME2, [T2].[TransactionDate], 1)
            , [Amount]            = [T2].[GrossValueLP]
            , [Currency]          = [CT].[Code]
            , [LotNumber]         = [TL].[LotNumber]
            , [LotCode]           = [TL].[LotCode]
            , [Recipient]         = [TRD].[Recipient]
            , [RecipientId]         = [TRD].[RecipientCUIT]
            , [RecipientAccountNumber]    = [TRD].[RecipientAccountNumber]
            , [AcreditationDate]      = CONVERT(DATETIME2, [TRD].[TransactionAcreditationDate], 1)
            , [Description]         = [TRD].[Description]
            , [InternalDescription]     = [TRD].[InternalDescription]
            , [ConceptCode]         = [TRD].[ConceptCode]
            , [BankAccountType]       = [BAT].[Code]
            , [EntityIdentificationType]  = [EIT].[Code]
            , [InternalStatus]        = [IS].[Code]
            , [InternalStatusDescription] = [IS].[Description]
            , [idEntityUser]        = @idEntityUser
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

        END
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
GO


