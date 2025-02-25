USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_DimProduct_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_DimProduct_AU](
	[DimProductID] [int] NOT NULL,
	[ProductCode] [nvarchar](10) NOT NULL,
	[PlanCode] [nvarchar](10) NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[DestinationType] [nvarchar](20) NOT NULL,
	[TripFrequency] [char](1) NULL,
	[GroupType] [char](1) NOT NULL,
	[MinAdults] [tinyint] NOT NULL,
	[MaxAdults] [tinyint] NULL,
	[MinChildren] [tinyint] NULL,
	[MaxChildren] [tinyint] NULL,
	[MinAge] [tinyint] NULL,
	[MaxAge] [tinyint] NULL,
	[MinDuration] [smallint] NULL,
	[MaxDuration] [smallint] NULL
) ON [PRIMARY]
GO
