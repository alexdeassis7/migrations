CREATE OR ALTER PROCEDURE [LP_Operation].[Reject_Transactions]
                                      (
                                        @Ticket			VARCHAR(15),
										@country_code VARCHAR(3),
										@provider VARCHAR(100),
										@DetailStatus VARCHAR(100)
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
        , @idStatusRejected       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idStatusInProgress     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
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
		, @LPCode VARCHAR(100)


	  SET @LPCode = @DetailStatus
      SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('Executed')
      SET @idStatusRejected = [LP_Operation].[fnGetIdStatusByCode]('Rejected')
      SET @idStatusInProgress = [LP_Operation].[fnGetIdStatusByCode]('InProgress')

      SET @TransactionDate = GETDATE()

      SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @country_code AND [Active] = 1 )
      SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = @provider AND [idCountry] = @idCountry AND [Active] = 1 )
	  SET @DetailStatus = (SELECT  TOP(1) [IS].[Code]
							FROM [LP_Configuration].[InternalStatus] [IS]
							INNER JOIN [LP_Configuration].[Provider] [P] ON [P].[idProvider] = [IS].[idProvider]
							INNER JOIN [LP_Configuration].[LPInternalStatusClient] [ISC] ON [ISC].[idInternalStatus] = [IS].[idInternalStatus]
							INNER JOIN [LP_Configuration].[LPInternalError] [IE] ON [ISC].[idLPInternalError] = [IE].[idLPInternalError]
							WHERE [IE].[Code] = @DetailStatus AND [P].[idCountry] = @idCountry AND [P].[idProvider] = @idProvider)
	  
      DECLARE @TxIdStatus [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


	    SET @isError =
            (
            SELECT
                [is].[isError]
            FROM
                [LP_Configuration].[InternalStatus] [is]
                INNER JOIN [LP_Configuration].[InternalStatusType] [ist] ON [is].[idInternalStatusType] = [ist].[idInternalStatusType]
            WHERE
                [is].[idCountry] = @idCountry
                AND [is].[idProvider] = @idProvider
                AND [is].[Active] = 1
                AND [is].[Code] = @DetailStatus
                AND [ist].[Code] = 'SCM'
                AND [ist].[Active] = 1
            )

		SET @TxIdStatus = 
              ( 
                CASE
                    WHEN @isError = 1 THEN @idStatusRejected
                    WHEN @isError = 0 THEN @idStatus
                    ELSE @idStatusInProgress
                END 
              )
     

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
			AND T2.idStatus = @idStatusInProgress

        IF(@StatusTransaction = @idStatusInProgress)
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
            ,[ProcessedDate]      = @TransactionDate
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

			UPDATE [LP_Operation].[BankPreRegisterBankAccount]
			SET [Deleted] = 1
			WHERE [AccountNumber] = @accountNumber


		IF (@LPCode = '718' AND @idCountry = 49)
		BEGIN 
			IF NOT EXISTS (
				SELECT * FROM [LP_Configuration].[BlackList] BL
				INNER JOIN [LP_Operation].[TransactionRecipientDetail] TRD ON TRD.Recipient = BL.BeneficiaryName AND TRD.RecipientCUIT = BL.DocumentId AND TRD.RecipientAccountNumber = BL.AccountNumber
				WHERE TRD.idTransaction = @idTransaction
			)
			BEGIN
				INSERT INTO [LP_Configuration].[BlackList] (BeneficiaryName,DocumentId,AccountNumber)
				SELECT Recipient,RecipientCUIT,RecipientAccountNumber FROM [LP_Operation].[TransactionRecipientDetail] WHERE idTransaction = @idTransaction
			END
		END
		IF(@isError = 0)
          BEGIN

		  IF(@country_code = 'ARG')
		  BEGIN
			/* INSERT INTO LP_Retentions_ARG.TransactionCertificate: SI RETIENEN GANANCIAS ==> SE CREA EL CERTIFICADO DE AFIP */
			INSERT INTO [LP_Retentions_ARG].[TransactionCertificate] ( [idTransaction], [FileName], [idFileType] )
			SELECT [T].[idTransaction], [LP_Retentions_ARG].[fnGetCertificateNumber]([T].[idTransaction],1),1
			FROM
			[LP_Operation].[Transaction] [T]
				INNER JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
			WHERE
			[T].[idTransaction] = @idTransaction
			AND [T].[Active] = 1
			AND ([TD].[TaxWithholdings] IS NOT NULL AND [TD].[TaxWithholdings] > 0) 


			/* INSERT INTO LP_Retentions_ARG.TransactionCertificate: SI RETIENEN GANANCIAS ==> SE CREA EL CERTIFICADO DE ARBA */
			INSERT INTO [LP_Retentions_ARG].[TransactionCertificate] ( [idTransaction], [FileName],[idFileType]  )
			SELECT [T].[idTransaction], [LP_Retentions_ARG].[fnGetCertificateNumber]([T].[idTransaction],2),2
			FROM
			[LP_Operation].[Transaction] [T]
				INNER JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
			WHERE
			[T].[idTransaction] = @idTransaction
			AND [T].[Active] = 1
			AND ([TD].[TaxWithholdingsARBA] IS NOT NULL AND [TD].[TaxWithholdingsARBA] > 0)
		  END

          /* REFRESCAR WALLET */
            DECLARE
              @idCurrencyTypeLP       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
              , @idCurrencyTypeClient     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
              , @Value_Spot         [LP_Common].[LP_F_DECIMAL]
              , @Base_Buy           [LP_Common].[LP_F_DECIMAL]
              , @ValueFX            [LP_Common].[LP_F_DECIMAL]
              , @BeforeValueBalance     [LP_Common].[LP_F_DECIMAL]
              , @BeforeBalanceFinalValue    [LP_Common].[LP_F_DECIMAL]
              , @SignMultiply         [LP_Common].[LP_F_INT]
              , @BeforeValueBalanceWithOutCommission    [LP_Common].[LP_F_DECIMAL]

            SET @SignMultiply = -1

            SELECT
              @idCurrencyTypeLP   = [idCurrencyTypeLP]
              , @idCurrencyTypeClient = [idCurrencyTypeClient]
            FROM
              [LP_Entity].[EntityCurrencyExchange]
            WHERE
              [idEntityUser] = @idEntityUser
              AND [Active] = 1

          SET @idTransactionOperation =
                            (
                              SELECT
                                [TRO].[idTransactionOperation]
                              FROM
                                [LP_Configuration].[TransactionType]            [TT]
                                  INNER JOIN [LP_Configuration].[TransactionGroup]    [TG]  ON [TT].[idTransactionGroup]    = [TG].[idTransactionGroup]
                                  INNER JOIN [LP_Configuration].[TransactionOperation]  [TRO] ON [TG].[idTransactionOperation]  = [TRO].[idTransactionOperation]
                              WHERE
                                [TT].[Code] = 'PODEPO'
                                AND [TT].[Active] = 1
                                AND [TG].[Active] = 1
                                AND [TRO].[Active] = 1
                            )

          SET @BeforeBalanceFinalValue = (SELECT TOP 1 [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC)

            IF(@BeforeBalanceFinalValue IS NULL)
            BEGIN
              SET @BeforeBalanceFinalValue = (@NetAmount * @SignMultiply) - @ProvVAT - @ProvCommission - @ProvGrossRevenue - @ProvDebitTax - @ProvCreditTax
            END
            ELSE
            BEGIN
              SET @BeforeBalanceFinalValue = @BeforeBalanceFinalValue - @NetAmount - @ProvVAT - @ProvCommission - @ProvGrossRevenue - @ProvDebitTax - @ProvCreditTax
            END
    
            IF(@idCurrencyTypeClient <> @idCurrencyTypeLP) /* MONEDA NO LOCAL */
            BEGIN
              SET @Value_Spot = (SELECT [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [idCurrencyExchange] = @idCurrencyExchange)
              SET @Base_Buy = (SELECT [Base_Buy] FROM [LP_Configuration].[CurrencyBase] WHERE [idCurrencyBase] = @idCurrencyBase)
              SET @ValueFX = @Value_Spot * (1 - @Base_Buy / 100)

              SELECT TOP 1 @BeforeValueBalance = [BalanceClient], @BeforeValueBalanceWithOutCommission = [BalanceClientWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [BalanceClient] IS NOT NULL AND [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

              IF(@BeforeValueBalance IS NULL)
              BEGIN
                SET @BeforeValueBalance = ROUND(((@GrossAmount / @ValueFX) * @SignMultiply), 2) - @CommissionWithVAT - @LocalTax--(@LocalTax / @ValueFX)
                SET @BeforeValueBalanceWithOutCommission = ROUND(((@GrossAmount / @ValueFX) * @SignMultiply), 2) - @LocalTax--(@LocalTax / @ValueFX)
              END
              ELSE
              BEGIN

                IF(SIGN(CAST(@BeforeValueBalance AS INT)) = -1)
                BEGIN
                  SET @BeforeValueBalance = @BeforeValueBalance - ROUND(((@GrossAmount / @ValueFX)), 2) - @CommissionWithVAT - @LocalTax--(@LocalTax / @ValueFX)
                END
                ELSE
                BEGIN
                  SET @BeforeValueBalance = @BeforeValueBalance + ROUND(((@GrossAmount / @ValueFX) * @SignMultiply), 2) - @CommissionWithVAT - @LocalTax--(@LocalTax / @ValueFX)
                END

                IF(SIGN(CAST(@BeforeValueBalanceWithOutCommission AS INT)) = -1)
                BEGIN
                  SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission - ROUND(((@GrossAmount / @ValueFX)), 2)- @LocalTax--(@LocalTax / @ValueFX)
                END
                ELSE
                BEGIN
                  SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission + ROUND(((@GrossAmount / @ValueFX) * @SignMultiply), 2) - @LocalTax--(@LocalTax / @ValueFX)
                END
              END

              INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceClientWithOutCommission] )
              VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @idCurrencyTypeLP, NULL, NULL, NULL, @idCurrencyTypeClient, ROUND((@GrossAmount / @ValueFX)* @SignMultiply, 2), ROUND((@NetAmount / @ValueFX) * @SignMultiply, 2), @BeforeValueBalance, @BeforeBalanceFinalValue, @BeforeValueBalanceWithOutCommission )

            END
            ELSE /* MONEDA LP */
            BEGIN
              SELECT TOP 1 @BeforeValueBalance = [BalanceLP], @BeforeValueBalanceWithOutCommission = [BalanceLPWithOutCommission]  FROM [LP_Operation].[Wallet] WHERE [BalanceLP] IS NOT NULL AND [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

              IF(@BeforeValueBalance IS NULL)
              BEGIN
                SET @BeforeValueBalance = (@GrossAmount * @SignMultiply) - @CommissionWithVAT - @LocalTax
                SET @BeforeValueBalanceWithOutCommission = (@GrossAmount * @SignMultiply) - @LocalTax
              END
              ELSE
              BEGIN

                IF(SIGN(CAST(@BeforeValueBalance AS INT)) = -1)
                BEGIN
                  SET @BeforeValueBalance = @BeforeValueBalance - @GrossAmount - @CommissionWithVAT - @LocalTax
                END
                ELSE
                BEGIN
                  SET @BeforeValueBalance = @BeforeValueBalance + (@GrossAmount * @SignMultiply) - @CommissionWithVAT - @LocalTax
                END

                IF(SIGN(CAST(@BeforeValueBalanceWithOutCommission AS INT)) = -1)
                BEGIN
                  SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission - @GrossAmount - @LocalTax
                END
                ELSE
                BEGIN
                  SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission + (@GrossAmount * @SignMultiply) - @LocalTax
                END
              END

              INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceLPWithOutCommission] )
              VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @idCurrencyTypeLP, (@GrossAmount* @SignMultiply), (@NetAmount * @SignMultiply), @BeforeValueBalance, @idCurrencyTypeClient, NULL, NULL, NULL, @BeforeBalanceFinalValue, @BeforeValueBalanceWithOutCommission )
            END
          END

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


