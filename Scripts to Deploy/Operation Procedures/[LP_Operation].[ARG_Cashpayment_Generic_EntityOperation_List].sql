CREATE OR ALTER PROCEDURE [LP_Operation].[ARG_Cashpayment_Generic_EntityOperation_List]
																			(
																				@Customer				[LP_Common].[LP_F_C12]
																				, @TransactionMechanism	[LP_Common].[LP_F_BOOL] = 0
																				, @country_code			[LP_Common].[LP_F_C3] = 'ARG'
																			)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	DECLARE
		@idTransactionMechanism		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idEntityAccount			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idEntityUser				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @qtyAccount				[LP_Common].[LP_F_INT]

	IF(@TransactionMechanism = 1)
	BEGIN
		SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_MANUAL')

		SELECT
			@idEntityUser		= [EU].[idEntityUser]
			, @idEntityAccount	= [EA].[idEntityAccount]
		FROM
			[LP_Entity].[EntityUser]							[EU]
				INNER JOIN [LP_Security].[EntityAccountUser]	[EAU]	ON [EAU].[idEntityUser] = [EU].[idEntityUser]
				INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[idEntityAccount] = [EAU].[idEntityAccount]
				INNER JOIN [LP_Location].[Country]				[C]		ON [C].[idCountry] = [EU].[idCountry]
		WHERE
			[EU].[Active] = 1
			AND [EAU].[Active] = 1
			AND [EA].[Active] = 1
			AND [C].[Active] = 1
			AND [EA].[UserSiteIdentification] = @customer
			AND [C].[ISO3166_1_ALFA003] = @country_code

		SET @qtyAccount =
						(
							SELECT
								COUNT([EA].[idEntityAccount])
							FROM
								[LP_Security].[EntityAccount] [EA]
									INNER JOIN [LP_Security].[EntityAccountUser] [EAC] ON [EAC].[idEntityAccount] = [EA].[idEntityAccount]
									INNER JOIN [LP_Entity].[EntityUser] [EU] ON [EU].[idEntityUser] = [EAC].[idEntityUser]
									INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [EU].[idCountry]
							WHERE
								[EA].[Active] = 1
								AND [EAC].[Active] = 1
								AND [EU].[Active] = 1
								AND [C].[Active] = 1
								AND [EA].[UserSiteIdentification] = @Customer
								AND [C].[ISO3166_1_ALFA003] = @country_code
						)
	END	
	ELSE
	BEGIN
		SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_AUTO')

		SELECT
			@idEntityUser		= [EU].[idEntityUser]
			, @idEntityAccount	= [EA].[idEntityAccount]
		FROM
			[LP_Entity].[EntityUser]							[EU]
				INNER JOIN [LP_Security].[EntityApiCredential]	[EAC]	ON [EAC].[idEntityUser]	= [EU].[idEntityUser]
				INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[idEntityUser] = [EU].[idEntityUser]
				INNER JOIN [LP_Location].[Country]				[C]		ON [C].[idCountry] = [EAC].[idCountry]
		WHERE
			[EU].[Active] = 1
			AND [EAC].[Active] = 1
			AND [EA].[Active] = 1
			AND [C].[Active] = 1
			AND [EA].[IsAdmin] = 1
			AND [EAC].[Identification] = @customer
			AND [C].[ISO3166_1_ALFA003] = @country_code

		SET @qtyAccount =
						(
							SELECT
								COUNT([EAC].[idEntityApiCredential])
							FROM
								[LP_Security].[EntityApiCredential] [EAC]
									INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [EAC].[idCountry]
							WHERE
								[EAC].[Active] = 1
								AND [C].[Active] = 1
								AND [EAC].[Identification] = @Customer
								AND [C].[ISO3166_1_ALFA003] = @country_code
						)

	END

	DECLARE @DateFrom	DATETIME, @DateTo DATETIME

	SET @DateTo = GETDATE()
	SET @DateFrom = DATEADD(DAY, -10, @DateTo)

	DECLARE @RESP XML
	
	SET @RESP =
				(
					SELECT
						CAST
						(
							(
								SELECT
									[T_TransactionDate]			= [t].[TransactionDate]
									, [EM_Description]			= [em].[Description]
									, [EA_Identification]		= [ea].[Identification]
									, [T_GrossValueLP]			= [t].[GrossValueLP]
									, [IS_Code]					= [is].[Code]
									, [IS_Description]			= [is].[Description]
									, [Transaction_id]			= bct.Ticket
								FROM
									[LP_Operation].[Transaction]								[t]
										INNER JOIN [LP_Operation].[TransactionLot]				[tl]	ON [t].[idTransactionLot]			= [tl].[idTransactionLot]
										INNER JOIN [LP_Catalog].[TransactionTypeProvider]		[ttp]	ON [t].[idTransactionTypeProvider]	= [ttp].[idTransactionTypeProvider]
										INNER JOIN [LP_Configuration].[TransactionType]			[tt]	ON [ttp].[idTransactionType]		= [tt].[idTransactionType]
										INNER JOIN [LP_Entity].[EntityUser]						[eu]	ON [t].[idEntityUser]				= [eu].[idEntityUser]
										INNER JOIN [LP_Security].[EntityAccount]				[ea]	ON [t].[idEntityAccount]			= [ea].[idEntityAccount]
										INNER JOIN [LP_Entity].[EntityMerchant]					[em]	ON [eu].[idEntityMerchant]			= [em].[idEntityMerchant]
										INNER JOIN [LP_Operation].[TransactionDetail]			[td]	ON [t].[idTransaction]				= [td].[idTransaction]
										INNER JOIN [LP_Operation].[BarCodeTicket]				[bct]	ON [t].[idTransaction]				= [bct].[idTransaction]
										INNER JOIN [LP_Common].[Status]							[s]		ON [t].[idStatus]					= [s].[idStatus]
										INNER JOIN [LP_Operation].[TransactionInternalStatus]	[tis]	ON [t].[idTransaction]				= [tis].[idTransaction]
										INNER JOIN [LP_Configuration].[InternalStatus]			[is]	ON [tis].[idInternalStatus]			= [is].[idInternalStatus]
								WHERE
									[tt].[Code] IN('RAPA', 'PAFA', 'BAPR', 'COEX')
									AND [eu].[idEntityUser] = @idEntityUser
								FOR JSON PATH
							) AS XML
						)
				)

	SELECT @RESP
COMMIT
END
