BEGIN TRAN

DECLARE @idCountry			   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idCurrencyType		   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idProvider			   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idPayWayService	   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idInternalStatusType  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountry = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'ARG')
SET @idCurrencyType = (SELECT idCurrencyType FROM LP_Configuration.CurrencyType where Code = 'COP')

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'ITAU',
	'Banco ITAU',
	'Banco Itau Argentina SA',
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
(@idProvider, @idCountry, 1, 'RETURNED','The payout has been returned','The payout has been returned', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'RECALLED','The payout has been recalled','The payout has been recalled', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'OnHold','Waiting for authentication','Waiting for authentication', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'I8', 'INSTRUMENTO VENCIDO', 'INSTRUMENTO VENCIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'I9', 'INSTRUMENTO BLOQUEADO O CON ORDEN DE NO PAGAR (F)', 'INSTRUMENTO BLOQUEADO O CON ORDEN DE NO PAGAR (F)', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'IA', 'INSTRUMENTO EN CUSTODIA', 'INSTRUMENTO EN CUSTODIA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'IB', 'INSTRUMENTO CESIONADO', 'INSTRUMENTO CESIONADO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '99', 'DOCUMENTO ERRONEO', 'DOCUMENTO ERRONEO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'IC', 'EN GESTION DE PAGO', 'EN GESTION DE PAGO', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'IG', 'SALDO INSUFICIENTE MOVIMIENTO EN RECICLE', 'SALDO INSUFICIENTE MOVIMIENTO EN RECICLE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'IH', 'ERROR ENVIO DE TRANSFERENCIA CCI', 'ERROR ENVIO DE TRANSFERENCIA CCI', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'II', 'ERROR TRANSFERENCIA RECHAZADA', 'ERROR TRANSFERENCIA RECHAZADA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B1', 'ERROR EN EMPRESA', 'ERROR EN EMPRESA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B2', 'ERROR EN NRO.BENEFICIARIO', 'ERROR EN NRO.BENEFICIARIO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B3', 'ERROR EN NOM.BEN..ALERTA', 'ERROR EN NOM.BEN..ALERTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B4', 'ERROR EN CUENTA.ALERTA', 'ERROR EN CUENTA.ALERTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B9', 'ERROR EN CBU', 'ERROR EN CBU', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'BA', 'ERROR EN DOCUM.', 'ERROR EN DOCUM.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W1', 'ERROR EN EMPRESA', 'ERROR EN EMPRESA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W2', 'ERROR EN NRO.BENEFICIARIO', 'ERROR EN NRO.BENEFICIARIO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W3', 'ERROR EN NOM.BEN. NO EMITE', 'ERROR EN NOM.BEN. NO EMITE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W4', 'ERROR EN CUENTA.  NO EMITE', 'ERROR EN CUENTA.  NO EMITE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W9', 'ERROR EN CBU NO ACREDITA', 'ERROR EN CBU NO ACREDITA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'WA', 'ERROR EN DOCUM. NO EMITE', 'ERROR EN DOCUM. NO EMITE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'L1', 'ERR.EN EMPRESA', 'ERR.EN EMPRESA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'L2', 'ERR.EN MONEDA', 'ERR.EN MONEDA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'L3', 'ERR.EN IMPORTE', 'ERR.EN IMPORTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'L4', 'ERR.EN CUENTA', 'ERR.EN CUENTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'QL', 'CBU INVALIDO', 'CBU INVALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'QO', 'ERROR BANCO DESTINO CBU', 'ERROR BANCO DESTINO CBU', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'QW', 'DIFIERE DOCUMENTO PAGO/BENEFICIARIO', 'DIFIERE DOCUMENTO PAGO/BENEFICIARIO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'QX', 'NO EXISTE BENEFICIARIO', 'NO EXISTE BENEFICIARIO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'T0', 'IMPORTE A ACREDITAR INVALIDO EN PIE', 'IMPORTE A ACREDITAR INVALIDO EN PIE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'I7', 'ORDEN PAGADA (F)', 'ORDEN PAGADA (F)', @idInternalStatusType, 0, 1),
(@idProvider, @idCountry, 1, 'O9', 'TIPO DE DOCUMENTO INVALIDO EN PAGO', 'TIPO DE DOCUMENTO INVALIDO EN PAGO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'OA', 'NRO DE DOCUMENTO INVALIDO EN PAGO', 'NRO DE DOCUMENTO INVALIDO EN PAGO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B5', 'ERROR EN FECHAS ALERTA', 'ERROR EN FECHAS ALERTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B6', 'ERROR EN DOMICIL. ALERTA', 'ERROR EN DOMICIL. ALERTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B7', 'ERROR EN ESTADO', 'ERROR EN ESTADO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B8', 'ERROR EN SUC. DE ENTREGA', 'ERROR EN SUC. DE ENTREGA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W5', 'ERROR EN FECHAS  NO EMITE', 'ERROR EN FECHAS  NO EMITE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W6', 'ERROR EN DOMICIL.  NO EMITE', 'ERROR EN DOMICIL.  NO EMITE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W8', 'ERROR EN SUC. DE ENTREGA NO EMITE', 'ERROR EN SUC. DE ENTREGA NO EMITE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'T3', 'MONEDA DEBE SER IGUAL CR', 'MONEDA DEBE SER IGUAL CR', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'AML', 'Rejected by AML', 'Rejected by AML', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibio exitosamente', 'El archivo se recibio exitosamente', @idInternalStatusType, 0, 0),

(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibio exitosamente', 'El archivo se recibio exitosamente', @idInternalStatusType, 0, 0)
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibio exitosamente', 'El archivo se recibio exitosamente', @idInternalStatusType, 0, 0)
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibio exitosamente', 'El archivo se recibio exitosamente', @idInternalStatusType, 0, 0)
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibio exitosamente', 'El archivo se recibio exitosamente', @idInternalStatusType, 0, 0)
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibio exitosamente', 'El archivo se recibio exitosamente', @idInternalStatusType, 0, 0)
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibio exitosamente', 'El archivo se recibio exitosamente', @idInternalStatusType, 0, 0)
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
AND [Code] IN ('REJECTED','B5','B6','B7','B8')

--ERROR BANK ACCOUNT CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('I8','I9','IA','IB')

--ERROR AMOUNT INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('L3')

--ERROR BANK INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('QO')

--ERROR BENEFICIARY DOCUMENT ID INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('OA','99')

--ERROR BENEFICIARY NAME INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('B3','W3')

--ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('IG','IH','II')

--ERROR INVALID DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('B5','L5')

--ERROR ACCOUNT TYPE INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '709'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('B4','L4','W4')

--ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('QW')

--ERROR ACCOUNT OF OTHER CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('T3')


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