USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_dimArea]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_dimArea](
	[Country] [nvarchar](20) NOT NULL,
	[AreaName] [nvarchar](100) NULL,
	[AreaType] [varchar](50) NULL,
	[LoadDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL
) ON [PRIMARY]
GO
