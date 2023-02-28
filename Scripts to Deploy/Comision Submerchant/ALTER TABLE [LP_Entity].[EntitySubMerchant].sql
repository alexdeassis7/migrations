ALTER TABLE [LP_Entity].[EntitySubMerchant] 
ADD [CommissionValuePO] [LP_Common].[LP_F_DECIMAL] DEFAULT(1.6) WITH VALUES -- DEFAULT COMISSION 1.6 (EXCEPT AIRBNB = 1.4) 

go

ALTER TABLE [LP_Entity].[EntitySubMerchant] 
ADD [CommissionCurrencyPO] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] DEFAULT(2493) WITH VALUES -- DEFAULT CURRENCY USD

go

update es
set es.[CommissionValuePO] = 1.4
from  [LP_Entity].[EntitySubMerchant] es
inner join [LP_Entity].[EntityUser] eus on eus.idEntityUser = es.idEntityUser
where es.Description = 'Airbnb' and eus.Lastname = 'Payoneer - Argentina'

go

update es 
set es.[CommissionValuePO] = 1.5
from [LP_Entity].[EntitySubMerchant] es
inner join [LP_Entity].[EntityUser] eus on eus.idEntityUser = es.idEntityUser
where eus.Lastname = 'Payoneer - COLOMBIA'