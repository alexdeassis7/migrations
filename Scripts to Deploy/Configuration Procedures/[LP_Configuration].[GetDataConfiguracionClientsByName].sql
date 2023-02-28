SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER Procedure [LP_Configuration].[GetDataConfiguracionClientsByName]
	@ClientName VARCHAR(100)
AS


DECLARE @IDSEntityUsers TABLE(id int)
Insert into @IDSEntityUsers
select IdEntityUser from LP_Entity.[EntityUser] EU
Where EU.FirstName LIKE  @ClientName + '%'  OR @ClientName is null


SELECT EU.FirstName,EAC.Identification,EAC.ApiKey, eu.Active FROM [LP_Security].[EntityApiCredential] EAC
	INNER JOIN [LP_Entity].[EntityUser] EU ON EAC.idEntityUser = EU.idEntityUser 
	Where EU.idEntityUser in (Select id from @IDSEntityUsers)
ORDER BY Identification DESC
FOR JSON PATH;

SELECT EA.idEntityAccount, lower(EA.UserSiteIdentification) as UserSiteIdentification,EP.PasswordSite, EU.FirstName, ea.Active FROM [LP_Security].[EntityAccount] EA
	inner join  lp_entity.entityUser EU ON EA.idEntityUser=EU.idEntityUser
	INNER JOIN [LP_Security].[EntityAccountPassword] EAP ON EA.idEntityAccount = EAP.idEntityAccount
	INNER JOIN [LP_Security].[EntityPassword] EP ON EAP.idEntityPassword = EP.idEntityPassword
	Where  EU.idEntityUser in (Select id from @IDSEntityUsers)
    and EA.Active = 1
FOR JSON PATH

select EU.idEntityUser, EU.LastName Client,ESM.CommissionValuePO Commission,CT.Code Currency,EU.fxPeriod ,CB.Base_Buy as 'Spread', ESM.WithRetentions as 'Retencion Afip', ESM.WithRetentions as 'Retencion Arba'
from lp_entity.entityUser EU
inner join lp_entity.entitySubMerchant ESM on ESM.idEntityUser = EU.idEntityUser and isDefault=1
inner join lp_entity.entityCurrencyExchange ECE on ECE.idEntityUser = EU.idEntityUser
inner join LP_Configuration.[CurrencyType] CT on ECE.idCurrencyTypeClient=CT.idCurrencyType
inner join [LP_Configuration].[CurrencyBase] CB on CB.idEntityUser=EU.idEntityUser
Where EU.idEntityUser in (Select id from @IDSEntityUsers)
group by EU.idEntityUser, EU.LastName,ESM.CommissionValuePO,CT.Code,EU.fxPeriod,CB.Base_Buy,CB.Base_Sell,ESM.WithRetentions, ESM.WithRetentions 
order by EU.LastName
FOR JSON PATH


GO