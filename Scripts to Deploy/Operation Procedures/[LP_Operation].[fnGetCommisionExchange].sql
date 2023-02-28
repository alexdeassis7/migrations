CREATE OR ALTER FUNCTION [LP_Operation].[fnGetCommisionExchange]
													(
														@idCurrencyExchange	[LP_Common].[LP_F_INT]
														,@idCurrencyBase	[LP_Common].[LP_F_INT]
														,@Amount			[LP_Common].[LP_F_DECIMAL]
														,@isBuy				BIT
													)
RETURNS [LP_Common].[LP_F_DECIMAL]
AS
BEGIN

	DECLARE @return [LP_Common].[LP_F_DECIMAL]
			,@fxValue [LP_Common].[LP_F_DECIMAL]
			,@spread [LP_Common].[LP_F_DECIMAL]

	IF (@isBuy = 1)
	BEGIN
		SET @spread = ( SELECT [Base_Buy] FROM [LP_Configuration].[CurrencyBase] WHERE [idCurrencyBase] = @idCurrencyBase )
        SET @fxValue = ( SELECT [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [idCurrencyExchange] = @idCurrencyExchange ) * ( 1 - @spread / 100.0 )
	END
	ELSE
	BEGIN
		SET @spread = ( SELECT [Base_Sell] FROM [LP_Configuration].[CurrencyBase] WHERE [idCurrencyBase] = @idCurrencyBase )
		SET @fxValue = ( SELECT [Value] FROM [LP_Configuration].[CurrencyExchange] WHERE [idCurrencyExchange] = @idCurrencyExchange ) * ( 1 + @spread / 100.0 )
	END
	SET @return = (SELECT  ROUND((@Amount * @fxValue),2))

	RETURN @return
END
GO


