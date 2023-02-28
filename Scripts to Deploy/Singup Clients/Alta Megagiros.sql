begin tran

declare  
@idEntityUserArg			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserCol			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserBra			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserChl			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantArg			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantCol			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantBra			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantChl			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


--Create Merchant 
	--Arg
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Megagiros Argentina', 1, 1)

set @idEntityMerchantArg = @@identity

	--Colombia
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Megagiros Colombia', 1, 1)

set @idEntityMerchantCol = @@identity

	--Brasil
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Megagiros Brasil', 1, 1)

set @idEntityMerchantBra = @@identity

	--Mexico
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Megagiros Mexico', 1, 1)

set @idEntityMerchantMex = @@identity

	--Uruguay
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Megagiros Uruguay', 1, 1)

set @idEntityMerchantUry = @@identity

	--Chile
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('Megagiros Chile', 1, 1)

set @idEntityMerchantChl = @@identity

------------------------------

--Create Entity User
	--Arg
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Megagiros Argentina', 'Megagiros Argentina', 'megagiros@localpayment.com', '', '', 2, 4, @idEntityMerchantArg , 4, 1, 1, '', 'LPMGGIARG',1)


set @idEntityUserArg = @@identity

	--Col
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Megagiros Colombia', 'Megagiros Colombia', 'megagiros@localpayment.com', '', '', 2, 4, @idEntityMerchantCol , 4, 1, 49, '', 'LPMGGICOL',1)

set @idEntityUserCol = @@identity

	--Bra
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Megagiros Brasil', 'Megagiros Brasil', 'megagiros@localpayment.com', '', '', 2, 4, @idEntityMerchantBra , 4, 1, 31, '', 'LPMGGIBRA',1)


set @idEntityUserBra = @@identity

	--Mex
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Megagiros Mexico', 'Megagiros Mexico', 'megagiros@localpayment.com', '', '', 2, 4, @idEntityMerchantMex , 4, 1, 150, '', 'LPMGGIMEX',1)


set @idEntityUserMex = @@identity

	--Ury
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Megagiros Uruguay', 'Megagiros Uruguay', 'megagiros@localpayment.com', '', '', 2, 4, @idEntityMerchantUry , 4, 1, 244, '', 'LPMGGIURY',1)


set @idEntityUserUry = @@identity

	--Chl
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Megagiros Chile', 'Megagiros Chile', 'megagiros@localpayment.com', '', '', 2, 4, @idEntityMerchantChl , 4, 1, 44, '', 'LPMGGICHL',1)


set @idEntityUserChl = @@identity

--CREATE SUBMERCHANTS

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('MEGAGIROS ARG', 'MEGAGIROS', @idEntityUserArg, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('MEGAGIROS COL', 'MEGAGIROS', @idEntityUserCol, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('MEGAGIROS BRA', 'MEGAGIROS', @idEntityUserBra, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('MEGAGIROS MEX', 'MEGAGIROS', @idEntityUserMex, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('MEGAGIROS URU', 'MEGAGIROS', @idEntityUserUry, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('MEGAGIROS CHI', 'MEGAGIROS', @idEntityUserChl, 1, 0, 1, '', '', 0, 1,'1.000000',2493)
----------------

--INSERT Trasnaction Types

-------- ARG

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserArg, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserArg, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserArg, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserArg, 17, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserArg, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

-------------- COL

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserCol, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserCol, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserCol, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserCol, 17, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserCol, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

-------------- BRA

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserBra, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserBra, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserBra, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserBra, 17, 1)

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

--ARG
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserArg, 2350, 2493, 1, 1)

--COL
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserCol, 2377, 2493, 1, 1)

--BRA
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserBra, 2363, 2493, 1, 1)

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

-- ARG
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2350, 1, 2, @idEntityUserArg, 2.00, 2.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 1, 2, @idEntityUserArg, 2.00, 2.00, 1, 1)

-- COL
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 49, 2, @idEntityUserCol, 2.00, 2.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2377, 49, 2, @idEntityUserCol, 2.00, 2.00, 1, 1)

-- BRA
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2363, 31, 2, @idEntityUserBra, 2.00, 2.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 31, 2, @idEntityUserBra, 2.00, 2.00, 1, 1)

-- MEX
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2446, 150, 2, @idEntityUserMex, 2.00, 2.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 150, 2, @idEntityUserMex, 2.00, 2.00, 1, 1)

-- URY
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2494, 244, 2, @idEntityUserUry, 2.50, 2.50, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 244, 2, @idEntityUserUry, 2.50, 2.50, 1, 1)

-- CHL
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy ,Active, Version)
values (2375, 44, 2, @idEntityUserChl, 2.00, 2.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy ,Active, Version)
values (2493, 44, 2, @idEntityUserChl, 2.00, 2.00, 1, 1)

--------------- VARIABLE VALUES

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (10, 1, 2, 1, 2, 2493, CAST(1.600000 AS Decimal(18, 6)), @idEntityUserArg, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (11, 1, 2, 1, 2, 2350, CAST(12.000000 AS Decimal(18, 6)), @idEntityUserArg, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (12, 1, 2, 1, 2, 2350, CAST(0.2100000 AS Decimal(18, 6)), @idEntityUserArg, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (13, 1, 2, 1, 2, 2350, CAST(0.030000 AS Decimal(18, 6)), @idEntityUserArg, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (14, 1, 2, 1, 2, 2350, CAST(0.000000 AS Decimal(18, 6)), @idEntityUserArg, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (8, 1, 2, 1, 2, 2350, CAST(1.210000 AS Decimal(18, 6)), @idEntityUserArg, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable])
VALUES (9, 1, 2, 1, 2, 2350, CAST(0.210000 AS Decimal(18, 6)), @idEntityUserArg, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (20, 49, 2, 1, 2, 2493, CAST(1.300000 AS Decimal(18, 6)), @idEntityUserCol, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (21, 49, 2, 1, 2, 2377, CAST(1.190000 AS Decimal(18, 6)), @idEntityUserCol, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable]) 
VALUES (22, 49, 2, 1, 2, 2377, CAST(0.190000 AS Decimal(18, 6)), @idEntityUserCol, 0)

INSERT [LP_Configuration].[VariableValue] 
([IdVariable], [IdCountry], [IdUnit], [Active], [idTransactionType], [idCurrencyType], [Value], [idEntityUser], [isCommissionVariable])
VALUES (24, 49, 2, 1, 2, 2377, CAST(0.004000 AS Decimal(18, 6)), @idEntityUserCol, 0)

----CROSS ---
------- ENTITY Account
INSERT INTO [LP_Security].[EntityAccount]
           ([Identification]
           ,[SecretKey]
           ,[UserSiteIdentification]
           ,[Active]
           ,[OP_InsDateTime]
           ,[OP_UpdDateTime]
           ,[DB_InsDateTime]
           ,[DB_UpdDateTime]
           ,[idEntityUser]
           ,[IsAdmin])
     VALUES
           ('000002700001'
	     ,NEWID()
           ,'admin@megagiros.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserArg
           ,1)

set @entityAccountId = @@identity

------- ENTITY ACCOUNT USER

--ARG

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserArg, 1)

-- COL
insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserCol, 1)

-- BRA
insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserBra, 1)

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

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002700001', '75_p&Wyyr6+2bmJa', @idEntityUserArg, 1, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002700001', '75_p&Wyyr6+2bmJa', @idEntityUserCol, 49, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002700001', '75_p&Wyyr6+2bmJa', @idEntityUserBra, 31, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002700001', '75_p&Wyyr6+2bmJa', @idEntityUserMex, 150, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002700001', '75_p&Wyyr6+2bmJa', @idEntityUserUry, 244, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002700001', '75_p&Wyyr6+2bmJa', @idEntityUserChl, 44, 1)

---- ENTITY PASSWORD

insert into LP_Security.EntityPassword values ('EATRPA6001','@xkM/cp5gC',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

UPDATE EU SET EU.[CommissionValue] = ES.CommissionValuePO
            , EU.[CommissionCurrency] = ES.CommissionCurrencyPO
FROM [LP_Entity].[EntityUser] EU
INNER JOIN [LP_Entity].[EntitySubMerchant] ES ON ES.idEntityUser = EU.idEntityUser
WHERE EU.idEntityUser IN (@idEntityUserArg, @idEntityUserBra, @idEntityUserChl, @idEntityUserCol, @idEntityUserMex, @idEntityUserUry)

ROLLBACK TRAN
--COMMIT