USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPolicyImport]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicyImport](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PolicyImportKey] [varchar](41) NULL,
	[DataImportKey] [varchar](41) NULL,
	[ID] [int] NOT NULL,
	[DataImportID] [int] NOT NULL,
	[PolicyXML] [xml] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Status] [varchar](15) NOT NULL,
	[PolicyStatus] [varchar](15) NULL,
	[PolicyID] [int] NULL,
	[RowID] [int] NOT NULL,
	[PolicyNumber] [varchar](25) NULL,
	[ParentID] [int] NULL,
	[BusinessUnit] [nvarchar](50) NULL,
	[UnAdjustedTotal] [money] NULL,
	[AdjustedTotal] [money] NULL,
	[PenguinUnAdjustedTotal] [money] NULL,
	[RowIDPolicyNumber] [varchar](61) NULL,
	[Comment] [nvarchar](1000) NULL,
	[Agent] [nvarchar](2000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
