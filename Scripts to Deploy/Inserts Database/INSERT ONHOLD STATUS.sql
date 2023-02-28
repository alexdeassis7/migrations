BEGIN TRAN
DECLARE @transactiontypeId int
--INSERT STATUS 
INSERT INTO [LP_Common].[Status] (Code,Name,Description,Active,OP_InsDateTime,OP_UpdDateTime,DB_InsDateTime,DB_UpdDateTime)
VALUES
('OnHold','OnHold','The payout has been put on hold',1,GETDATE(),GETDATE(),GETDATE(),GETDATE())

--INSERT INTERNALSTATUS x Provider
INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
SELECT idProvider,p.idCountry,1,'Onhold','Waiting for authentication','Waiting for authentication', IST.idInternalStatusType,1,1 FROM [LP_Configuration].[Provider] P
INNER JOIN [LP_Configuration].[InternalStatusType] IST ON IST.idCountry = P.idCountry AND IST.Code = 'SCM'

ROLLBACK