USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblEmcPenguinAreaMapping_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblEmcPenguinAreaMapping_AU](
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
/****** Object:  Index [idx_emc_EMC_tblEmcPenguinAreaMapping_AU_AreaMappingID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_emc_EMC_tblEmcPenguinAreaMapping_AU_AreaMappingID] ON [dbo].[emc_EMC_tblEmcPenguinAreaMapping_AU]
(
	[AreaMappingID] ASC
)
INCLUDE([AreaName],[AreaCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
