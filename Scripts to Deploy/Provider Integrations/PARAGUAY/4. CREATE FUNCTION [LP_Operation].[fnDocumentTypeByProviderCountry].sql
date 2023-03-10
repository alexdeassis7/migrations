USE [LocalPaymentPROD]
GO
/****** Object:  UserDefinedFunction [LP_Operation].[fnDocumentTypeByProviderCountry]    Script Date: 7/15/2022 12:04:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [LP_Operation].[fnDocumentTypeByProviderCountry]
																					(
																						 @idProvider	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
																						 ,@DocumentTypeInput int
																					)
RETURNS VARCHAR
AS
BEGIN
	DECLARE @Result VARCHAR

	SET @Result = 
				(
					SELECT
						DocumentTypeOutPut 
					FROM
						[LP_Configuration].[DocumentTypeByProvider]
					WHERE
						idProvider = @idProvider
						AND DocumentTypeInput = @DocumentTypeInput
				)

	RETURN @Result
END

