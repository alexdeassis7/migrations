begin tran

declare  @idEntityUserChile			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@merchantChile nvarchar(255) = 'Payoneer Chile',
@merchantChileId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCountryChile			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCurrencyTypeChile		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

set @idCountryChile = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'CHL')
set @idCurrencyTypeChile = (SELECT idCurrencyType FROM LP_Configuration.CurrencyType where Code = 'CLP')

insert into LP_Entity.EntityMerchant
([Description], idEntityBusinessNameType, Active)
values (@merchantChile, 1, 1)

set @merchantChileId = SCOPE_IDENTITY()  

insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values (@merchantChile, @merchantChile, 'danielra@payoneer.com', '', '', 2, 4,@merchantChileId , 4, 1, @idCountryChile, '', 'LPPAYCHL',1)

set @idEntityUserChile =  SCOPE_IDENTITY() 

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserChile, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserChile, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserChile, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserChile, 17, 1)

insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserChile, @idCurrencyTypeChile, 2493, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (@idCurrencyTypeChile, @idCountryChile, 2, @idEntityUserChile, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, @idCountryChile, 2, @idEntityUserChile, 1.00, 1.00, 1, 1)

----CROSS ---

SELECT @entityAccountId = [idEntityAccount]
FROM [LP_Security].[EntityAccount]
WHERE [Identification] = '000001500001'

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserChile, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000001500001', 'EBQY#XR9C1', @idEntityUserChile, @idCountryChile, 1)

-- insert into LP_Security.EntityPassword values ('EACP#RPIM2','PMITEST123',GETDATE(),1,1,GETUTCDATE()
--            ,GETUTCDATE()
--            ,GETDATE()
--            ,GETDATE())

-- set @entityPasswordId = SCOPE_IDENTITY()

-- insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
--            ,GETDATE()
--            ,GETDATE())




select @idEntityUserChile = idEntityUser from LP_Entity.EntityUser where LastName = 'Payoneer Chile'

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
select Description, SubMerchantIdentification,@idEntityUserChile,0,0,1,SubMerchantCode,SubMerchantAddress,0,IsCorporate,CommissionValuePO,CommissionCurrencyPO from LP_Entity.EntitySubMerchant where idEntityUser = 16 
--values ('Airbnb', 'Airbnb', @idEntityUserChile, 0, 0, 1, '', '', 0, 1,'1.300000',2493)


-- TRANSACTION TYPE PROVIDER
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'BCHILE',
	'Banco de Chile',
	'Banco de Chile',
	@idCountryChile,
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
	@idCountryChile,
	1
)

SET @idPayWayService = SCOPE_IDENTITY()  

SELECT @idProvider = idProvider FROM LP_Configuration.[Provider] WHERE [idCountry] = @idCountryChile

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO [LP_Configuration].[InternalStatusType](Code, [Name], [Description], [Active], [idCountry], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime])
VALUES('SCM', 'State Codes of Movements', 'State Codes of Movements', 1, @idCountryChile, GETDATE(), GETDATE(), GETDATE(), GETDATE())
SET @idInternalStatusType = SCOPE_IDENTITY()  


INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountryChile, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryChile, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountryChile, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryChile, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryChile, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0)

-- Payment Type
INSERT INTO [LP_Configuration].[PaymentType]([Code], [Name], [Description], [idCountry], [Active], [CatalogValue])
VALUES(
	'SUPPLIERS',
	'Pago a Proveedores',
	'Pago a Proveedores',
	@idCountryChile,
	1,
	2
)


INSERT INTO [LP_Configuration].[BankCode] ([Code], [Name], [Description], [idCountry], [Active], [SubCode])
VALUES
('1001', 'Banco de Chile', 'Banco de Chile', @idCountryChile, 1, '')

-- BANK ACCOUNT TYPE
INSERT [LP_Configuration].[BankAccountType] ([Code], [Name], [Description], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [idCountry]) 
VALUES 
(N'A', N'CA', N'Caja de Ahorro', 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), @idCountryChile),
(N'C', N'CC', N'Cuenta Corriente', 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), @idCountryChile),
(N'V', N'Vista Account', N'Cuenta Vista', 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), @idCountryChile),
(N'R', N'RutAccount', N'Cuenta Rut', 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), @idCountryChile)



-- Identification type
INSERT INTO [LP_Entity].[EntityIdentificationType]([Code], [Name], [Description], [idCountry], [Active])
VALUES ('CI', 'Cedula de Identidad', 'Cedula de Identidad', @idCountryChile, 1),
('RUT', 'Registro Unico Tributario', 'Registro Unico Tributario', @idCountryChile, 1)

commit tran