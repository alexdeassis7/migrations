GO
/****** Object:  StoredProcedure [LP_Entity].[GetEntityInfo]    Script Date: 03/07/2021 09:28:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [LP_Entity].[GetEntityInfo] 'danielra@payoneer.com','1'
ALTER PROCEDURE [LP_Entity].[GetEntityInfo]
										(
											@ClientID			[LP_Common].[LP_F_C50],
											@App				[LP_Common].[LP_F_BOOL] = 0
										)
AS
BEGIN
	DECLARE @qtyAccount INT
	DECLARE @Message VARCHAR(50)
	DECLARE @Status BIT


	SET @qtyAccount =
					(
						SELECT
							COUNT([EA].[idEntityUser])
						FROM
							[LP_Entity].[EntityUser]							[EU]
								INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[idEntityUser]	= [EU].[idEntityUser]
								--INNER JOIN [LP_Security].[EntityApiCredential]	[EAC]	ON [EAC].[idEntityUser]	= [EU].[idEntityUser]
						WHERE
							[EU].[Active] = 1
							AND [EA].[Active] = 1
							--AND [EAC].[Active] = 1
							AND [EA].[UserSiteIdentification] = @ClientID
							--AND ([EA].[UserSiteIdentification] = @ClientID OR ([EAC].[Identification] = @ClientID AND [EA].[IsAdmin] = 1))
					)

	IF(@qtyAccount = 1)
	BEGIN	

		SET @Status = 1
		SET @Message = 'OK - INFO DE USUARIO'

		--SELECT
		--	[idEntityUser]				= [EU].[idEntityUser]
		--	, [UserSiteIdentification]	= --[EA].[UserSiteIdentification]
		--								CASE
		--									WHEN [ET].[Code] = 'Merchant' THEN [EA].[UserSiteIdentification] + ', ' + [EM].[Description]
		--									ELSE [EU].[LastName] + ', ' + [EU].[FirstName]
		--								END
		--	, [IsAdmin]					=
		--								CASE
		--									WHEN [ET].[Code] = 'Admin' THEN CAST(1 AS BIT)
		--									ELSE CAST(0 AS BIT)
		--								END
		--	, [Merchant]				= [EM].[Description]
		--FROM
		--	[LP_Entity].[EntityUser]								[EU]
		--		INNER JOIN [LP_Security].[EntityAccount]			[EA]	ON [EA].[idEntityUser]		= [EU].[idEntityUser]
		--		INNER JOIN [LP_Security].[EntityAccountPassword]	[EAP]	ON [EAP].[idEntityAccount]	= [EA].[idEntityAccount]
		--		INNER JOIN [LP_Security].[EntityPassword]			[EP]	ON [EP].[idEntityPassword]	= [EAP].[idEntityPassword]
		--		LEFT JOIN [LP_Entity].[EntityMerchant]				[EM]	ON [EU].[idEntityMerchant]	= [EM].[idEntityMerchant] AND [EM].[Active] = 1
		--		INNER JOIN [LP_Entity].[EntityType]					[ET]	ON [ET].[idEntityType] = [EU].[idEntityType]
		--WHERE
		--	[EU].[Active] = 1
		--	AND [EA].[Active] = 1
		--	AND [EAP].[Active] = 1
		--	AND [EP].[Active] = 1
		--	AND [EA].[UserSiteIdentification] = @ClientID

		SELECT
			[idEntityUser]				= [EU].[idEntityUser]
			, [idEntityAccount]			= [EA].[idEntityAccount]
			, [UserSiteIdentification]	= --[EA].[UserSiteIdentification]
										CASE
											WHEN [ET].[Code] = 'Merchant' THEN [EA].[UserSiteIdentification] + ', ' + [EM].[Description]
											ELSE [EU].[LastName] + ', ' + [EU].[FirstName]
										END
			, [Admin]					=
										CASE
											WHEN [ET].[Code] = 'Admin' THEN CAST(1 AS BIT)
											ELSE CAST(0 AS BIT)
										END
			, [Merchant]				= [EM].[Description]
			, [lCountry]				=
										(
											SELECT
												[idEntityUser] = [EUI].[idEntityUser],
												[idEntityAccount] = [EAUI].[idEntityAccount],
												[Code] = [CI].[ISO3166_1_ALFA003]
												, [Name] = [CI].[Name]
												, [Description] = [CI].[Description]
												, [DescriptionUser] = [EA].[UserSiteIdentification]  + ', ' + [EUI].[FirstName] 
											FROM
												[LP_Security].[EntityAccountUser]			[EAUI]
													INNER JOIN [LP_Entity].[EntityUser]		[EUI]	ON [EUI].[idEntityUser] = [EAUI].[idEntityUser]
													INNER JOIN [LP_Location].[Country]		[CI]	ON [CI].[idCountry] = [EUI].[idCountry]
											WHERE
												[EAUI].[idEntityAccount] = [EA].[idEntityAccount]
											FOR JSON PATH
										)
		FROM
			[LP_Entity].[EntityUser]								[EU]
				INNER JOIN [LP_Security].[EntityAccount]			[EA]	ON [EA].[idEntityUser]		= [EU].[idEntityUser]
				INNER JOIN [LP_Security].[EntityAccountPassword]	[EAP]	ON [EAP].[idEntityAccount]	= [EA].[idEntityAccount]
				INNER JOIN [LP_Security].[EntityPassword]			[EP]	ON [EP].[idEntityPassword]	= [EAP].[idEntityPassword]
				LEFT JOIN [LP_Entity].[EntityMerchant]				[EM]	ON [EU].[idEntityMerchant]	= [EM].[idEntityMerchant] AND [EM].[Active] = 1
				INNER JOIN [LP_Entity].[EntityType]					[ET]	ON [ET].[idEntityType] = [EU].[idEntityType]
		WHERE
			[EU].[Active] = 1
			AND [EA].[Active] = 1
			AND [EAP].[Active] = 1
			AND [EP].[Active] = 1
			AND [EA].[UserSiteIdentification] = @ClientID--'danielra@payoneer.com'
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	END
	ELSE IF(@qtyAccount > 1)
	BEGIN
		SET @Status = 0
		SET @Message = 'NO SE PUEDE RETORNAR INFO DE USUARIO - MULTIPLES ACCOUNTS.'
	END
	ELSE
	BEGIN
		SET @Status = 0
		SET @Message = 'NO SE PUEDE RETORNAR INFO DE USUARIO - NO SE ENCONTRO EL USUARIO.'
	END

	SELECT [ValidationStatus] = @Status, [ValidationMessage] = @Message	

END

--EXEC [LP_Entity].[GetEntityInfo] 'danielra@payoneer.com', @App = 1
