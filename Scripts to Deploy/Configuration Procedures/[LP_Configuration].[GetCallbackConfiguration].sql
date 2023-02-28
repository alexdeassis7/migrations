CREATE OR ALTER PROCEDURE [LP_Configuration].[GetCallbackConfiguration] @idEntityUser AS INT
AS 
BEGIN

SELECT TOP 1
	[CN].[idEntityUser], 
	notificationUrl, 
	[countryCode] = [C].[ISO3166_1_ALFA003],
	[customer] = [EA].[Identification],
	[signature] = [CN].[signature],
	[parameters] = (
		SELECT ParameterName, ParameterValue
		FROM LP_Configuration.CallbackNotificationParameter
		WHERE idCallbackNotification = [CN].[idCallbackNotification]
		FOR JSON PATH
	)
FROM LP_Configuration.[CallbackNotification] [CN]
INNER JOIN LP_Entity.EntityUser [EU] ON [EU].[idEntityUser] = [CN].[idEntityUser]
INNER JOIN LP_Location.Country [C] ON [C].[idCountry] = [EU].[idCountry]
INNER JOIN [LP_Security].EntityAccountUser EAU ON EAU.idEntityUser = [CN].[idEntityUser]
INNER JOIN LP_Security.EntityAccount [EA] ON [EA].[idEntityAccount] = [EAU].[idEntityAccount]
WHERE [CN].[idEntityUser] = @idEntityUser
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

END