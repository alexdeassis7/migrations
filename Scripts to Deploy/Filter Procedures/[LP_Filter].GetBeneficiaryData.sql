CREATE OR ALTER PROCEDURE [LP_Filter].[GetBeneficiaryData]
  @ticketNumbers VARCHAR(MAX)
  AS
	SELECT trd.Recipient, trd.RecipientCUIT AS DocumentNumber, tr.idTransaction, td.GrossAmount AS Amount, trd.CBU, trd.RecipientAccountNumber AS AccountNumber, esm.SubMerchantAddress AS SubMerchantAddress, ti.Ticket
							FROM [LP_Operation].[Ticket] ti JOIN [LP_Operation].[Transaction] tr ON ti.idTransaction = tr.idTransaction
							JOIN [LP_Operation].[TransactionEntitySubMerchant] tes ON tes.idTransaction = tr.idTransaction
							JOIN [LP_Entity].[EntitySubMerchant] esm ON esm.idEntitySubMerchant = tes.idEntitySubMerchant
							JOIN [LP_Operation].[TransactionDetail] td ON td.idTransaction = ti.idTransaction
							JOIN [LP_Entity].[EntityUser] eu ON eu.idEntityUser = esm.idEntityUser
							JOIN [LP_Operation].[TransactionRecipientDetail] trd ON trd.idTransaction = tr.idTransaction
							WHERE ti.Ticket IN (SELECT Tickets.value  FROM OPENJSON(@ticketNumbers, '$.tickets') as Tickets)
							AND esm.Description IN  ('Payoneer Internal', 'Payoneer withdrawals')
							AND tr.idStatus = 4 
GO
