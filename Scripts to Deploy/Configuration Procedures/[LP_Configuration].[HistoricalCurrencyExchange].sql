/****** Object:  Table [LP_Configuration].[HistoricalCurrencyExchange]    Script Date: 4/6/2020 3:47:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [LP_Configuration].[HistoricalCurrencyExchange](
	[idHistoricalCurrencyExchange] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1) NOT NULL,
	[idCurrencyExchange] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[ProcessDate] [LP_Common].[LP_A_OP_INSDATETIME] NOT NULL,
	[Timestamp] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[CurrencyBase] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[CurrencyTo] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[idCountry] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[Value] [LP_Common].[LP_F_DECIMAL] NULL,
	[Active] [LP_Common].[LP_A_ACTIVE] NOT NULL,
	[OP_InsDateTime] [LP_Common].[LP_A_OP_INSDATETIME] NOT NULL,
	[OP_UpdDateTime] [LP_Common].[LP_A_OP_UPDDATETIME] NOT NULL,
	[DB_InsDateTime] [LP_Common].[LP_A_DB_INSDATETIME] NOT NULL,
	[DB_UpdDateTime] [LP_Common].[LP_A_DB_UPDDATETIME] NOT NULL,
	[ActionType] [LP_Common].[LP_F_C1] NOT NULL
) ON [PRIMARY]
GO


