begin tran

declare  
@idEntityUser				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

--Add Entity USER
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Israel', 'Ezequiel', 'ezequiel@localpayment.com', '', '', 1, 1, null , 1, 1, 1, '', 'LPSISRAEL',1)


set @idEntityUser = @@identity

--ADD SUMBERCHANT
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('LocalPayment', 'LocalPayment', @idEntityUser, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

--ADD TRANSACTION TYPE
insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 17, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

--------Currency Exchange
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUser, 2350, 2493, 1, 1)

------------ Currency Base
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2350, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

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
           ('000000000002'
           ,NEWID()
           ,'ezequiel@localpayment.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUser
           ,1)

set @entityAccountId = @@identity

------- ENTITY ACCOUNT USER
insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUser, 1)

------ API CREDENTIAL
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000000000002', 'y5Sq2y9Fg-[tD=;7', @idEntityUser, 1, 1)

---- ENTITY PASSWORD

insert into LP_Security.EntityPassword values ('EACB000002','7X87sGYVHjXkp3VT',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

ROLLBACK
GO
begin tran

declare  
@idEntityUser				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

--Add Entity USER
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Grynszpancholc', 'Jonathan', 'jonathan@localpayment.com', '', '', 1, 1, null , 1, 1, 1, '', 'LPSJONA',1)


set @idEntityUser = @@identity

--ADD SUMBERCHANT
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('LocalPayment', 'LocalPayment', @idEntityUser, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

--ADD TRANSACTION TYPE
insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 17, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

--------Currency Exchange
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUser, 2350, 2493, 1, 1)

------------ Currency Base
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2350, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

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
           ('000000000003'
           ,NEWID()
           ,'jonathan@localpayment.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUser
           ,1)

set @entityAccountId = @@identity

------- ENTITY ACCOUNT USER
insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUser, 1)

------ API CREDENTIAL
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000000000003', 'prt39Mpy7UdF4GAu', @idEntityUser, 1, 1)

---- ENTITY PASSWORD

insert into LP_Security.EntityPassword values ('EACB000003','R9gk7dTWGsyHdEFF',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

ROLLBACK
GO
begin tran

declare  
@idEntityUser				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

--Add Entity USER
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Garcia', 'Nicolas', 'nicolasgarcia@localpayment.com', '', '', 1, 1, null , 1, 1, 1, '', 'LPSGARZA',1)


set @idEntityUser = @@identity

--ADD SUMBERCHANT
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('LocalPayment', 'LocalPayment', @idEntityUser, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

--ADD TRANSACTION TYPE
insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 17, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

--------Currency Exchange
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUser, 2350, 2493, 1, 1)

------------ Currency Base
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2350, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

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
           ('000000000004'
           ,NEWID()
           ,'nicolasgarcia@localpayment.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUser
           ,1)

set @entityAccountId = @@identity

------- ENTITY ACCOUNT USER
insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUser, 1)

------ API CREDENTIAL
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000000000004', 'GbTWWByKQ7DpeYz8', @idEntityUser, 1, 1)

---- ENTITY PASSWORD

insert into LP_Security.EntityPassword values ('EACB000004','GbTWWByKQ7DpeYz8',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

ROLLBACK
GO
begin tran

declare  
@idEntityUser				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

--Add Entity USER
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Nishida', 'Ken', 'ken@localpayment.com', '', '', 1, 1, null , 1, 1, 1, '', 'LPSKEN',1)


set @idEntityUser = @@identity

--ADD SUMBERCHANT
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('LocalPayment', 'LocalPayment', @idEntityUser, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

--ADD TRANSACTION TYPE
insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 17, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

--------Currency Exchange
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUser, 2350, 2493, 1, 1)

------------ Currency Base
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2350, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

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
           ('000000000005'
           ,NEWID()
           ,'ken@localpayment.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUser
           ,1)

set @entityAccountId = @@identity

------- ENTITY ACCOUNT USER
insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUser, 1)

------ API CREDENTIAL
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000000000005', 'Nrxa9TKudQrb5YuJ', @idEntityUser, 1, 1)

---- ENTITY PASSWORD

insert into LP_Security.EntityPassword values ('EACB000005','Nrxa9TKudQrb5YuJ',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

ROLLBACK
GO
begin tran

declare  
@idEntityUser				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

--Add Entity USER
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('Reports', 'Reports', 'reports@localpayment.com', '', '', 1, 1, null , 1, 1, 1, '', 'LPSRPT',1)


set @idEntityUser = @@identity

--ADD SUMBERCHANT
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('LocalPayment', 'LocalPayment', @idEntityUser, 1, 0, 1, '', '', 0, 1,'1.000000',2493)

--ADD TRANSACTION TYPE
insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, 17, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUser, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)

--------Currency Exchange
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUser, 2350, 2493, 1, 1)

------------ Currency Base
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2350, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 1, 2, @idEntityUser, 1.00, 1.00, 1, 1)

----CROSS ---
------- ENTITY Account
UPDATE [LP_Security].[EntityAccount] SET idEntityUser = @idEntityUser WHERE UserSiteIdentification = 'robot@localpayment.com'

set @entityAccountId = (SELECT idEntityAccount FROM [LP_Security].[EntityAccount] WHERE UserSiteIdentification = 'robot@localpayment.com')

------- ENTITY ACCOUNT USER
UPDATE LP_Security.EntityAccountUser SET idEntityUser = @idEntityUser WHERE idEntityAccount = @entityAccountId

------ API CREDENTIAL
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000000000006', 'TtmzyhAJFJn44the', @idEntityUser, 1, 1)

ROLLBACK
