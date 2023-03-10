/****** Object:  StoredProcedure [LP_Retentions_ARG].[DownloadAFIPWithholdingsMonthly]    Script Date: 3/16/2020 9:44:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [LP_Retentions_ARG].[DownloadAFIPWithholdingsMonthly] 
														(
															@customer			[LP_Common].[LP_F_C50]
															, @year				[LP_Common].[LP_F_VERSION]
															, @month			[LP_Common].[LP_F_VERSION]
															, @typeFile         [LP_Common].[LP_F_C5]
														)
AS											
BEGIN	
--EXEC  [LP_Retentions_ARG].[DownloadAFIPWithholdingsMonthly] 'admin@localpayment.com', 2019, 12, 'EXCEL'

		DECLARE @idFileType INT
		SET @idFileType = ( SELECT [idFileType] FROM [LP_Configuration].[FileType] WHERE [Code] = 'RET-AFIP' )

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

		DECLARE @Lines TABLE
					(
						[idLine]						INT IDENTITY(1,1)
						, [Line]						VARCHAR(MAX)
					)

		DECLARE @Temp TABLE
					(
						[CodComprobante]				VARCHAR(MAX)
						, [LEN_CodComprobante]			INT
						, [FechaEmision]				VARCHAR(MAX)
						, [LEN_FechaEmision]			INT
						, [NumComprobante]				VARCHAR(MAX)
						, [LEN_NumComprobante]			INT
						, [ImporteComprbante]			VARCHAR(MAX)
						, [LEN_ImporteComprbante]		INT
						, [CodImpuesto]					VARCHAR(MAX)
						, [LEN_CodImpuesto]				INT
						, [CodRegimen]					VARCHAR(MAX)
						, [LEN_CodRegimen]				INT
						, [CodOPeración]				VARCHAR(MAX)
						, [LEN_CodOPeración]			INT
						, [BaseCalculo]					VARCHAR(MAX)
						, [LEN_BaseCalculo]				INT
						, [FechaEmisionRet]				VARCHAR(MAX)
						, [LEN_FechaEmisionRet]			INT
						, [CodCondicion]				VARCHAR(MAX)
						, [LEN_CodCondicion]			INT
						, [SujetoSuspen]				VARCHAR(MAX)
						, [LEN_SujetoSuspen]			INT
						, [ImporteRet]					VARCHAR(MAX)
						, [LEN_ImporteRet]				INT
						, [PorcExclusion]				VARCHAR(MAX)
						, [LEN_PorcExclusion]			INT
						, [FechaemiBoletin]				VARCHAR(MAX)
						, [LEN_FechaemiBoletin]			INT
						, [TipoDocRet]					VARCHAR(MAX)
						, [LEN_TipoDocRet]				INT
						, [NumDocRet]					VARCHAR(MAX)
						, [LEN_NumDocRet]				INT
						, [NumCertOrig]					VARCHAR(MAX)
						, [LEN_NumCertOrig]				INT
						, [LineComplete]				VARCHAR(MAX)

					)



			IF(@typeFile = 'TXT')
			BEGIN
			INSERT INTO @Temp
			SELECT		

						  [CodComprobante]			=	'06'
						, [LEN_CodComprobante]		=	2
						, [FechaEmision]			=	CONVERT(VARCHAR(10),  [T].[TransactionDate], 103)
						, [LEN_FechaEmision]		=	10
						, [NumComprobante]			=	RIGHT(  '0000000000000000' + CAST([TK].[Ticket] AS VARCHAR) , 16) 
						, [LEN_NumComprobante]		=	16		
						, [ImporteComprbante]		=	RIGHT(  '0000000000000000' + CAST(CAST([TD].[GrossAmount] AS DECIMAL(16,2)) AS VARCHAR) , 16) 
						, [LEN_ImporteComprbante]	=	16					
						, [CodImpuesto]				=	'0217'
						, [LEN_CodImpuesto]			=	3
						, [CodRegimen]				=	'031'
						, [LEN_CodRegimen]			=	3
						, [CodOPeración]			=	'1'
						, [LEN_CodOPeración]		=	1
						, [BaseCalculo]				=	RIGHT(  '0000000000000000' + CAST(CAST([TD].[GrossAmount] AS DECIMAL(14,2)) AS VARCHAR) , 14) 
						, [LEN_BaseCalculo]			=	14
						, [FechaEmisionRet]			=	CONVERT(VARCHAR(10),  [T].[TransactionDate], 103)
						, [LEN_FechaEmisionRet]		=	10
						, [CodCondicion]			=	'01'
						,  [LEN_CodCondicion]		=	2
						, [SujetoSuspen]			=	'0'
						, [LEN_SujetoSuspen]		=	1
						, [ImporteRet]				=	RIGHT(  '0000000000000000' + CAST(CAST([TD].[TaxWithholdings] AS DECIMAL(14,2))  AS VARCHAR) , 14) 
						, [LEN_ImporteRet]			=	14
						, [PorcExclusion]			=	'000.00'
						, [LEN_PorcExclusion]		=	6
						, [FechaemiBoletin]			=	'          '
						, [LEN_FechaemiBoletin]		=	10
						, [TipoDocRet]				=	'80'
						, [LEN_TipoDocRet]			=	2
						, [NumDocRet]				=	RIGHT(  '00000000000000000000' + CAST([TRD].[RecipientCUIT] AS VARCHAR) , 20)  
						, [LEN_NumDocRet]			=	20
						, [NumCertOrig]				=	RIGHT(  '00000000000000' + CAST(CONCAT(LEFT(SUBSTRING(REPLACE([TC].[FileName],'AFIP_',''),0,27),7),RIGHT(SUBSTRING(REPLACE([TC].[FileName],'AFIP_',''),0,27),7))AS VARCHAR) , 14)  
						, [LEN_NumCertOrig]			=	14
						,[LineComplete]				=	''
				FROM 
					[LP_Operation].[Transaction]								[T]
						INNER JOIN [LP_Operation].[Ticket]						[TK]	ON [T].idTransaction = [TK].idTransaction
						INNER JOIN [LP_Operation].[TransactionDetail]			[TD]	ON [T].idTransaction = [TD].[idTransaction]
						INNER JOIN [LP_Operation].[TransactionRecipientDetail]	[TRD]	ON [T].[idTransaction] = [TRD].[idTransaction]
						INNER JOIN [LP_Retentions_ARG].[TransactionCertificate] [TC]	ON [T].[idTransaction] = [TC].[idTransaction]  
																						AND [TC].[Active] = 1  
																						AND [TC].[idFileType] = @idFileType 
				WHERE 
						(
							[TC].[FileName] IS NOT NULL 
						) 
						AND
						(
							YEAR([T].[TransactionDate]) = @year
						)
						AND
						(
							MONTH([T].[TransactionDate]) = @month
						)
						AND ([TC].[RefundDate] IS NULL)


					UPDATE @Temp
					SET [LineComplete] =	[CodComprobante]	+		
											[FechaEmision]		+											
											[NumComprobante]	+													
											[ImporteComprbante]	+											
											[CodImpuesto]		+												
											[CodRegimen]		+												
											[CodOPeración]		+											
											[BaseCalculo]		+												
											[FechaEmisionRet]	+													
											[CodCondicion]		+											
											[SujetoSuspen]		+											
											[ImporteRet]		+												
											[PorcExclusion]		+												
											[FechaemiBoletin]	+														
											[TipoDocRet]		+											
											[NumDocRet]			+
											[NumCertOrig]		

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
											  [CodComprobante]			=	'06'
											, [FechaEmision]			=	CONVERT(VARCHAR(10),  [T].[TransactionDate], 103)
											, [NumComprobante]			=	RIGHT(  '0000000000000000' + CAST([TK].[Ticket] AS VARCHAR) , 16) 
											, [ImporteComprbante]		=	RIGHT(  '0000000000000000' + CAST(CAST([TD].[GrossAmount] AS DECIMAL(16,2)) AS VARCHAR) , 16) 
											, [CodImpuesto]				=	'0217'
											, [CodRegimen]				=	'031'
											, [CodOPeración]			=	'1'
											, [BaseCalculo]				=	RIGHT(  '0000000000000000' + CAST(CAST([TD].[GrossAmount] AS DECIMAL(14,2)) AS VARCHAR) , 14) 
											, [FechaEmisionRet]			=	CONVERT(VARCHAR(10),  [T].[TransactionDate], 103)
											, [CodCondicion]			=	'01'
											, [SujetoSuspen]			=	'0'
											, [ImporteRet]				=	RIGHT(  '0000000000000000' + CAST(CAST([TD].[TaxWithholdings] AS DECIMAL(14,2))  AS VARCHAR) , 14) 
											, [PorcExclusion]			=	'000.00'
											, [FechaemiBoletin]			=	null
											, [TipoDocRet]				=	'80'
											, [NumDocRet]				=	RIGHT(  '00000000000000000000' + CAST([TRD].[RecipientCUIT] AS VARCHAR) , 20)  
											, [NumCertOrig]				=	RIGHT(  '00000000000000' + CAST(CONCAT(LEFT(SUBSTRING(REPLACE([TC].[FileName],'AFIP_',''),0,27),7),RIGHT(SUBSTRING(REPLACE([TC].[FileName],'AFIP_',''),0,27),7))AS VARCHAR) , 14)  
											, [LineComplete]			=	''
									FROM 
										[LP_Operation].[Transaction]								[T]
											INNER JOIN [LP_Operation].[Ticket]						[TK]	ON [T].[idTransaction] = [TK].[idTransaction]
											INNER JOIN [LP_Operation].[TransactionDetail]			[TD]	ON [T].[idTransaction] = [TD].[idTransaction]
											INNER JOIN [LP_Operation].[TransactionRecipientDetail] [TRD]	ON [T].[idTransaction] = [TRD].[idTransaction]
											INNER JOIN [LP_Retentions_ARG].[TransactionCertificate] [TC]	ON [T].[idTransaction] = [TC].[idTransaction]  
																											AND [TC].[Active] = 1 
																											AND [TC].[idFileType] = @idFileType
									WHERE 
											(
												[TC].[FileName] IS NOT NULL 
											)
											AND
											(
												YEAR([T].[TransactionDate]) = @year
											)	
											AND
											(
												MONTH([T].[TransactionDate]) = @month
											)
											AND ([TC].[RefundDate] IS NULL)
													FOR JSON PATH
														) AS XML
													)
											)

					SELECT @jsonResult

		END

	--END

END

