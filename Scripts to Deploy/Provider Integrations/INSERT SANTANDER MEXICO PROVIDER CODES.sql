BEGIN TRAN

DECLARE @idCountry			    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idCurrencyType		    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idProvider             [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idInternalStatusType   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountry = (SELECT idCountry FROM LP_Location.Country WHERE ISO3166_1_ALFA003 = 'MEX')
SET @idCurrencyType = (SELECT idCurrencyType FROM LP_Configuration.CurrencyType WHERE Code = 'MXN')
SET @idProvider = (SELECT idProvider FROM [LP_Configuration].[Provider] WHERE idCountry = @idCountry and Code = 'SRM')
SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE idCountry = @idCountry AND Code = 'SCM')

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountry, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
--(@idProvider, @idCountry, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountry, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'R02', 'CUENTA CERRADA', 'CUENTA CERRADA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R03', 'CUENTA NO CORRESPONDE CON RUT', 'CUENTA NO CORRESPONDE CON RUT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R04', 'CUENTA NO EXISTE', 'CUENTA NO EXISTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R09', 'CUENTA EMPRESA INVALIDA', 'CUENTA EMPRESA INVALIDA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R10', 'RUT EMPRESA NO VALIDO', 'RUT EMPRESA NO VALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R11', 'NOMBRE ENPRESA INCORRECTO', 'NOMBRE ENPRESA INCORRECTO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R12', 'NUMERO CONVENIO INVALIDO', 'NUMERO CONVENIO INVALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R13', 'ERROR EN REG. ENCABEZADO', 'ERROR EN REG. ENCABEZADO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R16', 'ERROR EN TOTAL DE REGISTROS', 'ERROR EN TOTAL DE REGISTROS', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R17', 'CAMPO REQUERIDO O VALOR INVALIDO', 'CAMPO REQUERIDO O VALOR INVALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R18', 'MONTO TOTAL INVALIDO', 'MONTO TOTAL INVALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R19', 'MONTO TOTAL ABONADO INCORRECTO', 'MONTO TOTAL ABONADO INCORRECTO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R21', 'ERROR EN TIPO DE MOVIMIENTO', 'ERROR EN TIPO DE MOVIMIENTO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R22', 'RUT RECEPTOR INVALIDO', 'RUT RECEPTOR INVALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R23', 'CODIGO DEL BANCO NO DEFINIDO', 'CODIGO DEL BANCO NO DEFINIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R24', 'TRANSACCION DUPLICADA', 'TRANSACCION DUPLICADA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R25', 'ERROR EN FORMATO', 'ERROR EN FORMATO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R26', 'TIPO DE SERVICIO NO HABILITADO', 'TIPO DE SERVICIO NO HABILITADO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R28', 'TIPO CUENTA INCORRECTO', 'TIPO CUENTA INCORRECTO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R30', 'ERROR EN REGISTRO DETALLE', 'ERROR EN REGISTRO DETALLE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R31', 'RUT INVALIDO', 'RUT INVALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R32', 'ERROR EN NOMBRE DEL CLIENTE', 'ERROR EN NOMBRE DEL CLIENTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R33', 'FECHA DE PAGO INCORRECTA', 'FECHA DE PAGO INCORRECTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R34', 'FECHA DE PAGO NO APLICABLE', 'FECHA DE PAGO NO APLICABLE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R35', 'ERROR EN NUMERO DE CUENTA', 'ERROR EN NUMERO DE CUENTA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R37', 'TIPO MONEDA INVALIDA', 'TIPO MONEDA INVALIDA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R38', 'SERVICIO NO HABILITADO PARA IFR', 'SERVICIO NO HABILITADO PARA IFR', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R40', 'TOTAL DE REGISTROS INCORRECTO', 'TOTAL DE REGISTROS INCORRECTO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R50', 'IFO NO HABILITADO', 'IFO NO HABILITADO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R65', 'CODIGO TRANSACCION INCORRECTO', 'CODIGO TRANSACCION INCORRECTO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R80', 'CUENTA NO EXISTE', 'CUENTA NO EXISTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R81', 'OPERACION NO HABILITADA', 'OPERACION NO HABILITADA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R82', 'ERROR EN CAMPO MONTO', 'ERROR EN CAMPO MONTO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R83', 'RECEPTOR NO ES PERSONA NATURAL', 'RECEPTOR NO ES PERSONA NATURAL', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C01', 'CUENTA NO EXISTE', 'CUENTA NO EXISTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C30', 'CUENTA RECEPTOR NO NATURAL', 'CUENTA RECEPTOR NO NATURAL', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C04', 'RELACION RUT/CTA INVALIDA', 'RELACION RUT/CTA INVALIDA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C05', 'CUENTA ES DE AHORRO', 'CUENTA ES DE AHORRO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C32', 'CUENTA NO CORRESPONDE CON RUT', 'CUENTA NO CORRESPONDE CON RUT', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'AML', 'Rejected by AML', 'Rejected by AML', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibi� exitosamente', 'El archivo se recibi� exitosamente', @idInternalStatusType, 0, 0)

DECLARE @idLPInternalError INT
---- EXECUTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '300'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('EXECUTED')
--
---- RECEIVED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '100'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE [Code] IN ('RECI') AND idProvider = @idProvider
--
---- IN PROGRESS
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '200'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('PEND')
--
----REJECTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED','R04','R09','R12','R35','R80','C01','R83','C30','C05')
--
----ERROR BANK ACCOUNT CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R02')
--
----ERROR AMOUNT INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R18','R19','R82')
--
----ERROR BANK INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R23')
--
----ERROR BENEFICIARY DOCUMENT ID INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R10','R22','R31')
--
----ERROR BENEFICIARY NAME INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R11','R32')
--
----ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R13','R16','R17','R21','R24','R25','R26','R30','R38','R40','R50','R65','R81')
--
----ERROR INVALID DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R33','R34')
--
----ERROR ACCOUNT TYPE INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '709'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R28')
--
----ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R03','C04','C32')
--
----ERROR ACCOUNT OF OTHER CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'
--
INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R37')

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