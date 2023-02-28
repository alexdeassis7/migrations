begin tran

declare  @idEntityUserUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@merchantUruguay nvarchar(255) = 'Payoneer Uruguay',
@merchantUruguayId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCountryUruguay			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCurrencyTypeUruguay		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

set @idCountryUruguay = 244
set @idCurrencyTypeUruguay = 2494

insert into LP_Entity.EntityMerchant
([Description], idEntityBusinessNameType, Active)
values (@merchantUruguay, 1, 1)

set @merchantUruguayId = SCOPE_IDENTITY()  

insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values (@merchantUruguay, @merchantUruguay, 'danielra@payoneer.com', '', '', 2, 4,@merchantUruguayId , 4, 1, @idCountryUruguay, '', 'LPPAYURY',1)

set @idEntityUserUry =  SCOPE_IDENTITY() 

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, 17, 1)

insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserUry, @idCurrencyTypeUruguay, 2493, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (@idCurrencyTypeUruguay, @idCountryUruguay, 2, @idEntityUserUry, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, @idCountryUruguay, 2, @idEntityUserUry, 1.00, 1.00, 1, 1)

----CROSS ---

SELECT @entityAccountId = [idEntityAccount]
FROM [LP_Security].[EntityAccount]
WHERE [Identification] = '000001500001'

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserUry, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000001500001', 'EAQP#REIR2', @idEntityUserUry, @idCountryUruguay, 1)

-- insert into LP_Security.EntityPassword values ('EACP#RPIM2','PMITEST123',GETDATE(),1,1,GETUTCDATE()
--            ,GETUTCDATE()
--            ,GETDATE()
--            ,GETDATE())

-- set @entityPasswordId = SCOPE_IDENTITY()

-- insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
--            ,GETDATE()
--            ,GETDATE())




select @idEntityUserUry = idEntityUser from LP_Entity.EntityUser where LastName = 'Payoneer Uruguay'

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
select Description, SubMerchantIdentification,@idEntityUserUry,0,0,1,SubMerchantCode,SubMerchantAddress,0,IsCorporate,CommissionValuePO,CommissionCurrencyPO from LP_Entity.EntitySubMerchant where idEntityUser = 16 
--values ('Airbnb', 'Airbnb', @idEntityUserUry, 0, 0, 1, '', '', 0, 1,'1.300000',2493)


-- TRANSACTION TYPE PROVIDER
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'BROU',
	'BROU',
	'BROU',
	@idCountryUruguay,
	1
)

set @idProvider = SCOPE_IDENTITY()  

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO [LP_Configuration].[PayWayServices] ([Code], [Name], [Description], [idCountry], [Active])
VALUES (
	'BANKDEPO',
	'Depósito Bancario',
	'Depósito Bancario',
	@idCountryUruguay,
	1
)

SET @idPayWayService = SCOPE_IDENTITY()  

SELECT @idProvider = idProvider FROM LP_Configuration.[Provider] WHERE [idCountry] = @idCountryUruguay

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO [LP_Configuration].[InternalStatusType](Code, [Name], [Description], [Active], [idCountry], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime])
VALUES('SCM', 'State Codes of Movements', 'State Codes of Movements', 1, @idCountryUruguay, GETDATE(), GETDATE(), GETDATE(), GETDATE())
SET @idInternalStatusType = SCOPE_IDENTITY()  


INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountryUruguay, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryUruguay, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountryUruguay, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryUruguay, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryUruguay, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0)

-- Payment Type
INSERT INTO [LP_Configuration].[PaymentType]([Code], [Name], [Description], [idCountry], [Active], [CatalogValue])
VALUES(
	'SUPPLIERS',
	'Pago a Proveedores',
	'Pago a Proveedores',
	@idCountryUruguay,
	1,
	2
)


INSERT INTO [LP_Configuration].[BankCode] ([Code], [Name], [Description], [idCountry], [Active], [SubCode])
VALUES
('1001', 'BROU - Banco de la República Oriental del Uruguay', 'BROU - Banco de la República Oriental del Uruguay', @idCountryUruguay, 1, ''),
('1091', 'Banco Hipotecario del Uruguay', 'Banco Hipotecario del Uruguay', @idCountryUruguay, 1, ''),
('1110', 'Banco Bandes', 'Banco Bandes', @idCountryUruguay, 1, ''),
('1113', 'Banco ITAU', 'Banco ITAU', @idCountryUruguay, 1, ''),
('1128', 'Scotiabank', 'Scotiabank', @idCountryUruguay, 1, ''),
('1137', 'Banco Santander', 'Banco Santander', @idCountryUruguay, 1, ''),
('1153', 'Banco Bilbao Vizcaya Argentaria', 'Banco Bilbao Vizcaya Argentaria', @idCountryUruguay, 1, ''),
('1157', 'HSBC Bank', 'HSBC Bank', @idCountryUruguay, 1, ''),
('1162', 'Banque Heritage', 'Banque Heritage', @idCountryUruguay, 1, ''),
('1205', 'Citibank N.A. Sucursal', 'Citibank N.A. Sucursal', @idCountryUruguay, 1, ''),
('1246', 'Banco de la Nación Argentina', 'Banco de la Nación Argentina', @idCountryUruguay, 1, ''),
('1361', 'Banco de la Provincia de Buenos Aires', 'Banco de la Provincia de Buenos Aires', @idCountryUruguay, 1, ''),
('7905', 'PREX(FORTEX)', 'PREX(FORTEX)', @idCountryUruguay, 1, '')

-- BANK ACCOUNT TYPE
INSERT [LP_Configuration].[BankAccountType] ([Code], [Name], [Description], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [idCountry]) 
VALUES (
  N'A', 
  N'CA', 
  N'Caja de Ahorro', 
  1,
  GETDATE(),
  GETDATE(),
  GETDATE(),
  GETDATE(),
  @idCountryUruguay
)

INSERT [LP_Configuration].[BankAccountType] ([Code], [Name], [Description], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [idCountry]) 
VALUES (
  N'C', 
  N'CC', 
  N'Cuenta Corriente', 
  1,
  GETDATE(),
  GETDATE(),
  GETDATE(),
  GETDATE(),
  @idCountryUruguay
)


-- Identification type
INSERT INTO [LP_Entity].[EntityIdentificationType]([Code], [Name], [Description], [idCountry], [Active])
VALUES ('CI', 'Cedula de Identidad', 'Cedula de Identidad', @idCountryUruguay, 1),
('RUT', 'Registro Unico Tributario', 'Registro Unico Tributario', @idCountryUruguay, 1)

commit tran