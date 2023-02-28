DECLARE @countryId INT;

SET @countryId = (SELECT [idCountry]
FROM [LP_Location].[Country]
  WHERE Name = 'PERU'
)

DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

set @idProvider = (SELECT [idProvider] from [LP_Configuration].[Provider] where Code = 'BCPPER')

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE Code = 'SCM' AND idCountry = @countryId)


INSERT INTO [LP_Configuration].[InternalStatus]
([Code] ,[Name],[Description],[idProvider],[idCountry],[Active],[OP_InsDateTime],[OP_UpdDateTime],[DB_InsDateTime],[DB_UpdDateTime],[idInternalStatusType],[isError],[FinalStatus])
VALUES
('RETURNED','The payout has been returned','The payout has been returned',@idProvider,@countryId,1,GETDATE(),GETDATE(),GETDATE(),GETDATE()
,@idInternalStatusType,1,1),
('RECALLED'
,'The payout has been recalled'
,'The payout has been recalled'
,@idProvider
,@countryId
,1
,GETDATE()
,GETDATE()
,GETDATE()
,GETDATE()
,@idInternalStatusType
,1
,1),
('OnHold'
,'The payout has been put on hold'
,'The payout has been put on hold'
,@idProvider
,@countryId
,1
,GETDATE()
,GETDATE()
,GETDATE()
,GETDATE()
,@idInternalStatusType
,1
,1)