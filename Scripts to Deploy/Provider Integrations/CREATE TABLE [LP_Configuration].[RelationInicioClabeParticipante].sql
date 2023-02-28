USE [LocalPaymentPROD]
GO

/****** Object:  Table [LP_Configuration].[RelationInicioClabeParticipante]    Script Date: 6/2/2022 7:57:23 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LP_Configuration].[RelationInicioClabeParticipante]') AND type in (N'U'))
DROP TABLE [LP_Configuration].[RelationInicioClabeParticipante]
GO

/****** Object:  Table [LP_Configuration].[RelationInicioClabeParticipante]    Script Date: 6/2/2022 7:57:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [LP_Configuration].[RelationInicioClabeParticipante](
	[InicioClabe] [char](3) NOT NULL,
	[Participante] [char](10) NOT NULL,
	[Clabe] [varchar](50) NOT NULL
) ON [PRIMARY]
GO


