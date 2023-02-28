-- TRANSACTION TYPE PROVIDER
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'PLURAL',
	'Plural',
	'Plural',
	31,
	1
)

set @idProvider = SCOPE_IDENTITY()  

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idPayWayService = (SELECT [idPayWayService] FROM [LP_Configuration].[PayWayServices] where Code = 'BANKDEPO' AND idCountry = 31)

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)
begin tran
DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE Code = 'SCM' AND idCountry = 31)


--INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
--VALUES 
--(@idProvider, 31, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
--(@idProvider, 31, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
--(@idProvider, 31, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
--(@idProvider, 31, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
--(@idProvider, 31, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0)

-- NUEVOS ESTADOS DE ERROR MAPEADOS A INTERNAL ERRORS

DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
SET @idProvider = (SELECT idProvider FROM LP_Configuration.Provider WHERE Code = 'PLURAL' AND idCountry = 31)

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES
(@idProvider, 31, 1, 'CPF/CNPJ I', 'CPF/CNPJ INAPTO JUNTO A RECEITA FEDERAL DO BRASIL.', 'CPF/CNPJ INAPTO JUNTO A RECEITA FEDERAL DO BRASIL.', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CONTA ENCE', 'CONTA DESTINATARIA DO CREDITO ENCERRADA', 'CONTA DESTINATARIA DO CREDITO ENCERRADA', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AGENCIA OU', 'AGENCIA OU CONTA DESTINATARIA DO CREDITO INVALIDA', 'AGENCIA OU CONTA DESTINATARIA DO CREDITO INVALIDA', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AUSENCIA O', 'AUSENCIA OU DIVERGENCIA NA INDICACAO DO CPF/CNPJ', 'AUSENCIA OU DIVERGENCIA NA INDICACAO DO CPF/CNPJ', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DIVERGENCI', 'DIVERGENCIA NA TITULARIDADE', 'DIVERGENCIA NA TITULARIDADE', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DEVOLUCAO ', 'DEVOLUCAO POR FRAUDE', 'DEVOLUCAO POR FRAUDE', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'MOVIMENTAC', 'MOVIMENTACOES FINANCEIRAS LIGADAS AO TERRORISMO E AO SEU FIN', 'MOVIMENTACOES FINANCEIRAS LIGADAS AO TERRORISMO E AO SEU FIN', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CONTA DEST', 'CONTA DESTINATARIA DO CREDITO INVALIDA PARA O TIPO DE TRANSA', 'CONTA DESTINATARIA DO CREDITO INVALIDA PARA O TIPO DE TRANSA', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AML', 'REJECTED BY AML', 'REJECTED BY AML', @idInternalStatusType, 1, 1)

-- ERROR_BENEFICIARY_DOCUMENT_ID_INVALID
DECLARE @idLPInternalError as INT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('CPF/CNPJ I', 'AUSENCIA O')

-- ERROR_BANNK_ACCOUNT_CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('CONTA DEST')

-- ERROR_BANK _ACCOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AGENCIA OU', 'CONTA DEST')

-- ERROR_ACCOUNT_NOT_MATCH_BENEFICIARY_DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('DIVERGENCI')

-- ERROR_REJECTED_BY_AML
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '718'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('DEVOLUCAO', 'MOVIMENTAC', 'AML')


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
WHERE [Code] IN ('RECI') AND idCountry = 31

-- IN PROGRESS
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '200'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('PEND')


UPDATE LP_Configuration.InternalStatus 
SET Name = 'The payout was rejected', Description = 'The payout was rejected'
WHERE idProvider = @idProvider
AND idCountry = 31
AND Code = 'REJECTED'

commit tran