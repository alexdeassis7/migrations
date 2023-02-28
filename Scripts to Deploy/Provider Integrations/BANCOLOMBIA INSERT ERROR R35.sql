DECLARE @idProvider INT,
		@idCountry INT,
		@idInternalStatusType INT,
		@idLPInternalError as INT

SELECT @idCountry = idCountry FROM LP_Location.Country Where Code= 'COP'
SELECT @idProvider = idProvider FROM LP_Configuration.Provider WHERE Code = 'BCOLOMBIA' and idCountry = @idCountry
SELECT @idInternalStatusType = idInternalStatusType FROM LP_Configuration.InternalStatusType
Where idCountry = @idCountry and Code = 'SCM'

INSERT INTO [LP_Configuration].[InternalStatus] 
(Code,Name,Description,idProvider,idCountry,Active, idInternalStatusType,isError,FinalStatus)
VALUES ( 'R35','FROZEN ACCOUNT','FROZEN ACCOUNT',@idProvider,@idCountry,1,6,1,1)

SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = 701

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('R35')
