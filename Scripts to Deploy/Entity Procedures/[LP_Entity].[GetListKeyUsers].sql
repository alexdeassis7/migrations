CREATE OR ALTER PROCEDURE [LP_Entity].[GetListKeyUsers]
AS
BEGIN
	DECLARE @JSON XML

	SET @JSON	=
				(
					SELECT
						CAST
						(
							(
							
									SELECT 
										EA.Identification as Admin
										,EA.UserSiteIdentification
										,HMACKey AS 'Key'
									FROM
										[LP_Security].[EntityAccount] AS EA
										LEFT JOIN [LP_Entity].[EntityUser] AS EU ON EU.idEntityUser = EA.idEntityUser			  
										LEFT JOIN [LP_Entity].EntityType AS ET ON ET.IdEntityType = EU.IdEntityType
										LEFT JOIN [LP_Location].[Country] C ON C.idCountry = EU.idCountry
									WHERE ET.Code != 'Admin'
									order by EU.idEntityType,Ea.Identification
								FOR JSON PATH
							) AS XML
						)
				)

	SELECT @JSON

END


