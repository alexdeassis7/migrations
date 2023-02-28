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
values ('Thunes Uruguay', 'Thunes Uruguay', 'patricia.mcquillan@thunes.com', '', '', 2, 4, (select idEntityMerchant from LP_Entity.EntityMerchant where [description] = 'Thunes Uruguay') , 4, 1, 1, '', 'LPTHUURY',6)

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
           ('000002000001'
           ,'6765CB46-5C04-4428-BE3A-79DF4E20BB6E'
           ,'patricia.mcquillan@thunes.com'
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETDATE()
           ,GETDATE()
           ,@idEntityUserArg
           ,1)


set @entityAccountId = @@identity
insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserArg, 1)

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserCol, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002000001', 'EACP#R0012', @idEntityUserArg, 1, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002000001', 'EACP#R008', @idEntityUserCol, 49, 1)

commit tran

begin tran

declare  @idEntityUserArg			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserCol			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

select @idEntityUserArg = idEntityUser from LP_Entity.EntityUser where LastName = 'Thunes Argentina'
select @idEntityUserCol = idEntityUser from LP_Entity.EntityUser where LastName = 'Thunes Colombia' 

INSERT INTO [LP_Entity].[EntitySubMerchant] ( [Description], [SubMerchantIdentification], [idEntityUser], [isDefault], [WithRetentions], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [SubMerchantCode], [SubMerchantAddress], [WithRetentionsARBA] )
VALUES ('Global66', 'Global66', @idEntityUserCol, 0, 0, 1, GETUTCDATE(), GETUTCDATE(), GETDATE(), GETDATE(), '', '', 0 )


INSERT INTO [LP_Entity].[EntitySubMerchant] ( [Description], [SubMerchantIdentification], [idEntityUser], [isDefault], [WithRetentions], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [SubMerchantCode], [SubMerchantAddress], [WithRetentionsARBA] )
VALUES ( 'Global66', 'Global66', @idEntityUserArg, 0, 1, 1, GETUTCDATE(), GETUTCDATE(), GETDATE(), GETDATE(), '', '', 1 )


INSERT INTO [LP_Entity].[EntitySubMerchant] ( [Description], [SubMerchantIdentification], [idEntityUser], [isDefault], [WithRetentions], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [SubMerchantCode], [SubMerchantAddress], [WithRetentionsARBA] )
VALUES ('XCOOP', 'XCOOP', @idEntityUserCol, 0, 0, 1, GETUTCDATE(), GETUTCDATE(), GETDATE(), GETDATE(), '', '', 0 )


INSERT INTO [LP_Entity].[EntitySubMerchant] ( [Description], [SubMerchantIdentification], [idEntityUser], [isDefault], [WithRetentions], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [SubMerchantCode], [SubMerchantAddress], [WithRetentionsARBA] )
VALUES ( 'XCOOP', 'XCOOP', @idEntityUserArg, 0, 1, 1, GETUTCDATE(), GETUTCDATE(), GETDATE(), GETDATE(), '', '', 1 )

INSERT INTO [LP_Retentions_ARG].[Reg830_Merchant] ([idReg], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [idEntitySubMerchant], [idCountry])
VALUES (2, 1, GETUTCDATE(), GETUTCDATE(), GETDATE(), GETDATE(), (select idEntitySubMerchant from LP_Entity.EntitySubMerchant where [Description] = 'Global66' and identityuser =  @idEntityUserArg) , 1)

INSERT INTO [LP_Retentions_ARG].[Reg830_Merchant] ([idReg], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [idEntitySubMerchant], [idCountry])
VALUES (2, 1, GETUTCDATE(), GETUTCDATE(), GETDATE(), GETDATE(), (select idEntitySubMerchant from LP_Entity.EntitySubMerchant where [Description] = 'XCOOP' and identityuser =  @idEntityUserArg) , 1)

commit tran

----------------------------------
declare  @idEntityUserArg			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserCol			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

select @idEntityUserCol = idEntityUser from LP_Entity.EntityUser where LastName = 'Thunes Colombia'

select @idEntityUserArg = idEntityUser from LP_Entity.EntityUser where LastName = 'Thunes Argentina'

INSERT INTO [LP_Entity].[EntitySubMerchant] ( [Description], [SubMerchantIdentification], [idEntityUser], [isDefault], [WithRetentions], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [SubMerchantCode], [SubMerchantAddress], [WithRetentionsARBA] )
VALUES ('TransferTo SG', 'TransferTo SG', @idEntityUserCol, 0, 0, 1, GETUTCDATE(), GETUTCDATE(), GETDATE(), GETDATE(), '', '', 0 )

INSERT INTO [LP_Entity].[EntitySubMerchant] ( [Description], [SubMerchantIdentification], [idEntityUser], [isDefault], [WithRetentions], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [SubMerchantCode], [SubMerchantAddress], [WithRetentionsARBA] )
VALUES ( 'TransferTo SG', 'TransferTo SG', @idEntityUserArg, 0, 1, 1, GETUTCDATE(), GETUTCDATE(), GETDATE(), GETDATE(), '', '', 1 )

INSERT INTO [LP_Retentions_ARG].[Reg830_Merchant] ([idReg], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [idEntitySubMerchant], [idCountry])
VALUES (2, 1, GETUTCDATE(), GETUTCDATE(), GETDATE(), GETDATE(), (select idEntitySubMerchant from LP_Entity.EntitySubMerchant where [Description] = 'TransferTo SG' and identityuser =  @idEntityUserArg) , 1)





