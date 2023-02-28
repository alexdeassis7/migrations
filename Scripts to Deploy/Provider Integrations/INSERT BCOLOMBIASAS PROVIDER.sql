BEGIN TRAN
DECLARE @idCountryColombia			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCurrencyTypeColombia		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

set @idCountryColombia = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'COL')
set @idCurrencyTypeColombia = (SELECT idCurrencyType FROM LP_Configuration.CurrencyType where Code = 'COP')

DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
UPDATE LP_Configuration.[Provider] SET Name = 'Bancolombia - LP COLOMBIA SAS',Description = 'Bancolombia - LP COLOMBIA SAS' 
WHERE Code = 'BCOLOMBIA'


INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'BCOLOMBIA2',
	'Bancolombia - LP SAS',
	'Bancolombia - LP SAS',
	@idCountryColombia,
	1
)

set @idProvider = SCOPE_IDENTITY()  

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idPayWayService = (SELECT idPayWayService FROM [LP_Configuration].[PayWayServices] WHERE idCountry = @idCountryColombia AND Code = 'BANKDEPO')

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)
DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE idCountry = @idCountryColombia AND Code = 'SCM')

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
SELECT @idProvider, @idCountryColombia,1,Code,Name,Description,@idInternalStatusType,isError,FinalStatus 
FROM [LP_Configuration].[InternalStatus] WHERE idProvider = 9


DECLARE @idLPInternalError INT

-- EXECUTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '300'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('OKA', 'OKB', 'OKD', 'OKE', 'OKF', 'OKK', 'OKM', 'OKO', 'OKQ', 'OKR', 'OKT', 'OK4', 'OK7', 'OKZ')

-- RECEIVED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '100'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE [Code] IN ('RECI') AND idProvider = @idProvider

-- IN PROGRESS
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '200'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('OK2', 'OK1', 'PEND')

SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D06', 'D07', 'D34', 'RC2', 'RC5', 'R03', 'R08', 'R13', 'R15', 'P09', 'D49', 'D53')


-- 701
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D08', 'D10', 'D31', 'M05', 'M06', 'RC1', 'RC6', 'R07', 'R09', 'R11', 'R12', 'R14', 'R16')

-- 702
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D24')


-- 705
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D25', 'D39', 'D41', 'M09', 'R04', 'R21', 'R23', 'C25')

-- 706
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D21')

-- 707
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('A02', 'C24', 'P30', 'P36', 'C11', 'D32', 'D33', 'D42', 'M07', 'A04', 'C03', 'C04', 'C27', 'C16', 'C26')

-- 710
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D11', 'D18')


-- 712
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '712'


INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D87')
ROLLBACK