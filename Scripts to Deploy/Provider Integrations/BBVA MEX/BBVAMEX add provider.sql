begin tran
-- TRANSACTION TYPE PROVIDER
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
'BBVAMEX',--esto ponemos codigo a nuestro gusto tratando que sea unico como "ITAUBR"
'BBVA MEXICO',
'BBVA MEXICO',
150,
1
)

set @idProvider = SCOPE_IDENTITY()  

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idPayWayService = (SELECT [idPayWayService] FROM [LP_Configuration].[PayWayServices] where Code = 'BANKDEPO' AND idCountry = 150)

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
@idProvider,
@idPayWayService,
1
)

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE Code = 'SCM' AND idCountry = 150)


INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES
(@idProvider, 150, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, 150, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
(@idProvider, 150, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, 150, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNA0011', 'Alta exitosa', 'Alta exitosa.', @idInternalStatusType, 0, 1),
(@idProvider, 150, 1, 'KNA0803', 'Modificacion exitosa', 'Modificacion exitosa', @idInternalStatusType, 0, 1),
(@idProvider, 150, 1, 'KNE0010', 'Error con el codigo bancario', 'Error con el codigo bancario', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNE0022', 'Cuenta inexistente', 'Cuenta inexistente', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNE0047', 'Asunto invalido', 'Asunto invalido', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNE0081', 'Cod aba/bic erroneo', 'Cod aba/bic erroneo', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNE0082', 'Divisa invalida', 'Divisa invalida', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNE0083', 'Asunto invalido', 'Asunto invalido', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNE0212', 'Monto con formato erroneo', 'Monto con formato erroneo', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNE0316', 'Formato cta invalido', 'Formato cta invalido', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNE0552', 'Monto en ceros', 'Monto en ceros', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'KNE0818', 'Error con el registro', 'Registro ya existe', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'CNE1202', 'Cuenta no valida', 'Cuenta no valida', @idInternalStatusType, 1, 1),
(@idProvider, 150, 1, 'CNE1225', 'Divisa no permitida en el lote', 'Divisa no permitida en el lote', @idInternalStatusType, 1, 1)



-- NUEVOS ESTADOS DE ERROR MAPEADOS A INTERNAL ERRORS
DECLARE @idLPInternalError as INT

 --RECEIVED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '100'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE [Code] IN ('RECI') AND idCountry = 150 AND idProvider = @idProvider

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
AND [Code] IN ('EXECUTED', 'KNA0011', 'KNA0803')

 --ERROR_BANK _ACCOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('KNE0010', 'KNE0022', 'KNE0316', 'CNE1202')

 --ERROR_BANNK_ACCOUNT_CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED')

 --ERROR_AMOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('KNE0212', 'KNE0552')


 --ERROR_BANK_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED')


 --ERROR_BENEFICIARY_DOCUMENT_ID_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED')

 --ERROR_BENEFICIARY_NAME_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED')

 --ERROR_BANK_PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('KNE0047', 'KNE0081', 'KNE0083', 'KNE0818')

 --ERROR_INVALID_DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED')

 --ERROR_ACCOUNT_TYPE_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '709'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AP','HW')

 --ERROR_ACCOUNT_TYPE_NOT_MATCH_BENEFICIARY_DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED')

 --ERROR_ACCOUNT_OF_OTHER_CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('KNE0082', 'CNE1225')

 --ERROR_ACCOUNT_OF_OTHER_CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '718'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED')

--ROLLBACK
COMMIT