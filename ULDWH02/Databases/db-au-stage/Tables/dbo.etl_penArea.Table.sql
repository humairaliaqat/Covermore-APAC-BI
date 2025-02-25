USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penArea]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penArea](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[AreaKey] [varchar](71) NULL,
	[AreaID] [int] NOT NULL,
	[DomainID] [int] NULL,
	[AreaName] [nvarchar](100) NOT NULL,
	[Domestic] [bit] NOT NULL,
	[MinimumDuration] [numeric](5, 4) NOT NULL,
	[ChildAreaID] [int] NULL,
	[AreaGroup] [int] NULL,
	[NonResident] [bit] NULL,
	[Weighting] [int] NULL,
	[AreaType] [varchar](18) NOT NULL,
	[AreaNumber] [varchar](35) NULL,
	[AreaSetID] [int] NULL,
	[AreaCode] [nvarchar](3) NOT NULL
) ON [PRIMARY]
GO
