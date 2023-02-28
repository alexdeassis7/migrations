DROP PROCEDURE IF EXISTS [LP_Filter].[ListSettlementInformation]
GO

CREATE PROCEDURE [LP_Filter].[ListSettlementInformation]
@dateFrom varchar(100),
@dateTo varchar(100),
@merchantId varchar(100) = NULL
AS
BEGIN
	DECLARE @JSON XML

	SET @JSON	=
				(
					SELECT
						CAST
						( 
							(
								SELECT esm.Description, trd.Recipient, trd.RecipientCUIT, 'SettlementDate' = CAST([tc].[CertificateDate] AS datetime), tr.idTransaction, 'SettlementNumber' = tc.idTransactionCertificate, 'PDF' = tc.CertificateFileBytes, td.GrossAmount, trd.CBU, trd.RecipientAccountNumber, esm.SubMerchantAddress
							FROM [LP_Operation].[Ticket] ti JOIN [LP_Operation].[Transaction] tr ON ti.idTransaction = tr.idTransaction
							JOIN [LP_Operation].[TransactionEntitySubMerchant] tes ON tes.idTransaction = tr.idTransaction
							JOIN [LP_Entity].[EntitySubMerchant] esm ON esm.idEntitySubMerchant = tes.idEntitySubMerchant
							JOIN [LP_Operation].[TransactionDetail] td ON td.idTransaction = ti.idTransaction
							JOIN [LP_Entity].[EntityUser] eu ON eu.idEntityUser = esm.idEntityUser
							JOIN [LP_Operation].[TransactionRecipientDetail] trd ON trd.idTransaction = tr.idTransaction
							JOIN [LP_Operation].[TransactionCertificates] tc ON tc.idTransaction = tr.idTransaction
							AND esm.Description IN  ('Payoneer Internal', 'Payoneer withdrawals')
							AND tr.idStatus = 4 
							WHERE cast([tc].[CertificateDate] as date) BETWEEN @dateFrom AND @dateTo
							AND (esm.Description = @merchantId OR @merchantId IS NULL)
								FOR JSON PATH
							) AS XML
						)
				)

	SELECT @JSON

END
GO


