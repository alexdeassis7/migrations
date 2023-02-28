begin tran

declare  
@idEntityUserMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


--Create Merchant 
	
	--Mexico
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('I-Payout Mexico MXN', 1, 1)

set @idEntityMerchantMex = @@identity


------------------------------

--Create Entity User


	--Mex
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('I-Payout Mexico MXN', 'I-Payout Mexico MXN', 'eddie@i-payout.com', '', '', 2, 4, @idEntityMerchantMex , 4, 1, 150, '', 'LPIPAYMEXL',1)


set @idEntityUserMex = @@identity


--CREATE SUBMERCHANTS


	--MEX
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('Asili', 'Asili', @idEntityUserMex, 1, 0, 1, '', '', 0, 1,'1.500000',2493)

----------------

--INSERT Trasnaction Types


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

--insert into [LP_Entity].[EntityUserTransactionType]
--(idEntityUser, idTransactionType, Active)
--values(@idEntityUserMex, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)


--------Currency Exchange

--MEX
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserMex, 2446, 2446, 1, 1)


------------ Currency Base


-- MEX
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2446, 150, 2, @idEntityUserMex, 1.50, 1.50, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 150, 2, @idEntityUserMex, 1.50, 1.50, 1, 1)

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
           ('000003000002'
           ,NEWID()
           ,'eddie@i-payout.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserMex
           ,1)

set @entityAccountId = @@identity

------- ENTITY ACCOUNT USER

--MEX

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserMex, 1)


------ API CREDENTIAL

--MEX
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000003000002', 'GzYRrwwLvep9Cz5b', @idEntityUserMex, 150, 1)

---- ENTITY PASSWORD

insert into LP_Security.EntityPassword values ('EACB103000','2GTkWNUTxS3h2tNZ',GETDATE(),1,1,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

set @entityPasswordId = SCOPE_IDENTITY()

insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
           ,GETDATE()
           ,GETDATE())

UPDATE EU
	SET EU.[CommissionValue] = ES.CommissionValuePO
	, EU.[CommissionCurrency] = ES.CommissionCurrencyPO
	FROM [LP_Entity].[EntityUser] EU
	INNER JOIN [LP_Entity].[EntitySubMerchant] ES ON ES.idEntityUser = EU.idEntityUser
	WHERE EU.idEntityUser IN (@idEntityUserMex)



ROLLBACK TRAN
--COMMIT