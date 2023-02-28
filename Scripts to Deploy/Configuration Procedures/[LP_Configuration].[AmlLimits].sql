CREATE TABLE [LP_Configuration].[AmlLimits](
	[idAmlLimits]		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1) NOT NULL,
	[BeneficiaryName]	[LP_Common].[LP_F_C150] NOT NULL,
	[DocumentId]		[LP_Common].[LP_F_C100] NULL,
	[Limit]				[LP_Common].[LP_F_DECIMAL],
	[DB_InsDate]		[LP_Common].[LP_A_OP_INSDATETIME] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [LP_Configuration].[AmlLimits] ADD  CONSTRAINT [DF_LP_Configuration_AmlLimits_DB_InsDate]  DEFAULT (getdate()) FOR [DB_InsDate]
GO


