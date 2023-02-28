CREATE OR ALTER PROCEDURE [LP_Operation].[CreateReturnTransaction]
                              (
                                @IdTransactionP int,
								@statusName VARCHAR(100)
                              )
AS
BEGIN


BEGIN TRY

BEGIN TRAN
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
	  , @CommissionWithVAT      [LP_Common].[LP_F_DECIMAL]
	  , @merchantId				VARCHAR(60)
	  , @localTax			[LP_Common].[LP_F_DECIMAL]

    SET @TransactionDate = GETDATE()
	SET @statusName = REPLACE(@statusName,'ed','')

	SELECT 
		@idTransactionType = idTransactionType 
	FROM [LP_Configuration].[TransactionType]
	WHERE Code = @statusName

      SELECT
       @TransactionTypeCode    = 'AddBalance'
      , @Description        =  @statusName + ' of the payout'
      , @idEntityUser       = T.idEntityUser
      , @idCurrencyType     = T.CurrencyTypeClient
	  , @Value				= T.GrossValueClient
	  , @ValueConverted		= T.GrossValueLP
	  , @idCurrencyExchange = T.idCurrencyExchange
	  , @idCurrencyBase		= T.idCurrencyBase
	  , @merchantId			= TRD.InternalDescription
	  , @localTax			= ISNULL(TD.LocalTax,0)
	  FROM [LP_Operation].[Transaction] T
	  INNER JOIN [LP_Operation].[TransactionDetail] TD ON T.idTransaction = TD.idTransaction
	  INNER JOIN [LP_Operation].[TransactionRecipientDetail] TRD ON T.idTransaction = TRD.idTransaction
	  WHERE T.idTransaction = @IdTransactionP

	  SET @CommissionWithVAT = (SELECT Commission_With_VAT FROM [LP_Operation].[TransactionDetail] WHERE idTransaction = @IdTransactionP)

      SELECT
           @idEntityAccountDefault  = [EA].[idEntityAccount]
        FROM
          [LP_Entity].[EntityUser]              [EU]
            INNER JOIN [LP_SECURITY].[EntityAccountUser]    [EAU] on [EAU].idEntityUser=[EU].IdEntityUser
            INNER JOIN [LP_Security].[EntityAccount]    [EA]  ON [EA].[idEntityAccount] = [EAU].[idEntityAccount]
        WHERE
          [EU].[Active] = 1
          AND [EA].[Active] = 1
          AND [EA].[IsAdmin] = 1
          AND [EU].[idEntityUser] = @idEntityUser

    SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_MANUAL')

    SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('Executed')
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
        , @BeforeBalanceValueWithOutCommissionLP      [LP_Common].[LP_F_DECIMAL]
        , @BeforeBalanceValueWithOutCommissionClient    [LP_Common].[LP_F_DECIMAL]

      DECLARE
        @Credit_Tax_Porc  [LP_Common].[LP_F_DECIMAL]
        , @fxCreditTax    [LP_Common].[LP_F_DECIMAL]
        , @fxTotalCostRnd [LP_Common].[LP_F_DECIMAL]
        , @fxBalanceFinal [LP_Common].[LP_F_DECIMAL]

      SET @Credit_Tax_Porc = ISNULL([LP_Catalog].[fnGetProviderVariableValue]('VAR::ARG::GENERIC_TRANSACTION.CREDIT_TAX_PORC', @idCountry, @idProvider, @idTransactionType), 0)

	    SELECT  @Base_Sell = [Base_Sell], @Base_Buy = [Base_Buy] 
        FROM [LP_Configuration].[CurrencyBase] 
        WHERE idCurrencyBase = @idCurrencyBase

        SELECT @Value_Exchange_Auto = [Value] 
        FROM [LP_Configuration].[CurrencyExchange]
        WHERE idCurrencyExchange = @idCurrencyExchange

		SET @fxValue_Exchange_Auto = @Value_Exchange_Auto * ( 1 - @Base_Buy / 100.0 )

		SET @fxCreditTax = (@ValueConverted * @Credit_Tax_Porc)
		SET @fxTotalCostRnd = (@fxCreditTax * -1)

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
      VALUES ( CONCAT('000', DATEDIFF(SECOND, '19700101', GETDATE()), 1), '', '', @TransactionDate, NULL, NULL, @idStatus )
      SELECT @idTransactionLot = @@IDENTITY 

      /* INSERT INTO TRANSACTION */
        INSERT INTO [LP_Operation].[Transaction] ( [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [idCurrencyBase], [idCurrencyExchange], [Version], [idTransactionLot], [idEntityUser], [idEntityAccount], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idStatus], [Active], [ProcessedDate],[ReferenceTransaction])
        VALUES ( @TransactionDate, @Value, @idCurrencyType, @ValueConverted, @idCurrencyLP, @idCurrencyBase, @idCurrencyExchange, 1, @idTransactionLot, @idEntityUser, @idEntityAccountDefault, @idTransactionMechanism, @idTransactionTypeProvider, @idProviderPayWayService, @idStatus, 1, @TransactionDate,@merchantId )
        SELECT @idTransaction = @@IDENTITY

      /* INSERT INTO  TRANSACTIONFROMTO */
      INSERT INTO [LP_Operation].[TransactionFromTo] ( [IdTransaction], [FromIdEntityAccount], [ToIdEntityAccount] )
      VALUES ( @idTransaction, 1, @idEntityAccountDefault )

      /* INSERT INTO TRANSACTIONPROVIDER */
      INSERT INTO [LP_Operation].[TransactionProvider] ( [idTransaction], [idProvider], [CreditTax], [TotalCostRnd], [idStatus], [Version] )
      VALUES ( @idTransaction, @idProvider, @fxCreditTax, @fxTotalCostRnd, @idStatus, 1 )

      /* INSERT INTO WALLET */      
      IF(@idCurrencyClient = @idCurrencyLP)
      BEGIN

        SELECT TOP 1 @BeforeBalanceValue = [BalanceLP], @BeforeBalanceValueWithOutCommissionLP = [BalanceLPWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceLP] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceFinalValue = [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

          IF(@BeforeBalanceValue IS NULL)
          BEGIN
            SET @BeforeBalanceValue = @ValueConverted
            SET @BeforeBalanceValueWithOutCommissionLP = @ValueConverted
          END
          ELSE
          BEGIN
            SET @BeforeBalanceValue = @BeforeBalanceValue + @ValueConverted + @CommissionWithVAT + @localTax
            SET @BeforeBalanceValueWithOutCommissionLP = @BeforeBalanceValueWithOutCommissionLP + @ValueConverted + @localTax
          END

        SET @fxBalanceFinal = ISNULL(@BeforeBalanceFinalValue, 0) + @ValueConverted - @fxCreditTax

		  IF (@idCurrencyType = @idCurrencyClient)
		  BEGIN
			     INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceLPWithOutCommission] )
				 VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @idCurrencyLP, @Value, @Value, @BeforeBalanceValue, @idCurrencyClient, NULL, NULL, NULL, @fxBalanceFinal, @BeforeBalanceValueWithOutCommissionLP )
		  END
		  ELSE
		  BEGIN
				INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceLPWithOutCommission] )
				 VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @idCurrencyLP, @ValueConverted, @ValueConverted, @BeforeBalanceValue, @idCurrencyClient, NULL, NULL, NULL, @fxBalanceFinal, @BeforeBalanceValueWithOutCommissionLP )
		  END
      END
      ELSE
      BEGIN

        SELECT TOP 1 @BeforeBalanceValue = [BalanceClient], @BeforeBalanceValueWithOutCommissionClient = [BalanceClientWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 AND [BalanceClient] IS NOT NULL ORDER BY [idWallet] DESC
        SELECT TOP 1 @BeforeBalanceFinalValue = [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

		SELECT @Value = -GrossValueClient,@ValueConverted = -GrossValueClient FROM [LP_Operation].[Wallet] WHERE idTransaction = @IdTransactionP
          IF(@BeforeBalanceValue IS NULL)
          BEGIN
            SET @BeforeBalanceValue = @Value + @CommissionWithVAT + @localTax
            SET @BeforeBalanceValueWithOutCommissionClient = @Value + @localTax
          END
          ELSE
          BEGIN
            SET @BeforeBalanceValue = @BeforeBalanceValue + @Value + @CommissionWithVAT + @localTax
            SET @BeforeBalanceValueWithOutCommissionClient = @BeforeBalanceValueWithOutCommissionClient + @Value + @localTax
          END

        SET @fxBalanceFinal = ISNULL(@BeforeBalanceFinalValue, 0) + @ValueConverted - @fxCreditTax
		INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceClientWithOutCommission])
		VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @idCurrencyLP, NULL, NULL, NULL, @idCurrencyType, @Value, @Value, @BeforeBalanceValue, @fxBalanceFinal, @BeforeBalanceValueWithOutCommissionClient )
      END

      INSERT INTO [LP_Operation].[TransactionDescription] ([idTransaction], [Description]) VALUES(@idTransaction, @Description)
commit tran

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRAN
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