BEGIN TRAN

IF COL_LENGTH('[LP_Configuration].[Blacklist]','isSender') IS NULL
BEGIN
	ALTER TABLE [LP_Configuration].[Blacklist] ADD isSender [LP_Common].[LP_F_C40] NOT NULL DEFAULT 0;
END

ROLLBACK