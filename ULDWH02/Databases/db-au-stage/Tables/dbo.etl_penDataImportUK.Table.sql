USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penDataImportUK]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penDataImportUK](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[DataImportKey] [varchar](41) NULL,
	[ID] [int] NOT NULL,
	[SourceReference] [varchar](100) NOT NULL,
	[GroupCode] [varchar](50) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[JobID] [int] NOT NULL,
	[Status] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
