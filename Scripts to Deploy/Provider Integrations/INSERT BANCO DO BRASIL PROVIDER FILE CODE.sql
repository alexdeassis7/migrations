begin tran
-- TRANSACTION TYPE PROVIDER
DECLARE @idCountry	AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = 'BRA' AND [Active] = 1 )
SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BDOBR' AND [idCountry] = @idCountry AND [Active] = 1 )

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE Code = 'SCM' AND idCountry = @idCountry)

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibió exitosamente', 'El archivo se recibió exitosamente', @idInternalStatusType, 0, 0)

ROLLBACK