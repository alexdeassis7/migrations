DROP PROCEDURE IF EXISTS [LP_Configuration].[CleanCurrencyExchange];

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [LP_Configuration].[CleanCurrencyExchange]
AS
BEGIN
	BEGIN TRY
		DECLARE @CurrencyExchange TABLE (
			[idCurrencyExchange] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
			[ProcessDate] [LP_Common].[LP_A_OP_INSDATETIME] NOT NULL,
			[Timestamp] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
			[CurrencyBase] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
			[CurrencyTo] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
			[idCountry] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
			[Value] [LP_Common].[LP_F_DECIMAL] NULL,
			[Active] [LP_Common].[LP_A_ACTIVE] NOT NULL,
			[OP_InsDateTime] [LP_Common].[LP_A_OP_INSDATETIME] NOT NULL,
			[OP_UpdDateTime] [LP_Common].[LP_A_OP_UPDDATETIME] NOT NULL,
			[DB_InsDateTime] [LP_Common].[LP_A_DB_INSDATETIME] NOT NULL,
			[DB_UpdDateTime] [LP_Common].[LP_A_DB_UPDDATETIME] NOT NULL,
			[ActionType] [LP_Common].[LP_F_C1] NOT NULL
		)

		INSERT INTO @CurrencyExchange
		SELECT TOP(100)  [idCurrencyExchange]
				,[ProcessDate]
				,[Timestamp]
				,[CurrencyBase]
				,[CurrencyTo]
				,[idCountry]
				,[Value]
				,[Active]
				,[OP_InsDateTime]
				,[OP_UpdDateTime]
				,[DB_InsDateTime]
				,[DB_UpdDateTime]
				,[ActionType]
		FROM [LP_Configuration].[CurrencyExchange] [CE] WITH (NOLOCK)
		WHERE [idCurrencyExchange] NOT IN (SELECT [idCurrencyExchange] FROM [LP_Operation].[Transaction] [T] WITH (NOLOCK))

		BEGIN TRAN DeleteCurrency
			INSERT INTO [LP_Configuration].[HistoricalCurrencyExchange] (
				[idCurrencyExchange]
					,[ProcessDate]
					,[Timestamp]
					,[CurrencyBase]
					,[CurrencyTo]
					,[idCountry]
					,[Value]
					,[Active]
					,[OP_InsDateTime]
					,[OP_UpdDateTime]
					,[DB_InsDateTime]
					,[DB_UpdDateTime]
					,[ActionType]
			)
			SELECT [idCurrencyExchange]
					,[ProcessDate]
					,[Timestamp]
					,[CurrencyBase]
					,[CurrencyTo]
					,[idCountry]
					,[Value]
					,[Active]
					,[OP_InsDateTime]
					,[OP_UpdDateTime]
					,[DB_InsDateTime]
					,[DB_UpdDateTime]
					,[ActionType]
			FROM @CurrencyExchange

			DELETE FROM [LP_Configuration].[CurrencyExchange]
			WHERE [idCurrencyExchange] IN (
				SELECT [idCurrencyExchange] FROM @CurrencyExchange
			);
		COMMIT TRAN DeleteCurrency;

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
