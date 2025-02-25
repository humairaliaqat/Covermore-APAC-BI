USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penDataImport_20241003]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penDataImport_20241003](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[DataImportKey] [varchar](41) NULL,
	[ID] [int] NULL,
	[SourceReference] [varchar](100) NULL,
	[GroupCode] [varchar](50) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[JobID] [int] NULL,
	[Status] [varchar](50) NULL
) ON [PRIMARY]
GO
