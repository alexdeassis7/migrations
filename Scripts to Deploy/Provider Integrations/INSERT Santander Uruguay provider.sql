BEGIN TRAN
DECLARE @idCountryUruguay AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
-- TRANSACTION TYPE PROVIDER
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountryUruguay = (SELECT idCountry FROM [LP_Location].[Country] WHERE Name = 'URUGUAY')

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'SANTANDER',
	'Santander',
	'Santander',
	@idCountryUruguay,
	1
)

set @idProvider = SCOPE_IDENTITY()  

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
SET @idPayWayService = (SELECT idPayWayService FROM [LP_Configuration].[PayWayServices] WHERE Code = 'BANKDEPO' AND idCountry = @idCountryUruguay )

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE Code = 'SCM' AND idCountry = @idCountryUruguay)


INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountryUruguay, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryUruguay, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountryUruguay, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryUruguay, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryUruguay, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0)

ROLLBACK TRAN