BEGIN TRAN

DECLARE @idCountry			    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idProvider             [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idInternalStatusType   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountry      = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'BRA');
SET @idProvider  = (SELECT idProvider FROM [LP_Configuration].[Provider] WHERE idCountry = @idCountry and Code = 'SANTBR');
SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE idCountry = @idCountry AND Code = 'SCM');

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibió exitosamente', 'El archivo se recibió exitosamente', @idInternalStatusType, 0, 0)

COMMIT TRAN