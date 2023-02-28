CREATE OR ALTER PROCEDURE [LP_Filter].[ListProviders]
(
														 @transactionType			[LP_Common].[LP_F_VMAX]
)
AS
BEGIN
	SELECT CAST ((SELECT [P].[Code],[P].[Name],[C].[ISO3166_1_ALFA003] AS [CountryCode], [P].[BatchFileTxLimit]
					FROM [LP_Configuration].[Provider] [P]
					INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [P].[idProvider] = [TTP].[idProvider]
					INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [TTP].[idTransactionType]
					INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [P].[idCountry]
					WHERE [TT].[Code] = @transactionType
		FOR JSON PATH) AS XML)
END

















