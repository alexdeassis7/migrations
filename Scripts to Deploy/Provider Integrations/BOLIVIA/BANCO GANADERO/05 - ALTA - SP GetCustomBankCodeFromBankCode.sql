USE [LocalPaymentPROD]
GO

/****** Object:  StoredProcedure [LP_Operation].[GetLastInternalBatchNumberByProviderId]    Script Date: 8/7/2022 17:30:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Alfredo Severo
-- Create date: 08/07/2022
-- Description:	Obtiene el Custom BankCode en base a un BankCode y a un Provider especifico
-- =============================================

CREATE PROCEDURE [LP_Operation].[GetCustomBankCodeFromBankCode]
(
	@ProviderId INT,
	@BankCode VARCHAR(4),
	@CustomBankCode VARCHAR OUTPUT
)
AS BEGIN
    
	 SELECT @customCode = CustomBankCode
	 FROM LP_Configuration.BankCode_Lookup
	 WHERE idProvider = @ProviderId
	 AND BankCode = @BankCode

	 SELECT ISNULL(@customCode, '-1')
END;
GO


