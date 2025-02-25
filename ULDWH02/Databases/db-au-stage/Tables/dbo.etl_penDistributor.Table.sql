USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penDistributor]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penDistributor](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[DistributorKey] [varchar](71) NULL,
	[Distributorid] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Urls] [nvarchar](2000) NOT NULL,
	[DistributorAPIKeys] [nvarchar](1000) NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[DomainId] [int] NOT NULL
) ON [PRIMARY]
GO
