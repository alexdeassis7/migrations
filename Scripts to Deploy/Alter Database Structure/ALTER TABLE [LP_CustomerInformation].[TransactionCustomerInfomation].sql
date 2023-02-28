BEGIN TRAN
ALTER TABLE [LP_CustomerInformation].[TransactionCustomerInfomation]
ALTER COLUMN [Address] VARCHAR(300);

ALTER TABLE [LP_CustomerInformation].[TransactionCustomerInfomation]
ALTER COLUMN [SenderAddress] VARCHAR(300);

ALTER TABLE [LP_CustomerInformation].[TransactionCustomerInfomation]
ADD ZipCode VARCHAR(300)
,SenderZipCode VARCHAR(300);

COMMIT