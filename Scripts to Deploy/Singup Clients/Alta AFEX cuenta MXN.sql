begin tran

declare  
@idEntityUserMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantMex			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

	--Mexico
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('AFEX - Mexico', 1, 1)

set @idEntityMerchantMex = @@identity

	--Mex
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('AFEX - Mexico', 'AFEX - Mexico', 'lslater@afex.com', '', '', 2, 4, @idEntityMerchantMex , 4, 1, 150, '', 'LPAFEXMEX',1)


set @idEntityUserMex = @@identity

	--MEX
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('AFEX', 'AFEX', @idEntityUserMex, 1, 0, 1, '', '', 0, 1,'1.000000',2493)


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

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserMex, (select idTransactionType from LP_Configuration.TransactionType where Code = 'PAYIN'), 1)


--MEX
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserMex, 2446, 2446, 1, 1)

-- MEX
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2446, 150, 2, @idEntityUserMex, 0.5, 0.5, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 150, 2, @idEntityUserMex, 0.5, 0.5, 1, 1)



--MEX

SELECT @entityAccountId = idEntityAccount
FROM LP_Security.EntityAccount
WHERE Identification = '000007000001'

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserMex, 1)


--MEX
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000007000001', 'yBM8Bju5ZjXRe3zA', @idEntityUserMex, 150, 1)

ROLLBACK
--COMMIT