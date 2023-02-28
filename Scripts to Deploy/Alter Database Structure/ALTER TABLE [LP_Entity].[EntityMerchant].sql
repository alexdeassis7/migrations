IF COL_LENGTH ('LP_Entity.EntityMerchant','EmailsToReport') IS NULL
BEGIN
	ALTER TABLE [LP_Entity].[EntityMerchant] ADD EmailsToReport VARCHAR(MAX);
END;
GO
	UPDATE [LP_Entity].[EntityMerchant] SET [EmailsToReport] = 'xihu@payoneer.com' WHERE [Description] = 'Payoneer - ARG';
	UPDATE [LP_Entity].[EntityMerchant] SET [EmailsToReport] = 'patricia.mcquillan@thunes.com' WHERE [Description] = 'Thunes Argentina';
GO