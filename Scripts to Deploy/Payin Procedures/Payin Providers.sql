begin tran

DECLARE @idCountry AS int
DECLARE @idTransactionType AS INT = (select idtransactiontype from LP_Configuration.TransactionType where Code = 'PAYIN')
DECLARE @idPayWayService AS INT


SET @idCountry = (SELECT idCountry FROM LP_Location.Country WHERE ISO3166_1_ALFA003 = 'BRA')

insert into 
  LP_Configuration.[Provider] (Code,[Name],[Description],IdCountry,Active) 
values 
  ('I','ITAU','ITAU',@idCountry,1),
  ('B', 'BRADESCO', 'BRADESCO', @idCountry, 1),
  ('CA', 'CAIXA', 'CAIXA', @idCountry, 1),
  ('BB', 'BANCO DO BRASIL', 'BANCO DO BRASIL', @idCountry, 1),
  ('SB', 'SANTANDER', 'SANTANDER', @idCountry, 1)

insert into 
	LP_Configuration.PayWayServices (code,[name],[Description],idCountry,active) 
values 
	('PAYINBTRA','Transferencia Bancaria','Transferencia Bancaria', @idCountry, 1)

SET @idPayWayService = @@IDENTITY


insert into LP_Configuration.TransactionTypeProvider (idTransactionType,idProvider,Active) 
select @idTransactionType, idProvider, 1
from LP_Configuration.[Provider] 
where code IN ('I', 'B', 'CA','BB','SB') and idCountry = @idCountry

insert into LP_Configuration.ProviderPayWayServices (idProvider,idPayWayService,Active) 
select idProvider, @idPayWayService, 1
from LP_Configuration.[Provider] 
where code IN ('I', 'B', 'CA','BB','SB') and idCountry = @idCountry

------------------------------------------------------------------

SET @idCountry = (SELECT idCountry FROM LP_Location.Country WHERE ISO3166_1_ALFA003 = 'CHL')

insert into 
  LP_Configuration.[Provider] (Code,[Name],[Description],IdCountry,Active) 
values 
  ('WP','WEBPAY','WEBPAY',@idCountry,1)

insert into 
	LP_Configuration.PayWayServices (code,[name],[Description],idCountry,active) 
values 
	('PAYINBTRA','Transferencia Bancaria','Transferencia Bancaria', @idCountry, 1)

SET @idPayWayService = @@IDENTITY


insert into LP_Configuration.TransactionTypeProvider (idTransactionType,idProvider,Active) 
select @idTransactionType, idProvider, 1
from LP_Configuration.[Provider] 
where code IN ('WP') and idCountry = @idCountry

insert into LP_Configuration.ProviderPayWayServices (idProvider,idPayWayService,Active) 
select idProvider, @idPayWayService, 1
from LP_Configuration.[Provider] 
where code IN ('WP') and idCountry = @idCountry


--------------------------------------------------------------------------


SET @idCountry = (SELECT idCountry FROM LP_Location.Country WHERE ISO3166_1_ALFA003 = 'COL')

insert into 
  LP_Configuration.[Provider] (Code,[Name],[Description],IdCountry,Active) 
values 
  ('PC','PSE','PSE',@idCountry,1)

insert into 
	LP_Configuration.PayWayServices (code,[name],[Description],idCountry,active) 
values 
	('PAYINBTRA','Transferencia Bancaria','Transferencia Bancaria', @idCountry, 1)

SET @idPayWayService = @@IDENTITY

insert into LP_Configuration.TransactionTypeProvider (idTransactionType,idProvider,Active) 
select @idTransactionType, idProvider, 1
from LP_Configuration.[Provider] 
where code IN ('PC') and idCountry = @idCountry

insert into LP_Configuration.ProviderPayWayServices (idProvider,idPayWayService,Active) 
select idProvider, @idPayWayService, 1
from LP_Configuration.[Provider] 
where code IN ('PC') and idCountry = @idCountry


-------------------------------------------------------------------


SET @idCountry = (SELECT idCountry FROM LP_Location.Country WHERE ISO3166_1_ALFA003 = 'MEX')

insert into 
  LP_Configuration.[Provider] (Code,[Name],[Description],IdCountry,Active) 
values 
  ('SE','SPEI','SPEI',@idCountry,1),
  ('BV','BBVA BANCOMER','BBVA BANCOMER',@idCountry,1),
  ('BQ','BANORTE','BANORTE',@idCountry,1),
  ('SRM','SANTANDER','SANTANDER',@idCountry,1)

insert into 
	LP_Configuration.PayWayServices (code,[name],[Description],idCountry,active) 
values 
	('PAYINBTRA','Transferencia Bancaria','Transferencia Bancaria', @idCountry, 1)

SET @idPayWayService = @@IDENTITY

insert into LP_Configuration.TransactionTypeProvider (idTransactionType,idProvider,Active) 
select @idTransactionType, idProvider, 1
from LP_Configuration.[Provider] 
where code IN ('SE', 'BV', 'BQ', 'SRM') and idCountry = @idCountry

insert into LP_Configuration.ProviderPayWayServices (idProvider,idPayWayService,Active) 
select idProvider, @idPayWayService, 1
from LP_Configuration.[Provider] 
where code IN ('SE', 'BV', 'BQ', 'SRM') and idCountry = @idCountry



---------------------------------------------------------------------------

SET @idCountry = (SELECT idCountry FROM LP_Location.Country WHERE ISO3166_1_ALFA003 = 'URY')

insert into 
  LP_Configuration.[Provider] (Code,[Name],[Description],IdCountry,Active) 
values 
  ('SRU','SANTANDER','SANTANDER',@idCountry,1)

insert into 
	LP_Configuration.PayWayServices (code,[name],[Description],idCountry,active) 
values 
	('PAYINBTRA','Transferencia Bancaria','Transferencia Bancaria', @idCountry, 1)

SET @idPayWayService = @@IDENTITY

insert into LP_Configuration.TransactionTypeProvider (idTransactionType,idProvider,Active) 
select @idTransactionType, idProvider, 1
from LP_Configuration.[Provider] 
where code IN ('SRU') and idCountry = @idCountry

insert into LP_Configuration.ProviderPayWayServices (idProvider,idPayWayService,Active) 
select idProvider, @idPayWayService, 1
from LP_Configuration.[Provider] 
where code IN ('SRU') and idCountry = @idCountry

---------------------------------------------------------------------------------------------

-- INSERTING INTERNAL STATUS FOR NEW PROVIDERS

INSERT INTO LP_Configuration.InternalStatus(Code, Name, Description, idProvider, idCountry, Active, idInternalStatusType, isError, FinalStatus)
SELECT 'INPROGRESS', 
		'InProgress', 
		'The payin is being processed.', 
		P.idProvider, 
		idCountry, 
		1, 
		(SELECT idInternalStatusType FROM LP_Configuration.InternalStatusType WHERE Code = 'SCM' AND idCountry = P.idCountry), 
		0, 
		0
FROM LP_Configuration.Provider P 
inner join LP_Configuration.TransactionTypeProvider TTP ON TTP.idProvider = P.idProvider
WHERE TTP.idTransactionType = @idTransactionType

INSERT INTO LP_Configuration.InternalStatus(Code, Name, Description, idProvider, idCountry, Active, idInternalStatusType, isError, FinalStatus)
SELECT 'EXECUTED', 
		'Executed', 
		'Successfully executed.', 
		P.idProvider, 
		idCountry, 
		1, 
		(SELECT idInternalStatusType FROM LP_Configuration.InternalStatusType WHERE Code = 'SCM' AND idCountry = P.idCountry), 
		0, 
		1
FROM LP_Configuration.Provider P 
inner join LP_Configuration.TransactionTypeProvider TTP ON TTP.idProvider = P.idProvider
WHERE TTP.idTransactionType = @idTransactionType

INSERT INTO LP_Configuration.InternalStatus(Code, Name, Description, idProvider, idCountry, Active, idInternalStatusType, isError, FinalStatus)
SELECT 'EXPIRED', 
		'Expired', 
		'The payin request has expired.', 
		P.idProvider, 
		idCountry, 
		1, 
		(SELECT idInternalStatusType FROM LP_Configuration.InternalStatusType WHERE Code = 'SCM' AND idCountry = P.idCountry), 
		1, 
		1
FROM LP_Configuration.Provider P 
inner join LP_Configuration.TransactionTypeProvider TTP ON TTP.idProvider = P.idProvider
WHERE TTP.idTransactionType = @idTransactionType


ROLLBACK tran
