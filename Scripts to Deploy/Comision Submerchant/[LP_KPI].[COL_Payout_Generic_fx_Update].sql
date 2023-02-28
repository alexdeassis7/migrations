SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [LP_KPI].[COL_Payout_Generic_fx_Update]
                            (
                              @idTransactionLot   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
                            )
AS
BEGIN

  BEGIN TRY
    BEGIN TRANSACTION

      --SELECT [OK] = 0

      DECLARE   
        @Value              [LP_Common].[LP_F_DECIMAL]
        , @idTransaction        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idCountry          [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransactionType      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idEntityUser         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idProvider         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idStatus           [LP_Common].[LP_F_INT]
        , @idCurrencyExchange     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idCurrencyBase       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @Active           [LP_Common].[LP_A_ACTIVE]
        , @Version            [LP_Common].[LP_F_INT]
        , @TransactionDate        [LP_Common].[LP_A_DB_INSDATETIME]
        , @fxValue            [LP_Common].[LP_F_DECIMAL]
        , @Spread_fxValue_Buy     [LP_Common].[LP_F_DECIMAL]
        , @Spread_fxValue_Sell      [LP_Common].[LP_F_DECIMAL]
        , @RecipientCUIT        [LP_Common].[LP_F_C12]
        , @qtyTransactionLot      [LP_Common].[LP_F_INT]
        , @qtyTransactions        [LP_Common].[LP_F_INT]
        , @idxTransaction       [LP_Common].[LP_F_INT]
        , @General_VAT_D        [LP_Common].[LP_F_DECIMAL]
        , @General_VAT_M        [LP_Common].[LP_F_DECIMAL]
        , @ClientCommission       [LP_Common].[LP_F_DECIMAL]
        , @ClientDebitTaxGMF      [LP_Common].[LP_F_DECIMAL]
        , @fxClientNet          [LP_Common].[LP_F_DECIMAL]
        , @fxClientVAT          [LP_Common].[LP_F_DECIMAL]
        , @fxClientCommissionWithVAT  [LP_Common].[LP_F_DECIMAL]
        , @fxClientDebitTaxGMF      [LP_Common].[LP_F_DECIMAL]
        , @ProviderCommission     [LP_Common].[LP_F_DECIMAL]          
        , @ProviderPorcDebitTax     [LP_Common].[LP_F_DECIMAL]
        , @fxProviderVAT        [LP_Common].[LP_F_DECIMAL]    
        , @fxProviderCommissionWithVAT  [LP_Common].[LP_F_DECIMAL]
        , @fxProviderGrossRevenue   [LP_Common].[LP_F_DECIMAL]
        , @fxProviderProfitPerception [LP_Common].[LP_F_DECIMAL]
        , @fxProviderPerceptionVAT    [LP_Common].[LP_F_DECIMAL]  
        , @fxProviderDebitTax     [LP_Common].[LP_F_DECIMAL]
        , @fxProviderCreditTax      [LP_Common].[LP_F_DECIMAL]
        , @fxProviderTotalCostRdo   [LP_Common].[LP_F_DECIMAL]
        , @fxProviderTotalVAT     [LP_Common].[LP_F_DECIMAL]
        , @TotNetAmount         [LP_Common].[LP_F_DECIMAL]
        , @SysCurrencyLP        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @SysCurrencyClient      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @WithRetentions       [LP_Common].[LP_F_BOOL]
        , @idSubMerchant        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

      DECLARE @tempTransactions TABLE 
      (
        [idx]             [LP_Common].[LP_F_INT]            IDENTITY(1, 1)
        , [idTransaction]       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [TransactionDate]       [LP_Common].[LP_A_OP_INSDATETIME]
        , [GrossValueClient]      [LP_Common].[LP_F_DECIMAL]
        , [CurrencyTypeClient]      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [GrossValueLP]        [LP_Common].[LP_F_DECIMAL]
        , [CurrencyTypeLP]        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [Version]           [LP_Common].[LP_F_INT]
        , [idTransactionLot]      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [idEntityUser]        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [idEntityAccount]       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [idTransactionMechanism]    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [idTransactionTypeProvider] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [idProviderPayWayService]   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [idStatus]          [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [Active]            [LP_Common].[LP_A_ACTIVE]
        , [idCurrencyBase]        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , [idCurrencyExchange]      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      )

      SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('Received')

      SET @qtyTransactionLot = (SELECT COUNT(*) FROM [LP_Operation].[TransactionLot] [TL] WHERE [TL].[idTransactionLot] = @idTransactionLot AND [TL].[Active] = 1)

      INSERT INTO @tempTransactions ( [idTransaction], [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [Version], [idTransactionLot], [idEntityUser], [idEntityAccount], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idStatus], [Active], [idCurrencyBase], [idCurrencyExchange] )
      SELECT [idTransaction], [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [Version], [idTransactionLot], [idEntityUser], [idEntityAccount], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idStatus], [Active], [idCurrencyBase], [idCurrencyExchange]
      FROM [LP_Operation].[Transaction]
      WHERE [idTransactionLot] = @idTransactionLot AND [Active] = 1

      SET @qtyTransactions = (SELECT COUNT(*) FROM @tempTransactions)
      SET @idxTransaction = 1

      IF(@qtyTransactionLot = 1 AND @qtyTransactions >= 1)
      BEGIN
        WHILE(@idxTransaction <= @qtyTransactions)
          BEGIN

            IF(@idxTransaction = 1)
            BEGIN

            SELECT
              @idEntityUser     = [TT].[idEntityUser]
              , @idTransactionType  = [TTP].[idTransactionType]
              , @idProvider     = [TTP].[idProvider]
            FROM
              @tempTransactions [TT]
                INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TT].[idTransactionTypeProvider] = [TTP].[idTransactionTypeProvider]
            WHERE
              [TT].[idx] = @idxTransaction

            --SET @idCountry = [LP_Location].[fnGetIdCountyByidEntityUser](@idEntityUser)
            SET @idCountry = [LP_Location].[fnGetIdCountyByCountryCode]('COP')

            SELECT
              @SysCurrencyLP      = [idCurrencyTypeLP]
              , @SysCurrencyClient  = [idCurrencyTypeClient]
            FROM
              [LP_Entity].[EntityCurrencyExchange]
            WHERE
              [idEntityUser] = @idEntityUser
          END


          SELECT
            @Value          = ISNULL([TT].[GrossValueLP], 0)
            , @idTransaction    = [TT].[idTransaction]
            , @TransactionDate    = [TT].[TransactionDate]
            , @RecipientCUIT    = [TRD].[RecipientCUIT]
            , @idCurrencyBase   = [TT].[idCurrencyBase]
            , @idCurrencyExchange = [TT].[idCurrencyExchange]
          FROM
            @tempTransactions [TT]
              INNER JOIN [LP_Operation].[TransactionRecipientDetail] [TRD] ON [TT].[idTransaction] = [TRD].[idTransaction]
          WHERE
            [TT].[idx] = @idxTransaction

          SELECT                  
            @idSubMerchant  = [ESM].[idEntitySubMerchant]
          FROM
            [LP_Operation].[TransactionEntitySubMerchant] [TESM]
              INNER JOIN [LP_Entity].[EntitySubMerchant]  [ESM] ON [ESM].[idEntitySubMerchant] = [TESM].[idEntitySubMerchant]
          WHERE
            [TESM].[idTransaction] = @idTransaction
            AND [TESM].[Active] = 1
            AND [ESM].[Active] = 1

          SET @Spread_fxValue_Buy = ( SELECT [Base_Buy] FROM [LP_Configuration].[CurrencyBase] WHERE [idCurrencyBase] = @idCurrencyBase )
          SET @fxValue = ( SELECT [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [idCurrencyExchange] = @idCurrencyExchange ) * ( 1 - @Spread_fxValue_Buy / 100.0 )

          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
          /* GENERAL VALUES ----------------------------------------------------------------------------------------------------------------------------------------- */
          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
          SET @General_VAT_D        = ISNULL([LP_Catalog].[fnGetClientVariableValue]('VAR::COL::GENERAL.IVA_D', @idCountry, @idEntityUser, @idTransactionType, NULL, NULL), 0)
          SET @General_VAT_M        = ISNULL([LP_Catalog].[fnGetClientVariableValue]('VAR::COL::GENERAL.IVA_M', @idCountry, @idEntityUser, @idTransactionType, NULL, NULL), 0)

          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
          /* CLIENT ------------------------------------------------------------------------------------------------------------------------------------------------- */
          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */

          --SET @ClientCommission   = ROUND(ISNULL([LP_Catalog].[fnGetClientVariableValue]('VAR::COL::BANK_DEPOSIT.COMISION', @idCountry, @idEntityUser, @idTransactionType, @fxValue, @Value), 0) / @General_VAT_D, 2)
          SET @ClientCommission   = ROUND(ISNULL([LP_Catalog].[fnGetCommissionBySubMerchant](@idSubMerchant), 0) / @General_VAT_D, 2)
          SET @ClientDebitTaxGMF    = ISNULL([LP_Catalog].[fnGetClientVariableValue]('VAR::COL::BANK_DEPOSIT.IMPUESTO_GMF', @idCountry, @idEntityUser, @idTransactionType, NULL, NULL), 0)

          SET @fxClientVAT        = ROUND(@ClientCommission * @General_VAT_M, 2)
          SET @fxClientCommissionWithVAT  = @ClientCommission + @fxClientVAT
          SET @fxClientNet        = @Value
          SET @fxClientDebitTaxGMF    = ROUND(( @Value * @ClientDebitTaxGMF ) / @fxValue, 2)

          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
          /* PROVEEDOR ---------------------------------------------------------------------------------------------------------------------------------------------- */
          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */

          SET @ProviderCommission   = ISNULL([LP_Catalog].[fnGetProviderVariableValue]('VAR::COL::BANK_DEPOSIT.COSTO_BANCO', @idCountry, @idProvider, @idTransactionType), 0)
          --SET @ProviderPorcIIBB   = ISNULL([LP_Catalog].[fnGetProviderVariableValue]('VAR::ARG::BANK_DEPOSIT.PERCEPCION_IIBB', @idCountry, @idProvider, @idTransactionType), 0)
          SET @ProviderPorcDebitTax = NULL /* ISNULL([LP_Catalog].[fnGetProviderVariableValue]('VAR::COL::BANK_DEPOSIT.IMPUESTO_GMF', @idCountry, @idProvider, @idTransactionType), 0) */

          SET @fxProviderVAT          = ROUND(@ProviderCommission * @General_VAT_M, 2)
          SET @fxProviderCommissionWithVAT  = @ProviderCommission + @fxProviderVAT
          SET @fxProviderDebitTax       = NULL /*(@Value + @fxProviderCommissionWithVAT) * @ProviderPorcDebitTax*/
          SET @fxProviderCreditTax      = NULL

          /* VALIDAR TIPO CURRENCY LP VS CLIENT*/

          IF(@SysCurrencyLP = @SysCurrencyClient)
          BEGIN
            SET @fxProviderTotalCostRdo   = @ClientCommission - @ProviderCommission - ISNULL(@fxProviderDebitTax, 0) - ISNULL(@fxProviderCreditTax, 0)
            SET @fxProviderTotalVAT     = @fxClientVAT - @fxProviderVAT
          END
          ELSE
          BEGIN
            SET @fxProviderTotalCostRdo   = ROUND((@ClientCommission * @fxValue) - @ProviderCommission - ISNULL(@fxProviderDebitTax, 0) - ISNULL(@fxProviderCreditTax, 0), 2)
            SET @fxProviderTotalVAT     = ROUND((@fxClientVAT * @fxValue) - @fxProviderVAT, 2)
          END

          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
          /* CLIENT ------------------------------------------------------------------------------------------------------------------------------------------------- */
          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */

          UPDATE [LP_Operation].[TransactionDetail]
          SET
            [TransactionDate] = @TransactionDate
            , [GrossAmount] = @Value
            , [TaxWithholdings] = 0
            ,[TaxWithholdingsARBA] = 0
            , [NetAmount] = @Value
            , [Commission] = @ClientCommission
            , [VAT] = @fxClientVAT
            , [Commission_With_VAT] = @fxClientCommissionWithVAT
            , [idStatus] = @idStatus
            , [Active] = 1
            , [Version] = 1
            , [LocalTax] = @fxClientDebitTaxGMF
          WHERE
            [idTransaction] = @idTransaction

          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
          /* PROVEEDOR ---------------------------------------------------------------------------------------------------------------------------------------------- */
          /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */

          UPDATE [LP_Operation].[TransactionProvider]
          SET
            [idProvider] = @idProvider
            , [VAT] = @fxProviderVAT
            , [Commission] = @ProviderCommission
            , [Commission_With_VAT] = @fxProviderCommissionWithVAT
            , [Commission_With_Cash] = NULL
            , [Cash_VAT] = NULL
            , [Gross_Revenue_Perception_CABA] = NULL
            , [Gross_Revenue_Perception_BSAS] = NULL
            , [Gross_Revenue_Perception_OTHER] = NULL
            , [Profit_Perception] = NULL
            , [VAT_Perception] = NULL
            , [DebitTax] = @fxProviderDebitTax
            , [CreditTax] = @fxProviderCreditTax
            , [TotalCostRnd] = @fxProviderTotalCostRdo
            , [TotalVAT] = @fxProviderTotalVAT
            , [idStatus] = @idStatus
            , [Active] = 1
            , [Version] = 1
          WHERE
            [idTransaction] = @idTransaction

          SET @idxTransaction = @idxTransaction + 1

        END

      END

      SET @TotNetAmount =
                (
                  SELECT
                    SUM([TD].[NetAmount])
                  FROM
                    [LP_Operation].[Transaction] [T]
                      INNER JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
                  WHERE
                    [T].[idTransactionLot] = @idTransactionLot
                    AND [T].[Active] = 1
                )

      UPDATE [LP_Operation].[TransactionLot]
      SET
        [NetAmount] = @TotNetAmount
      WHERE
        [idTransactionLot] = @idTransactionLot

    COMMIT TRAN
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
