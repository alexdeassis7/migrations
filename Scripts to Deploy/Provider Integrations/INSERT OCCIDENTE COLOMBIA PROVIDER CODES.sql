BEGIN TRAN

DECLARE @idCountryColombia			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCurrencyTypeColombia		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

set @idCountryColombia = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'COL')
set @idCurrencyTypeColombia = (SELECT idCurrencyType FROM LP_Configuration.CurrencyType where Code = 'COP')

DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SELECT @idProvider = idProvider FROM [LP_Configuration].[Provider]
WHERE idCountry = @idCountryColombia and Code = 'OCCIDENTE'

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE idCountry = @idCountryColombia AND Code = 'SCM')

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountryColombia, 1, 'R07', 'ERROR ACCOUNT INNACTIVE OR BLOCKED', 'ERROR ACCOUNT INNACTIVE OR BLOCKED', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R19', 'ERROR ACCOUNT INVALID', 'ERROR ACCOUNT INVALID', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R62', 'ERROR ACCOUNT NOT OPEN', 'ERROR ACCOUNT NOT OPEN', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R13', 'ERROR ACCOUNT NOT EXISTS', 'ERROR ACCOUNT NOT EXISTS', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R52', 'ERROR ACCOUNT DISABLED', 'ERROR ACCOUNT DISABLED', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R51', 'ERROR ACCOUNT BENEFICIARY DOCUMENT ID NOT MATCH', 'ERROR ACCOUNT BENEFICIARY DOCUMENT ID NOT MATCH', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R14', 'ERROR ACCOUNT INVALID STRUCTURE', 'ERROR ACCOUNT INVALID STRUCTURE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R04', 'ERROR ACCOUNT INVALID NUMBER', 'ERROR ACCOUNT INVALID NUMBER', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R17', 'ERROR ACCOUNT INVALID BENEFICIARY DOCUMENT', 'ERROR ACCOUNT INVALID BENEFICIARY DOCUMENT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R20', 'ERROR ACCOUNT FROZEN', 'ERROR ACCOUNT FROZEN', @idInternalStatusType, 1, 1), 
(@idProvider, @idCountryColombia, 1, 'OK2', 'POR APLICAR EN ENTIDAD DE ACH', 'POR APLICAR EN ENTIDAD DE ACH', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryColombia, 1, 'OK', 'El archivo se recibió exitosamente', 'El archivo se recibió exitosamente', @idInternalStatusType, 0, 0)

DECLARE @idLPInternalError INT

-- IN PROGRESS
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '200'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('OK2')

--REJECTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R19','R62','R13','R52','R14','R04','R20')

--ERROR BANK ACCOUNT CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R07')

--ERROR BENEFICIARY DOCUMENT ID INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R51')

--ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R17')

COMMIT TRAN