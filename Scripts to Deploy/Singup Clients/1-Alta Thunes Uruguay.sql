begin tran

declare  
@idEntityUserUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantUry		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


--Create Merchant 
--Ury
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Thunes Uruguay', 1, 1)

set @idEntityMerchantUry = @@identity

------------------------------

--Create Entity User
--Ury
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Thunes Uruguay', 'Thunes Uruguay', 'patricia.mcquillan@thunes.com', '', '', 2, 4, @idEntityMerchantUry , 4, 1, 244, '', 'LPTHUURY',6)

set @idEntityUserUry = @@identity

-- IdEntityUser = 205
-------------------------------

--Create SubMerchant

	--URY
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('Thunes', 'Thunes', @idEntityUserUry, 0, 0, 1, '', '', 0, 1,'2.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('TransferTo SG', 'TransferTo SG', @idEntityUserUry, 1, 0, 1, '', '', 0, 1,'2.000000',2493)
----------------

--INSERT Trasnaction Types

-- URY
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

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

--------Currency Exchange

--URY
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserUry, 2494, 2493, 1, 1)

------------ Currency Base

-- URY
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2494, 244, 2, @idEntityUserUry, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 244, 2, @idEntityUserUry, 1.00, 1.00, 1, 1)

------------ Entity Account

SELECT @entityAccountId = [idEntityAccount] FROM [LP_Security].[EntityAccount] WHERE [Identification] = '000002000001';

------- ENTITY ACCOUNT USER

--URY

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserUry, 1)

------ API CREDENTIAL

--URY
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002000001', 'EAC0000012', @idEntityUserUry, 244, 1)

ROLLBACK TRAN
--COMMIT