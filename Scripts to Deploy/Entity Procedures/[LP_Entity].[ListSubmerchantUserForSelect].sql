CREATE OR ALTER PROCEDURE [LP_Entity].[ListSubmerchantUserForSelect]
(
	@idEntityUser VARCHAR(120) null
)
AS
BEGIN
	DECLARE @JSON XML

	IF @idEntityUser IS NULL OR @idEntityUser = '0'
	BEGIN

	SET @JSON	=
				(
					SELECT
						CAST
						( 
							(
								SELECT								
									[ESM].[idEntityUser],
									[ESM].[Description] + '-' + [LC].ISO3166_1_ALFA003 as [Description],
									[ESM].[idEntitySubMerchant],
									[ESM].[SubMerchantIdentification],
									[EU].[MailAccount],
									[LC].ISO3166_1_ALFA003 CountryCode 	
								FROM 
									[LP_Entity].[EntitySubMerchant] [ESM]			
								INNER JOIN
									[LP_Entity].[EntityUser] [EU] on [EU].[idEntityUser] = [ESM].[idEntityUser]
								INNER JOIN
									[LP_Location].[Country] [LC] on [LC].idCountry = [EU].idCountry
								WHERE 
									[ESM].[Active] = 1
									AND ([EU].[idEntityUser] = @idEntityUser OR @idEntityUser = 0)
								ORDER BY [ESM].[SubMerchantIdentification] ASC
								FOR JSON PATH
							) AS XML
						)
				)
	END

	ELSE
	BEGIN

	SET @JSON	=
				(
					SELECT
						CAST
						( 
							(
								SELECT								
									[ESM].[idEntityUser],
									[ESM].[Description] + '-' + [LC].ISO3166_1_ALFA003 as [Description],
									[ESM].[idEntitySubMerchant],
									[ESM].[SubMerchantIdentification],
									[EU].[MailAccount],
									[LC].ISO3166_1_ALFA003 CountryCode 	
								FROM 
									[LP_Entity].[EntitySubMerchant] [ESM]			
								INNER JOIN
									[LP_Entity].[EntityUser] [EU] on [EU].[idEntityUser] = [ESM].[idEntityUser]
								INNER JOIN
									[LP_Location].[Country] [LC] on [LC].idCountry = [EU].idCountry
								WHERE 
									[ESM].[Active] = 1
									AND [EU].[idEntityUser] IN (SELECT idEntityUser FROM LP_Security.EntityAccountUser WHERE idEntityAccount = (SELECT idEntityAccount FROM LP_Security.EntityAccount WHERE UserSiteIdentification = @idEntityUser))
								ORDER BY [ESM].[SubMerchantIdentification] ASC
								FOR JSON PATH
							) AS XML
						)
				)

	END

	SELECT @JSON

END
GO


