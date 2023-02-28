GO
/****** Object:  StoredProcedure [LP_Security].[Login]    Script Date: 16/08/2021 19:40:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [LP_Security].[Login]
										(
											@ClientID			[LP_Common].[LP_F_C50],
											@ClientPassword		[LP_Common].[LP_F_C50],
											@App				[LP_Common].[LP_F_BOOL] = 0
										)
AS
BEGIN

--EXEC  [LP_Security].[Login] @App = 1, @ClientID = 'ethan@epay.com', @ClientPassword = 'Pass0017'



--DECLARE 	@ClientID			[LP_Common].[LP_F_C50]
--DECLARE		@ClientPassword		[LP_Common].[LP_F_C50]
--DECLARE		@App				[LP_Common].[LP_F_BOOL] 
--SET @ClientID = '000001500001'
--SET @ClientPassword = 'Pass0002'
--SET @App = 0

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- turn it on

	DECLARE
		@qtyAccount						[LP_Common].[LP_F_INT]
		, @idEntityAccount				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idEntityUser					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idEntityApiCredential		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

		, @idTransactionMechanism		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

		, @Identification				[LP_Common].[LP_F_C100]
		, @SecretKey					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_HASH]
		, @Password						[LP_Common].[LP_F_C16]

		, @Admin						[LP_Common].[LP_F_BOOL]

		, @Message						[LP_Common].[LP_F_C50]
		, @Status						[LP_Common].[LP_F_BOOL]

	SET @qtyAccount =
					(
						SELECT
								IIF(COUNT([EA].[idEntityUser]) >= 2, 1, COUNT([EA].[idEntityUser]) )
						FROM
							[LP_Entity].[EntityUser]							[EU]
								INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[idEntityUser]	= [EU].[idEntityUser]
								INNER JOIN [LP_Security].[EntityApiCredential]	[EAC]	ON [EAC].[idEntityUser]	= [EU].[idEntityUser]
						WHERE
							[EU].[Active] = 1
							AND [EA].[Active] = 1
							AND [EAC].[Active] = 1
							AND ([EA].[UserSiteIdentification] = @ClientID OR ([EAC].[Identification] = @ClientID  AND [EA].[IsAdmin] = 1))
					)

	IF(@qtyAccount = 1)
	BEGIN	

		IF(@App = 1)
		BEGIN
			/* MANUAL - COMUNICACION DESDE LA WEBAPP */

			SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_MANUAL' AND [Active] = 1)

			SELECT
				@idEntityUser				= [EU].[idEntityUser]
				, @idEntityAccount			= [EA].[idEntityAccount]
				, @Identification			= [EA].[UserSiteIdentification]
				, @Password					= [EP].[PasswordSite]
				, @Admin					=
												CASE
													WHEN [ET].[Code] = 'Admin' THEN 1
													ELSE 0
												END
				, @SecretKey				= [EA].[SecretKey]
			FROM
				[LP_Entity].[EntityUser]								[EU]
					INNER JOIN [LP_Security].[EntityAccount]			[EA]	ON [EA].[idEntityUser]		= [EU].[idEntityUser]
					INNER JOIN [LP_Security].[EntityAccountPassword]	[EAP]	ON [EAP].[idEntityAccount]	= [EA].[idEntityAccount]
					INNER JOIN [LP_Security].[EntityPassword]			[EP]	ON [EP].[idEntityPassword]	= [EAP].[idEntityPassword]
					INNER JOIN [LP_Entity].[EntityType]					[ET]	ON [ET].[idEntityType]		= [EU].[idEntityType]
			WHERE
				[EU].[Active] = 1
				AND [EA].[Active] = 1
				AND [EAP].[Active] = 1
				AND [EP].[Active] = 1
				AND [EA].[UserSiteIdentification] = @ClientID AND [EP].[PasswordSite] = @ClientPassword

		END
		ELSE
		BEGIN
			/* AUTOMATICO - COMUNICACION DE TERCEROS DE FORMA AUTOMATICA/INTEGRADA A SUS SISTEMAS */

			SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_AUTO' AND [Active] = 1)

			SELECT
				@idEntityUser				= [EU].[idEntityUser]
				, @idEntityApiCredential	= [EAC].[idEntityApiCredential]
				, @Identification			= [EAC].[Identification]
				, @Password					= [EAC].[ApiKey] 
				, @Admin					=
												CASE
													WHEN [ET].[Code] = 'Admin' THEN 1
													ELSE 0

												END
				, @SecretKey				= [EA].[SecretKey]
			FROM
				[LP_Security].[EntityApiCredential]				[EAC]
					INNER JOIN [LP_Entity].[EntityUser]			[EU]	ON [EU].[idEntityUser]	= [EAC].[idEntityUser]
					INNER JOIN [LP_Security].[EntityAccount]	[EA]	ON [EA].[Identification]= [EAC].[Identification]
					INNER JOIN [LP_Entity].[EntityType]			[ET]	ON [ET].[idEntityType]	= [EU].[idEntityType]
			WHERE
				[EAC].[Active] = 1
				AND [EU].[Active] = 1
				AND [EA].[Active] = 1
				AND [EAC].[Identification] = @ClientID
				AND [EAC].[ApiKey] = @ClientPassword
				AND [EA].[IsAdmin] = 1

		END


		IF(@Password IS NOT NULL)
		BEGIN
			SET @Status = 1
			SET @Message = 'AUTENTICADO'


		END
		ELSE
		BEGIN
			SET @Status = 0
			SET @Message = 'Invalid Username or Password.'
		END

	END
	ELSE IF(@qtyAccount > 1)
	BEGIN
		SET @Status = 0
		SET @Message = 'AUTHENTICATION ERROR - MULTIPLES ACCOUNTS.'
	END
	ELSE
	BEGIN
		SET @Status = 0
		SET @Message = 'AUTHENTICATION ERROR - USERNAME OR PASSWORD NOT FOUND.'
	END

	SELECT [ValidationStatus] = @Status, [ValidationMessage] = @Message

	IF(@Status = 1)
	BEGIN

		SELECT [SecretKey] = @SecretKey, [ClienteID] = @Identification, [Admin] = @Admin

		IF(@App = 1)
		BEGIN
			INSERT INTO [LP_Log].[Login] ([idEntityUser],[idTransactionMechanism], [idEntityAccount] )
			VALUES( @idEntityUser, @idTransactionMechanism, @idEntityAccount )
		END
		ELSE
		BEGIN
			INSERT INTO [LP_Log].[Login] ([idEntityUser],[idTransactionMechanism], [idEntityApiCredential] )
			VALUES( @idEntityUser, @idTransactionMechanism, @idEntityApiCredential )
		END

	END

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- turn it off
	
END

