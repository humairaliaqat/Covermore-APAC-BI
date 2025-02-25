USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_NARCallActualTemp]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_NARCallActualTemp](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[SuperGroup] [nvarchar](25) NULL,
	[Group] [nvarchar](50) NOT NULL,
	[Territory] [nvarchar](50) NULL,
	[TerritoryManager] [varchar](33) NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[CRMCallKey] [varchar](41) NULL,
	[Category] [nvarchar](50) NOT NULL,
	[SubCategory] [nvarchar](50) NOT NULL,
	[AppointmentType] [varchar](25) NOT NULL,
	[Month] [smalldatetime] NULL,
	[BDM] [nvarchar](101) NULL,
	[Duration] [int] NULL
) ON [PRIMARY]
GO
