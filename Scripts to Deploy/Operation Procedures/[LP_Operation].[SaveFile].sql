ALTER PROCEDURE [LP_Operation].[SaveFile]
											(
												@FileBytes			VARBINARY(MAX)
												, @TransactionType	[LP_Common].[LP_F_CODE]
												, @DateTimeProcess	[LP_Common].[LP_F_DESCRIPTION]
												, @OriginalFileName [LP_Common].[LP_F_DESCRIPTION]
												, @FileName			[LP_Common].[LP_F_DESCRIPTION]
												, @FileNameZip		[LP_Common].[LP_F_DESCRIPTION]
												, @FileStatus		[LP_Common].[LP_F_CODE] = NULL
												, @CountryCode		[LP_Common].[LP_F_C3]
												, @ProviderCode		[LP_Common].[LP_F_CODE] = NULL
											)
AS
BEGIN

	DECLARE @idTransactionType [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
	SET @idTransactionType = ( SELECT [idTransactionType] FROM [LP_Configuration].[TransactionType] WHERE [Code] = 'PODEPO' AND [Active] = 1 )

	DECLARE @idCountry [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
	SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @CountryCode AND [Active] = 1)

	DECLARE @idProvider [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

	DECLARE @idFile [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


	SET @FileName = @CountryCode + '_' + @FileName
	SET @OriginalFileName = @CountryCode + '_' + @OriginalFileName
	SET @FileNameZip = @CountryCode + '_' + @FileNameZip

	INSERT INTO [LP_Operation].[Files] ( [FileBytes], [idTransactionType], [DateTimeProcess], [OriginalFileName], [FileName], [FileNameZip] )
	VALUES ( @FileBytes, @idTransactionType, @DateTimeProcess, @OriginalFileName, @FileName, @FileNameZip )

	SELECT @idFile = @@IDENTITY 

	DECLARE @idInternalStatus [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

	IF(@TransactionType = 'PODEPO' AND @CountryCode = 'ARG' AND @ProviderCode = 'BGALICIA' )
	BEGIN

		SET  @TransactionType='BGALICIA'

		SET @idProvider = (SELECT [p].[idProvider] FROM [LP_Configuration].[Provider] [p] WHERE [p].[Code] = @TransactionType)

		SET @idInternalStatus = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, @FileStatus, 'COSF')
	END
	ELSE IF(@TransactionType = 'PODEPO' AND @CountryCode = 'ARG' AND @ProviderCode = 'BSPVIELLE' )
	BEGIN
		SET @TransactionType = 'BSPVIELLE'
		SET @idProvider = (SELECT [p].[idProvider] FROM [LP_Configuration].[Provider] [p] WHERE [p].[Code] = @TransactionType)
		SET @idInternalStatus = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, @FileStatus, 'COSF')
	END

	ELSE IF(@TransactionType = 'PODEPO' AND @CountryCode = 'COL')
	BEGIN
		SET  @TransactionType='BCOLOMBIA'


		SET @idProvider = (SELECT [p].[idProvider] FROM [LP_Configuration].[Provider] [p] WHERE [p].[Code] = @ProviderCode)

		SET @idInternalStatus = (SELECT [idInternalStatus] FROM [LP_Configuration].[InternalStatus] WHERE [idCountry] = @idCountry AND [Code] = 'OK ' AND [idProvider] = @idProvider)
	END	

	ELSE IF(@TransactionType = 'PODEPO' AND @CountryCode = 'BRA')
	BEGIN

		SET @idProvider = (SELECT [p].[idProvider] FROM [LP_Configuration].[Provider] [p] WHERE [p].[Code] = @ProviderCode)

		SET @idInternalStatus = (SELECT [idInternalStatus] FROM [LP_Configuration].[InternalStatus] WHERE [idCountry] = @idCountry AND [Code] = 'OK ' AND [idProvider] = @idProvider)
	END	

	ELSE IF(@TransactionType = 'PODEPO' AND @CountryCode = 'CHL')
	BEGIN

		SET @idProvider = (SELECT [p].[idProvider] FROM [LP_Configuration].[Provider] [p] WHERE [p].[Code] = @ProviderCode)

		SET @idInternalStatus = (SELECT [idInternalStatus] FROM [LP_Configuration].[InternalStatus] WHERE [idCountry] = @idCountry AND [Code] = 'OK ' AND [idProvider] = @idProvider)
	END	

	ELSE IF(@TransactionType IN ('PAFA','RAPA','BAPR','COEX'))
	BEGIN
		--SET  @TransactionType='BCOLOMBIA'
		SET @idProvider = (SELECT [p].[idProvider] FROM [LP_Configuration].[Provider] [p] WHERE [p].[Code] = @TransactionType)
		SET @idInternalStatus = (SELECT [idInternalStatus] FROM [LP_Configuration].[InternalStatus] WHERE [idProvider]= @idProvider AND [idCountry] = @idCountry AND [Code] = 'PAIDFIRST ')
	END	

	INSERT INTO [LP_Operation].[FileInternalStatus] ( [idFile], [idInternalStatus] )
	VALUES(@idFile, @idInternalStatus)

END









