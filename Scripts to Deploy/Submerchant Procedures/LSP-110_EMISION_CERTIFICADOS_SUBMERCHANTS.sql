/****** Object:  StoredProcedure [LP_Filter].[GetBeneficiaryData]    Script Date: 4/24/2020 3:39:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
	
	
CREATE TABLE [LP_Operation].[TransactionCertificates](
	[idTransactionCertificate] [bigint] IDENTITY(1,1) NOT NULL,
	[idTransaction] [bigint] NOT NULL,
	[CertificateFileBytes] [varbinary](max) NULL,
	[certificateNumber] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idTransactionCertificate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[idTransaction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE PROCEDURE [LP_Filter].[GetBeneficiaryData]
@ticketNumber bigint
AS
	SELECT trd.Recipient, trd.RecipientCUIT, tr.idTransaction, td.GrossAmount, trd.CBU, trd.RecipientAccountNumber, esm.SubMerchantAddress
							FROM [LP_Operation].[Ticket] ti JOIN [LP_Operation].[Transaction] tr ON ti.idTransaction = tr.idTransaction
							JOIN [LP_Operation].[TransactionEntitySubMerchant] tes ON tes.idTransaction = tr.idTransaction
							JOIN [LP_Entity].[EntitySubMerchant] esm ON esm.idEntitySubMerchant = tes.idEntitySubMerchant
							JOIN [LP_Operation].[TransactionDetail] td ON td.idTransaction = ti.idTransaction
							JOIN [LP_Entity].[EntityUser] eu ON eu.idEntityUser = esm.idEntityUser
							JOIN [LP_Operation].[TransactionRecipientDetail] trd ON trd.idTransaction = tr.idTransaction
							WHERE ti.Ticket = @ticketNumber 
							AND esm.Description IN  ('Payoneer Internal', 'Payoneer withdrawals')
							AND tr.idStatus = 4 
GO

CREATE PROCEDURE [LP_Operation].[TransactionCertificates_Create]
  (
  @idTransaction bigint,
  @data varbinary(max),
  @certificateNumber int
  )
  AS
	INSERT INTO LP_Operation.TransactionCertificates
	VALUES (@idTransaction, @data, @certificateNumber)
GO


