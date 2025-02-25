USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_DimRegion_AU_AG]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_DimRegion_AU_AG](
	[DimRegionID] [int] NOT NULL,
	[DestinationType] [varchar](2) NULL,
	[AreaCode] [nvarchar](20) NULL,
	[RiskRank] [int] NULL,
	[RegionName] [nvarchar](100) NULL
) ON [PRIMARY]
GO
