
CREATE OR ALTER PROCEDURE [LP_Operation].[PayIn_Generic_Entity_Operation_Executed]
																				(
																					 @JSON					NVARCHAR(MAX)
																				)
AS
DECLARE 
@IdTransaction [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@IdLotTransaction [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@GrossAmount  [LP_Common].[LP_F_DECIMAL],
@GrossAmountLocalCurrency  [LP_Common].[LP_F_DECIMAL],
@NetAmount  [LP_Common].[LP_F_DECIMAL],
@ClientCommission       [LP_Common].[LP_F_DECIMAL],
@SysCurrencyLP        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@SysCurrencyClient      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUser         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@BeforeBalanceFinalValue          [LP_Common].[LP_F_DECIMAL],
@BeforeValueBalance           [LP_Common].[LP_F_DECIMAL],
@Value_Spot               [LP_Common].[LP_F_DECIMAL],
@Base_Sell                 [LP_Common].[LP_F_DECIMAL],
@ValueFX                  [LP_Common].[LP_F_DECIMAL],
@idCurrencyExchange     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCurrencyBase       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@BeforeValueBalanceWithOutCommission    [LP_Common].[LP_F_DECIMAL],
@SignMultiply               [LP_Common].[LP_F_INT] = 1,
@TransactionDate        [LP_Common].[LP_A_OP_INSDATETIME] = getutcdate(),
@Commission      [LP_Common].[LP_F_DECIMAL],
@idTransactionOperation [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] = 1, --PayIn
@idCountry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idProvider			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
 @ProvVAT            [LP_Common].[LP_F_DECIMAL],
 @ProvCommission       [LP_Common].[LP_F_DECIMAL],
 @ProvGrossRevenue       [LP_Common].[LP_F_DECIMAL],
 @ProvDebitTax         [LP_Common].[LP_F_DECIMAL],
 @ProvCreditTax        [LP_Common].[LP_F_DECIMAL]

BEGIN
IF(OBJECT_ID('tempdb..#TXs_Payin') IS NOT NULL)
BEGIN 
	DROP TABLE #TXs_Payin 
END
	BEGIN TRY
			SELECT
				Tickets.value Ticket,
				tr.idEntityUser,
				tr.idTransaction,
				tr.idTransactionLot,
				ISNULL(trd.GrossAmount, 0) as GrossAmount,
				ISNULL(trd.NetAmount, 0) as NetAmount,
				ROUND(ISNULL([SM].[CommissionValuePO], 0) , 2)  as ClientCommission,
				[idCurrencyTypeLP],
				[idCurrencyTypeClient],
				[CE].[idCurrencyExchange],
				[tr].[idCurrencyBase],
				[trd].Commission,
				ISNULL(TP.VAT, 0) as ProvVAT,
				ISNULL(TP.Commission, 0) as ProvCommission,
				ISNULL(TP.Gross_Revenue_Perception_CABA, 0) as ProvGrossRevenue,
				ISNULL(TP.DebitTax, 0) as ProvDebitTax,
				ISNULL(TP.CreditTax, 0) as ProvCreditTax
			INTO #TXs_Payin
			FROM OPENJSON(@JSON, '$.Tickets') as Tickets
			inner join LP_Operation.Ticket ti WITH (NOLOCK) on ti.Ticket = Tickets.value
			inner join LP_Operation.[Transaction] tr WITH (NOLOCK) on tr.idTransaction = ti.idTransaction
			inner join LP_Operation.[TransactionDetail] trd  WITH (NOLOCK) on trd.idTransaction = tr.idTransaction
 			inner join LP_Operation.[TransactionEntitySubMerchant]  tresub WITH (NOLOCK) on tresub.idTransaction = tr.idTransaction
			inner join LP_Operation.[TransactionPayinDetail] trpay WITH (NOLOCK) on trpay.idTransaction = tr.idTransaction
			inner join [LP_Operation].[TransactionProvider]     [TP] WITH (NOLOCK)  ON [tr].[idTransaction]   = [TP].[idTransaction]
			inner join [LP_Entity].[EntitySubMerchant] [SM] WITH (NOLOCK) on sm.idEntitySubMerchant = tresub.idEntitySubMerchant
			inner join [LP_Entity].[EntityCurrencyExchange] ec WITH (NOLOCK) on ec.idEntityUser = tr.idEntityUser
			inner join [LP_Configuration].[CurrencyExchange] [CE] WITH (NOLOCK) on ce.idCurrencyExchange = tr.idCurrencyExchange
			where
				tr.idStatus = 3 --In Progress

		BEGIN TRANSACTION
			----
			DECLARE payin_list_cursor CURSOR FORWARD_ONLY FOR
			SELECT idEntityUser,idTransaction,idTransactionLot, GrossAmount, NetAmount, ClientCommission,idCurrencyTypeLP,idCurrencyTypeClient,idCurrencyExchange,idCurrencyBase, Commission, ProvVAT, ProvCommission, ProvGrossRevenue,ProvDebitTax,ProvCreditTax FROM  #TXs_Payin

			OPEN payin_list_cursor;

			FETCH NEXT FROM payin_list_cursor INTO @idEntityUser,@IdTransaction, @IdLotTransaction, @GrossAmount, @NetAmount, @ClientCommission, @SysCurrencyLP, @SysCurrencyClient,@idCurrencyExchange,@idCurrencyBase, @Commission, @ProvVAT, @ProvCommission, @ProvGrossRevenue, @ProvDebitTax, @ProvCreditTax

			WHILE @@FETCH_STATUS = 0
			  BEGIN
					
					SELECT 
						@idCountry	= [P].[idCountry]
						,@idProvider = [TTP].[idProvider]	
					FROM [LP_Operation].[Transaction] [T]
					INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idTransactionTypeProvider] = [T].[idTransactionTypeProvider]
					INNER JOIN [LP_Configuration].[Provider] [P] ON [TTP].[idProvider] = [P].[idProvider]
					WHERE [T].[idTransaction] = @IdTransaction


			  		UPDATE  LP_Operation.[TransactionLot] 
					SET 
						idStatus = 4 --Executed,
					WHERE
						idTransactionLot = @IdLotTransaction

					UPDATE  LP_Operation.[TransactionDetail] 
					SET 
						idStatus = 4 --Executed,
					WHERE
						idTransaction = @IdTransaction

					UPDATE  LP_Operation.[TransactionInternalStatus] 
					SET 
						idInternalStatus = (select idInternalStatus from LP_Configuration.InternalStatus where code = 'EXECUTED' AND idCountry = @idCountry AND idProvider = @idProvider) --Executed,
					WHERE
						idTransaction = @IdTransaction


		SET @BeforeBalanceFinalValue = (SELECT TOP 1 [BalanceFinal] FROM [LP_Operation].[Wallet] WHERE [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC)

          IF(@BeforeBalanceFinalValue IS NULL)
          BEGIN
            SET @BeforeBalanceFinalValue = (@NetAmount * @SignMultiply) - @ProvVAT - @ProvCommission - @ProvGrossRevenue - @ProvDebitTax - @ProvCreditTax
          END
          ELSE
          BEGIN
            SET @BeforeBalanceFinalValue = @BeforeBalanceFinalValue + @NetAmount - @ProvVAT - @ProvCommission - @ProvGrossRevenue - @ProvDebitTax - @ProvCreditTax
          END

		SET @Value_Spot = (SELECT [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [idCurrencyExchange] = @idCurrencyExchange)
        SET @Base_Sell = (SELECT [Base_Sell] FROM [LP_Configuration].[CurrencyBase] WHERE [idCurrencyBase] = @idCurrencyBase)
        --SET @Base_Buy = (SELECT [Base_Sell] FROM [LP_Configuration].[CurrencyBase] WHERE [idCurrencyBase] = @idCurrencyBase)
        SET @ValueFX = @Value_Spot * (1 + @Base_Sell / 100)

          IF(@SysCurrencyClient <> @SysCurrencyLP) /* MONEDA NO LOCAL */
          BEGIN
			select @idCurrencyExchange = idcurrencyexchange from [LP_Configuration].[CurrencyExchange] [CE] WITH (NOLOCK)
			 where ce.[CurrencyTo] =  @SysCurrencyLP AND [CE].[Active] = 1 AND [CE].[ActionType] = 'A'
            --SET @ValueFX = @Value_Spot * (1 + @Base_Buy / 100)

            --SET @ValueFX = (SELECT [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [idCurrencyExchange] = @CurrencyClose)

            --SET @BeforeValueBalance = (SELECT TOP 1 [BalanceClient] FROM [LP_Operation].[Wallet] WHERE [BalanceClient] IS NOT NULL AND [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC)
            SELECT TOP 1 @BeforeValueBalance = [BalanceClient], @BeforeValueBalanceWithOutCommission = [BalanceClientWithOutCommission] FROM [LP_Operation].[Wallet] WHERE [BalanceClient] IS NOT NULL AND [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC           

            IF(@BeforeValueBalance IS NULL)
            BEGIN
              SET @BeforeValueBalance = round(((@GrossAmount / @ValueFX) * @SignMultiply), 2) - @Commission
              SET @BeforeValueBalanceWithOutCommission = round(((@GrossAmount / @ValueFX) * @SignMultiply), 2)
            END
            ELSE
            BEGIN

              --SET @BeforeValueBalance = @BeforeValueBalance - (@GrossAmount / @ValueFX) - @CommissionWithVAT
              --SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission + round(((@GrossAmount / @ValueFX) * @SignMultiply), 2)

              IF(SIGN(CAST(@BeforeValueBalance AS INT)) = -1)
              BEGIN
                SET @BeforeValueBalance = @BeforeValueBalance + round(((@GrossAmount / @ValueFX)), 2) - @Commission  
              END
              ELSE
              BEGIN
                SET @BeforeValueBalance = @BeforeValueBalance + round(((@GrossAmount / @ValueFX) * @SignMultiply), 2) - @Commission  
              END

              IF(SIGN(CAST(@BeforeValueBalanceWithOutCommission AS INT)) = -1)
              BEGIN
                SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission + round(((@GrossAmount / @ValueFX)), 2)
              END
              ELSE
              BEGIN
                SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission + round(((@GrossAmount / @ValueFX) * @SignMultiply), 2)
              END

            END

            INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceClientWithOutCommission] )
            VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @SysCurrencyLP, NULL, NULL, NULL, @SysCurrencyClient, round((@GrossAmount / @ValueFX)* @SignMultiply, 2), round((@NetAmount / @ValueFX) * @SignMultiply, 2), @BeforeValueBalance, @BeforeBalanceFinalValue, @BeforeValueBalanceWithOutCommission )

          END
          ELSE /* MONEDA LP */
          BEGIN
            --SET @BeforeValueBalance = (SELECT TOP 1 [BalanceLP] FROM [LP_Operation].[Wallet] WHERE [BalanceLP] IS NOT NULL AND [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC)
            SELECT TOP 1 @BeforeValueBalance = [BalanceLP], @BeforeValueBalanceWithOutCommission = [BalanceLPWithOutCommission]  FROM [LP_Operation].[Wallet] WHERE [BalanceLP] IS NOT NULL AND [idEntityUser] = @idEntityUser AND [Active] = 1 ORDER BY [idWallet] DESC

            IF(@BeforeValueBalance IS NULL)
            BEGIN
              SET @BeforeValueBalance = (@GrossAmount * @SignMultiply) - (@Commission * @ValueFX)
              SET @BeforeValueBalanceWithOutCommission = (@GrossAmount * @SignMultiply)
            END
            ELSE
            BEGIN
              --SET @BeforeValueBalance = @BeforeValueBalance - @GrossAmount - @CommissionWithVAT
              --SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission - @GrossAmount

              IF(SIGN(CAST(@BeforeValueBalance AS INT)) = -1)
              BEGIN
                SET @BeforeValueBalance = @BeforeValueBalance + @GrossAmount - (@Commission * @ValueFX)
              END
              ELSE
              BEGIN
                SET @BeforeValueBalance = @BeforeValueBalance + (@GrossAmount * @SignMultiply) - (@Commission * @ValueFX)
              END

              IF(SIGN(CAST(@BeforeValueBalanceWithOutCommission AS INT)) = -1)
              BEGIN
                SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission + @GrossAmount
              END
              ELSE
              BEGIN
                SET @BeforeValueBalanceWithOutCommission = @BeforeValueBalanceWithOutCommission + (@GrossAmount * @SignMultiply)
              END
            END

            INSERT INTO [LP_Operation].[Wallet] ( [WalletDate], [idEntityUSer], [idTransaction], [idTransactionOperation], [idCurrencyTypeLP], [GrossValueLP], [NetValueLP], [BalanceLP], [idCurrencyTypeClient], [GrossValueClient], [NetValueClient], [BalanceClient], [BalanceFinal], [BalanceLPWithOutCommission] )
            VALUES ( DATEDIFF(SECOND, '19700101', @TransactionDate), @idEntityUser, @idTransaction, @idTransactionOperation, @SysCurrencyLP, (@GrossAmount * @SignMultiply), (@NetAmount * @SignMultiply), @BeforeValueBalance, @SysCurrencyClient, NULL, NULL, NULL, @BeforeBalanceFinalValue, @BeforeValueBalanceWithOutCommission )
          END			

		  			UPDATE  LP_Operation.[Transaction] 
					SET 
						idStatus = 4, --Executed,
						idCurrencyExchangeClosed = @idCurrencyExchange,
						ProcessedDate = GETUTCDATE()
					WHERE
						idTransaction = @IdTransaction

			FETCH NEXT FROM payin_list_cursor INTO @idEntityUser,@IdTransaction, @IdLotTransaction, @GrossAmount, @NetAmount, @ClientCommission, @SysCurrencyLP, @SysCurrencyClient,@idCurrencyExchange,@idCurrencyBase, @Commission, @ProvVAT, @ProvCommission, @ProvGrossRevenue, @ProvDebitTax, @ProvCreditTax

			  END;

			CLOSE payin_list_cursor;

			DEALLOCATE payin_list_cursor;  


			--Calculo de comision aplicar conversion usando el base sell en caso que la moneda de la cuenta
			--sea diferente a la moneda de la transaccion
				--update currencyexchangeclosed, con el valor de la cotizacion actual para esa moneda
				--SET @CurrencyClose = ( SELECT TOP 1 [CE].[idCurrencyExchange] FROM [LP_Configuration].[CurrencyExchange] [CE] WHERE [CE].[Active] = 1 AND [CE].[ActionType] = 'A' AND [CE].[CurrencyTo] = @idCurrencyClient ORDER BY [CE].[idCurrencyExchange] DESC )
			--insert wallet
			--update status:
				--Transaction detail
				--Transaction lot
				--transaction internal status
		
		COMMIT
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




--Pasar N Transactions a Executed
--Calculo de comision aplicar conversion usando el base sell en caso que la moneda de la cuenta
--sea diferente a la moneda de la transaccion