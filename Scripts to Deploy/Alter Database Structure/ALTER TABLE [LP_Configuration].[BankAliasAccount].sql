BEGIN TRAN

DECLARE @idCountry      			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
DECLARE @idProvider      			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = 'MEX' AND [Active] = 1 )
SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'SRM' AND [idCountry] = @idCountry AND [Active] = 1 )

IF COL_LENGTH('[LP_Operation].[BankAliasAccount]','idProvider') IS NULL
BEGIN
	ALTER TABLE [LP_Operation].[BankAliasAccount] ADD idProvider [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NULL DEFAULT 0;
END

UPDATE [LP_Operation].[BankAliasAccount] SET [idProvider] = @idProvider;

ROLLBACK