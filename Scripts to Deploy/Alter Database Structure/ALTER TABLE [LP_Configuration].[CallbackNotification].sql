BEGIN TRAN
ALTER TABLE [LP_Configuration].[CallbackNotification] 
ADD [Signature] BIT
ROLLBACK