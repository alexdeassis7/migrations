begin tran

declare  
@idEntityUserUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityMerchantUry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

	--Mexico
insert into LP_Entity.EntityMerchant
(Description, idEntityBusinessNameType, Active)
values ('I-Payout Uruguay', 1, 1)

set @idEntityMerchantUry = @@identity

	--Mex
insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values ('I-Payout Uruguay', 'I-Payout Uruguay', 'jorge.bracho@i-payout.com', '', '', 2, 4, @idEntityMerchantUry , 4, 1, 244, '', 'LPIPAYURY',1)


set @idEntityUserUry = @@identity

	--MEX
insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('Asili', 'Asili', @idEntityUserUry, 1, 0, 1, '', '', 0, 1,'1.500000',2493)


----------------------------- MEX

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


--URY
insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserUry, 2494, 2493, 1, 1)

-- URY
insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2494, 244, 2, @idEntityUserUry, 1, 1, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy,Active, Version)
values (2493, 244, 2, @idEntityUserUry, 1, 1, 1, 1)



--URY

SELECT @entityAccountId = idEntityAccount
FROM LP_Security.EntityAccount
WHERE Identification = '000003000001'

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserUry, 1)


--URY
insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000003000001', '2Epm7pz5T9vwAtv2', @idEntityUserUry, 244, 1)

UPDATE EU
	SET EU.[CommissionValue] = ES.CommissionValuePO
	, EU.[CommissionCurrency] = ES.CommissionCurrencyPO
	FROM [LP_Entity].[EntityUser] EU
	INNER JOIN [LP_Entity].[EntitySubMerchant] ES ON ES.idEntityUser = EU.idEntityUser
	WHERE EU.idEntityUser = @idEntityUserUry

ROLLBACK
--COMMIT