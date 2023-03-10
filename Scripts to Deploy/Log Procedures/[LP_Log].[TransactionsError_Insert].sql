CREATE OR ALTER PROCEDURE [LP_Log].[TransactionsError_Insert] (
														@Customer				[LP_Common].[LP_F_C50]
														,@JSON					NVARCHAR(MAX)
														,@country_code			[LP_Common].[LP_F_C3]
														,@TransactionMechanism 	[LP_Common].[LP_F_BOOL]
													)
										
AS
BEGIN

	DECLARE
				@TransactionDate				DATETIME
				, @idEntityAccount				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idEntityUser					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @qtyAccount					[LP_Common].[LP_F_INT]

					IF(@TransactionMechanism = 1)
			BEGIN
			

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
					AND [EA].[UserSiteIdentification] = @Customer
					AND [C].[ISO3166_1_ALFA003] = @country_code

			END	
			ELSE
			BEGIN
				

				SELECT
					@idEntityUser		= [EU].[idEntityUser]
					, @idEntityAccount	= [EA].[idEntityAccount]
				FROM
					[LP_Entity].[EntityUser]							[EU]
						INNER JOIN [LP_Security].[EntityApiCredential]	[EAC]	ON [EAC].[idEntityUser]	= [EU].[idEntityUser]
						INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[Identification] = [EAC].[Identification]
						INNER JOIN [LP_Location].[Country]				[C]		ON [C].[idCountry] = [EAC].[idCountry]
				WHERE
					[EU].[Active] = 1
					AND [EAC].[Active] = 1
					AND [EA].[Active] = 1
					AND [C].[Active] = 1
					AND [EA].[IsAdmin] = 1
					AND [EAC].[Identification] = @Customer
					AND [C].[ISO3166_1_ALFA003] = @country_code

			END
	
			/*******************************************************************************/
			   DECLARE
                    @idTx BIGINT,
					@idField BIGINT,
					@idErrorType BIGINT,
					@idCurrentRejectedTxs BIGINT,
					@JSON_ERROR VARCHAR(MAX)
			CREATE TABLE #TxsErrors
					(						
					[idTxError]					INT IDENTITY(1,1)
					,[idTransactionType]				BIGINT					
					,[beneficiaryName]				VARCHAR(150)
					,[typeOfId]						VARCHAR(150)
					,[beneficiaryId]				VARCHAR(150)
					,[cbu]							VARCHAR(150)
					,[bankCode]						VARCHAR(150)
					,[accountType]					VARCHAR(150)
					,[accountNumber]				VARCHAR(150)
					,[amount]						VARCHAR(150)
					,[paymentDate]					VARCHAR(150)
					,[submerchantCode]				VARCHAR(150)
					,[currency]						VARCHAR(150)
					,[merchantId]					VARCHAR(150)
					,[beneficiaryAddress]			VARCHAR(150)
					,[beneficiaryCity]				VARCHAR(150)
					,[beneficiaryCountry]			VARCHAR(150)
					,[beneficiaryEmail]				VARCHAR(150)
					,[beneficiaryBirthdate]			VARCHAR(150)
					,[senderName]					VARCHAR(150)
					,[senderAddress]				VARCHAR(150)
					,[senderCountry]				VARCHAR(150)
					,[senderState]					VARCHAR(150)
					,[senderTaxid]					VARCHAR(150)
					,[senderBirthDate]				VARCHAR(150)
					,[senderEmail]					VARCHAR(150)
					,[errors]						VARCHAR(MAX)

					)
	
				INSERT INTO #TxsErrors 

				 SELECT 
					[idTransactionType]					
					,[beneficiaryName]
					,[typeOfId]
					,[beneficiaryId]
					,[cbu]
					,[bankCode]
					,[accountType]
					,[accountNumber]
					,[amount]
					,[paymentDate]
					,[submerchantCode]
					,[currency]
					,[merchantId]
					,[beneficiaryAddress]
					,[beneficiaryCity]
					,[beneficiaryCountry]
					,[beneficiaryEmail]
					,[beneficiaryBirthdate]
					,[senderName]		
					,[senderAddress]	
					,[senderCountry]	
					,[senderState]		
					,[senderTaxid]		
					,[senderBirthDate]	
					,[senderEmail]		
					,[errors]	
				 FROM OPENJSON(@JSON)
				 
				 WITH
				(		
	
									
					[idTransactionType]				BIGINT						'$.idTransactionType'				
					,[beneficiaryName]				[LP_Common].[LP_F_C150]		'$.beneficiaryName'
					,[typeOfId]						[LP_Common].[LP_F_C150]		'$.typeOfId'
					,[beneficiaryId]				[LP_Common].[LP_F_C150]		'$.beneficiaryId'
					,[cbu]							[LP_Common].[LP_F_C150]		'$.cbu'
					,[bankCode]						[LP_Common].[LP_F_C150]		'$.bankCode'
					,[accountType]					[LP_Common].[LP_F_C150]		'$.accountType'
					,[accountNumber]				[LP_Common].[LP_F_C150]		'$.accountNumber'
					,[amount]						[LP_Common].[LP_F_C150]		'$.amount'
					,[paymentDate]					[LP_Common].[LP_F_C150]		'$.paymentDate'
					,[submerchantCode]				[LP_Common].[LP_F_C150]		'$.submerchantCode'
					,[currency]						[LP_Common].[LP_F_C150]		'$.currency'
					,[merchantId]					[LP_Common].[LP_F_C150]		'$.merchantId'
					,[beneficiaryAddress]			[LP_Common].[LP_F_C150]		'$.beneficiaryAddress'
					,[beneficiaryCity]				[LP_Common].[LP_F_C150]		'$.beneficiaryCity'
					,[beneficiaryCountry]			[LP_Common].[LP_F_C150]		'$.beneficiaryCountry'
					,[beneficiaryEmail]				[LP_Common].[LP_F_C150]		'$.beneficiaryEmail'
					,[beneficiaryBirthdate]			[LP_Common].[LP_F_C150]		'$.beneficiaryBirthdate'
					,[senderName]					[LP_Common].[LP_F_C150]		'$.beneficiarySenderName'
					,[senderAddress]				[LP_Common].[LP_F_C150]		'$.beneficiarySenderAddress'
					,[senderCountry]				[LP_Common].[LP_F_C150]		'$.beneficiarySenderState'
					,[senderState]					[LP_Common].[LP_F_C150]		'$.beneficiarySenderCountry'
					,[senderTaxid]					[LP_Common].[LP_F_C150]		'$.beneficiarySenderTaxid'
					,[senderBirthDate]				[LP_Common].[LP_F_C150]		'$.beneficiarySenderBirthDate'
					,[senderEmail]					[LP_Common].[LP_F_C150]		'$.beneficiarySenderEmail'
					,[errors]						[LP_Common].[LP_F_VMAX]		'$.errors'		
			
			)	
	
			
			WHILE EXISTS(SELECT * FROM #TxsErrors)
			BEGIN 

			SELECT TOP 1 @idTx = 	[idTxError]	, @JSON_ERROR = [errors] FROM #TxsErrors
		
			INSERT INTO [LP_Log].[RejectedTxs](

					[idTransactionType]
					,[idEntityUser]
					,[beneficiaryName]
					,[typeOfId]
					,[beneficiaryId]
					,[cbu]
					,[bankCode]
					,[accountType]
					,[accountNumber]
					,[amount]
					,[paymentDate]
					,[submerchantCode]
					,[currency]
					,[merchantId]
					,[beneficiaryAddress]
					,[beneficiaryCity]
					,[beneficiaryCountry]
					,[beneficiaryEmail]
					,[beneficiaryBirthdate]
					,[senderName]		
					,[senderAddress]	
					,[senderCountry]	
					,[senderState]		
					,[senderTaxid]		
					,[senderBirthDate]	
					,[senderEmail]
						
				 )		

			SELECT TOP 1 
						[idTransactionType]	,
						@idEntityUser		,
						[beneficiaryName]	,					
						[typeOfId]			,	
						[beneficiaryId]		,
						[cbu]				,	
						[bankCode]			,	
						[accountType]		,	
						[accountNumber]		,
						LP_COMMON.fnConvertIntToDecimalAmount([amount]),
						[paymentDate]		,	
						[submerchantCode]	,	
						[currency]			,	
						[merchantId]		,	
						[beneficiaryAddress],	
						[beneficiaryCity]	,	
						[beneficiaryCountry],	
						[beneficiaryEmail]	,
						[beneficiaryBirthdate]
						,[senderName]		
						,[senderAddress]	
						,[senderCountry]	
						,[senderState]		
						,[senderTaxid]		
						,[senderBirthDate]	
						,[senderEmail]		
			FROM #TxsErrors
				
			SET @idCurrentRejectedTxs = @@IDENTITY

	
			INSERT INTO [LP_Log].[RejectedTxsFieldsErrorTypes] (idRejectedTxs,idFieldErrorType)
			SELECT 
					@idCurrentRejectedTxs,
					[FET].[idFieldErrortype]
			
			FROM OPENJSON(@JSON_ERROR) 
				 
				 WITH
					(			
									
					[Key]			VARCHAR(50)		'$.Key',				
					[Code]			VARCHAR(50)		'$.Code'
		
					)	AS [ER]
					INNER JOIN [LP_Log].[Field] [F]				ON [F].[Name]		= [ER].[Key]
					INNER JOIN [LP_Log].[ErrorType] [ET]		ON [ET].[errorType] = [ER].[Code]
					INNER JOIN [LP_Log].[FieldErrorType] [FET]	ON [FET].[idField]	= [F].[idField] AND [FET].[idErrorType] = [ET].[idErrorType]

			DELETE FROM #TxsErrors WHERE [idTxError] = @idTx
 
			END				
	
END
