USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimQuoteSource_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimQuoteSource_AU](
	[DimQuoteSourceID] [int] NOT NULL,
	[QuoteSource] [nvarchar](30) NOT NULL
) ON [PRIMARY]
GO
