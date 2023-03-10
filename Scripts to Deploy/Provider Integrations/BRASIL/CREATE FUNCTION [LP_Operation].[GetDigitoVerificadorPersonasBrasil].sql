USE [LocalPaymentPROD]
GO
/****** Object:  UserDefinedFunction [LP_Operation].[GetDigitoVerificadorPersonasBrasil]    Script Date: 6/29/2022 3:39:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [LP_Operation].[GetDigitoVerificadorPersonasBrasil]
(
	@DigitoVerificador CHAR(1)
)
RETURNS Char(1)

AS
BEGIN
	Declare @NroASumar int = 3
	Declare @Suma int = 0 
	Declare @ReturnValue Char(1)

	IF @DigitoVerificador <> 'X'
	BEGIN
	SET @Suma = @DigitoVerificador + @NroASumar
	END 

	IF @DigitoVerificador = 'X' 
	BEGIN 
		SET @ReturnValue = '2'  
		return @ReturnValue
	END 


	IF @DigitoVerificador < 7 
	BEGIN 
			SET @ReturnValue = @Suma  
	END 
	ELSE IF @DigitoVerificador = 7 
	BEGIN 
			SET @ReturnValue = 'x'  
	END 
	ELSE IF @DigitoVerificador = 8 
	BEGIN 
			SET @ReturnValue = '0'  
	END 
	ELSE IF @DigitoVerificador = 9 
	BEGIN 
			SET @ReturnValue = '1'  
	END 
	return @ReturnValue
END
