/*
   lunes, 30 de mayo de 202213:47:37
   User: asevero
   Server: 172.31.78.48
   Database: LocalPaymentPROD
   Application: 
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION;
SET QUOTED_IDENTIFIER ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
COMMIT;
BEGIN TRANSACTION;
GO
CREATE TABLE [LP_Operation].[ProviderInternalBatch] (
BatchNumber INT NOT NULL,
ProviderId INT NOT NULL,
LastUpdatedAt DATETIME NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX IX_Batch_Provider
ON [LP_Operation].[ProviderInternalBatch](BatchNumber)
WITH(STATISTICS_NORECOMPUTE=OFF, IGNORE_DUP_KEY=OFF, ALLOW_ROW_LOCKS=ON, ALLOW_PAGE_LOCKS=ON)
ON [PRIMARY];
GO
ALTER TABLE [LP_Operation].[ProviderInternalBatch] SET(LOCK_ESCALATION=TABLE);
GO
COMMIT;
