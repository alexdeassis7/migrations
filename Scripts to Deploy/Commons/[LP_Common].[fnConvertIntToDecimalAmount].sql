CREATE OR ALTER FUNCTION [LP_Common].[fnConvertIntToDecimalAmount]
														(
															@Amount			[LP_Common].[LP_F_C100]
														)
RETURNS [LP_Common].[LP_F_DECIMAL]
AS
BEGIN

	DECLARE @IntPart	VARCHAR(18)
	DECLARE @DecPart	VARCHAR(6)
	DECLARE @Value		[LP_Common].[LP_F_DECIMAL]

	IF(LEN(@Amount) < 3)
	BEGIN
		SET @Amount = RIGHT('00' + @Amount, 3)
	END

	SET @IntPart = SUBSTRING(CAST(@Amount AS VARCHAR(30)), 1, LEN(CAST(@Amount AS VARCHAR(30))) - 2)
	SET @DecPart = RIGHT(CAST(@Amount AS VARCHAR(30)), 2)

	SET @Value = CAST(CAST(@IntPart AS VARCHAR(15)) + '.' + CAST(@DecPart AS VARCHAR(3)) AS DECIMAL(18,6))

	RETURN @Value
	
END