BEGIN TRAN
DECLARE @transactiontypeId int
--INSERT STATUS 
INSERT INTO [LP_Common].[Status] (Code,Name,Description,Active,OP_InsDateTime,OP_UpdDateTime,DB_InsDateTime,DB_UpdDateTime)
VALUES
('Returned','Returned','The payout has been returned',1,GETDATE(),GETDATE(),GETDATE(),GETDATE())
,('Recalled','Recalled','The payout has been recalled',1,GETDATE(),GETDATE(),GETDATE(),GETDATE())

--INSERT TXS TYPE
INSERT INTO [LP_Configuration].[TransactionType] ([Code],[Name],[Description],[idCountry],[Active],[OP_InsDateTime],[OP_UpdDateTime],[DB_InsDateTime],[DB_UpdDateTime],[idTransactionGroup])
VALUES
('Return','Return', 'Return',1,1,GETDATE(),GETDATE(),GETDATE(),GETDATE(),10)
set @transactiontypeId = @@IDENTITY

INSERT INTO [LP_Configuration].[TransactionTypeProvider](idTransactionType,idProvider,Active)
VALUES(@transactiontypeId,8,1)

INSERT INTO [LP_Configuration].[TransactionType] ([Code],[Name],[Description],[idCountry],[Active],[OP_InsDateTime],[OP_UpdDateTime],[DB_InsDateTime],[DB_UpdDateTime],[idTransactionGroup])
VALUES
('Recall','Recall', 'Recall',1,1,GETDATE(),GETDATE(),GETDATE(),GETDATE(),10)
set @transactiontypeId = @@IDENTITY

INSERT INTO [LP_Configuration].[TransactionTypeProvider](idTransactionType,idProvider,Active)
VALUES(@transactiontypeId,8,1)

--INSERT INTERNALSTATUS x Provider
INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
SELECT idProvider,p.idCountry,1,'RETURNED','The payout has been returned','The payout has been returned', IST.idInternalStatusType,1,1 FROM [LP_Configuration].[Provider] P
INNER JOIN [LP_Configuration].[InternalStatusType] IST ON IST.idCountry = P.idCountry AND IST.Code = 'SCM'

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
SELECT idProvider,p.idCountry,1,'RECALLED','The payout has been recalled','The payout has been recalled', IST.idInternalStatusType,1,1 FROM [LP_Configuration].[Provider] P
INNER JOIN [LP_Configuration].[InternalStatusType] IST ON IST.idCountry = P.idCountry AND IST.Code = 'SCM'

ROLLBACK