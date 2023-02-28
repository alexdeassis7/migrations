/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO


CREATE TABLE [LP_Configuration].[DocumentTypeByProvider]
	(
	idDocumentType int NOT NULL IDENTITY (1, 1),
	idProvider int NOT NULL,
	DocumentTypeInput int NOT NULL,
	DocumentTypeOutPut Varchar(50) NOT NULL,
	CreatedDate datetime NOT NULL
	)  ON [PRIMARY]
GO

ALTER TABLE [LP_Configuration].[DocumentTypeByProvider] ADD CONSTRAINT
	PK_LP_Configuration_DocumentTypeByProvider_1 PRIMARY KEY CLUSTERED 
	(
	idDocumentType
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE [LP_Configuration].[DocumentTypeByProvider] SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
