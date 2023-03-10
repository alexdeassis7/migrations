ALTER PROCEDURE [LP_Retentions_ARG].[GetTransactionsData]
															(
																@retentionCode LP_Common.LP_F_CODE
															)
AS
--DECLARE @retentionCode  LP_Common.LP_F_CODE
--SET @retentionCode = 'RET-ARBA'


BEGIN

	DECLARE
		@RESP		XML
		, @idStatus INT

	DECLARE @Retentions TABLE
	(				
		[CertificateNumber]					INT NOT NULL IDENTITY(1,1) PRIMARY KEY
		, [TransactionDate]					DATETIME
		, [AgentUser]						VARCHAR(MAX)
		, [AgentAddress]					VARCHAR(MAX)
		, [AgentCUIT]						VARCHAR(12)
		, [SubjectUser]						VARCHAR(MAX)
		, [SubjectAddress]					VARCHAR(MAX)
		, [SubjectCUIT]						VARCHAR(12)
		, [Tax]								VARCHAR(MAX)
		, [Voucher]							VARCHAR(MAX)
		, [VoucherNumber]					BIGINT
		, [InternalDescription]				VARCHAR(MAX)
		, [Regime]							VARCHAR(MAX)
		, [RetentionAmount]					DECIMAL(18,6)
		, [GrossAmount]						DECIMAL(18,6)
		, [NetAmount]						DECIMAL(18,6)
		, [idTransaction]					BIGINT
		, [TransactionCertificateName]		VARCHAR(MAX)
		, [idTransactionCertificate]		BIGINT
	) 

	DECLARE @idFileType LP_Common.LP_I_UNIQUE_IDENTIFIER_INT
	SET @idFileType = (SELECT idFileType FROM [LP_Configuration].[FileType] WHERE Code = @retentionCode )

	SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('Executed')

	IF(@retentionCode = 'RET-AFIP')
	BEGIN

		/*

		AFIP

		*/

		INSERT INTO @Retentions ( [TransactionDate], [AgentUser], [AgentAddress], [AgentCUIT], [SubjectUser], [SubjectAddress], [SubjectCUIT], [Tax], [Voucher], [VoucherNumber], [InternalDescription], [Regime], [RetentionAmount], [GrossAmount], [NetAmount], [idTransaction], [TransactionCertificateName], [idTransactionCertificate] )
		SELECT
			[T].[TransactionDate],
			'LOCAL PAYMENT S.R.L',
			' ',
			'30716132028',
			[TRD].[Recipient],
			CAST(ISNULL(NULLIF([TCI].[Address],''), ' ') AS VARCHAR(MAX)), 
			[TRD].[RecipientCUIT],
			'Impuesto a las ganancias',
			[T].[idTransaction],
			[TI].[Ticket],
			[TRD].[InternalDescription],
			[R].[DESCR],
			[TD].[TaxWithholdings],
			[TD].[GrossAmount],
			--[TD].[NetAmount],

			[NetAmount] = [TD].[GrossAmount] - [TD].[TaxWithholdings],

			[T].[idTransaction],
			REPLACE (@retentionCode, 'RET-', '') + '_' + [TC].[FileName],
			[TC].[idTransactionCertificate]
		FROM
			[LP_Operation].[Transaction]											[T]
				INNER JOIN [LP_Operation].[TransactionDetail]						[TD]	ON [T].[idTransaction]				= [TD].[idTransaction]
				INNER JOIN [LP_Operation].[TransactionRecipientDetail]				[TRD]	ON [TRD].[idTransaction]			= [T].[idTransaction]
				INNER JOIN [LP_Configuration].[TransactionTypeProvider]				[TP]	ON [T].[idTransactionTypeProvider]	= [TP].[idTransactionTypeProvider]
				INNER JOIN [LP_Configuration].[TransactionType]						[TT]	ON [TP].[idTransactionType]			= [TT].[idTransactionType]
				INNER JOIN [LP_Configuration].[TransactionGroup]					[TG]	ON [TT].[idTransactionGroup]		= [TG].[idTransactionGroup]
				INNER JOIN [LP_Configuration].[TransactionOperation]				[O]		ON [O].[idTransactionOperation]		= [TG].[idTransactionOperation]
				INNER JOIN [LP_Operation].[TransactionEntitySubMerchant]			[TESM]	ON [TESM].[idTransaction]			= [T].[idTransaction]
				INNER JOIN [LP_Retentions_ARG].[Reg830_Merchant]					[RM]	ON [RM].[idEntitySubMerchant]		= [TESM].[idEntitySubMerchant]
				INNER JOIN [LP_Retentions_ARG].[Reg830]								[R]		ON [RM].[idReg]						= [R].[idReg]
																							AND [R].[idTypeImplementation]		= 1
																							AND [R].[idFileType]				= 1
																							AND [R].[Active]					= 1
																							AND [R].[idStateProvince] IS NULL
				INNER JOIN [LP_Operation].[Ticket]									[TI]	ON [T].[idTransaction]				= [TI].[idTransaction]
				INNER JOIN [LP_Retentions_ARG].[TransactionCertificate]				[TC]	ON [T].[idTransaction]				= [TC].[idTransaction]
				LEFT JOIN [LP_CustomerInformation].[TransactionCustomerInfomation]	[TCI]	ON [TCI].[idTransaction]			= [T].[idTransaction]
		WHERE
			[O].[Code] = 'PO' AND
			[TD].[TaxWithholdings] IS NOT NULL AND
			[TD].[TaxWithholdings] <> 0 AND
			[T].[idStatus] = @idStatus AND
			[TC].[FileBytes] IS NULL AND
			[TC].[Active] = 1 AND
			[TC].[idFileType] = @idFileType

	END
	ELSE
	BEGIN

		/*

		ARBA

		*/

		INSERT INTO @Retentions ( [TransactionDate], [AgentUser], [AgentAddress], [AgentCUIT], [SubjectUser], [SubjectAddress], [SubjectCUIT], [Tax], [Voucher], [VoucherNumber], [InternalDescription], [Regime], [RetentionAmount], [GrossAmount], [NetAmount], [idTransaction], [TransactionCertificateName], [idTransactionCertificate] )
		SELECT
			[T].[TransactionDate],
			'LOCAL PAYMENT S.R.L',
			' ',
			'30716132028',
			[TRD].[Recipient],
			ISNULL(NULLIF([TCI].[Address],''), ' '), 
			[TRD].[RecipientCUIT],
			'Impuesto a las ganancias',
			[T].[idTransaction],
			[TI].[Ticket],
			[TRD].[InternalDescription],
			CAST([R].[REG] AS VARCHAR(10)) + ' - ' + [R].[DESCR],
			[TD].[TaxWithholdingsARBA],
			[TD].[GrossAmount],
			--[TD].[NetAmount],

			[NetAmount] = [TD].[GrossAmount] - [TD].[TaxWithholdingsARBA],

			[T].[idTransaction],
			REPLACE (@retentionCode, 'RET-', '') + '_' + [TC].[FileName],
			[TC].[idTransactionCertificate]
		FROM
			[LP_Operation].[Transaction]											[T]
				INNER JOIN [LP_Operation].[TransactionDetail]						[TD]	ON [T].[idTransaction]				= [TD].[idTransaction]
				INNER JOIN [LP_Operation].[TransactionRecipientDetail]				[TRD]	ON [TRD].[idTransaction]			= [T].[idTransaction]
				INNER JOIN [LP_Configuration].[TransactionTypeProvider]				[TP]	ON [T].[idTransactionTypeProvider]	= [TP].[idTransactionTypeProvider]
				INNER JOIN [LP_Configuration].[TransactionType]						[TT]	ON [TP].[idTransactionType]			= [TT].[idTransactionType]
				INNER JOIN [LP_Configuration].[TransactionGroup]					[TG]	ON [TT].[idTransactionGroup]		= [TG].[idTransactionGroup]
				INNER JOIN [LP_Configuration].[TransactionOperation]				[O]		ON [O].[idTransactionOperation]		= [TG].[idTransactionOperation]
				INNER JOIN [LP_Operation].[TransactionEntitySubMerchant]			[TESM]	ON [TESM].[idTransaction]			= [T].[idTransaction]
				INNER JOIN [LP_Retentions_ARG].[Reg830_Merchant]					[RM]	ON [RM].[idEntitySubMerchant]		= [TESM].[idEntitySubMerchant]
				INNER JOIN [LP_Retentions_ARG].[Reg830]								[R]		ON [RM].[idReg]						= [R].[idReg]
																							AND [R].[idTypeImplementation]		= 2
																							AND [R].[idFileType]				= 2
																							AND [R].[Active]					= 1
				INNER JOIN [LP_Operation].[Ticket]									[TI]	ON [T].[idTransaction]				= [TI].[idTransaction]
				INNER JOIN [LP_Retentions_ARG].[TransactionCertificate]				[TC]	ON [T].[idTransaction]				= [TC].[idTransaction]
				LEFT JOIN [LP_CustomerInformation].[TransactionCustomerInfomation]	[TCI]	ON [TCI].[idTransaction]			= [T].[idTransaction]
		WHERE
			[O].[Code] = 'PO' AND
			[TD].[TaxWithholdingsARBA] IS NOT NULL AND [TD].[TaxWithholdingsARBA] <> 0 AND
			[T].[idStatus] = @idStatus AND
			[TC].[FileBytes] IS NULL AND
			[TC].[Active] = 1 AND
			[TC].[idFileType] = @idFileType

    END

	SET @RESP = CAST((SELECT * FROM @Retentions FOR JSON PATH) AS XML)

	SELECT @RESP
END