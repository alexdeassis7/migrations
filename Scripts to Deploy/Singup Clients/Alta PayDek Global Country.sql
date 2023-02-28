begin tran

declare  
@idGlobalCountry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCountryCurrency			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserGlobalId	    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId		    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantGlobal		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


--Create GLobal COuntry
insert into LP_Location.Country
(Code, Name, Description, Active, ISO3166_1_ALFA002, ISO3166_1_ALFA003, ISO3166_1_NUMERIC)
values ('GLO','Global','Global Country', 1, 'GO', 'GLO', 999);

set @idGlobalCountry = @@identity

--CountryCurrency
insert into LP_Location.CountryCurrency
(idCountry, idCurrencyType, Active)
values (@idGlobalCountry, 2493, 1)

set @idCountryCurrency = @@identity

--Create Merchant 

--Glo
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Paydek Global', 1, 1)

set @idEntityMerchantGlobal = @@identity

------------------------------

--Create Entity User
--Glo
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Paydek Global', 'Paydek Global', 'alan.barry@paydek.com', '', '', 2, 4, @idEntityMerchantGlobal , 4, 1, @idGlobalCountry, '', 'LPPAYDEKGLO',1)

set @idEntityUserGlobalId = @@identity

--CREATE SUBMERCHANTS
--Global

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('PayDek', 'PayDek', @idEntityUserGlobalId, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

----------------

--INSERT Trasnaction Types

-------- GLO

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserGlobalId, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserGlobalId, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserGlobalId, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserGlobalId, 17, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserGlobalId, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

--------Currency Exchange

--ARG
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserGlobalId, 2493, 2493, 1, 1)

------------ Currency Base

-- ARG
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, @idGlobalCountry, 2, @idEntityUserGlobalId, 1.00, 1.00, 1, 1)

--------------- VARIABLE VALUES

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (10, @idGlobalCountry, 2, 1, 2, 2493, CAST(1.600000 AS Decimal(18, 6)), @idEntityUserGlobalId, 0)

------- ENTITY Account

SELECT @entityAccountId = [idEntityAccount] FROM [LP_Security].[EntityAccount] WHERE [Identification] = '000004000001';

------- ENTITY ACCOUNT USER

--GLO

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserGlobalId, 1)


------ API CREDENTIAL

--GLO
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000004000001', '$-82L)])t{%\S+e&', @idEntityUserGlobalId, @idGlobalCountry, 1)

ROLLBACK TRAN
--COMMIT