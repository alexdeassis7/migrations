

/****** Object:  StoredProcedure [LP_Operation].[ARG_Payout_Generic_Entity_Operation_Create]    Script Date: 3/23/2020 5:01:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



alter PROCEDURE [LP_Operation].[ARG_Payout_Generic_Entity_Operation_Create]
																				(
																					@Customer				[LP_Common].[LP_F_C50]
																					, @JSON					NVARCHAR(MAX)
																					, @TransactionMechanism	[LP_Common].[LP_F_BOOL]
																					, @country_code			[LP_Common].[LP_F_C3]
																				)
AS
--TESTING POR APP

--DECLARE @Customer				[LP_Common].[LP_F_C50]
--DECLARE @JSON					NVARCHAR(MAX)
--DECLARE @TransactionMechanism	[LP_Common].[LP_F_BOOL]
--DECLARE @country_code			[LP_Common].[LP_F_C3]
--SET @Customer = 'danielra@payoneer.com'
--SET @JSON = '{"idTransactionLot":0,"LotNumber":0,"LotCode":null,"Description":null,"LotDate":null,"CustomerName":null,"TransactionType":null,"Status":null,"GrossAmount":0,"NetAmount":0,"TaxWithholdings":0,"Balance":0,"idFlow":0,"idStatus":0,"Active":false,"Transactions":[{"idTransaction":0,"TransactionDate":"20191021","Value":150000,"Version":0,"idTransactionLot":0,"idTransactionType":0,"idStatus":0,"idEntityAccount":0,"Status":null,"Active":false,"StatusObservation":null,"idCurrencyType":0,"id":null,"type_of_id":null,"bank_code":null,"TransactionDetail":{"idTransactionDetail":0,"IdTransaction":0,"GrossAmount":0,"NetAmount":0,"TaxWithholdings":0,"Commission":0,"IVACommission":0,"Balance":0,"BankCost":0,"IVABankCost":0,"DebitTax":0,"CreditTax":0,"TotalCostRdo":0,"IVATotal":0,"TransactionDate":0,"idStatus":0,"Active":false,"Version":0},"TransactionRecipientDetail":{"idTransactionRecipientDetail":0,"Recipient":"Del Carlo Torres","RecipientCUIT":"30710631758","CBU":"0110752630075200954179","RecipientAccountNumber":null,"TransactionAcreditationDate":"20191021","Description":"","InternalDescription":"12","ConceptCode":"0","BankAccountType":"C","EntityIdentificationType":null,"CurrencyType":"ARS","PaymentType":null,"idTransaction":0,"idStatus":0,"Active":false,"IdType":null,"Id":null,"BankCode":null},"TransactionPayWayDetail":{"idTransactionPayWayDetail":0,"AmountPaymentInstallments":0,"StartDate":null,"EndDate":null,"FinalAmount":0,"idTransaction":0,"idStatus":0,"Active":false},"TransactionDebinDetail":{"idTransactionDebinDetail":0,"idTransaction":0,"idStatus":0,"Active":false,"id_ticket":null,"bank_transaction":null,"currency":null,"amount":0,"beneficiary_softd":null,"site_transaction_id":null,"description":null,"concept_code":null,"payment_type":null,"payout_date":null,"alias":null,"cbu":null,"buyer_cuit":null,"buyer_name":null,"buyer_bank_code":null,"buyer_cbu":null,"buyer_alias":null,"buyer_bank_description":null,"status":null},"TransactionCustomerInformation":{"FirstName":null,"LastName":null,"Email":null,"Address":"Ruta 13 lote 36 casa 2  Uspallata Argentina 5545 Ruta 13 lote 36 casa 2  Uspallata Argentina 5545 Ruta 13 lote 36 casa 2  Uspallata Argentina 5545 123","BirthDate":"","Country":"Argentina","City":"","Annotation":""},"TransactionSubMerchantDetail":{"SubMerchantIdentification":"Airbnb"}}]}'
--SET @TransactionMechanism = 1
--SET @country_code = 'ARG'


--TESTING POR API

--DECLARE @Customer				[LP_Common].[LP_F_C50]
--DECLARE @JSON					NVARCHAR(MAX)
--DECLARE @TransactionMechanism	[LP_Common].[LP_F_BOOL]
--DECLARE @country_code			[LP_Common].[LP_F_C3]
--SET @Customer = '000001500001'
--SET @JSON = '{"idTransactionLot":0,"LotNumber":0,"LotCode":null,"Description":null,"LotDate":null,"CustomerName":null,"TransactionType":null,"Status":null,"GrossAmount":0,"NetAmount":0,"TaxWithholdings":0,"Balance":0,"idFlow":0,"idStatus":0,"Active":false,"Transactions":[{"idTransaction":0,"TransactionDate":"20191111","Value":10000000,"Version":0,"idTransactionLot":0,"idTransactionType":0,"idStatus":0,"idEntityAccount":0,"Status":null,"Active":false,"StatusObservation":null,"idCurrencyType":0,"id":null,"type_of_id":null,"bank_code":null,"TransactionDetail":{"idTransactionDetail":0,"IdTransaction":0,"GrossAmount":0,"NetAmount":0,"TaxWithholdings":0,"Commission":0,"IVACommission":0,"Balance":0,"BankCost":0,"IVABankCost":0,"DebitTax":0,"CreditTax":0,"TotalCostRdo":0,"IVATotal":0,"TransactionDate":0,"idStatus":0,"Active":false,"Version":0},"TransactionRecipientDetail":{"idTransactionRecipientDetail":0,"Recipient":"Usuario EE","RecipientCUIT":"20313031447","CBU":"0150501601000245488475","RecipientAccountNumber":null,"TransactionAcreditationDate":"20191231","Description":"RapydPAGO","InternalDescription":"523611","ConceptCode":"0","BankAccountType":"A","EntityIdentificationType":null,"CurrencyType":"ARS","PaymentType":null,"idTransaction":0,"idStatus":0,"Active":false,"IdType":null,"Id":null,"BankCode":null},"TransactionPayWayDetail":{"idTransactionPayWayDetail":0,"AmountPaymentInstallments":0,"StartDate":null,"EndDate":null,"FinalAmount":0,"idTransaction":0,"idStatus":0,"Active":false},"TransactionDebinDetail":{"idTransactionDebinDetail":0,"idTransaction":0,"idStatus":0,"Active":false,"id_ticket":null,"bank_transaction":null,"currency":null,"amount":0,"beneficiary_softd":null,"site_transaction_id":null,"description":null,"concept_code":null,"payment_type":null,"payout_date":null,"alias":null,"cbu":null,"buyer_cuit":null,"buyer_name":null,"buyer_bank_code":null,"buyer_cbu":null,"buyer_alias":null,"buyer_bank_description":null,"status":null},"TransactionCustomerInformation":{"FirstName":null,"LastName":null,"Email":null,"Address":null,"BirthDate":null,"Country":null,"City":null,"Annotation":null},"TransactionSubMerchantDetail":{"SubMerchantIdentification":"Airbnb"}}]}'
--SET @TransactionMechanism = 0
--SET @country_code = 'ARG'

BEGIN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	BEGIN TRY

			IF OBJECT_ID('tempdb..#LotTrans') IS NOT NULL DROP TABLE #LotTrans

			DECLARE
				@TransactionDate				DATETIME
				, @idEntityAccount				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idEntityUser					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idCountry					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idStatus						[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idTransactionType			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idTransactionTypeProvider	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idProvider					[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]	
				, @idProviderPayWayService		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @ProviderCode					[LP_Common].[LP_F_CODE]
				, @idTransactionMechanism		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
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

			SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('Received')

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

				--SET @qtyAccount = ( SELECT COUNT([idEntityAccount]) FROM [LP_Security].[EntityAccount] WHERE [UserSiteIdentification] = @Customer AND [Active] = 1 )

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

			END

			SET @idCountry = [LP_Location].[fnGetIdCountyByidEntityUser](@idEntityUser)	

			SET @idProvider = ( SELECT [idProvider] FROM [LP_Configuration].[Provider] WHERE [Code] = 'BSPVIELLE' AND [idCountry] = @idCountry AND [Active] = 1) 

			SET @idTransactionType =
									(
										SELECT
											[tt].[idTransactionType]
										FROM
											[LP_Configuration].[TransactionType] [tt]
										WHERE
											[tt].[Code] = 'PODEPO'
											AND [tt].[Active] = 1
									)

			SELECT
				@idTransactionTypeProvider	= [ttp].[idTransactionTypeProvider]
				, @ProviderCode				= [ttp].[PROV_Code]
			FROM
				[LP_Catalog].[TransactionTypeProvider] [ttp]
			WHERE
				[ttp].[idTransactionType] = @idTransactionType
				AND [ttp].[idCountry] = @idCountry
				AND [ttp].[TT_Active] = 1
				AND [ttp].[PROV_Active] = 1
				AND [ttp].[COUNTRY_Active] = 1
				AND [ttp].[TTP_Active] = 1
				AND [ttp].[PROV_Code] = 'BSPVIELLE'

			SET @idProviderPayWayService =
											(
												SELECT
													[ppws].[idProviderPayWayService]
												FROM
													[LP_Catalog].[ProviderPayWayServices] [ppws]
												WHERE
													[ppws].[PROV_Code] = @ProviderCode
													AND [ppws].[PWS_Code] = 'BANKDEPO'
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
				, [Recipient]					VARCHAR(100)
				, [RecipientCUIT]				VARCHAR(100)
				, [CBU]							VARCHAR(100)
				, [RecipientAccountNumber]		VARCHAR(100)
				, [TransactionAcreditationDate]	VARCHAR(100)
				, [Description]					VARCHAR(100)
				, [InternalDescription]			VARCHAR(100)
				, [ConceptCode]					VARCHAR(100)
				, [BankAccountType]				VARCHAR(100)
				, [EntityIdentificationType]	VARCHAR(100)
				, [CurrencyType]				VARCHAR(100)
				, [Email]						VARCHAR(100)
				, [Address]						VARCHAR(300)
				, [BirthDate]					VARCHAR(100)
				, [PhoneNumber]					VARCHAR(100)
				, [SenderName]					VARCHAR(100)
				, [SenderAddress]				VARCHAR(300)
				, [SenderState]					VARCHAR(100)
				, [SenderCountry]               VARCHAR(100)
				, [SenderTAXID]					VARCHAR(100)
				, [SenderBirthDate]				VARCHAR(100)
				, [SenderEmail]			   		VARCHAR(100)
				, [SenderPhoneNumber]			VARCHAR(100)
				, [ZipCode]						VARCHAR(100)
				, [SenderZipCode]				VARCHAR(100)
				, [Country]						VARCHAR(100)
				, [City]						VARCHAR(100)
				, [Annotation]					VARCHAR(100)
				, [StatusObservation]			VARCHAR(100)
				, [SubMerchant]					VARCHAR(60)
			)

			INSERT  INTO #LotTrans ([Value], [TransactionDate], [Recipient], [RecipientCUIT], [CBU], [RecipientAccountNumber], [TransactionAcreditationDate], [Description], [InternalDescription], [ConceptCode], [BankAccountType], [EntityIdentificationType], [CurrencyType], /*[FirstName] , [LastName],*/ [Email] , [Address] , [BirthDate],[PhoneNumber] , [Country], [City] , [Annotation], 
			[SenderName],[SenderAddress],[SenderState],[SenderCountry],[SenderTAXID],[SenderBirthDate],[SenderEmail],[SenderPhoneNumber],
			[SubMerchant],[ZipCode],[SenderZipCode])
			SELECT
				[Value]
				, [TransactionDate]
				, [Recipient]
				, [RecipientCUIT]
				, [CBU]
				, [RecipientAccountNumber]
				, [TransactionAcreditationDate]
				, [[Description]
				, [InternalDescription]
				, [ConceptCode]
				, [BankAccountType]
				, [EntityIdentificationType]
				, [CurrencyType]
				, [Email]
				, [Address]
				, [BirthDate]
				, [RecipientPhoneNumber]
				, [Country]
				, [City]
				, [Annotation]
				, ISNULL([SenderName],'')
				, ISNULL([SenderAddress],'')
				, ISNULL([SenderState],'')
				, ISNULL([SenderCountry],'')
				, ISNULL([SenderTAXID],'')
				, [SenderBirthDate]
				, ISNULL([SenderEmail],'')
				, ISNULL([SenderPhoneNumber],'')
				, [SubMerchant]
				, [ZipCode]
				, [SenderZipCode]
			FROM OPENJSON(@JSON)
			WITH
			(		
				[Transactions]					NVARCHAR(MAX) AS JSON
			)
			AS [Lot]
			CROSS APPLY OPENJSON ([Lot].[Transactions])
			WITH
			(
				[Value]								[LP_Common].[LP_F_C100] '$.Value',
				[TransactionDate]					[LP_Common].[LP_F_C100] '$.TransactionDate',
				[TransactionRecipientDetail]		NVARCHAR(MAX) AS JSON,
				[TransactionCustomerInformation]	NVARCHAR(MAX) AS JSON,
				[TransactionSubMerchantDetail]		NVARCHAR(MAX) AS JSON
			)AS [Transactions]
			CROSS APPLY OPENJSON ([Transactions].[TransactionRecipientDetail])
			WITH
			(
				[Recipient]						[LP_Common].[LP_F_C100] '$.Recipient',
				[RecipientCUIT]					[LP_Common].[LP_F_C100] '$.RecipientCUIT',
				[CBU]							[LP_Common].[LP_F_C100] '$.CBU',
				[RecipientAccountNumber]		[LP_Common].[LP_F_C100] '$.RecipientAccountNumber',
				[TransactionAcreditationDate]	[LP_Common].[LP_F_C100] '$.TransactionAcreditationDate',
				[[Description]					[LP_Common].[LP_F_C100] '$.Description',
				[InternalDescription]			[LP_Common].[LP_F_C100] '$.InternalDescription',
				[ConceptCode]					[LP_Common].[LP_F_C100] '$.ConceptCode',
				[BankAccountType]				[LP_Common].[LP_F_C100] '$.BankAccountType',
				[EntityIdentificationType]		[LP_Common].[LP_F_C100] '$.EntityIdentificationType',
				[CurrencyType]					[LP_Common].[LP_F_C100] '$.CurrencyType',
				[RecipientPhoneNumber]			[LP_Common].[LP_F_C100] '$.RecipientPhoneNumber'
			) AS [Recipient]
			CROSS APPLY OPENJSON ([Transactions].[TransactionCustomerInformation])
			WITH
			(
				[Email]							[LP_Common].[LP_F_C100] '$.Email',
				[Address]						VARCHAR(300) '$.Address',
				[BirthDate]						[LP_Common].[LP_F_C100] '$.BirthDate',
				[Country]						[LP_Common].[LP_F_C100] '$.Country',
				[City]							[LP_Common].[LP_F_C100] '$.City',
				[Annotation]					[LP_Common].[LP_F_C100] '$.Annotation',
				[ZipCode]						[LP_Common].[LP_F_C100] '$.ZipCode',
				[SenderName]					[LP_Common].[LP_F_DESCRIPTION] '$.SenderName',
				[SenderAddress]					VARCHAR(300) '$.SenderAddress',
				[SenderState]					[LP_Common].[LP_F_C20] '$.SenderState',
				[SenderCountry]					[LP_Common].[LP_F_C20] '$.SenderCountry',
				[SenderTAXID]					[LP_Common].[LP_F_C20] '$.SenderTaxid',
				[SenderBirthDate]				[LP_Common].[LP_F_C100] '$.SenderBirthDate',
				[SenderEmail]					[LP_Common].[LP_F_C100] '$.SenderEmail',
				[SenderPhoneNumber]				[LP_Common].[LP_F_C100] '$.SenderPhoneNumber',
				[SenderZipCode]					[LP_Common].[LP_F_C100] '$.SenderZipCode'
			) AS [CustomerInformation]
			CROSS APPLY OPENJSON ([Transactions].[TransactionSubMerchantDetail])
			WITH
			(
				[SubMerchant]					[LP_Common].[LP_F_DESCRIPTION] '$.SubMerchantIdentification'
			) AS [SubMerchantDetail]

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
			

			
			DECLARE @Submerchants TABLE 
			(
				[Identification]		[LP_Common].[LP_F_DESCRIPTION]
			)
			DECLARE @SubmerchantIdentification [LP_Common].[LP_F_DESCRIPTION]

			INSERT INTO @Submerchants (Identification)
			SELECT DISTINCT(SubMerchant) FROM #LotTrans WHERE SubMerchant NOT IN (SELECT SubMerchantIdentification FROM [LP_Entity].[EntitySubMerchant] WHERE idEntityUser = @idEntityUser)

			IF ((SELECT COUNT(Identification) FROM @Submerchants) > 0)
			BEGIN
				DECLARE submerchant_cursor CURSOR FORWARD_ONLY FOR
				SELECT Identification  FROM  @Submerchants

				OPEN submerchant_cursor;

				FETCH NEXT FROM submerchant_cursor INTO @SubmerchantIdentification
				WHILE @@FETCH_STATUS = 0
				BEGIN
					EXEC [LP_Entity].[NewSubmerchant] @idEntityUser,@SubmerchantIdentification
					FETCH NEXT FROM submerchant_cursor INTO @SubmerchantIdentification
				END
				CLOSE submerchant_cursor;

				DEALLOCATE submerchant_cursor;  
			END

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
												[InternalDescription]
											FROM
												[LP_Operation].[TransactionRecipientDetail] td								
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

			IF(@qtyAccount = 1)
			BEGIN	
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
					SELECT [RID].[idNew], [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'RECI', 'SCM')
					FROM
						@referenciasID				[RID]
							LEFT JOIN #LotTrans		[LT]	ON [RID].[TempId] = [LT].[idTransIntTemp]
					WHERE
						[LT].[StatusObservation] = 'OK'

					INSERT INTO [LP_Operation].[TransactionRecipientDetail] ([idTransaction], [Recipient], [RecipientCUIT], [CBU], [RecipientAccountNumber], [TransactionAcreditationDate], [Description], [InternalDescription], [ConceptCode], [idBankAccountType], [idEntityIdentificationType], [idCurrencyType], [idStatus], [idPaymentType], [idBankCode],[RecipientPhoneNumber])
					SELECT
						RID.[idNew]
						, [Recipient]
						, [RecipientCUIT]
						, [CBU]
						, [LP_Common].[CBU_Validate](NULL, [CBU], 'AccountNumber')
						, [TransactionAcreditationDate]
						, LT.[Description]
						, [InternalDescription]
						, [ConceptCode]
						, BAT.[idBAnkAccountType]
						, ISNULL(EIT.[idEntityIdentificationType], (SELECT [EITI].[idEntityIdentificationType] FROM [LP_Entity].[EntityIdentificationType] [EITI] WHERE [EITI].[Code] = 'CUIT'))
						, CT.[idCurrencyType]
						, @idStatus
						, (SELECT [PT].[idPaymentType] FROM [LP_Configuration].[PaymentType] [PT] WHERE [PT].[idCountry] = @idCountry)
						, (SELECT [BK].[idBankCode] FROM [LP_Configuration].[BankCode] [BK] WHERE [BK].[Code] = '00' + SUBSTRING([CBU], 1, 3) AND [BK].[idCountry] = @idCountry )
						, LT.PhoneNumber
					FROM
						#LotTrans												[LT]
							LEFT JOIN @referenciasID							[RID]	ON [LT].[idTransIntTemp]			= [RID].[TempId]
							LEFT JOIN [LP_Operation].[Transaction]				[T]		ON [T].[idTransaction]				= [RID].[idNew]
							LEFT JOIN [LP_Entity].[EntityUser]					[EU]	ON [EU].[idEntityUser]				= [T].[idEntityUser]
							LEFT JOIN [LP_Location].[Country]					[C]		ON [C].[idCountry]					= [EU].[idCountry]
							LEFT JOIN [LP_Configuration].[BankAccountType]		[BAT]	ON [LT].[BankAccountType]			= [BAT].[Code] AND [BAT].[idCountry] = [C].[idCountry]
																						AND [BAT].[idCountry]				= @idCountry
							LEFT JOIN [LP_Entity].[EntityIdentificationType]	[EIT]	ON (([LT].[EntityIdentificationType]= [EIT].[Code] AND [EIT].[Active] = 1) OR ([LT].[EntityIdentificationType] IS NULL) AND [EIT].[idCountry] = [C].[idCountry] AND [EIT].[Code] = 'CUIT')
							LEFT JOIN [LP_Configuration].[CurrencyType]			[CT]	ON [LT].[CurrencyType]				= [CT].[Code]							
					WHERE
						[LT].[StatusObservation] = 'OK'
						AND [BAT].[Active] = 1						
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

					INSERT INTO [LP_Operation].[TransactionFromTo]( [idTransaction], [FromIdEntityAccount], [ToIdEntityAccount])
					SELECT [RID].[idNew], @idEntityAccount, @idEntityAccount
					FROM
						@referenciasID				[RID]
							LEFT JOIN #LotTrans		[LT]	ON [RID].[TempId] = [LT].[idTransIntTemp]
					WHERE
						[LT].[StatusObservation] = 'OK'

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

					/* INSERT TransactionCustomerInformation */
					SET @idxTx = 1
					SET @qtyTxs =
								(
									SELECT
										COUNT(*)
									FROM
										@referenciasID				[RID]
											LEFT JOIN #LotTrans		[LT]	ON [RID].[TempId] = [LT].[idTransIntTemp]
									WHERE
										[LT].[StatusObservation] = 'OK'
								)

					IF(@qtyTxs >= 1)
					BEGIN
						WHILE(@idxTx <= @qtyTxs)
						BEGIN

							DECLARE
								@idTransaction		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
								, @FirstName	[LP_Common].[LP_F_DESCRIPTION]
								, @LastName		[LP_Common].[LP_F_DESCRIPTION]
								, @Email		[LP_Common].[LP_F_DESCRIPTION]
								, @Address		VARCHAR(300)
								, @BirthDate	[LP_Common].[LP_F_C8]
								, @Country		[LP_Common].[LP_F_DESCRIPTION]
								, @City			[LP_Common].[LP_F_DESCRIPTION]
								, @ZipCode		VARCHAR(100) = NULL
								, @Annotation	[LP_Common].[LP_F_DESCRIPTION]
								, @SenderName   [LP_Common].[LP_F_DESCRIPTION]
								, @SenderAddress VARCHAR(300)
								, @SenderState [LP_Common].[LP_F_C20]
								, @SenderCountry [LP_Common].[LP_F_C20]
								, @SenderTAXID [LP_Common].[LP_F_C20]
								, @SenderBirthDate	[LP_Common].[LP_F_C8]	= NULL
								, @SenderEmail		[LP_Common].[LP_F_DESCRIPTION]= NULL
								, @SenderPhoneNumber [LP_Common].[LP_F_C150] = NULL
								, @SenderZipCode		VARCHAR(100) = NULL

							SELECT
								@idTransaction	= [RI].[idNew]
								, @FirstName	= [LT].[Recipient]
								, @Email		= [LT].[Email]
								, @Address		= [LT].[Address]
								, @BirthDate	= [LT].[BirthDate]
								, @Country		= [LT].[Country]
								, @City			= [LT].[City]
								, @Annotation	= [LT].[Annotation]
								, @SenderName   = [LT].[SenderName]
								, @SenderAddress = [LT].[SenderAddress]
								, @SenderState = [LT].[SenderState]
								, @SenderCountry = [LT].[SenderCountry]
								, @SenderTAXID = [LT].[SenderTAXID]
								, @SenderBirthDate = [LT].[SenderBirthDate]
								, @SenderEmail = [LT].[SenderEmail]
								, @SenderPhoneNumber = [LT].[SenderPhoneNumber]
								, @ZipCode = [LT].[ZipCode]
								, @SenderZipCode = [LT].[SenderZipCode]
							FROM
								@referenciasID [RI]
									INNER JOIN #LotTrans [LT] ON [RI].[TempId] = [LT].[idTransIntTemp]
							WHERE
								[RI].[IDX] = @idxTx
								AND [LT].[StatusObservation] = 'OK'

							EXEC [LP_CustomerInformation].[TransactionCustomerInfomation_INSERT] @idTransaction, @FirstName, @LastName, @Email, @Address, @BirthDate, @Country, @City, @Annotation, @SenderName, @SenderAddress, @SenderState, @SenderCountry, @SenderTAXID, @SenderBirthDate, @SenderEmail, @SenderPhoneNumber,@ZipCode,@SenderZipCode

							SET @idxTx = @idxTx + 1
						END
					END

					/* INSERT LP_DataValidation.ClientIdentificationOperation */
					INSERT INTO [LP_DataValidation].[ClientIdentificationOperation] ( [idTransaction], [ClientIdentification], [ClientName], [ClientMail])
					SELECT
						RID.[idNew]
						, LT.[RecipientCUIT]
						, LT.[Recipient]
						, 'WITHOUT MAIL'
					FROM
						#LotTrans AS [LT]
							LEFT JOIN @referenciasID	AS RID	ON LT.[idTransIntTemp] = RID.[TempId]
					WHERE
						[LT].[StatusObservation] = 'OK'

					/* INSERT INTO [LP_Operation].[TransactionEntitySubMerchant] ==> RELACION ENTRE LA TRANSACTION, MERCHANT Y SUBMERCHANT POR EL TEMA DE LA RETENCION */
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
					EXEC [LP_KPI].[ARG_Payout_Generic_fx_Create] @idTransactionLot = @LoteNum, @country_code = @country_code

					/* TRACKING TRANSACTIONS DATES */
					EXEC [LP_Operation].[Tracking_Init] @LoteNum

					COMMIT TRAN
				END

				SET @jsonResult =
									(
										SELECT
											CAST
											(
												(
													SELECT TOP 1
														[idTransactionLot]	= ISNULL(MAX([TLE].[idTransactionLot]), 0)
														, [LotNumber]		= ISNULL(MAX([TLE].[LotNumber]), 0)
														, [LotCode]			= ISNULL(MAX([TLE].[LotCode]), '')
														, [Description]		= ISNULL(MAX([TLE].[Description]), '')
														, [LotDate]			= ISNULL(CONVERT(VARCHAR(8), MAX([TLE].[LotDate]), 112), '')

														, [GrossAmount]		= ISNULL(REPLACE(CAST(CONVERT(DECIMAL(18,2), [TLE].[GrossAmount]) AS VARCHAR(18)), '.', ''), 0)
														, [NetAmount]		= ISNULL(REPLACE(CAST(CONVERT(DECIMAL(18,2), [TLE].[NetAmount]) AS VARCHAR(18)), '.', ''), 0)
														, [TaxWithholdings_Afip]	= 0
														, [TaxWithholdings_Arba]	= 0
														, [Balance]			= ISNULL(REPLACE(CAST(CONVERT(DECIMAL(18,2), [TLE].[AccountBalance]) AS VARCHAR(18)), '.', ''), 0)

														, [idStatus]		= ISNULL([TLE].[idStatus], 0)
														, [Status]			= ISNULL([STATL].[Code], '')
														, [Active]			= ISNULL([TLE].[Active], 0)
														, [Transactions]	= 
																				(
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
																					, [idEntityAccount]												= [T].[idEntityAccount]
																					, [Active]														= [T].[Active]
																					, [StatusObservation]											= [LT].[StatusObservation]
																					, [TransactionDetail.IdTransactionDetail]						= [TD].[IdTransactionDetail]
																					, [TransactionDetail.GrossAmount]								= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[GrossAmount]) AS VARCHAR(18)), '.', '')
																					, [TransactionDetail.NetAmount]									= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[NetAmount]) AS VARCHAR(18)), '.', '')
																					, [TransactionDetail.TaxWithholdings_Afip]						= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[TaxWithholdings]) AS VARCHAR(18)), '.', '')
																					, [TransactionDetail.TaxWithholdings_Arba]						= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[TaxWithholdingsARBA]) AS VARCHAR(18)), '.', '')
																					, [TransactionDetail.Commission]								= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[Commission]) AS VARCHAR(18)), '.', '')
																					, [TransactionDetail.IVA]										= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[VAT]) AS VARCHAR(18)), '.', '')
																					, [TransactionDetail.IVACommission]								= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[Commission_With_VAT]) AS VARCHAR(18)), '.', '')
																					, [TransactionDetail.Status]									= [STATD].[Code]
																					, [TransactionDetail.Active]									= [TD].[Active]
																					, [TransactionDetail.Version]									= [TD].[Version]
																					, [TransactionDetail.ExchangeRate]								= ISNULL(REPLACE(CAST(CONVERT(DECIMAL(18,6),  round(ce.value * (100 - cb.Base_Buy) / 100, 6)) AS VARCHAR(18)), '.', ''), 0)
																					, [TransactionRecipientDetail.idTransactionRecipientDetail]		= [TRD].[idTransactionRecipientDetail]
																					, [TransactionRecipientDetail.Recipient]						= ISNULL([TRD].[Recipient], [LT].[Recipient])
																					, [TransactionRecipientDetail.RecipientCUIT]					= ISNULL([TRD].[RecipientCUIT], [LT].[RecipientCUIT])
																					, [TransactionRecipientDetail.CBU]								= ISNULL([TRD].[CBU], [LT].[CBU])
																					, [TransactionRecipientDetail.RecipientAccountNumber]			= ISNULL([TRD].[RecipientAccountNumber], [LT].[RecipientAccountNumber])
																					, [TransactionRecipientDetail.TransactionAcreditationDate]		= ISNULL(CONVERT(VARCHAR(8), [TRD].[TransactionAcreditationDate], 112), [LT].[TransactionAcreditationDate])
																					, [TransactionRecipientDetail.Description]						= ISNULL([TRD].[Description], [LT].[Description])
																					, [TransactionRecipientDetail.InternalDescription]				= ISNULL([TRD].[InternalDescription], [LT].[InternalDescription])
																					, [TransactionRecipientDetail.ConceptCode]						= ISNULL([TRD].[ConceptCode], [LT].[ConceptCode])
																					, [TransactionRecipientDetail.BankAccountType]					= ISNULL([BAT].[Code], '')
																					, [TransactionRecipientDetail.EntityIdentificationType]			= 'CUIT'
																					, [TransactionRecipientDetail.CurrencyType]						= 'ARS'
																					, [TransactionRecipientDetail.PaymentType]						= ISNULL([PT].[CatalogValue], '')
																					, [TransactionRecipientDetail.idTransaction]					= [TRD].[idTransaction]
																					, [TransactionRecipientDetail.idStatus]							= ISNULL([TRD].[idStatus], 0)
																					, [TransactionRecipientDetail.Status]							= ISNULL([STATRD].[Code], [LT].[StatusObservation])
																					, [TransactionRecipientDetail.Active]							= ISNULL([TRD].[Active], 0)
																					, [TransactionRecipientDetail.RecipientPhoneNumber]				= ISNULL([TRD].[RecipientPhoneNumber], 0)

																					, [TransactionCustomerInformation.Email]						= ISNULL([TCI].[Email], [LT].[Email])
																					, [TransactionCustomerInformation.Address]						= ISNULL([TCI].[Address], [LT].[Address])
																					, [TransactionCustomerInformation.BirthDate]					= ISNULL([TCI].[BirthDate], [LT].[BirthDate])
																					, [TransactionCustomerInformation.Country]						= ISNULL([TCI].[Country], [LT].[Country])
																					, [TransactionCustomerInformation.City]							= ISNULL([TCI].[City], [LT].[City])
																					, [TransactionCustomerInformation.Annotation]					= ISNULL([TCI].[Annotation], [LT].[Annotation])
																					, [TransactionCustomerInformation.SenderName]					= ISNULL([TCI].[SenderName], [LT].[SenderName])
																					, [TransactionCustomerInformation.SenderAddress]				= ISNULL([TCI].[SenderAddress], [LT].[SenderAddress])
																					, [TransactionCustomerInformation.SenderState]				= ISNULL([TCI].[SenderState], [LT].[SenderState])
																					, [TransactionCustomerInformation.SenderCountry]				= ISNULL([TCI].[SenderCountry], [LT].[SenderCountry])
																					, [TransactionCustomerInformation.SenderTAXID]				= ISNULL([TCI].[SenderTAXID], [LT].[SenderTAXID])
																					, [TransactionCustomerInformation.SenderBirthDate]				= ISNULL([TCI].[SenderBirthDate], [LT].[SenderBirthDate])
																					, [TransactionCustomerInformation.SenderEmail]				= ISNULL([TCI].[SenderEmail], [LT].[SenderEmail])
																					, [TransactionCustomerInformation.SenderPhoneNumber]		= ISNULL([TCI].[SenderPhoneNumber], [LT].[SenderPhoneNumber])
																					, [TransactionCustomerInformation.SenderZipCode]			= ISNULL([TCI].[SenderZipCode], [LT].[SenderZipCode])
																					, [TransactionCustomerInformation.ZipCode]					= ISNULL([TCI].[ZipCode], [LT].[ZipCode])
																					, [TransactionSubMerchantDetail.SubMerchantIdentification]		= ISNULL([ESM].[SubMerchantIdentification], [LT].[SubMerchant])
																					, [Ticket] = [TICK].Ticket
																				FROM
																					#LotTrans																[LT]
																						LEFT JOIN @referenciasID											[RID]		ON [RID].[TempId]					= [LT].[idTransIntTemp]
																						LEFT JOIN [LP_Operation].[Transaction]								[T]			ON [T].[idTransaction]				= [RID].[idNew]
																						LEFT JOIN [LP_Operation].[TransactionDetail]						[TD]		ON	[TD].[idTransaction]			= [T].[idTransaction]
																																										AND	[TD].[Active]					= 1
																						LEFT JOIN [LP_Operation].[TransactionRecipientDetail]				[TRD]		ON	[TRD].[idTransaction]			= [T].[idTransaction]
																						LEFT JOIN [LP_Common].[Status]										[STAT]		ON	[STAT].[idStatus]				= [T].[idStatus]
																						LEFT JOIN [LP_Common].[Status]										[STATRD]	ON	[STATRD].[idStatus]				= [TRD].[idStatus]
																						LEFT JOIN [LP_Common].[Status]										[STATD]		ON	[STATD].[idStatus]				= [TD].[idStatus]
																						LEFT JOIN [LP_Configuration].[BankAccountType]						[BAT]		ON	[TRD].[idBankAccountType]		= [BAT].[idBankAccountType]
																						LEFT JOIN [LP_Configuration].[PaymentType]							[PT]		ON	[TRD].[idPaymentType]			= [PT].[idPaymentType]
																						LEFT JOIN [LP_Configuration].[TransactionTypeProvider]				[TTP]		ON	[T].[idTransactionTypeProvider] = [TTP].[idTransactionTypeProvider]
																						LEFT JOIN [LP_CustomerInformation].[TransactionCustomerInfomation]	[TCI]		ON	[T].[idTransaction]				= [TCI].[idTransaction]
																						LEFT JOIN [Lp_Operation].[Ticket]                                   [TICK]      ON  [T].[idTransaction]             = [TICK].[idTransaction]
																						LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]				[TESM]		ON	[TESM].[idTransaction]			= [T].[idTransaction]
																						LEFT JOIN [LP_Entity].[EntitySubMerchant]							[ESM]		ON	[TESM].[idEntitySubMerchant]	= [ESM].[idEntitySubMerchant]
																						LEFT JOIN [LP_Configuration].CurrencyExchange						[ce]		ON	[t].idCurrencyExchange = ce.idCurrencyExchange
																						LEFT JOIN [LP_Configuration].CurrencyBase							[cb]		ON	[t].idCurrencyBase = cb.idCurrencyBase

																				FOR JSON PATH
																			)
													FROM
														#LotTrans										[LTE]
															LEFT JOIN @referenciasID					[RIDE]	ON [LTE].[idTransIntTemp]	= [RIDE].[TempId]
															LEFT JOIN [LP_Operation].[Transaction]		[TE]	ON [TE].[idTransaction]		= [RIDE].[idNew]
															LEFT JOIN [LP_Operation].[TransactionLot]	[TLE]	ON [TLE].[idTransactionLot]	= [TE].[idTransactionLot]
															LEFT JOIN [LP_Common].[Status]				[STATL]	ON [STATL].[idStatus]		= [TLE].[idStatus]
													GROUP BY
														[TLE].[idTransactionLot],
														[TLE].[LotNumber],
														[TLE].[LotCode],
														[TLE].[Description],
														[TLE].[LotDate],
														[TLE].[GrossAmount],
														[TLE].[NetAmount],
														[TLE].[AccountBalance],
														[TLE].[idStatus],
														[STATL].[Code],
														[TLE].[Active]
													ORDER BY [TLE].idTransactionLot DESC

													FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
												) 
											AS XML)
									)
				SELECT @jsonResult

			END
			ELSE
			BEGIN
				SET @Status = 0
				SET @Message = 'CLIENTE INEXISTENTE. VERFIQUE SU CUSTOMER_ID'
			END

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


GO


