begin tran

declare  
@idEntityUserMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserChl			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantChl			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


--Create Merchant 
	--Mexico
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Paydek Mexico', 1, 1)

set @idEntityMerchantMex = @@identity

	--Uruguay
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Paydek Uruguay', 1, 1)

set @idEntityMerchantUry = @@identity

	--Chile
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Paydek Chile', 1, 1)

set @idEntityMerchantChl = @@identity

------------------------------

--Create Entity User
	--Mex
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Paydek Mexico', 'Paydek Mexico', 'alan.barry@paydek.com', '', '', 2, 4, @idEntityMerchantMex , 4, 1, 150, '', 'PAYDEKMEX',1)


set @idEntityUserMex = @@identity

	--Ury
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Paydek Uruguay', 'Paydek Uruguay', 'alan.barry@paydek.com', '', '', 2, 4, @idEntityMerchantUry , 4, 1, 244, '', 'PAYDEKURY',1)


set @idEntityUserUry = @@identity

	--CHL
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Paydek Chile', 'Paydek Chile', 'alan.barry@paydek.com', '', '', 2, 4, @idEntityMerchantChl , 4, 1, 44, '', 'PAYDEKCHL',1)


set @idEntityUserChl = @@identity

--CREATE SUBMERCHANTS
	--MEX
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('Paydek', 'Paydek', @idEntityUserMex, 1, 0, 1, '', '', 0, 1,'0.600000',2493)

	--URY
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('Paydek', 'Paydek', @idEntityUserUry, 1, 0, 1, '', '', 0, 1,'1.300000',2493)

	--CHL
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('Paydek', 'Paydek', @idEntityUserChl, 1, 0, 1, '', '', 0, 1,'1.300000',2493)
----------------

--INSERT Trasnaction Types

-------- ARG
----------------------------- MEX

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserMex, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserMex, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserMex, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserMex, 17, 1)

----------------------------- URY
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

----------------------------- CHL
insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserChl, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserChl, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserChl, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserChl, 17, 1)

--------Currency Exchange
--MEX
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserMex, 2446, 2493, 1, 1)

--URY
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserUry, 2494, 2493, 1, 1)

--CHL
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserChl, 2375, 2493, 1, 1)

------------ Currency Base
-- MEX
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2446, 150, 2, @idEntityUserMex, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 150, 2, @idEntityUserMex, 1.00, 1.00, 1, 1)

-- URY
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2494, 244, 2, @idEntityUserUry, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 244, 2, @idEntityUserUry, 1.00, 1.00, 1, 1)

-- CHL
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2375, 44, 2, @idEntityUserChl, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 44, 2, @idEntityUserChl, 1.00, 1.00, 1, 1)

------- ENTITY Account

set @entityAccountId = (SELECT idEntityAccount FROM [LP_Security].[EntityAccount] WHERE Identification = '000004000001')

------- ENTITY ACCOUNT USER
--MEX

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserMex, 1)

--URY

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserUry, 1)

--CHL

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserChl, 1)

------ API CREDENTIAL
--MEX
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000004000001', '$-82L)])t{%\S+e&', @idEntityUserMex, 150, 1)

--URY
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000004000001', '$-82L)])t{%\S+e&', @idEntityUserUry, 244, 1)

--CHL
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000004000001', '$-82L)])t{%\S+e&', @idEntityUserChl, 44, 1)

UPDATE EU
	SET EU.[CommissionValue] = ES.CommissionValuePO
	, EU.[CommissionCurrency] = ES.CommissionCurrencyPO
	FROM [LP_Entity].[EntityUser] EU
	INNER JOIN [LP_Entity].[EntitySubMerchant] ES ON ES.idEntityUser = EU.idEntityUser
	WHERE EU.idEntityUser IN (@idEntityUserChl, @idEntityUserMex, @idEntityUserUry)

ROLLBACK TRAN
--COMMIT