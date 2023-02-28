begin tran
DECLARE @idProvider int
DECLARE @idCountry int

SELECT @idCountry = idCountry FROM LP_Location.Country Where Code= 'ARS'

INSERT INTO [LP_Configuration].[Provider](Code, Name, Description, idCountry, Active)
VALUES('SANTAR', 'Banco Santander', 'Banco Santander', @idCountry, 1)

SET @idProvider = SCOPE_IDENTITY()

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SELECT @idPayWayService = idPayWayService
FROM LP_Configuration.PayWayServices
WHERE Code = 'BANKDEPO' AND idCountry = @idCountry AND Active = 1


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
(@idProvider, @idCountry, 1, 'R03',	'CUENTA INEXISTENTE',	'CUENTA INEXISTENTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R04',	'NUMERO DE CUENTA INVALIDO',	'NUMERO DE CUENTA INVALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R05',	'CANAL INVALIDO',	'CANAL INVALIDO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R10',	'SALDO INSUFICIENTE',	'SALDO INSUFICIENTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R11',	'CUENTA BLOQUEADA',	'CUENTA BLOQUEADA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R13',	'SUCURSAL/ENTIDAD/DESTINO INEXISTENTE',	'SUCURSAL/ENTIDAD/DESTINO INEXISTENTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R14',	'NRO. CUIT ERRONEO',	'NRO. CUIT ERRONEO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R17',	'ERROR DE FORMATO',	'ERROR DE FORMATO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R18',	'FECHA COMPENSACION ERRONEA ',	'FECHA COMPENSACION ERRONEA ', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R19',	'IMPORTE ERRONEO',	'IMPORTE ERRONEO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R20',	'MONEDA DISTINTA A CUENTA DE DEBITO',	'MONEDA DISTINTA A CUENTA DE DEBITO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R22',	'SOLICITUD DE BENEFICIARIO',	'SOLICITUD DE BENEFICIARIO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R23',	'SUCURSAL NO HABILITADA',	'SUCURSAL NO HABILITADA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R24',	'TRANSACCION DUPLICADA',	'TRANSACCION DUPLICADA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R25',	'ERROR EN REGISTRO ADICIONAL',	'ERROR EN REGISTRO ADICIONAL', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R26',	'ERROR POR CAMPO MANDATORIO',	'ERROR POR CAMPO MANDATORIO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R27',	'ERROR EN CONTADOR DE REGISTRO',	'ERROR EN CONTADOR DE REGISTRO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R31',	'DEVOLUCION DE CAMARA (UNWINDING)',	'DEVOLUCION DE CAMARA (UNWINDING)', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R35',	'ARCHIVO SIN CABECERA',	'ARCHIVO SIN CABECERA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R36',	'SECUENCIA INVALIDA DE REGISTRO',	'SECUENCIA INVALIDA DE REGISTRO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R37',	'DIFERENCIA EN TOTAL DE TRAILER',	'DIFERENCIA EN TOTAL DE TRAILER', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R38',	'REGISTRO CABECERA DUPLICADO',	'REGISTRO CABECERA DUPLICADO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R39',	'INGRESO DESPUES HORA CIERRE',	'INGRESO DESPUES HORA CIERRE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R40',	'CUIT/CUIL/CDI DIFERENTE',	'CUIT/CUIL/CDI DIFERENTE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R45',	'PAGO DE SUELDO A PERSONA JURIDICA',	'PAGO DE SUELDO A PERSONA JURIDICA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R75',	'FECHA INVALIDA',	'FECHA INVALIDA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R76',	'ERROR EN DV DEL CUIT EMPRESA',	'ERROR EN DV DEL CUIT EMPRESA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R77',	'ERROR EN CAMPO 4 REG.INDIVID',	'ERROR EN CAMPO 4 REG.INDIVID', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R78',	'ERROR EN CUENTA A ACREDITAR',	'ERROR EN CUENTA A ACREDITAR', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R79',	'ERROR REFERENCIA UNIVOCA TRANSFERENCIA',	'ERROR REFERENCIA UNIVOCA TRANSFERENCIA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R80',	'ERROR EN CAMPO CONCEPTO',	'ERROR EN CAMPO CONCEPTO', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R86',	'IDENTIFICACION EMPRESA ERRONEA',	'IDENTIFICACION EMPRESA ERRONEA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R87',	'MONEDA INVALIDA',	'MONEDA INVALIDA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R88',	'CODIGO TRANSACCION INVALIDA',	'CODIGO TRANSACCION INVALIDA', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R90',	'TX NO CORRESP/NO EXIST.TX ORIGINAL',	'TX NO CORRESP/NO EXIST.TX ORIGINAL', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R91',	'CODIGO BANCO INCOMPAT. C/MONEDA TX',	'CODIGO BANCO INCOMPAT. C/MONEDA TX', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R93',	'DIA NO LABORABLE',	'DIA NO LABORABLE', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R98',	'A SOLICITUD DE LA ENTIDAD ORIGINANTE ',	'A SOLICITUD DE LA ENTIDAD ORIGINANTE ', @idInternalStatusType, 1, 1)



DECLARE @idLPInternalError as INT

 --RECEIVED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '100'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE [Code] IN ('RECI') AND idCountry = 31 AND idProvider = @idProvider

--IN PROGRESS
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '200'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('PEND')

 --EXECUTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '300'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('EXECUTED')

-- ERROR_ACCOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED','R03','R04','R05','R88','R90','R91','R93','R98','R22','R40','R45','R76','R77','R78','R79','R80','R86')

-- ERROR BANK ACCOUNT CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R11')

-- ERROR_AMOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R19')

-- ERROR_BANK_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R13')

--ERROR BANK BRANCH INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '704'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R23')

-- ERROR_BENEFICIARY_DOCUMENT_ID_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R14')

-- ERROR_BENEFICIARY_NAME_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('')

-- ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R17','R24','R25' ,'R26' ,'R27' ,'R31' ,'R35' ,'R36' ,'R37' ,'R38' ,'R39')

-- ERROR INVALID DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R75','R39','R18')

-- ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('')

-- ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '712'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R10')

-- ERROR ACCOUNT NOT ACCEPT TRANSFERS
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '713'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('')

-- ERROR ACCOUNT OF OTHER CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R87','R20')


ROLLBACK
