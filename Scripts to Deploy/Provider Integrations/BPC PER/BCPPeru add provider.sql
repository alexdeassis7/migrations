-- TRANSACTION TYPE PROVIDER
DECLARE @countryId INT;

SET @countryId = (SELECT [idCountry]
FROM [LP_Location].[Country]
  WHERE Name = 'PERU'
)

DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
'BCPPER',--esto ponemos codigo a nuestro gusto tratando que sea unico como "ITAUBR"
'Banco de Credito del Peru',
'Banco de Credito del Peru',
@countryId,
1
)

set @idProvider = SCOPE_IDENTITY();

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


INSERT INTO [LP_Configuration].[PayWayServices]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idCountry]
           ,[Active])
     VALUES
           ('BANKDEPO'
           ,'Depósito Bancario'
           ,'Depósito Bancario'
           ,@countryId
           ,1)


SET @idPayWayService = SCOPE_IDENTITY();

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
@idProvider,
@idPayWayService,
1
)

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE Code = 'SCM' AND idCountry = @countryId)

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES
(@idProvider, @countryId, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, @countryId, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
(@idProvider, @countryId, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, @countryId, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1)


DECLARE @idLPInternalError as INT

 --RECEIVED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '100'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE [Code] IN ('RECI') AND idCountry = @countryId AND idProvider = @idProvider

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

 --ERROR_BANK _ACCOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED')

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
AND [Code] IN ('REJECTED')


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
AND [Code] IN ('REJECTED')

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
AND [Code] IN ('REJECTED')

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
AND [Code] IN ('REJECTED')

 --ERROR_ACCOUNT_OF_OTHER_CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '718'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED')
