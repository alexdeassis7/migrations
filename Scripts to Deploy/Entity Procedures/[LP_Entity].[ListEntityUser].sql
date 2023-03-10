ALTER PROCEDURE [LP_Entity].[ListEntityUser]
(
	@userIdentification VARCHAR(120)
)
AS
BEGIN

	DECLARE @JSON XML

	IF @userIdentification IS NULL OR @userIdentification = '0'
	BEGIN

	SET @JSON	=
				(
					SELECT
						CAST
						( 
							(
								SELECT
									[idEntityUser]		= [EU].[idEntityUser]
									, [FirstName]		= [EU].[FirstName]
									, [Identification]	= [EAC].[Identification]
									, [CountryCode]     = [C].[ISO3166_1_ALFA003]
									, [UserSiteIdentification] = [EA].[UserSiteIdentification] 
									, [CurrencyClient]	= [ECE].[idCurrencyTypeClient]
								FROM
									[LP_Entity].[EntityUser] [EU]
										INNER JOIN [LP_Security].[EntityAccountUser] [EAU] ON [EAU].[idEntityUser] = [EU].[idEntityUser]
										INNER JOIN [LP_Security].[EntityAccount] [EA] ON [EA].[idEntityAccount] = [EAU].[idEntityAccount]
										INNER JOIN [LP_Entity].[EntityCurrencyExchange] [ECE] ON [ECE].[idEntityUser] = [EU].[idEntityUser]
										INNER JOIN [LP_Security].[EntityApiCredential] [EAC] ON [EAC].[idEntityUser] = [EU].[idEntityUser]
										INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [EU].[idCountry]
								WHERE
									[ECE].[Active] = 1
									AND [EU].[Active] = 1
									AND [EA].[Active] = 1
									AND [ECE].[Active] = 1
									AND [EA].[IsAdmin] = 1
									-- AND ([EU].[idEntityUser] = @idEntityUser OR @idEntityUser = 0)
								FOR JSON PATH
							) AS XML
						)
				)

	END
	ELSE -- IF THERES IDENTITY USER VALUE
	BEGIN
		
		SET @JSON	=
				(
					SELECT
						CAST
						( 
							(
								SELECT 
									[idEntityUser]		= [EU].[idEntityUser]
									, [FirstName]		= [EU].[FirstName]
									, [Identification]	= [EAC].[Identification]
									, [CountryCode]     = [C].[ISO3166_1_ALFA003]
									, [UserSiteIdentification] = [EA].[UserSiteIdentification] 
									, [CurrencyClient]	= [ECE].[idCurrencyTypeClient]
								FROM
									[LP_Security].[EntityAccountUser] [EAU]
										INNER JOIN [LP_Entity].[EntityUser] [EU] ON [EAU].[idEntityUser] = [EU].[idEntityUser] 
										INNER JOIN [LP_Security].[EntityAccount] [EA] ON [EA].[idEntityAccount] = [EAU].[idEntityAccount]
										INNER JOIN [LP_Entity].[EntityCurrencyExchange] [ECE] ON [ECE].[idEntityUser] = [EU].[idEntityUser]
										INNER JOIN [LP_Security].[EntityApiCredential] [EAC] ON [EAC].[idEntityUser] = [EU].[idEntityUser]
										INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [EU].[idCountry]
								WHERE
									[ECE].[Active] = 1
									AND [EU].[Active] = 1
									AND [EA].[Active] = 1
									AND [ECE].[Active] = 1
									-- AND [EA].[IsAdmin] = 1
									AND [EAU].[idEntityAccount] = @userIdentification
								FOR JSON PATH
							) AS XML
						)
				)

	END

	SELECT @JSON

END
