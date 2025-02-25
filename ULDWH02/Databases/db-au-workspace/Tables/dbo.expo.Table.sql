USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[expo]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[expo](
	[States] [varchar](3) NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[OutletName] [nvarchar](50) NOT NULL,
	[BDMName] [nvarchar](101) NULL,
	[Date] [smalldatetime] NOT NULL,
	[ExpoPeriod] [varchar](3) NOT NULL,
	[ExpoQuoteCount] [int] NULL,
	[ExpoFlagQuoteCount] [int] NULL,
	[QuoteCount] [int] NULL,
	[SellPrice] [money] NULL,
	[PolicyCount] [int] NULL
) ON [PRIMARY]
GO
