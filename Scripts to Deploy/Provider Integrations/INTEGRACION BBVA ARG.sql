begin tran

ALTER TABLE LP_Operation.Ticket ADD TicketAlternative8 VARCHAR(8)

DECLARE @idProvider int
DECLARE @idCountry int

SELECT @idCountry = idCountry FROM LP_Location.Country Where Code= 'ARS'

INSERT INTO [LP_Configuration].[Provider](Code, Name, Description, idCountry, Active)
VALUES('BBBVA', 'Banco BBVA Frances', 'Banco BBVA Frances', @idCountry, 1)

SET @idProvider = SCOPE_IDENTITY()

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SELECT @idPayWayService = idPayWayService
FROM LP_Configuration.PayWayServices
WHERE Code = 'BANKDEPO' AND idCountry = @idCountry AND Active = 1

SELECT @idPayWayService


INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)


DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SELECT @idInternalStatusType = idInternalStatusType FROM LP_Configuration.InternalStatusType
Where idCountry = @idCountry and Code = 'SCM'



INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountry, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountry, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'I8', 'INSTRUMENTO VENCIDO', 'INSTRUMENTO VENCIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'I9', 'INSTRUMENTO BLOQUEADO O CON ORDEN DE NO PAGAR (F)', 'INSTRUMENTO BLOQUEADO O CON ORDEN DE NO PAGAR (F)', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'IA', 'INSTRUMENTO EN CUSTODIA', 'INSTRUMENTO EN CUSTODIA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'IB', 'INSTRUMENTO CESIONADO', 'INSTRUMENTO CESIONADO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '99', 'DOCUMENTO ERRONEO', 'DOCUMENTO ERRONEO', @idInternalStatusType, 1, 1),
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
(@idProvider, @idCountry, 1, 'IC', 'EN GESTION DE PAGO', 'EN GESTION DE PAGO', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'IG', 'SALDO INSUFICIENTE MOVIMIENTO EN RECICLE', 'SALDO INSUFICIENTE MOVIMIENTO EN RECICLE', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'IH', 'ERROR ENVIO DE TRANSFERENCIA CCI', 'ERROR ENVIO DE TRANSFERENCIA CCI', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'II', 'ERROR TRANSFERENCIA RECHAZADA', 'ERROR TRANSFERENCIA RECHAZADA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'O9', 'TIPO DE DOCUMENTO INVALIDO EN PAGO', 'TIPO DE DOCUMENTO INVALIDO EN PAGO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'OA', 'NRO DE DOCUMENTO INVALIDO EN PAGO', 'NRO DE DOCUMENTO INVALIDO EN PAGO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B5', 'ERROR EN FECHAS ALERTA', 'ERROR EN FECHAS ALERTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B6', 'ERROR EN DOMICIL. ALERTA', 'ERROR EN DOMICIL. ALERTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B7', 'ERROR EN ESTADO', 'ERROR EN ESTADO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'B8', 'ERROR EN SUC. DE ENTREGA', 'ERROR EN SUC. DE ENTREGA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W5', 'ERROR EN FECHAS  NO EMITE', 'ERROR EN FECHAS  NO EMITE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W6', 'ERROR EN DOMICIL.  NO EMITE', 'ERROR EN DOMICIL.  NO EMITE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'W8', 'ERROR EN SUC. DE ENTREGA NO EMITE', 'ERROR EN SUC. DE ENTREGA NO EMITE', @idInternalStatusType, 1, 1)



-- ERROR_ACCOUNT_INCORRECT
DECLARE @idLPInternalError as INT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('B4', 'B9', 'W4', 'W9', 'L4', 'QL', 'QO', 'QC', 'QM', 'QN')

-- ERROR_AMOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('L2', 'L3', 'T0', 'OI', 'O4', 'OM', 'OS', 'OU', 'QB', 'Q1', 'OZ')

-- ERROR_BANK_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('I8', 'I9', 'IA', 'IB', 'IG', 'IH', 'II', 'O0', 'O1', 'O2', 'O5', 'O6', 'O7', 'O8', 'OB', 'OC', 'OD', 'OE', 'OF', 'OJ', 'OK', 'ON', 'OO', 'OP', 'OQ', 'QD', 'Q0', 'Q2')

-- ERROR_BENEFICIARY_DOCUMENT_ID_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('B2', 'B1', 'BA', 'W1', 'W2', 'WA', 'QW', '99', 'O9', 'OA', 'O3')

-- ERROR_BENEFICIARY_NAME_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('B3', 'W3', 'QX', 'L1')

-- ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('B5', 'B6', 'B7', 'B8', 'W5', 'W6', 'W8', 'OH', 'OT', 'OV', 'OW', 'OX', 'QA', 'QP', 'QQ', 'QR')

-- ERROR INVALID DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('OG', 'Q5', 'Q6', 'Q7', 'Q8', 'Q9', 'OL', 'OR', 'OY', 'QS', 'QT', 'QU', 'QV')

-- ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('Q4','Q3')

-- ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '712'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('QE','QE','QJ','QK')

-- ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '713'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('QF', 'QG', 'QH', 'QI')


commit tran



-- INSERT NEW CODES
insert into LP_Configuration.InternalStatus(idProvider, idCountry,[Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(13, 1, 1, 'IC', 'EN GESTION DE PAGO', 'EN GESTION DE PAGO', 3, 0, 0),
(13, 1, 1, 'IG', 'SALDO INSUFICIENTE MOVIMIENTO EN RECICLE', 'SALDO INSUFICIENTE MOVIMIENTO EN RECICLE', 3, 0, 0),
(13, 1, 1, 'IH', 'ERROR ENVIO DE TRANSFERENCIA CCI', 'ERROR ENVIO DE TRANSFERENCIA CCI', 3, 1, 1),
(13, 1, 1, 'II', 'ERROR TRANSFERENCIA RECHAZADA', 'ERROR TRANSFERENCIA RECHAZADA', 3, 1, 1),
(13, 1, 1, 'O9', 'TIPO DE DOCUMENTO INVALIDO EN PAGO', 'TIPO DE DOCUMENTO INVALIDO EN PAGO', 3, 1, 1),
(13, 1, 1, 'OA', 'NRO DE DOCUMENTO INVALIDO EN PAGO', 'NRO DE DOCUMENTO INVALIDO EN PAGO', 3, 1, 1),
(13, 1, 1, 'B5', 'ERROR EN FECHAS ALERTA', 'ERROR EN FECHAS ALERTA', 3, 1, 1),
(13, 1, 1, 'B6', 'ERROR EN DOMICIL. ALERTA', 'ERROR EN DOMICIL. ALERTA', 3, 1, 1),
(13, 1, 1, 'B7', 'ERROR EN ESTADO', 'ERROR EN ESTADO', 3, 1, 1),
(13, 1, 1, 'B8', 'ERROR EN SUC. DE ENTREGA', 'ERROR EN SUC. DE ENTREGA', 3, 1, 1),
(13, 1, 1, 'W5', 'ERROR EN FECHAS  NO EMITE', 'ERROR EN FECHAS  NO EMITE', 3, 1, 1),
(13, 1, 1, 'W6', 'ERROR EN DOMICIL.  NO EMITE', 'ERROR EN DOMICIL.  NO EMITE', 3, 1, 1),
(13, 1, 1, 'W8', 'ERROR EN SUC. DE ENTREGA NO EMITE', 'ERROR EN SUC. DE ENTREGA NO EMITE', 3, 1, 1)
GO
insert into LP_Configuration.InternalStatus(idProvider, idCountry,[Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(13, 1, 1, 'T3', 'MONEDA DEBE SER IGUAL CR', 'MONEDA DEBE SER IGUAL CR', 3, 1, 1)

DECLARE @idLPInternalError as INT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = 13
AND [Code] IN ('T3')
