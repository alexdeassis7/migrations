BEGIN TRAN
ALTER TABLE [LP_Retentions_ARG].[TransactionCertificate] 
ADD [RefundDate] [LP_Common].[LP_A_OP_INSDATETIME] NULL
ROLLBACK
BEGIN TRAN
	ALTER TABLE [LP_Retentions_ARG].[TransactionCertificate]
	ALTER COLUMN [FileName] VARCHAR(120);
ROLLBACK