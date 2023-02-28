USE [LocalPaymentPROD]
GO

/****** Object:  StoredProcedure [LP_Operation].[CheckDuplicity]    Script Date: 23/6/2022 20:00:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [LP_Operation].[CheckDuplicity]
		@amount [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@beneficiaryName VARCHAR(60),
		@identification [LP_Common].[LP_F_C50],
	    @country_code			[LP_Common].[LP_F_C3]
AS

--DECLARE @Amount [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
DECLARE @AmountSearch [LP_Common].[LP_F_DECIMAL]
DECLARE @idEntityUser [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
DECLARE @idEntityAccount [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
SET @AmountSearch= [LP_Common].[fnConvertIntToDecimalAmount](@Amount)

SELECT
		@idEntityUser		= [EU].[idEntityUser]
		, @idEntityAccount	= [EA].[idEntityAccount]
	FROM
		[LP_Entity].[EntityUser]							[EU]
			INNER JOIN [LP_Security].[EntityApiCredential]	[EAC]	ON [EAC].[idEntityUser] = [EU].[idEntityUser]
			INNER JOIN [LP_Security].[EntityAccountUser]	[EAU]	ON [EAU].[idEntityUser] = [EU].[idEntityUser]
			INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[idEntityAccount] = [EAU].[idEntityAccount]
			INNER JOIN [LP_Location].[Country]				[C]		ON [C].[idCountry] = [EU].[idCountry]
	WHERE
		[EU].[Active] = 1
		AND [EAU].[Active] = 1
		AND [EA].[Active] = 1
		AND [C].[Active] = 1
		AND [EA].[IsAdmin] = 1
		AND [C].[ISO3166_1_ALFA003] = @country_code
		AND [EAC].[Identification] = @identification


SELECT COUNT(Recipient)
  FROM [LP_Operation].[Transaction] T WITH(NOLOCK)
  inner join [LP_Operation].[TransactionDetail] TD WITH(NOLOCK) ON T.idTransaction=TD.idTransaction
  Inner join [LP_Operation].[TransactionRecipientDetail] TRD WITH(NOLOCK) ON TRD.idTransaction=T.idTransaction
  Where NetAmount=@AmountSearch and Recipient=@beneficiaryName and CAST(TransactionAcreditationDate AS DATE) = CAST( GETDATE() AS DATE) AND T.[idEntityUser]=@idEntityUser
GO


