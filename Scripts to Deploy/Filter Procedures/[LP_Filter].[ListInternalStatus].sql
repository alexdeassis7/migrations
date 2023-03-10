CREATE OR ALTER PROCEDURE [LP_Filter].[ListInternalStatus]
AS
BEGIN
	SELECT CAST ((	SELECT  [IE].[Code],[IE].[Description] as [Name], [C].[ISO3166_1_ALFA003] AS [CountryCode] ,[P].[Code] AS [ProviderCode], [IS].[isError]
						FROM [LP_Configuration].[InternalStatus] [IS]
						INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [IS].[idCountry]
						INNER JOIN [LP_Configuration].[Provider] [P] ON [P].[idProvider] = [IS].[idProvider]
						INNER JOIN [LP_Configuration].[LPInternalStatusClient] [ISC] ON [ISC].[idInternalStatus] = [IS].[idInternalStatus]
						INNER JOIN [LP_Configuration].[LPInternalError] [IE] ON [ISC].[idLPInternalError] = [IE].[idLPInternalError]
						WHERE FinalStatus = 1 AND [IS].[Active] = 1 AND isError = 1
						GROUP BY [IE].[Code], [C].[ISO3166_1_ALFA003],[P].[Code],[IS].[isError], [IE].[Description]
		FOR JSON PATH) AS XML)
END

















