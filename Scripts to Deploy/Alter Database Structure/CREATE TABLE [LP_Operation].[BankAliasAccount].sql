USE [LocalPaymentProd]
GO

/****** Object:  Table [LP_Operation].[BankPreRegisterBankAccountSabadell]    Script Date: 11/02/2021 08:06:19 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [LP_Operation].[BankAliasAccount](
	[idBankAliasAccount] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1) NOT NULL,
	[AccountNumber] [LP_Common].[LP_F_C40],
	[AccountAlias] [LP_Common].[LP_F_C40],
	[idBankCode] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
	[Deleted] [tinyint] NULL DEFAULT ((0)),
	[OP_InsDateTime] [LP_Common].[LP_A_OP_INSDATETIME] NOT NULL,
	[OP_UpdDateTime] [LP_Common].[LP_A_OP_UPDDATETIME] NOT NULL,
	[DB_InsDateTime] [LP_Common].[LP_A_DB_INSDATETIME] NOT NULL,
	[DB_UpdDateTime] [LP_Common].[LP_A_DB_UPDDATETIME] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idBankAliasAccount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [LP_Operation].[BankAliasAccount] ADD  CONSTRAINT [DF_RejectedPayins_OP_InsDateTime]  DEFAULT (getutcdate()) FOR [OP_InsDateTime]
GO

ALTER TABLE [LP_Operation].[BankAliasAccount] ADD  CONSTRAINT [DF_RejectedPayins_OP_UpdDateTime]  DEFAULT (getutcdate()) FOR [OP_UpdDateTime]
GO

ALTER TABLE [LP_Operation].[BankAliasAccount] ADD  CONSTRAINT [DF_RejectedPayins_DB_InsDateTime]  DEFAULT (getdate()) FOR [DB_InsDateTime]
GO

ALTER TABLE [LP_Operation].[BankAliasAccount] ADD  CONSTRAINT [DF_RejectedPayins_DB_UpdDateTime]  DEFAULT (getdate()) FOR [DB_UpdDateTime]
GO

GO