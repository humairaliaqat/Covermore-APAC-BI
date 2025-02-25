USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblEmcPenguinAreaMapping_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblEmcPenguinAreaMapping_UK](
	[AreaMappingID] [int] NOT NULL,
	[AreaName] [nvarchar](100) NULL,
	[HealixRegionID] [int] NULL,
	[CompID] [int] NULL,
	[AreaCode] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[Status] [varchar](50) NOT NULL,
	[SortOrder] [int] NULL
) ON [PRIMARY]
GO
