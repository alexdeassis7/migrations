CREATE OR ALTER  PROCEDURE [LP_Log].[PayinError_Insert] (
														@Customer				[LP_Common].[LP_F_C50]
														,@JSON					NVARCHAR(MAX)
														,@country_code			[LP_Common].[LP_F_C3]
													)
										
AS
BEGIN

	DECLARE
				@TransactionDate				DATETIME
				, @idEntityAccount				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idEntityUser					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @qtyAccount					[LP_Common].[LP_F_INT]


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

	
			/*******************************************************************************/
			   DECLARE
                    @idTx BIGINT,
					@idField BIGINT,
					@idErrorType BIGINT,
					@idCurrentRejectedTxs BIGINT,
					@JSON_ERROR VARCHAR(MAX)
			CREATE TABLE #TxsErrors
					(						
						[idTxError]					INT IDENTITY(1,1),
						[idEntityUser] bigint NOT NULL,
						[amount] VARCHAR(150) NULL,
						[currency] VARCHAR(150) NULL,
						[paymentMethodCode] VARCHAR(150) NULL,
						[merchantId] VARCHAR(150) NULL,
						[payerName] VARCHAR(150) NULL,
						[payerDocument] VARCHAR(150) NULL,
						[payerAccountNumber] VARCHAR(150) NULL,
						[submerchantCode] VARCHAR(150) NULL,
						[errors]						VARCHAR(MAX)

					)
	
				INSERT INTO #TxsErrors 

				 SELECT 				
					@idEntityUser
					,[amount]
					,[currency]
					,[paymentMethodCode]
					,[merchantId]
					,[payerName]
					,[payerDocument]
					,[payerAccountNumber]
					,[submerchantCode]
					,[errors]
				 FROM OPENJSON(@JSON)
				 
				 WITH
				(		
	
					[amount] [LP_Common].[LP_F_C150]							'$.amount'
					,[currency] [LP_Common].[LP_F_C150]							'$.currency'
					,[paymentMethodCode] [LP_Common].[LP_F_C150]				'$.payment_method_code'
					,[merchantId] [LP_Common].[LP_F_C150]						'$.merchant_id'
					,[payerName] [LP_Common].[LP_F_C150]						'$.payer_name'
					,[payerDocument] [LP_Common].[LP_F_C150]					'$.payer_document_number'
					,[payerAccountNumber] [LP_Common].[LP_F_C150]				'$.payer_account_number'
					,[submerchantCode] [LP_Common].[LP_F_C150]					'$.submerchant_code'
					,[errors]						[LP_Common].[LP_F_VMAX]		'$.errors'		
			
			)	
	
			
			WHILE EXISTS(SELECT * FROM #TxsErrors)
			BEGIN 

			SELECT TOP 1 @idTx = 	[idTxError]	, @JSON_ERROR = [errors] FROM #TxsErrors
		
			INSERT INTO [LP_Log].[RejectedPayins](
					[idEntityUser]
					,[amount]
					,[currency]
					,[paymentMethodCode]
					,[merchantId]
					,[payerName]
					,[payerDocument]
					,[payerAccountNumber]
					,[submerchantCode]
					,[errors]
				 )		

			SELECT TOP 1 
					[idEntityUser]
					,[amount]
					,[currency]
					,[paymentMethodCode]
					,[merchantId]
					,[payerName]
					,[payerDocument]
					,[payerAccountNumber]
					,[submerchantCode]
					,[errors]	
			FROM #TxsErrors
				
			SET @idCurrentRejectedTxs = @@IDENTITY

			DELETE FROM #TxsErrors WHERE [idTxError] = @idTx
 
			END				
END
