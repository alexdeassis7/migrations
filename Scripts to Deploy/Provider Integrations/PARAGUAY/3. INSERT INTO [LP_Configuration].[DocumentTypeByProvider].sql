			DECLARE @idCountry	INT
			SET @idCountry = (SELECT TOP(1) [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'PYG' AND [Active] = 1  ORDER BY idCountry)

			DECLARE @idProvider	INT
			SET @idProvider = ( SELECT TOP(1) [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'ITAUPYG' AND [idCountry] = @idCountry AND [Active] = 1  ORDER BY idProvider)

INSERT INTO [LP_Configuration].[DocumentTypeByProvider] VALUES (@idProvider, (Select idEntityIdentificationType from [LP_Entity].[EntityIdentificationType] Where Code = 'CI' AND idCountry = @idCountry), '1', GETUTCDATE())
INSERT INTO [LP_Configuration].[DocumentTypeByProvider] VALUES (@idProvider, (Select idEntityIdentificationType from [LP_Entity].[EntityIdentificationType] Where Code = 'RUC' AND idCountry = @idCountry), '5', GETUTCDATE())

