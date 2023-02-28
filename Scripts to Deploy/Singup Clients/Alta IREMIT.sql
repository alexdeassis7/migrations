begin tran

declare  
@idEntityUserArg			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserCol			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserBra			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserChl			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId1			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId2			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId3			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId4			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId5			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId6			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId7			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantArg			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantCol			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantBra			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantChl			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId1			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId2			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId3			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId4			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId5			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId6			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId7			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


--Create Merchant 
	--Arg
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('IREMIT Argentina', 1, 1)

set @idEntityMerchantArg = @@identity

	--Colombia
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('IREMIT Colombia', 1, 1)

set @idEntityMerchantCol = @@identity

	--Brasil
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('IREMIT Brasil', 1, 1)

set @idEntityMerchantBra = @@identity

	--Mexico
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('IREMIT Mexico', 1, 1)

set @idEntityMerchantMex = @@identity

	--Uruguay
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('IREMIT Uruguay', 1, 1)

set @idEntityMerchantUry = @@identity

	--Chile
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('IREMIT Chile', 1, 1)

set @idEntityMerchantChl = @@identity

------------------------------

--Create Entity User
	--Arg
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('IREMIT Argentina', 'IREMIT Argentina', 'dpdumalag@iremit-inc.com', '', '', 2, 4, @idEntityMerchantArg , 4, 1, 1, '', 'LPIREMITARG',1)


set @idEntityUserArg = @@identity

	--Col
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('IREMIT Colombia', 'IREMIT Colombia', 'dpdumalag@iremit-inc.com', '', '', 2, 4, @idEntityMerchantCol , 4, 1, 49, '', 'LPIREMITCOL',1)

set @idEntityUserCol = @@identity

	--Bra
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('IREMIT Brasil', 'IREMIT Brasil', 'dpdumalag@iremit-inc.com', '', '', 2, 4, @idEntityMerchantBra , 4, 1, 31, '', 'LPIREMITBRA',1)


set @idEntityUserBra = @@identity

	--Mex
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('IREMIT Mexico', 'IREMIT Mexico', 'dpdumalag@iremit-inc.com', '', '', 2, 4, @idEntityMerchantMex , 4, 1, 150, '', 'LPIREMITMEX',1)


set @idEntityUserMex = @@identity

	--Ury
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('IREMIT Uruguay', 'IREMIT Uruguay', 'dpdumalag@iremit-inc.com', '', '', 2, 4, @idEntityMerchantUry , 4, 1, 244, '', 'LPIREMITURY',1)


set @idEntityUserUry = @@identity

	--Chl
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('IREMIT Chile', 'IREMIT Chile', 'dpdumalag@iremit-inc.com', '', '', 2, 4, @idEntityMerchantChl , 4, 1, 44, '', 'LPIREMITCHL',1)


set @idEntityUserChl = @@identity

--CREATE SUBMERCHANTS

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('IREMIT', 'IREMIT', @idEntityUserArg, 0, 0, 1, '', '', 0, 1,'0.750000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('IREMIT', 'IREMIT', @idEntityUserCol, 0, 0, 1, '', '', 0, 1,'1.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('IREMIT', 'IREMIT', @idEntityUserBra, 0, 0, 1, '', '', 0, 1,'1.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('IREMIT', 'IREMIT', @idEntityUserMex, 0, 0, 1, '', '', 0, 1,'1.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('IREMIT', 'IREMIT', @idEntityUserUry, 0, 0, 1, '', '', 0, 1,'2.000000',2493)

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('IREMIT', 'IREMIT', @idEntityUserChl, 0, 0, 1, '', '', 0, 1,'1.500000',2493)
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
values (2350, 1, 2, @idEntityUserArg, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 1, 2, @idEntityUserArg, 1.00, 1.00, 1, 1)


-- COL

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 49, 2, @idEntityUserCol, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2377, 49, 2, @idEntityUserCol, 1.00, 1.00, 1, 1)

-- BRA

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2363, 31, 2, @idEntityUserBra, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 31, 2, @idEntityUserBra, 1.00, 1.00, 1, 1)

-- MEX
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2446, 150, 2, @idEntityUserMex, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
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
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy ,Active, Version)
values (2375, 44, 2, @idEntityUserChl, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy ,Active, Version)
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
           ('000005100001'
		   ,NEWID()
           ,'mtoranda@iremit-inc.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserArg
           ,1)

set @entityAccountId1 = @@identity

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
           ('000005100002'
		   ,NEWID()
           ,'rabenito@iremit-inc.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserArg
           ,0)

set @entityAccountId2 = @@identity

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
           ('000005100003'
		   ,NEWID()
           ,'dlsobrepena@iremit-inc.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserArg
           ,0)

set @entityAccountId3 = @@identity

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
           ('000005100004'
		   ,NEWID()
           ,'salagan@iremit-inc.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserArg
           ,0)

set @entityAccountId4 = @@identity

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
           ('000005100005'
		   ,NEWID()
           ,'famamaradlo@iremit-inc.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserArg
           ,0)

set @entityAccountId5 = @@identity

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
           ('000005100006'
		   ,NEWID()
           ,'esdy@iremit-inc.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserArg
           ,0)

set @entityAccountId6 = @@identity

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
           ('000005100007'
		   ,NEWID()
           ,'dpdumalag@iremit-inc.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserArg
           ,0)

set @entityAccountId7 = @@identity

------- ENTITY ACCOUNT USER

--ARG

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId1, @idEntityUserArg, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId2, @idEntityUserArg, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId3, @idEntityUserArg, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId4, @idEntityUserArg, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId5, @idEntityUserArg, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId6, @idEntityUserArg, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId7, @idEntityUserArg, 1)

-- COL
insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId1, @idEntityUserCol, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId2, @idEntityUserCol, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId3, @idEntityUserCol, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId4, @idEntityUserCol, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId5, @idEntityUserCol, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId6, @idEntityUserCol, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId7, @idEntityUserCol, 1)

-- BRA
insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId1, @idEntityUserBra, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId2, @idEntityUserBra, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId3, @idEntityUserBra, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId4, @idEntityUserBra, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId5, @idEntityUserBra, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId6, @idEntityUserBra, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId7, @idEntityUserBra, 1)

--MEX

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId1, @idEntityUserMex, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId2, @idEntityUserMex, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId3, @idEntityUserMex, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId4, @idEntityUserMex, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId5, @idEntityUserMex, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId6, @idEntityUserMex, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId7, @idEntityUserMex, 1)

--URY

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId1, @idEntityUserUry, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId2, @idEntityUserUry, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId3, @idEntityUserUry, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId4, @idEntityUserUry, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId5, @idEntityUserUry, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId6, @idEntityUserUry, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId7, @idEntityUserUry, 1)

--CHL

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId1, @idEntityUserChl, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId2, @idEntityUserChl, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId3, @idEntityUserChl, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId4, @idEntityUserChl, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId5, @idEntityUserChl, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId6, @idEntityUserChl, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId7, @idEntityUserChl, 1)

------ API CREDENTIAL

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000005100001', 'IREM##AR1', @idEntityUserArg, 1, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000005100001', 'IREM##CO1', @idEntityUserCol, 49, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000005100001', 'IREM##BR1', @idEntityUserBra, 31, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000005100001', 'IREM##MX1', @idEntityUserMex, 150, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000005100001', 'IREM##UY1', @idEntityUserUry, 244, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000005100001', 'IREM##CHL1', @idEntityUserChl, 44, 1)

---- ENTITY PASSWORD

insert into LP_Security.EntityPassword values ('EAC0005001','$IRE#MIT_1',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId1 = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId1,@entityPasswordId1,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

insert into LP_Security.EntityPassword values ('EAC0005002','$IRE#MIT_2',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId2 = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId2,@entityPasswordId2,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

insert into LP_Security.EntityPassword values ('EAC0005003','$IRE#MIT_3',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId3 = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId3,@entityPasswordId3,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

insert into LP_Security.EntityPassword values ('EAC0005004','$IRE#MIT_4',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId4 = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId4,@entityPasswordId4,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

insert into LP_Security.EntityPassword values ('EAC0005005','$IRE#MIT_5',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId5 = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId5,@entityPasswordId5,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

insert into LP_Security.EntityPassword values ('EAC0005006','$IRE#MIT_6',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId6 = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId6,@entityPasswordId6,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

insert into LP_Security.EntityPassword values ('EAC0005006','$IRE#MIT_7',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId7 = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId7,@entityPasswordId7,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

UPDATE EU SET EU.[CommissionValue] = ES.CommissionValuePO
            , EU.[CommissionCurrency] = ES.CommissionCurrencyPO
FROM [LP_Entity].[EntityUser] EU
INNER JOIN [LP_Entity].[EntitySubMerchant] ES ON ES.idEntityUser = EU.idEntityUser
WHERE EU.idEntityUser IN (@idEntityUserArg, @idEntityUserBra, @idEntityUserChl, @idEntityUserCol, @idEntityUserMex, @idEntityUserUry)

ROLLBACK TRAN
--COMMIT