INSERT INTO [LP_Configuration].[InternalStatus] 
(Code,Name,Description,idProvider,idCountry,Active, idInternalStatusType,isError,FinalStatus)
SELECT
'AML','Rejected by AML','Rejected by AML',idProvider,idCountry,1,6,1,1
FROM [LP_Configuration].[Provider]