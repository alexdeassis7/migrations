USE [LocalPaymentPROD]
GO

/****** Object:  Table [LP_Configuration].[BankCode_Lookup]    Script Date: 30/6/2022 13:13:02 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [LP_Configuration].[BankCode_Lookup](
	[idBankCodeLookup] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1) NOT NULL,
	[BankCode] [LP_Common].[LP_F_CODE] NOT NULL,
	[CustomBankCode] VARCHAR(100),
	[idCountry] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[idProvider] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[Active] [LP_Common].[LP_A_ACTIVE] NOT NULL,
	[OP_InsDateTime] [LP_Common].[LP_A_OP_INSDATETIME] NOT NULL,
	[OP_UpdDateTime] [LP_Common].[LP_A_OP_UPDDATETIME] NOT NULL,
	[DB_InsDateTime] [LP_Common].[LP_A_DB_INSDATETIME] NOT NULL,
	[DB_UpdDateTime] [LP_Common].[LP_A_DB_UPDDATETIME] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idBankCodeLookup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [LP_Configuration].[BankCode_Lookup] ADD  DEFAULT ((1)) FOR [Active]
GO

ALTER TABLE [LP_Configuration].[BankCode_Lookup] ADD  DEFAULT (GETUTCDATE()) FOR [OP_InsDateTime]
GO

ALTER TABLE [LP_Configuration].[BankCode_Lookup] ADD  DEFAULT (GETUTCDATE()) FOR [OP_UpdDateTime]
GO

ALTER TABLE [LP_Configuration].[BankCode_Lookup] ADD  DEFAULT (GETDATE()) FOR [DB_InsDateTime]
GO

ALTER TABLE [LP_Configuration].[BankCode_Lookup] ADD  DEFAULT (GETDATE()) FOR [DB_UpdDateTime]
GO


ALTER TABLE [LP_Configuration].[BankCode_Lookup]  WITH CHECK ADD  CONSTRAINT [FK_LP_Configuration_BankCode_Lookup_Country] FOREIGN KEY([idCountry])
REFERENCES [LP_Location].[Country] ([idCountry])
GO

ALTER TABLE [LP_Configuration].[BankCode_Lookup] CHECK CONSTRAINT [FK_LP_Configuration_BankCode_Lookup_Country]
GO


