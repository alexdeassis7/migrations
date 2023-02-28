USE [LocalPaymentProd]
GO

/****** Object:  Table [LP_Operation].[BankPreRegisterBankAccountSabadell]    Script Date: 11/02/2021 08:06:19 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [LP_Operation].[BankPreRegisterBankAccountSabadell](
	[idBankPreRegisterBankAccount] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1) NOT NULL,
	[AccountNumber] [varchar](18) NULL,
	[AccountAlias] [varchar](15) NULL,
	[idBankPreRegisterLot] [int] NULL,
	[Deleted] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[idBankPreRegisterBankAccount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[AccountNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [LP_Operation].[BankPreRegisterBankAccountSabadell] ADD  DEFAULT ((0)) FOR [Deleted]
GO


