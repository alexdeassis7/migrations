ALTER FUNCTION [LP_Retentions_ARG].[fnGetCertificateNumber]
															(
																@idTransaction			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
																,@idFileType		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
															)
RETURNS VARCHAR(120)
AS
BEGIN

	DECLARE
		@TransactionDate		[LP_Common].[LP_A_DB_INSDATETIME]
		, @idTransactionLot		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @YearlyMonthlyDate	[LP_Common].[LP_F_C6]
		, @YearDate				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @YearActualDate		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @LastValueFileName	[LP_Common].[LP_F_VMAX]
		, @NewValueFileName		[LP_Common].[LP_F_VMAX]
		, @Ticket				VARCHAR(14)
		, @MerchantId			VARCHAR(60)

	SET @idTransactionLot = ( SELECT [idTransactionLot] FROM [LP_Operation].[Transaction] WHERE [idTransaction] = @idTransaction )

	SET @TransactionDate = ( SELECT [LotDate] FROM [LP_Operation].[TransactionLot] WHERE [idTransactionLot] = @idTransactionLot )

	SET @Ticket = ( SELECT [Ticket] FROM [LP_Operation].[Ticket] WHERE [idTransaction] = @idTransaction )

	SET @MerchantId = (SELECT [InternalDescription] FROM [LP_Operation].[TransactionRecipientDetail] WHERE idTransaction = @idTransaction)

	SET @YearlyMonthlyDate = CONVERT(VARCHAR(6), @TransactionDate, 112)

	SET @YearDate = LEFT(@YearlyMonthlyDate, 4)
	SET @YearActualDate = LEFT(CONVERT(VARCHAR(8), GETDATE(), 112), 4)

	SET @LastValueFileName = ( SELECT TOP 1 REPLACE(REPLACE([FileName],'ARBA_',''),'AFIP_','') FROM [LP_Retentions_ARG].[TransactionCertificate] WHERE idFileType=@idFileType AND FileName IS NOT NULL AND LEFT(REPLACE(REPLACE([FileName],'ARBA_',''),'AFIP_',''),4) = @YearDate ORDER BY [OP_InsDateTime] DESC )

	IF(@LastValueFileName IS NOT NULL)
	BEGIN

		/* 'SE SIGUE CON LA CORRELATIVIDAD.' */

		SET @NewValueFileName = LEFT(@LastValueFileName, 4) + RIGHT(CONVERT(VARCHAR(6), @TransactionDate, 112), 2) + RIGHT('00000000000000000000' + CAST(CAST(RIGHT(LEFT(@LastValueFileName, 26), 20) AS BIGINT) + 1 AS VARCHAR(20)), 20) + '_' + @Ticket + '_' + @MerchantId

	END
	ELSE
	BEGIN

		/* 'SE EMPIEZA UN CORRELATIVO NUEVO.' */

		SET @NewValueFileName = @YearlyMonthlyDate + '00000000000000000001_' + @Ticket + '_' + @MerchantId

	END

	RETURN @NewValueFileName

END