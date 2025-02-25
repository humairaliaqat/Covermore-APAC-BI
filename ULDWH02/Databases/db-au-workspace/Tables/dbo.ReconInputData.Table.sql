USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ReconInputData]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconInputData](
	[CountryKey] [varchar](10) NULL,
	[CompanyKey] [varchar](10) NULL,
	[Metric] [nvarchar](50) NULL,
	[SourceServer] [nvarchar](50) NULL,
	[SourceDataBase] [nvarchar](50) NULL,
	[SourceTable] [nvarchar](50) NULL,
	[DestinationServer] [nvarchar](50) NULL,
	[DestinationDataBase] [nvarchar](50) NULL,
	[DestinationTable] [nvarchar](50) NULL,
	[ColumnName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
