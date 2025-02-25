USE [db-au-stage]
GO
/****** Object:  Table [dbo].[temp_cte_src]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_cte_src](
	[DataSource] [varchar](50) NULL,
	[CountryKey] [varchar](50) NULL,
	[CompanyKey] [varchar](50) NULL,
	[BusinessUnitID] [int] NULL,
	[BusinessUnit] [varchar](50) NULL,
	[AlphaCode] [varchar](50) NULL,
	[OutletAlphaKey] [varchar](50) NULL,
	[QuoteCountSRC] [int] NULL,
	[QuoteSessionCountSRC] [int] NULL
) ON [PRIMARY]
GO
