BEGIN TRAN

DECLARE @idCountry			   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idCurrencyType		   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idProvider			   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idPayWayService	   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idInternalStatusType  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountry = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'COL')
SET @idCurrencyType = (SELECT idCurrencyType FROM LP_Configuration.CurrencyType where Code = 'COP')

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'SCOTIACOL',
	'Scotiabank',
	'COLPATRIA Scotiabank',
	@idCountry,
	1
)

SET @idProvider = SCOPE_IDENTITY()  

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

SET @idPayWayService = (SELECT idPayWayService FROM [LP_Configuration].[PayWayServices] WHERE idCountry = @idCountry AND Code = 'BANKDEPO')

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE idCountry = @idCountry AND Code = 'SCM')

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountry, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountry, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'RETURNED','The payout has been returned','The payout has been returned', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'RECALLED','The payout has been recalled','The payout has been recalled', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'R02', 'ERROR BANK ACCOUNT CLOSED', 'ERROR BANK ACCOUNT CLOSED', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R18', 'ERROR AMOUNT INCORRECT', 'ERROR AMOUNT INCORRECT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R10', 'ERROR BENEFICIARY DOCUMENT ID INVALID', 'ERROR BENEFICIARY DOCUMENT ID INVALID', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R11', 'ERROR BENEFICIARY NAME INCORRECT', 'ERROR BENEFICIARY NAME INCORRECT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R13', 'ERROR BANK PROCESSING', 'ERROR BANK PROCESSING', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R03', 'ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT', 'ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibio exitosamente', 'El archivo se recibio exitosamente', @idInternalStatusType, 0, 0)

DECLARE @idLPInternalError INT
-- EXECUTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '300'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('EXECUTED')

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
AND [Code] IN ('PEND')

--REJECTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED','R04','R09','R12','R35','R80','C01','R83','C30','C05')

--ERROR BANK ACCOUNT CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R02')

--ERROR AMOUNT INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R18','R19','R82')

--ERROR BANK INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R23')

--ERROR BENEFICIARY DOCUMENT ID INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R10','R22','R31')

--ERROR BENEFICIARY NAME INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R11','R32')

--ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R13','R16','R17','R21','R24','R25','R26','R30','R38','R40','R50','R65','R81')

--ERROR INVALID DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R33','R34')

--ERROR ACCOUNT TYPE INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '709'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R28')

--ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R03','C04','C32')

--ERROR ACCOUNT OF OTHER CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R37')

ROLLBACK