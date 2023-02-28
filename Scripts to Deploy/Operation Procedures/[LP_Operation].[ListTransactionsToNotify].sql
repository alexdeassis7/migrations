DROP PROCEDURE IF EXISTS [LP_Operation].[ListTransactionsToNotify]
GO
/****** Object:  StoredProcedure [LP_Operation].[ListTransactionsToNotify]    Script Date: 3/20/2020 2:35:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [LP_Operation].[ListTransactionsToNotify]
  @lotId AS varchar(max) = NULL 
AS
BEGIN
  DECLARE @JSON XML
  DECLARE @TempBody TABLE (
    idTransactionLot INT
    ,UserEmail VARCHAR(80)
    ,Merchant LP_Common.LP_F_DESCRIPTION
    ,TotalTransactions INT
    ,TotalAmount LP_Common.LP_F_DECIMAL
    ,CurrencyType VARCHAR(10)
    ,LotDate LP_Common.LP_A_OP_INSDATETIME
    ,Country LP_Common.LP_F_NAME
  
  );
  BEGIN TRY
    BEGIN TRAN
    --GET TRANSACTION LOT DATA
      INSERT INTO @TempBody
      SELECT 
        [TL].[idTransactionLot]
        ,[EU].[MailAccount]
        ,[EM].[Description]
        ,COUNT([T].[idTransaction]) AS [TotalTransaction]
        ,SUM([T].[GrossValueClient]) AS [TotalAmount]
        ,[CT].[code] [CurrencyCode]
        ,[TL].[LotDate]
        ,[CY].[Name]
      FROM [LP_Operation].[TransactionLot] [TL] 
        INNER JOIN [LP_Operation].[Transaction] [T]             ON [T].[idTransactionLot] = [TL].[idTransactionLot] 
        INNER JOIN [LP_Entity].[EntityUser] [EU]              ON [T].[idEntityUser] = [EU].[idEntityUser]
        INNER JOIN [LP_Entity].[EntityMerchant] [EM]            ON [EM].[idEntityMerchant] = [EU].[idEntityMerchant]
        INNER JOIN [LP_Configuration].[CurrencyType] [CT]         ON [CT].[idCurrencyType] = [T].[CurrencyTypeClient]
        INNER JOIN [LP_Location].[Country] [CY]               ON [CY].[idCountry] = [EU].[idCountry]
        LEFT JOIN [LP_Configuration].[TransactionTypeProvider]      [TTP]   ON [T].[idTransactionTypeProvider]  = [TTP].[idTransactionTypeProvider]
        LEFT JOIN [LP_Configuration].[TransactionType]          [TT]        ON [TTP].[idTransactionType]    = [TT].[idTransactionType]
      WHERE [TL].[Notified] IS NULL
      AND ([TL].[idTransactionLot] = @lotId OR @lotId IS NULL )
      AND [TT].[Code] NOT IN('AddBalance', 'AddDebit', 'ReceivedCo')
      GROUP BY [TL].[idTransactionLot], [EM].[Description], [CT].[code], [TL].[LotDate], [EU].[MailAccount],[CY].[Name]

      --UPDATE UPDATE [NOTIFIED] TO CURRENT DATE
      UPDATE [LP_Operation].[TransactionLot] SET [Notified] = GETDATE() WHERE [idTransactionLot] IN (SELECT [idTransactionLot] FROM @TempBody)

      SET @JSON =
            (
              SELECT
                CAST
                ( 
                  (
                    SELECT 
                      [UserEmail] AS [User]
                      ,[Merchant]
                      ,SUM([TotalTransactions]) AS [TotalTransactions]
                      ,SUM([TotalAmount]) AS [TotalAmount]
                      ,[CurrencyType]
                      ,MIN(LotDate) AS [LotDate]
                      ,[Country]
                    FROM @TempBody
                    GROUP BY [UserEmail],[Merchant],[CurrencyType],[Country]
                    FOR JSON PATH
                  ) AS XML
                )
            )
    COMMIT
    SELECT @JSON
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


GO


