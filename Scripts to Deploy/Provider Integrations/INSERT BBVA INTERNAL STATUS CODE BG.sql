begin tran

DECLARE @idProvider int
DECLARE @idCountry int

SELECT @idCountry = idCountry FROM LP_Location.Country Where Code= 'ARS'

SELECT @idProvider = idProvider FROM [LP_Configuration].[Provider] where Code = 'BBBVA' --EJECUTAR TAMBIEN CON BBBVATP

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SELECT @idInternalStatusType = idInternalStatusType FROM LP_Configuration.InternalStatusType
Where idCountry = @idCountry and Code = 'SCM'

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountry, 1, 'BG', 'CUIT DIFIERE DE CREDENCIAL', 'CUIT DIFIERE DE CREDENCIAL', @idInternalStatusType, 1, 1)

DECLARE @idLPInternalError as INT

SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '714'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('BG')

ROLLBACK