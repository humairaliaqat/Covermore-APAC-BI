USE [db-au-log]
GO
/****** Object:  Table [dbo].[DWH_Recon]    Script Date: 24/02/2025 2:34:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DWH_Recon](
	[Layer] [varchar](50) NULL,
	[TargetTable] [varchar](50) NULL,
	[SourceTable] [varchar](50) NULL,
	[Dimension] [varchar](50) NULL,
	[DimensionValue] [varchar](50) NULL,
	[CountryKey] [varchar](50) NULL,
	[CompanyKey] [varchar](50) NULL,
	[PeriodCol] [varchar](50) NULL,
	[PeriodVal] [varchar](50) NULL,
	[Measurement] [varchar](50) NULL,
	[SourceValue] [numeric](16, 2) NULL,
	[TargetValue] [numeric](16, 2) NULL,
	[InsertDate] [date] NULL,
	[UpdateDate] [date] NULL,
	[isValid] [char](1) NULL
) ON [PRIMARY]
GO
