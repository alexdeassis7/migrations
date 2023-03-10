/****** Object:  StoredProcedure [LP_Retentions_ARG].[DownloadARBAWithholdingsMonthly]    Script Date: 3/16/2020 9:46:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [LP_Retentions_ARG].[DownloadARBAWithholdingsMonthly] 
																		(
																			@customer			[LP_Common].[LP_F_C50]
																			, @month			[LP_Common].[LP_F_VERSION]
																			, @year				[LP_Common].[LP_F_VERSION]
																			, @typeFile			[LP_Common].[LP_F_C5]
																		)
AS											
BEGIN

--EXEC [LP_Retentions_ARG].[DownloadARBAWithholdingsMonthly] 'admin@localpayment.com', 11, 2019, 'EXCEL'



		DECLARE @idFileType INT
		SET @idFileType = ( SELECT [idFileType] FROM [LP_Configuration].[FileType] WHERE [Code] = 'RET-ARBA' )

		DECLARE
		@qtyAccount				[LP_Common].[LP_F_INT]

		SELECT
			@qtyAccount	= COUNT([EA].[idEntityAccount])
		FROM
			[LP_Security].[EntityAccount] [EA]
				INNER JOIN [LP_Security].[EntityAccountUser]	[EAU]	ON [EAU].[idEntityAccount] = [EA].[idEntityAccount]
				INNER JOIN [LP_Entity].[EntityUser]				[EU]	ON [EU].[idEntityUser] = [EAU].[idEntityUser]
				INNER JOIN [LP_Location].[Country]				[C]		ON [C].[idCountry] = [EU].[idCountry]
		WHERE
			[EA].[UserSiteIdentification] = @customer
			AND [EA].[Active] = 1
			AND [EU].[Active] = 1
			AND [C].[Active] = 1
			AND [C].[ISO3166_1_ALFA003] = 'ARG'


	--IF(@qtyAccount >= 1)
	--BEGIN

		IF(@typeFile = 'TXT')
		BEGIN

		DECLARE @Lines TABLE
							(
								[idLine]						INT IDENTITY(1,1)
								, [Line]						VARCHAR(MAX)
							)

		DECLARE @Temp TABLE
							(
								[Cuit]							VARCHAR(MAX)
								, [LEN_Cuit]					INT
								, [WithholdingDate]				VARCHAR(MAX)
								, [LEN_WithholdingDate]			INT
								, [BranchNumber]				VARCHAR(MAX)
								, [LEN_BranchNumber]			INT
								, [EmisionNumber]				VARCHAR(MAX)
								, [LEN_EmisionNumber]			INT
								, [Amount]						VARCHAR(MAX)
								, [LEN_Amount]					INT
								, [OperationType]				VARCHAR(MAX)
								, [LEN_OperationType]			INT
								, [LineComplete]				VARCHAR(MAX)
							)


		INSERT INTO @Temp ([Cuit], [LEN_Cuit], [WithholdingDate], [LEN_WithholdingDate], [BranchNumber], [LEN_BranchNumber], [EmisionNumber], [LEN_EmisionNumber],
							[Amount], [LEN_Amount], [OperationType], [LEN_OperationType] )
					SELECT
								[CUIT]						= ( SUBSTRING([TRD].[RecipientCUIT], 0, 3) ) + '-' + ( SUBSTRING([TRD].[RecipientCUIT], 3, 8) ) + '-' + ( SUBSTRING([TRD].[RecipientCUIT], 11, 3) )
								, [LEN_Cuit]				= 13
								, [WithholdingDate]			= ( CONVERT(VARCHAR,  [T].[TransactionDate], 103 ) )
								, [LEN_WithholdingDate]		= 10
								, [BranchNumber]			= '0001'
								, [LEN_BranchNumber]		= 4
								, [EmisionNumber]			= SUBSTRING(REPLACE([TC].[FileName],'ARBA_',''), 19, 8)
								, [LEN_EmisionNumber]		= 8 
								, [Amount]					= REPLACE ( RIGHT ( '0000000000' + CAST ( CAST ([TD].[TaxWithholdingsARBA] AS DECIMAL(18,2)) AS varchar ), 11 ) , '.' , ',')
								, [LEN_Amount]				= 11
								, [OperationType]			= 'A' --A = Alta, B = Baja, M = Modificación
								, [LEN_OperationType]		= 1
					FROM
								[LP_Retentions_ARG].[TransactionCertificate]			[TC]																					
								INNER JOIN [LP_Operation].[Transaction]					[T]		ON [T].[idTransaction]				= [TC].[idTransaction]
								INNER JOIN [LP_Operation].[TransactionRecipientDetail]	[TRD]	ON	[T].[idTransaction]				= [TRD].[idTransaction]
								INNER JOIN [LP_Operation].[TransactionDetail]			[TD]	ON	[T].[idTransaction]				= [TD].[idTransaction]
								LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[T].[idTransaction]				= [TESM].[idTransaction]
								INNER JOIN [LP_Entity].[EntitySubMerchant]				[ESM]	ON	[TESM].[idEntitySubMerchant]	= [ESM].[idEntitySubMerchant]
								INNER JOIN [LP_Retentions_ARG].[Reg830_Merchant]		[RRM]	ON	[TESM].[idEntitySubMerchant]	= [RRM].[idEntitySubMerchant]  
								INNER JOIN [LP_Retentions_ARG].[Reg830]					[RR]	ON	[TC].[idFileType]				= [RR].[idFileType] 
																								AND [RR].[idReg]					= [RRM].[idReg]
								LEFT JOIN [LP_Entity].[EntityUser]						[EU]	ON	[T].[idEntityUser]				= [EU].[idEntityUser]
								LEFT JOIN [LP_Entity].[EntityMerchant]					[EM]	ON	[EU].[idEntityMerchant]			= [EM].[idEntityMerchant]
					WHERE
							(
								[TC].[FileName] IS NOT NULL 
							)
						AND
							(
								[TC].[Active] = 1
							)
						AND
							(
								[TC].[idFileType] = @idFileType
							)
						AND
							(
								MONTH([T].[TransactionDate]) = @month
							)
						AND
							(
								YEAR([T].[TransactionDate]) = @year
							)
						AND ([TC].[RefundDate] IS NULL)


					UPDATE @Temp
					SET [LineComplete]  = [Cuit] + [WithholdingDate] + [BranchNumber] + [EmisionNumber] + [Amount] + [OperationType] 


					INSERT INTO @Lines
					SELECT [LineComplete] FROM @Temp			

					DECLARE @Rows INT
					SET @Rows = ((SELECT COUNT(*) FROM @Temp))

					IF(@Rows > 0)
					BEGIN
						SELECT [Line] FROM @Lines ORDER BY [idLine] ASC
					END
				END

		ELSE IF (@typeFile = 'EXCEL')
				BEGIN
					DECLARE @jsonResult		XML

				SET @jsonResult =
						(
							SELECT
								CAST
								(
									(
										SELECT
												[CUIT]						= ( SUBSTRING([TRD].[RecipientCUIT], 0, 3) ) + '-' + ( SUBSTRING([TRD].[RecipientCUIT], 3, 8) ) + '-' + ( SUBSTRING([TRD].[RecipientCUIT], 11, 3) )
												, [WithholdingDate]			= ( CONVERT(VARCHAR,  [T].[TransactionDate], 103 ) )
												, [BranchNumber]			= '0001'
												, [EmisionNumber]			= SUBSTRING(REPLACE([TC].[FileName],'ARBA_',''), 19, 8)
												, [Amount]					= REPLACE ( RIGHT ( '0000000000' + CAST ( CAST ([TD].[TaxWithholdingsARBA] AS DECIMAL(18,2)) AS varchar ), 11 ) , '.' , ',')
												, [OperationType]			= 'A' --A = Alta, B = Baja, M = Modificación
										FROM
												[LP_Retentions_ARG].[TransactionCertificate]			[TC]																					
												INNER JOIN [LP_Operation].[Transaction]					[T]		ON [T].[idTransaction]				= [TC].[idTransaction]
												INNER JOIN [LP_Operation].[TransactionRecipientDetail]	[TRD]	ON	[T].[idTransaction]				= [TRD].[idTransaction]
												INNER JOIN [LP_Operation].[TransactionDetail]			[TD]	ON	[T].[idTransaction]				= [TD].[idTransaction]
												LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[T].[idTransaction]				= [TESM].[idTransaction]
												INNER JOIN [LP_Entity].[EntitySubMerchant]				[ESM]	ON	[TESM].[idEntitySubMerchant]	= [ESM].[idEntitySubMerchant]
												INNER JOIN [LP_Retentions_ARG].[Reg830_Merchant]		[RRM]	ON	[TESM].[idEntitySubMerchant]	= [RRM].[idEntitySubMerchant]  
												INNER JOIN [LP_Retentions_ARG].[Reg830]					[RR]	ON	[TC].[idFileType]				= [RR].[idFileType] 
																												AND [RR].[idReg]					= [RRM].[idReg]
												LEFT JOIN [LP_Entity].[EntityUser]						[EU]	ON	[T].[idEntityUser]				= [EU].[idEntityUser]
												LEFT JOIN [LP_Entity].[EntityMerchant]					[EM]	ON	[EU].[idEntityMerchant]			= [EM].[idEntityMerchant]

										WHERE
												(
													[TC].[FileName] IS NOT NULL 
												)
												AND
												(
													[TC].[Active] = 1
												)
												AND
												(
													[TC].[idFileType] = @idFileType
												)
												AND
												(
													MONTH([T].[TransactionDate]) = @month
												)
												AND
												(
													YEAR([T].[TransactionDate]) = @year
												)
												AND ([TC].[RefundDate] IS NULL)

												FOR JSON PATH

											) AS XML
										)
									)

						SELECT @jsonResult

		END
	END
--END

