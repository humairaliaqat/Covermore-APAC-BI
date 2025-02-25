USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[etl_penPolicy_testDestination_test]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicy_testDestination_test](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PolicyKey] [varchar](71) NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[Area] [nvarchar](100) NULL,
	[AreaCode] [nvarchar](3) NULL,
	[DestinationOrder] [bigint] NULL,
	[Destination] [nvarchar](max) NULL,
	[CountryAreaID] [int] NULL,
	[CountryID] [int] NULL,
	[AreaID] [int] NULL,
	[Weighting] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
