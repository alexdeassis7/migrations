BEGIN TRAN

DECLARE @idCountryColombia			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idCurrencyTypeColombia		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idProvider                 [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idInternalStatusType		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]



SET @idCountryColombia = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'COL')
SET @idCurrencyTypeColombia = (SELECT idCurrencyType FROM LP_Configuration.CurrencyType where Code = 'COP')
SET @idProvider = (SELECT idProvider FROM [LP_Configuration].[Provider] WHERE idCountry = @idCountryColombia and Code = 'ACCIVAL')
SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE idCountry = @idCountryColombia AND Code = 'SCM')

-- STATUS

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountryColombia, 1, 'R13', 'CUENTA NO ABIERTA', 'CUENTA NO ABIERTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R14', 'ID NO COINCIDE CON TITULAR DE LA CUENTA ', 'ID NO COINCIDE CON TITULAR DE LA CUENTA ', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'R35', 'CUENTA INACTIVA O BLOQUEADA', 'CUENTA INACTIVA O BLOQUEADA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'D07', 'CUENTA NO EXISTE', 'CUENTA NO EXISTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'D53', 'NO DE CUENTA INVALIDO', 'NO DE CUENTA INVALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryColombia, 1, 'AML', 'Rejected by AML', 'Rejected by AML', @idInternalStatusType, 1, 1)


DECLARE @idLPInternalError INT

--REJECTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('D07','D53','R13')

--ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT (REJECTED)
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R14')

--ERROR BANK ACCOUNT CLOSED (REJECTED)
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R35')

--REJECTED BY AML
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '718'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AML')

ROLLBACK