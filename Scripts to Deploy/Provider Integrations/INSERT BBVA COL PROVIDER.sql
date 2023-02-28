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
	'BBVACOL',
	'Banco BBVA',
	'Banco Bilbao Vizcaya Argentaria Colombia S.A',
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
(@idProvider, @idCountry, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),(@idProvider, @idCountry, 1, 'A01', 'OPERACION EXITOSA', 'OPERACION EXITOSA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'A03', 'OK PERO NO ABONO AL CLIENTE', 'OK PERO NO ABONO AL CLIENTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C05', 'DPE VENCIDO', 'DPE VENCIDO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C04', 'DPE BLOQUEADO', 'DPE BLOQUEADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C03', 'DPE RECHAZADO', 'DPE RECHAZADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C02', 'DPE ABONADO', 'DPE ABONADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C01', 'DPE PENDIENTE DE ABONO', 'DPE PENDIENTE DE ABONO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'C06', 'DPE EXCEDIO LIMITE', 'DPE EXCEDIO LIMITE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'D02', 'CUENTA NO PENSIONAL O BLOQUEADA', 'CUENTA NO PENSIONAL O BLOQUEADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'D01', 'MESADA BLOQUEADA', 'MESADA BLOQUEADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'D00', 'RECHAZO BAEP', 'RECHAZO BAEP',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'D83', 'ANULADO', 'ANULADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'D03', 'PARAMETROS ERRADOS LLAMANDO A PE9CA', 'PARAMETROS ERRADOS LLAMANDO A PE9CA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'D04', 'INFORMACION ERRADA LLAMANDO A PE9CA', 'INFORMACION ERRADA LLAMANDO A PE9CA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'D05', 'TRANSACCION NO SE PUEDE DAR DE ALTA', 'TRANSACCION NO SE PUEDE DAR DE ALTA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'D06', 'USUARIO NO AUTORIZADO.', 'USUARIO NO AUTORIZADO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'D07', 'NO HAY DESCRIPCION DEL PAGO A REALI', 'NO HAY DESCRIPCION DEL PAGO A REALI',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R04', 'CUENTA NO EXISTE', 'CUENTA NO EXISTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R16', 'CUENTA INACTIVA O BLOQUEADA', 'CUENTA INACTIVA O BLOQUEADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R02', 'CUENTA CUENTA CANCELADA O SALDADA', 'CUENTA CUENTA CANCELADA O SALDADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R63', 'IMPORTE INCORRECTO', 'IMPORTE INCORRECTO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R12', 'NUMERO BANCO NO VALIDO', 'NUMERO BANCO NO VALIDO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R17', 'IDENTIFICACION INCORRECTA', 'IDENTIFICACION INCORRECTA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'R13', 'FECHA VALOR DEBE SER FECHA DEL DIA', 'FECHA VALOR DEBE SER FECHA DEL DIA',  @idInternalStatusType, 1, 1),
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
AND [Code] IN ('REJECTED')

--ERROR BANK ACCOUNT CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R16','R02','R04')

--ERROR AMOUNT INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R63')

--ERROR BANK INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R12')

--ERROR BENEFICIARY DOCUMENT ID INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R17')

--ERROR BENEFICIARY NAME INCORRECT
/*SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R11','R32')*/

--ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('A03','C01','C02','C03','C04','C05','C06','D00','D01','D02','D03','D04','D05','D06','D83')

--ERROR INVALID DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R13')

--ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
/*SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('R17')*/


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