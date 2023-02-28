CREATE TABLE [LP_Log].[RejectedPayins](
	[idRejectedPayins] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1) NOT NULL,
	[idEntityUser] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[amount] [LP_Common].[LP_F_C150] NULL,
	[currency] [LP_Common].[LP_F_C150] NULL,
	[paymentMethodCode] [LP_Common].[LP_F_C150] NULL,
	[merchantId] [LP_Common].[LP_F_C150] NULL,
	[payerName] [LP_Common].[LP_F_C150] NULL,
	[payerDocument] [LP_Common].[LP_F_C150] NULL,
	[payerAccountNumber] [LP_Common].[LP_F_C150] NULL,
	[submerchantCode] [LP_Common].[LP_F_C150] NULL,
	[errors]				VARCHAR(MAX) NULL,
	[OP_InsDateTime] [LP_Common].[LP_A_OP_INSDATETIME] NOT NULL,
	[OP_UpdDateTime] [LP_Common].[LP_A_OP_UPDDATETIME] NOT NULL,
	[DB_InsDateTime] [LP_Common].[LP_A_DB_INSDATETIME] NOT NULL,
	[DB_UpdDateTime] [LP_Common].[LP_A_DB_UPDDATETIME] NOT NULL,
 CONSTRAINT [PK_RejectedPayins] PRIMARY KEY CLUSTERED 
(
	[idRejectedPayins] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [LP_Log].[RejectedPayins] ADD  CONSTRAINT [DF_RejectedPayins_OP_InsDateTime]  DEFAULT (getutcdate()) FOR [OP_InsDateTime]
GO

ALTER TABLE [LP_Log].[RejectedPayins] ADD  CONSTRAINT [DF_RejectedPayins_OP_UpdDateTime]  DEFAULT (getutcdate()) FOR [OP_UpdDateTime]
GO

ALTER TABLE [LP_Log].[RejectedPayins] ADD  CONSTRAINT [DF_RejectedPayins_DB_InsDateTime]  DEFAULT (getdate()) FOR [DB_InsDateTime]
GO

ALTER TABLE [LP_Log].[RejectedPayins] ADD  CONSTRAINT [DF_RejectedPayins_DB_UpdDateTime]  DEFAULT (getdate()) FOR [DB_UpdDateTime]
GO

ALTER TABLE [LP_Log].[RejectedPayins]  WITH CHECK ADD  CONSTRAINT [FK_RejectedPayins_EntityUser] FOREIGN KEY([idEntityUser])
REFERENCES [LP_Entity].[EntityUser] ([idEntityUser])
GO

ALTER TABLE [LP_Log].[RejectedPayins] CHECK CONSTRAINT [FK_RejectedPayins_EntityUser]
GO


