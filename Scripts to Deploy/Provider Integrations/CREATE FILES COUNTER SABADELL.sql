USE [LocalPaymentProd]
GO

/****** Object:  Table [LP_Operation].[FileDowloadCount]    Script Date: 11/02/2021 08:08:58 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [LP_Operation].[FileDowloadCount](
	[idFileDowloadCount] [int] IDENTITY(1,1) NOT NULL,
	[Date] [varchar](8) NULL,
	[idProvider] [int] NULL,
	[operationType] [varchar](8) NULL,
PRIMARY KEY CLUSTERED 
(
	[idFileDowloadCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


