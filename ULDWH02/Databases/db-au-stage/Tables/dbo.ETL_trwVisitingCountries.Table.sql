USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwVisitingCountries]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwVisitingCountries](
	[VisitingCountryID] [numeric](18, 0) NULL,
	[Description] [varchar](500) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
