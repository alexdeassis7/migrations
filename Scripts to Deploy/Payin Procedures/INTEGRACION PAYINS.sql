BEGIN TRAN

CREATE TABLE LP_Operation.TransactionPayinDetail(
	idTransactionPayinDetail [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1) PRIMARY KEY,
	idTransaction [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	PayerName [LP_Common].[LP_F_C50] NOT NULL,
	PayerDocumentNumber [LP_Common].[LP_F_C50] NOT NULL,
	PayerAccountNumber [LP_Common].[LP_F_C50] NOT NULL,
	PaymentMethodCode [LP_Common].[LP_F_C10] NOT NULL,
	MerchantId VARCHAR(22) NOT NULL,
	ExpirationDate	DATETIME NOT NULL,
	[OP_InsDateTime] [LP_Common].[LP_A_OP_INSDATETIME] NOT NULL DEFAULT GETDATE(),
	[OP_UpdDateTime] [LP_Common].[LP_A_OP_UPDDATETIME] NOT NULL DEFAULT GETDATE(),
	[DB_InsDateTime] [LP_Common].[LP_A_DB_INSDATETIME] NOT NULL DEFAULT GETDATE(),
	[DB_UpdDateTime] [LP_Common].[LP_A_DB_UPDDATETIME] NOT NULL DEFAULT GETDATE(),
)

ALTER TABLE [LP_Operation].TransactionPayinDetail  WITH CHECK ADD  CONSTRAINT [FK_LP_Operation_TransactionPayinDetail_Transaction] FOREIGN KEY([idTransaction])
REFERENCES [LP_Operation].[Transaction] ([idTransaction])
GO

ALTER TABLE [LP_Operation].TransactionPayinDetail CHECK CONSTRAINT [FK_LP_Operation_TransactionPayinDetail_Transaction]


COMMIT TRAN