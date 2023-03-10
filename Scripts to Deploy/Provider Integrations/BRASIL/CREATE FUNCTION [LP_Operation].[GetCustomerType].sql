USE [LocalPaymentPROD]
GO
/****** Object:  UserDefinedFunction [LP_Operation].[GetCustomerType]    Script Date: 6/29/2022 3:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [LP_Operation].[GetCustomerType]
(
	@DocDeEmpresa		VARCHAR(20)
)
RETURNS Char(1)
AS
BEGIN
	
	Declare @ReturnValue Char(1)

	IF LEN(@DocDeEmpresa) = 14
	BEGIN 
			SET @ReturnValue = '1'  
	END 
	ELSE IF LEN(@DocDeEmpresa) = 11
	BEGIN 
			SET @ReturnValue = '2'  
	END 
	
	return @ReturnValue	-- Return the result of the function

END
