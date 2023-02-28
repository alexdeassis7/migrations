IF COL_LENGTH('[LP_Operation].[TransactionLot]', 'Notified') IS NULL
BEGIN
	ALTER TABLE [LP_Operation].[TransactionLot]  ADD Notified DATETIME NULL;
END
GO

UPDATE [LP_Operation].[TransactionLot] SET [Notified] = GETDATE();
GO