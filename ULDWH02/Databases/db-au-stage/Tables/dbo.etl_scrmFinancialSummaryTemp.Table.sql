USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_scrmFinancialSummaryTemp]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_scrmFinancialSummaryTemp](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[Date] [datetime] NOT NULL,
	[PolicyCount] [int] NULL,
	[QuoteCount] [int] NULL,
	[GrossSales] [money] NULL,
	[Commission] [money] NULL
) ON [PRIMARY]
GO
