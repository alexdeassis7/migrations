begin tran

declare  
@idEntityUserArg			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserCol			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserBra			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserChl			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantArg			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantCol			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantBra			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantChl			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


--Create Merchant 
	--Arg
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('AFEX - Argentina', 1, 1)

set @idEntityMerchantArg = @@identity

	--Colombia
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('AFEX - Colombia', 1, 1)

set @idEntityMerchantCol = @@identity

	--Brasil
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('AFEX - Brasil', 1, 1)

set @idEntityMerchantBra = @@identity

	--Uruguay
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('AFEX - Uruguay', 1, 1)

set @idEntityMerchantUry = @@identity

	--Chile
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('AFEX - Chile', 1, 1)

set @idEntityMerchantChl = @@identity

------------------------------

--Create Entity User
	--Arg
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('AFEX - Argentina', 'AFEX - Argentina', 'lslater@afex.com', '', '', 2, 4, @idEntityMerchantArg , 4, 1, 1, '', 'LPAFEXARG',1)


set @idEntityUserArg = @@identity

	--Col
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('AFEX - Colombia', 'AFEX - Colombia', 'lslater@afex.com', '', '', 2, 4, @idEntityMerchantCol , 4, 1, 49, '', 'LPAFEXCOL',1)

set @idEntityUserCol = @@identity

	--Bra
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('AFEX - Brasil', 'AFEX - Brasil', 'lslater@afex.com', '', '', 2, 4, @idEntityMerchantBra , 4, 1, 31, '', 'LPAFEXBRA',1)


set @idEntityUserBra = @@identity

	--Ury
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('AFEX - Uruguay', 'AFEX - Uruguay', 'lslater@afex.com', '', '', 2, 4, @idEntityMerchantUry , 4, 1, 244, '', 'LPAFEXURY',1)


set @idEntityUserUry = @@identity

	--CHL
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('AFEX - Chile', 'AFEX - Chile', 'lslater@afex.com', '', '', 2, 4, @idEntityMerchantChl , 4, 1, 44, '', 'LPAFEXCHL',1)


set @idEntityUserChl = @@identity

--CREATE SUBMERCHANTS
	--ARG
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('AFEX', 'AFEX', @idEntityUserArg, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

	--COL
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('AFEX', 'AFEX', @idEntityUserCol, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

	--BRA
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('AFEX', 'AFEX', @idEntityUserBra, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

	--URY
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('AFEX', 'AFEX', @idEntityUserUry, 1, 0, 1, '', '', 0, 1,'1.500000',2493)

	--CHL
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('AFEX', 'AFEX', @idEntityUserChl, 1, 0, 1, '', '', 0, 1,'1.000000',2493)
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

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserBra, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)


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

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

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

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserChl, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

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
values (2350, 1, 2, @idEntityUserArg, 0.5, 0.5, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 1, 2, @idEntityUserArg, 0.5, 0.5, 1, 1)


-- COL

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 49, 2, @idEntityUserCol, 0.8, 0.8, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2377, 49, 2, @idEntityUserCol, 0.8, 0.8, 1, 1)

-- BRA

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2363, 31, 2, @idEntityUserBra, 0.7, 0.7, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 31, 2, @idEntityUserBra, 0.7, 0.7, 1, 1)

-- URY
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2494, 244, 2, @idEntityUserUry, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 244, 2, @idEntityUserUry, 1.00, 1.00, 1, 1)

-- CHL
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2375, 44, 2, @idEntityUserChl, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 44, 2, @idEntityUserChl, 1.00, 1.00, 1, 1)
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
           ('000007000001'
           ,NEWID()
           ,'lslater@afex.com'
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

--URY

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserUry, 1)

--CHL

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserChl, 1)

------ API CREDENTIAL

--ARG
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000007000001', 'nkQ6cG4ycyP4H3RM', @idEntityUserArg, 1, 1)

--COL
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000007000001', 'QBdddsA8NwR3x8Yw', @idEntityUserCol, 49, 1)

--BRA
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000007000001', 'SNMC4nJ782aQsdpn', @idEntityUserBra, 31, 1)



--URY
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000007000001', 'Z7TURRaQ2FbmaujA', @idEntityUserUry, 244, 1)

--CHL
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000007000001', 'ARRLq5Vj46tuSS3t', @idEntityUserChl, 44, 1)

---- ENTITY PASSWORD

insert into LP_Security.EntityPassword values ('000007000001','WgqGUpWX7N',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())


ROLLBACK TRAN
--COMMIT