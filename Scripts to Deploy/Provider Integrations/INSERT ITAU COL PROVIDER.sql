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
	'ITAUCOL',
	'Banco ITAU',
	'Itau Corpbanca Colombia Sa',
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
(@idProvider, @idCountry, 1, 'R02', 'ERROR ACCOUNT CLOSED', 'ERROR ACCOUNT CLOSED', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R03', 'ERROR ACCOUNT NOT OPENED', 'ERROR ACCOUNT NOT OPENED', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R04', 'ERROR INVALID ACCOUNT', 'ERROR INVALID ACCOUNT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R06', 'ERROR PAYMENT WAS RETURNED BY THE BANK', 'ERROR PAYMENT WAS RETURNED BY THE BANK', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R07', 'ERROR AUTHORIZATION WAS REVOKE BY THE CLIENT', 'ERROR AUTHORIZATION WAS REVOKE BY THE CLIENT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R12', 'ERROR BANK BRANCH INCORRECT', 'ERROR BANK BRANCH INCORRECT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R16', 'ERROR ACCOUNT IS LOCKED OR INACTIVE', 'ERROR ACCOUNT IS LOCKED OR INACTIVE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R17', 'ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT', 'ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R20', 'ERROR ACCOUNT IS NOT ENABLED TO RECEIVE PAYMENTS', 'ERROR ACCOUNT IS NOT ENABLED TO RECEIVE PAYMENTS', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R23', 'ERROR THE PAYMENT WAS RETURNED BY THE CLIENT', 'ERROR THE PAYMENT WAS RETURNED BY THE CLIENT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'AML', 'Rejected by AML', 'Rejected by AML', @idInternalStatusType, 1, 1),
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
AND [Code] IN ('REJECTED','R03','R04')

--ERROR BANK ACCOUNT CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R02')

--ERROR BANK BRANCH INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '704'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R12')

--ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R06','R07','R16','R20','R23')

--ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R17')

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