DROP PROCEDURE IF EXISTS [LP_Retentions].[RefundRetention]
GO
/****** Object:  StoredProcedure [LP_Retentions].[ListRetentions]    Script Date: 3/16/2020 2:49:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LP_Retentions].[RefundRetention]
														(
															@customer			[LP_Common].[LP_F_C50]
															, @json				[LP_Common].[LP_F_VMAX]
														)
AS											
BEGIN

	DECLARE
		@qtyAccount			[LP_Common].[LP_F_INT]
		, @idEntityAccount	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @Message			[LP_Common].[LP_F_C50]
		, @Status			[LP_Common].[LP_F_BOOL]
		, @idStatus			INT

	SELECT
		@qtyAccount = COUNT([idEntityAccount])
		, @idEntityAccount = MAX([idEntityAccount])
	FROM
		[LP_Security].[EntityAccount]
	WHERE
		[UserSiteIdentification] = @customer
		AND [Active] = 1

	IF(@qtyAccount = 1)
	BEGIN
		DECLARE
			@jsonResult				XML,
			@transactionIds		NVARCHAR(MAX)

		SELECT	@transactionIds = CAST(JSON_VALUE(@JSON, '$.transactionIds') AS NVARCHAR(MAX))	
		SET @idStatus = [LP_Operation].[fnGetIdStatusByCode]('Executed')

		BEGIN TRY
			BEGIN TRAN
				UPDATE [LP_Retentions_ARG].[TransactionCertificate] SET [RefundDate] = GETDATE() WHERE idTransaction IN (SELECT * FROM STRING_SPLIT(@transactionIds,','))
				COMMIT
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			ROLLBACK TRAN


			DECLARE @TicketErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
			DECLARE @TicketErrorSeverity INT = ERROR_SEVERITY()
			DECLARE @TicketErrorState INT = ERROR_STATE()

			RAISERROR
					(
						@TicketErrorMessage,
						@TicketErrorSeverity,
						@TicketErrorState
					);
		END CATCH

		SET @jsonResult =
						(
							SELECT
								CAST
								(
									(
										SELECT
											[idTransaction]			= [T].[idTransaction]
											, [TransactionDate]		= [T].[TransactionDate]
											, [ProcessedDate]		= [T].[ProcessedDate]
											, [Merchant]			= [EU].[FirstName]
											, [SubMerchant]			= [ESM].[SubMerchantIdentification]
											, [RecipientCUIT]		= [TRD].[RecipientCUIT]
											, [Recipient]			= [TRD].[Recipient]
											, [Ticket]				= [TCK].[Ticket]
											, [MerchantId]			= [TRD].[InternalDescription]
											, [FileName]			= [FileName]
											, [CertificateNumber]	= SUBSTRING([FileName], 0, 27)
											, [CurrencyType]		= [LP_Operation].[fnGetCurrency]([T].[CurrencyTypeLP])
											, [GrossAmount]			= [TD].[GrossAmount]
											, [TaxWithholdings]		= IIF(TC.idFileType=1, TD.TaxWithholdings,IIF(TC.idFileType=2,TD.TaxWithholdingsARBA, TD.TaxWithholdingsAGIP))
											, [NetAmount]			= [TD].GrossAmount - IIF(TC.idFileType=1, TD.TaxWithholdings,IIF(TC.idFileType=2,TD.TaxWithholdingsARBA, TD.TaxWithholdingsAGIP))
											, [GrossUSD]			= ([W].[GrossValueClient] * -1)

											, [IdReg]				= [RR].[idReg]
											, [Regime]				= [RR].[DESCR]
											, [Retention]			= [FT].[Name]
											, [CBU]					= [TRD].[CBU]
											, [NroRegimen]			= [RR].[REG]
											, [Refund]				= [TC].[RefundDate]

										FROM
											[LP_Operation].[Transaction]								[T]
												INNER JOIN [LP_Operation].[TransactionLot]				[TL]	ON [T].[idTransactionLot]		= [TL].[idTransactionLot]
												INNER JOIN [LP_Retentions_ARG].[TransactionCertificate]	[TC]	ON [T].[idTransaction]			= [TC].[idTransaction]
												INNER JOIN [LP_Configuration].[FileType]				[FT]	ON [TC].[idFileType]			=   [FT].[idFileType]
												INNER JOIN [LP_Operation].[Ticket]						[TCK]	ON [T].[idTransaction]			= [TCK].[idTransaction]
												INNER JOIN [LP_Operation].[TransactionDetail]			[TD]	ON [T].[idTransaction]			= [TD].[idTransaction]
												LEFT JOIN [LP_Operation].[Wallet]						[W]		ON [T].[idTransaction]			= [W].[idTransaction]
												LEFT JOIN [LP_Operation].[TransactionRecipientDetail]	[TRD] WITH(INDEX=IX_LP_Operation_TransactionRecipientDetail_RecipientCUIT)	ON [T].[idTransaction]			= [TRD].[idTransaction]
												LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON [T].[idTransaction]			= [TESM].[idTransaction]
												LEFT JOIN [LP_Entity].[EntitySubMerchant]				[ESM]	ON [TESM].[idEntitySubMerchant]	= [ESM].[idEntitySubMerchant]
												LEFT JOIN [LP_Retentions_ARG].[Reg830_Merchant]			[RRM]	ON [TESM].[idEntitySubMerchant]	=	[RRM].[idEntitySubMerchant]  
												INNER JOIN [LP_Retentions_ARG].[Reg830]					[RR]	ON [TC].[idFileType]			=	[RR].[idFileType] AND [RR].[idReg] = [RRM].[idReg]
												LEFT JOIN [LP_Entity].[EntityUser]						[EU]	ON [T].[idEntityUser]			= [EU].[idEntityUser]
												LEFT JOIN [LP_Entity].[EntityMerchant]					[EM]	ON [EU].[idEntityMerchant]		= [EM].[idEntityMerchant]


										WHERE		
												[TC].[FileName] IS NOT NULL 
											AND [T].[idStatus] = @idStatus
											AND [T].[idTransaction] IN (SELECT * FROM STRING_SPLIT(@transactionIds,','))


										ORDER BY
											[T].[Idtransaction]

										FOR JSON PATH
									) AS XML
								)
						)

		SELECT @jsonResult

	END
	ELSE
	BEGIN
		SET @Status = 0
		SET @Message = 'CLIENTE INEXISTENTE. VERFIQUE SU CUSTOMER_ID'
	END
END
