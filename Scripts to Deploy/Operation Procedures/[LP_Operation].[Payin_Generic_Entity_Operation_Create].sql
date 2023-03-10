CREATE OR ALTER  PROCEDURE [LP_Operation].[Payin_Generic_Entity_Operation_Create] (
																					@customer [LP_Common].[LP_F_C50],
																					@JSON		NVARCHAR(MAX), 
																					@country_code			[LP_Common].[LP_F_C3],
																					@expire_days		INT
																				)
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	BEGIN TRY

		DECLARE
			@TransactionDate				DATETIME
			, @idEntityAccount				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @idEntityUser					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @idCountry					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @idStatus						[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @idTransactionType			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @idTransactionTypeProvider	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @idTransactionMechanism		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] = 1
			, @idProvider					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]	
			, @idProviderPayWayService		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @ProviderCode					[LP_Common].[LP_F_CODE]
			, @qtyAccount					[LP_Common].[LP_F_INT]
			, @Message						[LP_Common].[LP_F_CODE]
			, @Status						[LP_Common].[LP_F_BOOL]
			, @LoteNum						[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @SUM_VALUE_LOT				[LP_Common].[LP_F_DECIMAL]
			, @CurrencyTypeLP				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @CurrencyTypeClient			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @LastValueCurrencyExchangeLP	[LP_Common].[LP_F_DECIMAL]
			, @jsonResult					XML
			, @ListID						[LP_Common].[LP_T_ID]
			, @qtyTxs						[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @idxTx						[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, @LastValueCurrencyExchangeLPId [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


		SET @ProviderCode = JSON_VALUE(@JSON, '$.payment_method_code')


		DECLARE @referenciasID [LP_Operation].[Referencias_Id];

		DECLARE @tCurrencyExchange TABLE
		(
			[idCurrencyExchange]	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, [CurrencyBase]		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, [CurrencyTo]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, [Value]				[LP_Common].[LP_F_DECIMAL]
			, [idCountry]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		)

		DECLARE @tCurrencyBase TABLE
		(
			[idCurrencyBase]		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, [idCurrencyType]		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, [idCountry]			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, [idEntityUser]		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
			, [Base_Buy]			[LP_Common].[LP_F_DECIMAL]
		)

		SET @TransactionDate = GETDATE()

		SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('InProgress')



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

		--SET @qtyAccount = ( SELECT COUNT([idEntityApiCredential]) FROM [LP_Security].[EntityApiCredential] WHERE [Identification] = @Customer AND [Active] = 1 )

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


		SET @idCountry = (SELECT idCountry FROM [LP_Entity].[EntityUser] WHERE idEntityUser = @idEntityUser)

		SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = @ProviderCode AND [idCountry] = @idCountry AND [Active] = 1) 

		SET @idTransactionType =
								(
									SELECT
										[tt].[idTransactionType]
									FROM
										[LP_Configuration].[TransactionType] [tt]
									WHERE
										[tt].[Code] = 'PAYIN'
										AND [tt].[Active] = 1
								)

		SELECT
			@idTransactionTypeProvider	= [ttp].[idTransactionTypeProvider]
		FROM
			[LP_Catalog].[TransactionTypeProvider] [ttp]
		WHERE
			[ttp].[idTransactionType] = @idTransactionType
			AND [ttp].[idCountry] = @idCountry
			AND [ttp].[TT_Active] = 1
			AND [ttp].[PROV_Active] = 1
			AND [ttp].[COUNTRY_Active] = 1
			AND [ttp].[TTP_Active] = 1
			AND [ttp].[PROV_Code] = @ProviderCode

		SET @idProviderPayWayService =
										(
											SELECT
												[ppws].[idProviderPayWayService]
											FROM
												[LP_Catalog].[ProviderPayWayServices] [ppws]
											WHERE
												[ppws].[PROV_Code] = @ProviderCode
												AND [ppws].[PWS_Code] = 'PAYINBTRA'
												AND [ppws].[idCountry] = @idCountry
												AND [ppws].[PWS_Active] = 1
												AND [ppws].[PROV_Active] = 1
												AND [ppws].[COUNTRY_Active] = 1
												AND [ppws].[PPWS_Active] = 1
										)

		SELECT
			@CurrencyTypeLP			= [ece].[idCurrencyTypeLP]
			, @CurrencyTypeClient	= [ece].[idCurrencyTypeClient]
		FROM
			[LP_Entity].[EntityCurrencyExchange] [ece]
		WHERE
			[ece].[Active] = 1
			AND [ece].[idEntityUser] = @idEntityUser


		CREATE TABLE #LotTrans
		(
			[idTransIntTemp]				BIGINT IDENTITY(1,1)
			, [value]						VARCHAR(100)
			, [TransactionDate]				VARCHAR(100)
			, [Description]					VARCHAR(100)
			, [InternalDescription]			VARCHAR(100)
			, [ConceptCode]					VARCHAR(100)
			, [BankAccountType]				VARCHAR(100)
			, [EntityIdentificationType]	VARCHAR(100)
			, [CurrencyType]				VARCHAR(100)
			, [PayerName]					VARCHAR(100)
			, [PayerDocumentNumber]			VARCHAR(100)
			, [PayerAccountNumber]			VARCHAR(100)
			, [StatusObservation]			VARCHAR(100)
			, [SubMerchant]					VARCHAR(60)
			, [PayerPhoneNumber]			VARCHAR(100)
			, [PayerEmail]					VARCHAR(100)
		)


		INSERT INTO #LotTrans ([value], [TransactionDate], [Description], [InternalDescription], [ConceptCode], [BankAccountType], 
					[EntityIdentificationType], [CurrencyType], [PayerName], [PayerDocumentNumber], 
					[PayerAccountNumber], [SubMerchant],[PayerPhoneNumber],[PayerEmail])
		VALUES(
			JSON_VALUE(@JSON, '$.amount'),
			GETDATE(),
			'',
			JSON_VALUE(@JSON, '$.merchant_id'),
			'',
			'',
			'',
			JSON_VALUE(@JSON, '$.currency'),
			JSON_VALUE(@JSON, '$.payer_name'),
			JSON_VALUE(@JSON, '$.payer_document_number'),
			JSON_VALUE(@JSON, '$.payer_account_number'),
			ISNULL(JSON_VALUE(@JSON, '$.submerchant_code'), ''),
			JSON_VALUE(@JSON, '$.payer_phone_number'),
			JSON_VALUE(@JSON, '$.payer_email')
		)


		INSERT INTO @tCurrencyExchange ([idCurrencyExchange], [CurrencyBase], [CurrencyTo], [Value], [idCountry])
		SELECT [idCurrencyExchange], [CurrencyBase], [CurrencyTo], [Value], [idCountry] FROM [LP_Configuration].[CurrencyExchange] WHERE [Active] = 1  AND [ActionType] = 'A'

		INSERT INTO @tCurrencyBase ([idCurrencyBase], [idCurrencyType], [idCountry], [idEntityUser], [Base_Buy])
		SELECT [idCurrencyBase], [idCurrencyType], [idCountry], [idEntityUser], [Base_Buy] FROM [LP_Configuration].[CurrencyBase] WHERE [Active] = 1

		SELECT
				@LastValueCurrencyExchangeLP = [ce].[Value], @LastValueCurrencyExchangeLPId = ce.idCurrencyExchange
			FROM
				[LP_Configuration].CurrencyExchange ce
			WHERE
				idCurrencyExchange = [LP_Configuration].[fnGetCurrencyExchangeByEnityUserId](@idEntityUser,@CurrencyTypeLP)

		UPDATE #LotTrans
		SET
			[StatusObservation] =
								CASE
									WHEN [ESM].[SubMerchantIdentification] IS NOT NULL THEN 'OK'
									ELSE 'ERROR::NF'
								END
		FROM
			#LotTrans										[LT]
				LEFT JOIN [LP_Entity].[EntitySubMerchant]	[ESM] ON [ESM].[SubMerchantIdentification] = [LT].[SubMerchant]

		UPDATE #LotTrans
		SET
			[StatusObservation] = 'ERROR::NUNIQUE'
		FROM
			#LotTrans
		WHERE
			[InternalDescription] IN
									(
										SELECT
											[InternalDescription]
										FROM
											#LotTrans
										GROUP BY
											[InternalDescription]
										HAVING COUNT(*) > 1
									)

		UPDATE #LotTrans
		SET
			[StatusObservation] = 'ERROR::AEXIST'
		FROM
			#LotTrans
		WHERE
			[InternalDescription] IN
									(			
										SELECT
											MerchantId
										FROM
											[LP_Operation].[TransactionPayinDetail] td								
										inner join 
											LP_Operation.[Transaction] t on t.idTransaction = td.idTransaction
										inner join 
											LP_Security.EntityAccount ea on ea.idEntityAccount = @idEntityAccount
										inner join 
											LP_Security.EntityAccountUser eacu on eacu.idEntityAccount = ea.idEntityAccount and eacu.idEntityUser = t.idEntityUser
										WHERE
												[InternalDescription] IN
																	(
																		SELECT
																			[InternalDescription]
																		FROM
																			#LotTrans
																		WHERE [StatusObservation] = 'OK'
																	)
									)

		UPDATE #LotTrans
		SET [StatusObservation] = 'ERROR::DUPAMT'
		FROM #LotTrans LT
		WHERE [LP_Common].[fnConvertIntToDecimalAmount]([LT].[value]) IN (
			SELECT [T].[GrossValueClient]
			FROM [LP_Operation].[Transaction] [T]
			INNER JOIN [LP_Security].[EntityAccount] [EA]					ON [EA].[idEntityAccount] = @idEntityAccount
			INNER JOIN [LP_Security].[EntityAccountUser] [EACU]				ON [EACU].[idEntityAccount] = [EA].[idEntityAccount] and [EACU].[idEntityUser] = [T].[idEntityUser]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider]	[TTP]	ON [T].[idTransactionTypeProvider] = [TTP].[idTransactionTypeProvider]
			INNER JOIN [LP_Entity].[EntityUser] [EU]						ON [T].[idEntityUser] = [EU].[idEntityUser]
			WHERE [T].[GrossValueClient] IN (
				SELECT DISTINCT [LP_Common].[fnConvertIntToDecimalAmount]([LT].[value])
				FROM #LotTrans
				WHERE StatusObservation = 'OK'
			)
			AND [TTP].[idTransactionType] = @idTransactionType
			AND [T].[idStatus] = @idStatus
			AND [EU].[idCountry] NOT IN (SELECT idCountry FROM [LP_Location].[Country] WHERE Code = 'MXN')
		)

		IF(@qtyAccount = 0)
		BEGIN
			UPDATE #LotTrans
			SET [StatusObservation] = 'ERROR::CNF'
			FROM #LotTrans LT
		END
		

			IF((SELECT COUNT(*) FROM #LotTrans WHERE [StatusObservation] = 'OK') > 0)
			BEGIN

				BEGIN TRANSACTION

				INSERT INTO [LP_Operation].[TransactionLot] ([LotNumber], [LotCode], [DescripTion], [LotDate], [idStatus])
				VALUES(CONCAT('000', DATEDIFF(SECOND, '19700101', GETDATE()), @idEntityAccount, @idTransactionType), '', '', @TransactionDate, @idStatus)

				SELECT @LoteNum = @@IDENTITY		

				MERGE INTO [LP_Operation].[Transaction] AS [Dest]
				USING
				(
					SELECT
						[LT].*
						, [CT].[idCurrencyType]
					FROM
						#LotTrans [LT]
							LEFT JOIN [LP_Configuration].[CurrencyType] [CT] ON [LT].[CurrencyType] = [CT].[Code]
					WHERE [LT].[StatusObservation] = 'OK'
				) AS [INS] ON 1 = 0 AND [Dest].[idTransactionLot] = @LoteNum
				WHEN NOT MATCHED BY TARGET
					THEN INSERT ([idEntityUser], [idEntityAccount], [TransactionDate], [GrossValueClient], [CurrencyTypeClient], [GrossValueLP], [CurrencyTypeLP], [Version], [idTransactionLot], [idStatus], [idTransactionMechanism], [idTransactionTypeProvider], [idProviderPayWayService], [idCurrencyExchange], [idCurrencyBase])
					VALUES
					(
						@idEntityUser
						, @idEntityAccount
						, @TransactionDate
						, [LP_Common].[fnConvertIntToDecimalAmount]([INS].[Value])
						, [INS].[idCurrencyType]
						, 
							CASE
								WHEN [INS].[idCurrencyType] = @CurrencyTypeLP THEN [LP_Common].[fnConvertIntToDecimalAmount]([INS].[Value]) * 1
								ELSE
									[LP_Common].[fnConvertIntToDecimalAmount]([INS].[Value]) 
									*
										@LastValueCurrencyExchangeLP
									* 
									(
										1
										-
										(
											SELECT
												[TCB].[Base_Buy]
											FROM
												@tCurrencyBase [TCB]
											WHERE
												[TCB].[idCountry] = @idCountry
												AND [TCB].[idEntityUser] = @idEntityUser
												AND [TCB].[idCurrencyType] = [INS].[idCurrencyType]
										)
										/
										100
									)
							END
						, @CurrencyTypeLP
						, 1
						, @LoteNum
						, @idStatus
						, @idTransactionMechanism
						, @idTransactionTypeProvider
						, @idProviderPayWayService
						,@LastValueCurrencyExchangeLPId
						,
						(
							SELECT [TCB].[idCurrencyBase] FROM @tCurrencyBase [TCB] WHERE [TCB].[idCountry] = @idCountry AND [TCB].[idEntityUser] = @idEntityUser AND [TCB].[idCurrencyType] = [INS].[idCurrencyType]
						)
					)
				OUTPUT [INSERTED].[idTransaction], [INS].[idTransIntTemp]
				INTO @referenciasID ([idNew], [TempId]);

				INSERT INTO LP_Operation.TransactionInternalStatus ( [idTransaction], [idInternalStatus] )
				SELECT [RID].[idNew],[LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'INPROGRESS', 'SCM')
				FROM
					@referenciasID				[RID]
						LEFT JOIN #LotTrans		[LT]	ON [RID].[TempId] = [LT].[idTransIntTemp]
				WHERE
					[LT].[StatusObservation] = 'OK'


				INSERT INTO LP_Operation.TransactionPayinDetail(idTransaction, PayerName, PayerDocumentNumber, PayerAccountNumber, PaymentMethodCode, ExpirationDate, MerchantId,PayerPhoneNumber,PayerEmail)
				SELECT
					RID.idNew,
					LT.PayerName,
					LT.PayerDocumentNumber,
					LT.PayerAccountNumber,
					@ProviderCode,
					DATEADD(day, @expire_days, LT.TransactionDate),
					[LT].[InternalDescription],
					[LT].[PayerPhoneNumber],
					[LT].[PayerEmail]
				FROM
					#LotTrans												[LT]
						LEFT JOIN @referenciasID							[RID]	ON [LT].[idTransIntTemp]			= [RID].[TempId]
						LEFT JOIN [LP_Operation].[Transaction]				[T]		ON [T].[idTransaction]				= [RID].[idNew]
						LEFT JOIN [LP_Entity].[EntityUser]					[EU]	ON [EU].[idEntityUser]				= [T].[idEntityUser]
						LEFT JOIN [LP_Location].[Country]					[C]		ON [C].[idCountry]					= [EU].[idCountry]
						LEFT JOIN [LP_Configuration].[CurrencyType]			[CT]	ON [LT].[CurrencyType]				= [CT].[Code]							
				WHERE
					[LT].[StatusObservation] = 'OK'			
					AND [CT].[Active] = 1
					AND [C].[ISO3166_1_ALFA003] = @country_code	


				SELECT
					@SUM_VALUE_LOT = SUM([GrossValueLP])
				FROM
					[LP_Operation].[Transaction]
				WHERE
					[idTransactionLot] = @LoteNum

				UPDATE [LP_Operation].[TransactionLot]
				SET
					[GrossAmount] = @SUM_VALUE_LOT
				WHERE
					[idTransactionLot] = @LoteNum


				/* NUEVA LOGICA TICKET */
				DECLARE
					@qtyTickets		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
					, @idxTicket	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

				SET @qtyTickets = 
								(
									SELECT COUNT(*)
									FROM
										@referenciasID				[RID]
											LEFT JOIN #LotTrans		[LT]	WITH(NOLOCK) ON [RID].[TempId] = [LT].[idTransIntTemp]
									WHERE
										[LT].[StatusObservation] = 'OK'
								)
					
				SET @idxTicket = 1

				EXEC [LP_Operation].[CreateTicket] @qtyTickets,@idxTicket, @referenciasID

				EXEC [LP_Operation].[CreateReferenceNumber] @referenciasID
				

				INSERT INTO [LP_DataValidation].[ClientIdentificationOperation] ( [idTransaction], [ClientIdentification], [ClientName], [ClientMail])
				SELECT
					RID.[idNew]
					, LT.PayerAccountNumber
					, LT.PayerName
					, 'WITHOUT MAIL'
				FROM
					#LotTrans AS [LT]
						LEFT JOIN @referenciasID	AS RID	ON LT.[idTransIntTemp] = RID.[TempId]
				WHERE
					[LT].[StatusObservation] = 'OK'


				INSERT INTO [LP_Operation].[TransactionEntitySubMerchant] ( [idTransaction], [idEntitySubMerchant] )
				SELECT
					[MAP].[idNew]
					, [SUBM].[idEntitySubMerchant]
				FROM
					@referenciasID									[MAP]
						INNER JOIN #LotTrans						[API]	ON [API].[idTransIntTemp]				= [MAP].[TempId]
						LEFT JOIN [LP_Entity].[EntitySubMerchant]	[SUBM]	ON [SUBM].[SubMerchantIdentification]	= [API].[SubMerchant] AND [SUBM].[idEntityUser] = @idEntityUser --AND [SUBM].[isDefault] = 0				
				WHERE
					[API].[StatusObservation] = 'OK'


				/* KPI TransactionDetail/TransactionProvider :: INS :: Lógica nueva */
				EXEC [LP_KPI].[Payin_Generic_fx_Create] @idTransactionLot = @LoteNum, @country_code = @country_code

				/* TRACKING TRANSACTIONS DATES */
				EXEC [LP_Operation].[Tracking_Init] @LoteNum

				COMMIT TRAN
			END

			
			SELECT
				[idTransaction]													= [T].[idTransaction]
				, [TransactionDate]												= ISNULL(CONVERT(VARCHAR(8), [T].[TransactionDate], 112), '')
				--, [Value]														= REPLACE(CAST(CONVERT(DECIMAL(18,2), [T].[GrossValueLP]) AS VARCHAR(18)), '.', '')
				, [Value]														= REPLACE(CAST(CONVERT(DECIMAL(18,2),IIF(LT.StatusObservation <> 'OK',  [LP_Common].[fnConvertIntToDecimalAmount]([LT].[Value]),[T].[GrossValueLP])) AS VARCHAR(18)), '.', '')
				, [Version]														= [T].[Version]
				, [idTransactionLot]											= [T].[idTransactionLot]
				, [idTransactionType]											= [TTP].[idTransactionType]
				, [idStatus]													= ISNULL([T].[idStatus], 0)
				, [Status]														= ISNULL([STAT].[Code], [LT].[StatusObservation])
				, [StatusDetail]												= CASE 
																					WHEN [STAT].[Code] = 'InProgress' THEN 'The payin is being processed.'
																					WHEN [STAT].[Code] = 'Executed' THEN 'Successfully executed'
																					ELSE 'The payin request has expired'
																				  END
				, [idEntityAccount]												= [T].[idEntityAccount]
				, [Active]														= [T].[Active]
				, [StatusObservation]											= [LT].[StatusObservation]
				, [TransactionDetail.IdTransactionDetail]						= [TD].[IdTransactionDetail]
				, [TransactionDetail.GrossAmount]								= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[GrossAmount]) AS VARCHAR(18)), '.', '')
				, [TransactionDetail.NetAmount]									= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[NetAmount]) AS VARCHAR(18)), '.', '')
				, [TransactionDetail.Commission]								= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[Commission]) AS VARCHAR(18)), '.', '')
				, [TransactionDetail.Status]									= [STATD].[Code]
				, [TransactionDetail.Active]									= [TD].[Active]
				, [TransactionDetail.Version]									= [TD].[Version]
				, [TransactionDetail.ExchangeRate]								= ISNULL(REPLACE(CAST(CONVERT(DECIMAL(18,6),  round(ce.value * (100 - cb.base_sell) / 100, 6)) AS VARCHAR(18)), '.', ''), 0)
				, [TransactionPayinDetail.idTransactionPayinDetail]				= [TRD].[idTransactionPayinDetail]
				, [TransactionPayinDetail.PayerName]							= [TRD].[PayerName]
				, [TransactionPayinDetail.PayerDocumentNumber]					= [TRD].[PayerDocumentNumber]
				, [TransactionPayinDetail.PayerAccountNumber]					= [TRD].[PayerAccountNumber]
				, [TransactionPayinDetail.PaymentMethodCode]					= [TRD].[PaymentMethodCode]
				, [TransactionPayinDetail.ExpirationDate]						= [TRD].[ExpirationDate]
				, [TransactionPayinDetail.MerchantId]							= [TRD].[MerchantId]
				, [TransactionPayinDetail.PayerPhoneNumber]						= [TRD].[PayerPhoneNumber]
				, [TransactionPayinDetail.PayerEmail]							= [TRD].[PayerEmail]
				, [TransactionSubMerchantDetail.SubMerchantIdentification]		= ISNULL([ESM].[SubMerchantIdentification], [LT].[SubMerchant])
				, [Ticket] = [TICK].Ticket
				, [ReferenceCode] = [TICK].[ReferenceCode]
			FROM
				#LotTrans																[LT]
					LEFT JOIN @referenciasID											[RID]		ON [RID].[TempId]					= [LT].[idTransIntTemp]
					LEFT JOIN [LP_Operation].[Transaction]								[T]			ON [T].[idTransaction]				= [RID].[idNew]
					LEFT JOIN [LP_Operation].[TransactionDetail]						[TD]		ON	[TD].[idTransaction]			= [T].[idTransaction]
																									AND	[TD].[Active]					= 1
					LEFT JOIN [LP_Operation].[TransactionPayinDetail]					[TRD]		ON	[TRD].[idTransaction]			= [T].[idTransaction]
					LEFT JOIN [LP_Common].[Status]										[STAT]		ON	[STAT].[idStatus]				= [T].[idStatus]
					LEFT JOIN [LP_Common].[Status]										[STATD]		ON	[STATD].[idStatus]				= [TD].[idStatus]
					LEFT JOIN [LP_Configuration].[TransactionTypeProvider]				[TTP]		ON	[T].[idTransactionTypeProvider] = [TTP].[idTransactionTypeProvider]
					LEFT JOIN [Lp_Operation].[Ticket]                                   [TICK]      ON  [T].[idTransaction]             = [TICK].[idTransaction]
					LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]				[TESM]		ON	[TESM].[idTransaction]			= [T].[idTransaction]
					LEFT JOIN [LP_Entity].[EntitySubMerchant]							[ESM]		ON	[TESM].[idEntitySubMerchant]	= [ESM].[idEntitySubMerchant]
					LEFT JOIN [LP_Configuration].CurrencyExchange						[ce]		ON	[t].idCurrencyExchange = ce.idCurrencyExchange
					LEFT JOIN [LP_Configuration].CurrencyBase							[cb]		ON	[t].idCurrencyBase = cb.idCurrencyBase

																	
			--SELECT @jsonResult

		IF OBJECT_ID('tempdb..#LotTrans') IS NOT NULL DROP TABLE #LotTrans

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN


		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

		RAISERROR
				(
					@ErrorMessage,
					@ErrorSeverity,
					@ErrorState
				);
	END CATCH
END