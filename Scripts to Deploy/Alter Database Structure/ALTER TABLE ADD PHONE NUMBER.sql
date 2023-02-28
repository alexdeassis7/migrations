BEGIN TRAN
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[LP_CustomerInformation].[TransactionCustomerInfomation]') 
         AND name = 'SenderPhoneNumber'
)
BEGIN
	ALTER TABLE [LP_CustomerInformation].[TransactionCustomerInfomation]
		ADD [SenderPhoneNumber]					[LP_Common].[LP_F_C150] NULL
END

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[LP_Operation].[TransactionRecipientDetail]') 
         AND name = 'RecipientPhoneNumber'
)
BEGIN
		ALTER TABLE [LP_Operation].[TransactionRecipientDetail]
		ADD [RecipientPhoneNumber]					[LP_Common].[LP_F_C150] NULL
END
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[LP_Operation].[TransactionPayinDetail]') 
         AND name = 'PayerPhoneNumber'
)
BEGIN
		ALTER TABLE [LP_Operation].[TransactionPayinDetail]
		ADD [PayerPhoneNumber]					[LP_Common].[LP_F_C150] NULL,
		[PayerEmail]					[LP_Common].[LP_F_C150] NULL
END
ROLLBACK