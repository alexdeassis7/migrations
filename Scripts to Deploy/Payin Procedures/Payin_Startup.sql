BEGIN TRAN
declare  @idTransactionTypePayin			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
insert into LP_Common.[Status] (Code, [Name], [Description]) values ('Expired','Expired','The Payin was expired') 

INSERT INTO LP_Location.CountryCurrency (idCountry,idCurrencyType,Active) values ((select idcountry from LP_Location.Country where Code = 'BRL'),(select idCurrencyType from LP_Configuration.CurrencyType where code = 'BRL'),1)
INSERT INTO LP_Location.CountryCurrency (idCountry,idCurrencyType,Active) values ((select idcountry from LP_Location.Country where Code = 'COP'),(select idCurrencyType from LP_Configuration.CurrencyType where code = 'COP'),1)
INSERT INTO LP_Location.CountryCurrency (idCountry,idCurrencyType,Active) values ((select idcountry from LP_Location.Country where Code = 'UYU'),(select idCurrencyType from LP_Configuration.CurrencyType where code = 'UYU'),1)


insert into LP_Configuration.[TransactionType] (code,[name],[Description],idCountry,Active,idTransactionGroup) values ('PAYIN','PAYIN','PAYIN',1,1,3)

set @idTransactionTypePayin = @@identity

insert into LP_Entity.EntityUser
	(lastname,firstname, mailaccount, Telephonenumber, mobilenumber,identitytype,identityidentificationtype,identitymerchant,identityadress,active,idCountry,accountnumberlp,merchantalias,fxperiod)
	select 
	(LastName + '_Payin') as lastname,(firstname + '_Payin') as firstname, mailaccount, Telephonenumber, mobilenumber,identitytype,identityidentificationtype,identitymerchant,identityadress,active,idCountry,accountnumberlp,merchantalias,fxperiod
	from 
	LP_Entity.EntityUser


insert into [LP_Entity].[EntityUserTransactionType]
	(identityuser,idtransactiontype,active)
	select
		identityuser,@idTransactionTypePayin,1
	from 
		LP_Entity.EntityUser
	where firstname like '%_Payin%'
	
insert into LP_Entity.EntityCurrencyExchange
	(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, [Version])
	select
		identityuser,cc.idCurrencyType,cc.idCurrencyType, 1, 1
	from 
		LP_Entity.EntityUser 
	inner join 
		LP_Location.Country c on LP_Entity.EntityUser.idCountry = c.idCountry
	inner join 
		LP_Configuration.CurrencyType cc on cc.Code= c.Code
	where firstname like '%_Payin%' 
	
insert into 
	LP_Configuration.PayWayServices (code,[name],[Description],idCountry,active) 
values 
	('PAYINBTRA','Transferencia Bancaria','Transferencia Bancaria',1,1)


insert into 
	LP_Configuration.[Provider] (Code,[Name],[Description],IdCountry,Active) 
values 
	('SRA','BANCO SANTANDER','BANCO SANTANDER',1,1)

insert into LP_Configuration.TransactionTypeProvider (idTransactionType,idProvider,Active) values ((select idtransactiontype from LP_Configuration.TransactionType where Code = 'PAYIN'),
(select idProvider from LP_Configuration.[Provider] where code = 'SRA'),1)

insert into LP_Configuration.ProviderPayWayServices (idProvider,idPayWayService,Active) 
values ((select idProvider from LP_Configuration.[Provider] where code = 'SRA'),
(select idPayWayService from LP_Configuration.PayWayServices where code = 'PAYINBTRA'),
1)

insert into LP_Configuration.Variable (IdCountry,Code,[Name],[Description],Active) values (1,'VAR::ARG::GENERAL_PAYIN.EXPIRE_DAYS','VAR::ARG::GENERAL_PAYIN.EXPIRE_DAYS','VAR::ARG::GENERAL_PAYIN.EXPIRE_DAYS',1)

insert into LP_Configuration.InternalStatus (Code, [Name], [Description],idProvider,idCountry,Active,idInternalStatusType, FinalStatus,isError) values ('EXPIRED','Payin expired','Payin expired',4,1,1,4,1,0)

COMMIT TRAN

