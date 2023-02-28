SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [LP_KPI].[ARG_Payout_Generic_fx_Update]
                                  (
                                    @idTransactionLot   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
                                  )
    AS
    BEGIN

      BEGIN TRY
        BEGIN TRANSACTION

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
            , @fxClientNet          [LP_Common].[LP_F_DECIMAL]
            , @fxClientVAT          [LP_Common].[LP_F_DECIMAL]
            , @fxClientCommissionWithVAT  [LP_Common].[LP_F_DECIMAL]
            , @fxClientTaxWithHoldings    [LP_Common].[LP_F_DECIMAL]
            ,@fxClientTaxWithHoldingsARBA [LP_Common].[LP_F_DECIMAL]
            , @ProviderCommission     [LP_Common].[LP_F_DECIMAL]  
            , @ProviderPorcIIBB       [LP_Common].[LP_F_DECIMAL]
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
            , @ClientDebitTaxGMF      [LP_Common].[LP_F_DECIMAL]
            , @fxClientDebitTaxGMF      [LP_Common].[LP_F_DECIMAL]

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

                SET @idCountry = [LP_Location].[fnGetIdCountyByidEntityUser](@idEntityUser)

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

              SET @Spread_fxValue_Buy = ( SELECT [Base_Buy] FROM [LP_Configuration].[CurrencyBase] WHERE [idCurrencyBase] = @idCurrencyBase )
              SET @fxValue = ( SELECT [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [idCurrencyExchange] = @idCurrencyExchange ) * ( 1 - @Spread_fxValue_Buy / 100.0 )

              --SET @WithRetentions = (SELECT [WithRetentions] FROM [LP_Configuration].[EntityUserConfiguration] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1)

              SELECT                  
                @WithRetentions   = [ESM].[WithRetentions]
                , @idSubMerchant  = [ESM].[idEntitySubMerchant]
              FROM
                [LP_Operation].[TransactionEntitySubMerchant] [TESM]
                  INNER JOIN [LP_Entity].[EntitySubMerchant]  [ESM] ON [ESM].[idEntitySubMerchant] = [TESM].[idEntitySubMerchant]
              WHERE
                [TESM].[idTransaction] = @idTransaction
                AND [TESM].[Active] = 1
                AND [ESM].[Active] = 1

              IF(@WithRetentions IS NULL)
                SET @WithRetentions = 1

              IF(@WithRetentions = 1)
              BEGIN
                --SET @fxClientTaxWithHoldings = ISNULL([LP_Retentions_ARG].[fnGetRetentionAmount](@Value, @idEntityUser, @idSubMerchant, @RecipientCUIT ), 0)
                SET @fxClientTaxWithHoldings = ISNULL(round([LP_Retentions_ARG].[fnGetRetentionAmount](@Value, @idEntityUser, @idSubMerchant, @RecipientCUIT, @TransactionDate, @idTransaction ), 2), 0)
                SET @fxClientTaxWithHoldingsARBA = ISNULL(round([LP_Retentions_ARG].[fnGetArbaRetentionAmount](@Value, @idEntityUser, @idSubMerchant, @RecipientCUIT ), 2), 0)
              END
              ELSE
              BEGIN
                SET @fxClientTaxWithHoldings = 0
                SET @fxClientTaxWithHoldingsARBA = 0
              END

              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
              /* GENERAL VALUES ----------------------------------------------------------------------------------------------------------------------------------------- */
              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
              SET @General_VAT_D        = ISNULL([LP_Catalog].[fnGetClientVariableValue]('VAR::ARG::GENERAL.IVA_D', @idCountry, @idEntityUser, @idTransactionType, NULL, NULL), 0)
              SET @General_VAT_M        = ISNULL([LP_Catalog].[fnGetClientVariableValue]('VAR::ARG::GENERAL.IVA_M', @idCountry, @idEntityUser, @idTransactionType, NULL, NULL), 0)

              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
              /* CLIENT ------------------------------------------------------------------------------------------------------------------------------------------------- */
              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */      
              --SET @ClientCommission     = ISNULL([LP_Catalog].[fnGetClientVariableValue]('VAR::ARG::BANK_DEPOSIT.COMISION', @idCountry, @idEntityUser, @idTransactionType), 0) / @General_VAT_D
              --SET @ClientCommission     = round(ISNULL([LP_Catalog].[fnGetClientVariableValue]('VAR::ARG::BANK_DEPOSIT.COMISION', @idCountry, @idEntityUser, @idTransactionType, @fxValue, @Value), 0) / @General_VAT_D, 2)
              SET @ClientCommission     = ROUND(ISNULL([LP_Catalog].[fnGetCommissionBySubMerchant](@idSubMerchant), 0) / @General_VAT_D, 2)
              SET @ClientDebitTaxGMF      = 0

              SET @fxClientVAT        = round(@ClientCommission * @General_VAT_M, 2)
              SET @fxClientCommissionWithVAT  = @ClientCommission + @fxClientVAT
              SET @fxClientNet        = @Value - @fxClientTaxWithHoldings - @fxClientTaxWithHoldingsARBA
              SET @fxClientDebitTaxGMF    = 0

              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
              /* PROVEEDOR ---------------------------------------------------------------------------------------------------------------------------------------------- */
              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */

              SET @ProviderCommission   = ISNULL([LP_Catalog].[fnGetProviderVariableValue]('VAR::ARG::BANK_DEPOSIT.COSTO_BANCO', @idCountry, @idProvider, @idTransactionType), 0)
              SET @ProviderPorcIIBB   = ISNULL([LP_Catalog].[fnGetProviderVariableValue]('VAR::ARG::BANK_DEPOSIT.PERCEPCION_IIBB', @idCountry, @idProvider, @idTransactionType), 0)
              SET @ProviderPorcDebitTax = ISNULL([LP_Catalog].[fnGetProviderVariableValue]('VAR::ARG::BANK_DEPOSIT.IMPUESTO_DEBITO', @idCountry, @idProvider, @idTransactionType), 0)

              SET @fxProviderVAT      = round(@ProviderCommission * @General_VAT_M, 2)
              SET @fxProviderCommissionWithVAT  = @ProviderCommission + @fxProviderVAT
              SET @fxProviderGrossRevenue   = round(@ProviderCommission * @ProviderPorcIIBB, 2)
              SET @fxProviderProfitPerception   = NULL
              SET @fxProviderPerceptionVAT    = NULL
              SET @fxProviderDebitTax     = round((@Value + @ProviderCommission + @fxProviderVAT + @fxProviderGrossRevenue) * @ProviderPorcDebitTax, 2)
              SET @fxProviderCreditTax    = NULL

              /* VALIDAR TIPO CURRENCY LP VS CLIENT*/

              IF(@SysCurrencyLP = @SysCurrencyClient)
              BEGIN
                SET @fxProviderTotalCostRdo   = @ClientCommission - @ProviderCommission - @fxProviderDebitTax - ISNULL(@fxProviderCreditTax, 0)
                SET @fxProviderTotalVAT     = @fxClientVAT - @fxProviderVAT
              END
              ELSE
              BEGIN
                SET @fxProviderTotalCostRdo   = round(@ClientCommission * @fxValue, 2) - @ProviderCommission - @fxProviderDebitTax - ISNULL(@fxProviderCreditTax, 0)
                SET @fxProviderTotalVAT     = round(@fxClientVAT * @fxValue, 2) - @fxProviderVAT
              END

              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
              /* CLIENT ------------------------------------------------------------------------------------------------------------------------------------------------- */
              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */

              UPDATE [LP_Operation].[TransactionDetail]
              SET
                [GrossAmount]     = @Value,
                [TaxWithholdings]   = @fxClientTaxWithHoldings,
                [TaxWithholdingsARBA] = @fxClientTaxWithHoldingsARBA,
                [NetAmount]       = @fxClientNet,
                [Commission]      = @ClientCommission,
                [VAT]         = @fxClientVAT,         
                [Commission_With_VAT] = @fxClientCommissionWithVAT,
                [Version]       = [Version] + 1,
                [LocalTax]        =   @fxClientDebitTaxGMF
              WHERE
                [idTransaction] = @idTransaction

              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
              /* PROVEEDOR ---------------------------------------------------------------------------------------------------------------------------------------------- */
              /* -------------------------------------------------------------------------------------------------------------------------------------------------------- */

              UPDATE [LP_Operation].[TransactionProvider]
              SET
                [VAT]               = @fxProviderVAT
                , [Commission]            = @ProviderCommission
                , [Commission_With_VAT]       = @fxProviderCommissionWithVAT
                , [Commission_With_Cash]      = NULL
                , [Cash_VAT]            = NULL
                , [Gross_Revenue_Perception_CABA] = @fxProviderGrossRevenue
                , [Gross_Revenue_Perception_BSAS] = NULL
                , [Gross_Revenue_Perception_OTHER]  = NULL
                , [Profit_Perception]       = @fxProviderProfitPerception
                , [VAT_Perception]          = @fxProviderPerceptionVAT
                , [DebitTax]            = @fxProviderDebitTax
                , [CreditTax]           = @fxProviderCreditTax
                , [TotalCostRnd]          = @fxProviderTotalCostRdo
                , [TotalVAT]            = @fxProviderTotalVAT
                , [Version]             = [Version] + 1
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
