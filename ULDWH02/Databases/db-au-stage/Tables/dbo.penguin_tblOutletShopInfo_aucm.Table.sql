USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutletShopInfo_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutletShopInfo_aucm](
	[OutletID] [int] NOT NULL,
	[Branch] [nvarchar](60) NULL,
	[Website] [varchar](100) NULL,
	[EGMNationID] [int] NULL,
	[FCAreaID] [int] NULL,
	[STARegionID] [int] NULL,
	[StateSalesAreaId] [int] NOT NULL,
	[FCNationID] [int] NULL,
	[B2CAlphaCode] [nvarchar](20) NULL,
	[AgencyGradingId] [int] NULL,
	[SugarCRMID] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblOutletShopInfo_aucm_OutletID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblOutletShopInfo_aucm_OutletID] ON [dbo].[penguin_tblOutletShopInfo_aucm]
(
	[OutletID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
