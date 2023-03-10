ALTER PROCEDURE [LP_Log].[ListTransactionsError] (
														@Customer				[LP_Common].[LP_F_C50]
														,@JSON					NVARCHAR(MAX)

											)
AS	
BEGIN 


	DECLARE @jsonResult			XML

			, @dateFrom				[LP_Common].[LP_F_C8]
			, @dateTo				[LP_Common].[LP_F_C8]
			, @idEntityUser			[LP_Common].[LP_F_INT]
			, @transactionType		[LP_Common].[LP_F_CODE]
			, @amount				[LP_Common].[LP_F_C50]
			, @merchantId			[LP_Common].[LP_F_C50]
			, @pageSize				[LP_Common].[LP_F_INT]
			, @offset				[LP_Common].[LP_F_INT]
			, @idEntityAccount		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]	
			, @idEntitySubmerchant  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]	
			, @idEntityUserLogued	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @idField				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @idErrorType			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @qtyAccount			[LP_Common].[LP_F_INT]
			, @Message				[LP_Common].[LP_F_C50]
			, @Status				[LP_Common].[LP_F_BOOL]
SELECT
		@qtyAccount = COUNT([idEntityAccount])
		, @idEntityAccount = MAX([idEntityAccount])
	FROM
		[LP_Security].[EntityAccount]
	WHERE
		[UserSiteIdentification] = @Customer
		AND [Active] = 1


	IF(@qtyAccount = 1)
	BEGIN	



		SELECT

			  @dateFrom				=	CAST(JSON_VALUE(@JSON, '$.dateFrom') AS VARCHAR(8))
			, @dateTo				=	CAST(JSON_VALUE(@JSON, '$.dateTo') AS VARCHAR(8))			
			, @idEntityUser 		=	CAST(JSON_VALUE(@JSON, '$.idEntityUser') AS INT)	
			, @idEntitySubmerchant  =   CAST(JSON_VALUE(@JSON, '$.idEntitySubMerchant') AS INT)	 
			, @transactionType		=	CAST(JSON_VALUE(@JSON, '$.transactionType') AS VARCHAR(20))	
			, @amount				=	CAST(JSON_VALUE(@JSON, '$.amount') AS  VARCHAR(50))	
			, @merchantId			=	CAST(JSON_VALUE(@JSON, '$.merchantId') AS VARCHAR(50))	
			,@idField		=	CAST(JSON_VALUE(@JSON, '$.idField') AS INT)	
			,@idErrorType=	CAST(JSON_VALUE(@JSON, '$.idErrorType') AS INT)	
			, @pageSize				=	CAST(JSON_VALUE(@JSON, '$.pageSize') AS INT)
			, @offset				=	CAST(JSON_VALUE(@JSON, '$.offset') AS INT)

			/******************************PARTE NUEVA*******************************************/

	--			DECLARE  @idField				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
	--		, @idErrorType			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
	--SET @idField = 8
	--SET @idErrorType = 2
		DECLARE		@RejectedTxs TABLE (

							idRejectedTxs  [LP_Common].[LP_F_INT]   NOT NULL
				)

				INSERT INTO @RejectedTxs (idRejectedTxs)

	SELECT  DISTINCT

					[RTFE].[idRejectedTxs]

	FROM

	[LP_Log].[RejectedTxsFieldsErrorTypes] [RTFE]
	INNER JOIN [LP_Log].[FieldErrorType]  [FET] ON [FET].[idFieldErrorType] = [RTFE].[idFieldErrorType] 
	WHERE

			(([FET].[idField] =  @idField )  OR (@idField is  null) ) AND (([FET].[idErrorType] = @idErrorType) OR (@idErrorType is null)	)



			SET @jsonResult =
						(
							SELECT
								CAST

								(
									(

										SELECT 
												[ProcessDate]		=	[RT].[OP_InsDateTime],												
												[TransactionType]	=	[TT].[Name],
												[PaymentDate]		=   [RT].[paymentDate],
												[Merchant]		=  		[EU].[FirstName],
												[MerchantId]		=	[RT].[merchantId],
												[SubMerchant]		=	[RT].[submerchantCode],
												[BeneficiaryName]	=	[RT].[beneficiaryName],
												[Country]           =	[RT].[beneficiaryCountry],
												[City]				=	[RT].[beneficiaryCity],
												[Address]			=	[RT].[beneficiaryAddress],
												[Email]				=	[RT].[beneficiaryEmail],
												[Birthdate]			=	[RT].[beneficiaryBirthdate],
												[BeneficiaryID]		=	[RT].[beneficiaryId],
												[CBU]				=	[RT].[cbu],
												[Amount]			=	[RT].[amount],
												[ListErrors]		=	(
																			SELECT 
																					[Key]			= [F].[Name],
																					[Message]      = [FET].[Description]
																			FROM [LP_Log].[RejectedTxsFieldsErrorTypes] [RTET]
																					INNER JOIN [LP_Log].[FieldErrorType] [FET]	ON [FET].[idFieldErrorType]	= [RTET].[idFieldErrorType] 
																					INNER JOIN [LP_Log].[Field] [F]				ON [F].[idField]	= [FET].[idField]
																					INNER JOIN [LP_Log].[ErrorType] [ET]		ON [ET].[idErrorType] = [FET].[idErrorType]
																			WHERE [RTET].[idRejectedTxs] = [RT].[idRejectedTxs]
																			FOR JSON PATH

																			)

										FROM [LP_Log].[RejectedTxs] [RT]
										LEFT JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [RT].[idTransactionType]
										LEFT JOIN [LP_Entity].[EntityUser] [EU]  ON [EU].[idEntityUser] = [RT].[idEntityUser]
										LEFT JOIN [LP_Entity].[EntitySubMerchant] [ESM] ON [ESM].[SubMerchantIdentification] = [RT].[submerchantCode] AND [ESM].[idEntityUser] = @idEntityUser
										INNER JOIN @RejectedTxs [RTF] ON [RT].[idRejectedTxs] = [RTF].[idRejectedTxs] 
										--INNER JOIN [LP_Log].[Field] [F]				ON [F].[idField]	= @idField
										--INNER JOIN [LP_Log].[ErrorType] [ET]		ON [ET].[idErrorType] = @idErrorType
										--INNER JOIN [LP_Log].[FieldErrorType] [FET]	ON [FET].[idField]	= @idField AND [FET].[idErrorType] = @idErrorType
										--INNER JOIN [LP_Log].[RejectedTxsFieldsErrorTypes] [RTFE] ON [RTFE].[idRejectedTxs] = [RT].[idRejectedTxs]
										WHERE 
										 ( (( [RT].[OP_InsDateTime] >= @dateFrom ) OR ( @dateFrom  IS NULL ) ) AND ( ( [RT].[OP_InsDateTime]<= DATEADD(DAY,1,@dateTo)) OR ( @dateTo IS NULL ) ))
										AND	(
											( [EU].[idEntityUser] = @idEntityUser ) OR ( @idEntityUser IS NULL ) 
											)	
										AND (
											( [RT].[amount] = @amount ) OR ( @amount IS NULL ) 
											)
										AND (
											([RT].[merchantId] = @merchantId) OR (@merchantId IS NULL)
											)
										AND (
											([ESM].[idEntitySubMerchant] = @idEntitySubmerchant) OR (@idEntitySubmerchant IS NULL)
											)
										AND (
											( [TT].[Code] = @transactionType ) OR ( @transactionType IS NULL )
											)

 										ORDER BY
											[RT].[OP_InsDateTime] DESC 
										OFFSET ISNULL(@offset, 0) ROWS  
										FETCH NEXT ISNULL(@pageSize, 100) ROWS ONLY
										FOR JSON PATH
									) AS XML
								)
						)

						SELECT @jsonResult

						--DECLARE @lenJson int
						
						--SELECT @lenJson= DATALENGTH(@jsonResult)
						
						--IF @lenJson >= 2097151
						--BEGIN
						
						--	SET @Status = 0
						--	SET @Message = 'JSON SIZE. REDUCE THE SEARCH  RANGE'
	
						--END
						--ELSE
						--BEGIN

						--	SELECT @jsonResult
						
						--END

						

	END
	ELSE
	BEGIN
		SET @Status = 0
		SET @Message = 'CLIENTE INEXISTENTE. VERFIQUE SU CUSTOMER_ID'
	END
END

  --EXEC [LP_Log].[ListTransactionsError] 'ADMIN@LOCALPAYMENT.COM', '{"dateFrom":"20191218","dateTo":"20191219","idEntityUser":null,"transactionType":null,"amount":null,"idEntitySubmerchant":null,"merchantId":null,"idField":8,"idErrorType":null,"pageSize":20,"offset":0}'
--EXEC [LP_Log].[ListTransactionsError]  'ADMIN@LOCALPAYMENT.COM','{"dateFrom":"20191114","dateTo":"20191128","idEntityUser":null,"idTransactionType":null,"amount":"35000","merchantId":null,"pageSize":"20","offset":"0"}','ARG'
