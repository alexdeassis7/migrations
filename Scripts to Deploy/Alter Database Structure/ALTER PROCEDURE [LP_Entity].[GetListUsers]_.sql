/****** Object:  StoredProcedure [LP_Entity].[GetListUsers]    Script Date: 3/19/2020 10:36:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [LP_Entity].[GetListUsers]
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
								EU.LastName
								,EU.FirstName as 'Name'
								,EA.UserSiteIdentification
								,ET.Name as 'TypeUser'
								,EM.Description as 'Merchant' 
								,EA.IsAdmin as 'Admin'
								,EM.EmailsToReport AS 'ReportEmail'
			
							FROM
								[LP_Security].[EntityAccount] AS EA
									LEFT JOIN [LP_Entity].[EntityUser] AS EU ON EU.idEntityUser = EA.idEntityUser				  
									LEFT JOIN [LP_Entity].[EntityMerchant] AS EM ON EU.idEntityMerchant = EM.idEntityMerchant
									LEFT JOIN [LP_Entity].EntityType AS ET ON ET.IdEntityType = EU.IdEntityType
							WHERE
								EU.Active = 1
							
								FOR JSON PATH
							) AS XML
						)
				)

	SELECT @JSON

END


