USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Temp_Bendigo]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temp_Bendigo](
	[Quote reference number] [int] NULL,
	[Reference number] [varchar](100) NULL,
	[Quote saved date] [datetime] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PolicyKey] [varchar](41) NULL,
	[QuoteCountryKey] [varchar](50) NULL,
	[AffiliateCode] [nvarchar](100) NULL
) ON [PRIMARY]
GO
