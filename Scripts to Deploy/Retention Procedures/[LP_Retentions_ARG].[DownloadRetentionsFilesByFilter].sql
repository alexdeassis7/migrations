/****** Object:  StoredProcedure [LP_Retentions_ARG].[DownloadRetentionsFilesByFilter]    Script Date: 4/7/2020 1:27:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LP_Retentions_ARG].[DownloadRetentionsFilesByFilter]
                                                    @merchantId     bigint
                                                    ,@retentionCode nvarchar(10)
                                                    ,@transactionsDate date = null
													,@certificateNumber varchar(60)
													,@internalDescriptionMerchantId varchar(60)
													,@payoutId bigint
AS
BEGIN
        DECLARE @resp xml

            SET @resp = CAST(
                                (
                                    SELECT 
                                            tc.idTransactionCertificate, 
                                            tc.[FileBytes], 
                                            tc.[FileName]
                                    FROM [LP_Retentions_ARG].[TransactionCertificate] tc 
                                        INNER JOIN [LP_Operation].[Transaction] t on t.idTransaction = tc.idTransaction
                                        INNER JOIN [LP_Configuration].[FileType] FT ON TC.idFileType    = FT.idFileType
										INNER JOIN [LP_Operation].[TransactionLot] tl ON tl.idTransactionLot = t.idTransactionLot
										INNER JOIN [LP_Operation].[TransactionRecipientDetail] trd ON trd.[idTransaction] = t.[idTransaction]
                                    WHERE
                                        tc.[FileBytes] IS NOT NULL 
                                        AND Tc.Active = 1
                                        AND FT.Code=@retentionCode
                                        AND t.[idEntityUser] = @merchantId
                                        AND cast(t.TransactionDate as date) = @transactionsDate 
										AND (@payoutId is null or tl.idTransactionLot = @payoutId)
										AND (@internalDescriptionMerchantId is null or trd.InternalDescription = @internalDescriptionMerchantId)
										AND (@certificateNumber is null or SUBSTRING(tc.FileName,0, CHARINDEX('_',tc.FileName)) = @certificateNumber)
                                        FOR JSON PATH) 
                                AS XML)
        SELECT @resp
END
GO

