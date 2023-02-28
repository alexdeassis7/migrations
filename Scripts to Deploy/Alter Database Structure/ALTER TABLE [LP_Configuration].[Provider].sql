IF COL_LENGTH('[LP_Configuration].[Provider]','BatchFileTxLimit') IS NULL
BEGIN
	ALTER TABLE [LP_Configuration].[Provider] ADD BatchFileTxLimit INT;
END

UPDATE LP_Configuration.[Provider] SET BatchFileTxLimit = 195 WHERE Code = 'ITAU' AND idCountry = 44