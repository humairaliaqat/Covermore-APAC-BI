USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutletSalesTargets_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutletSalesTargets_ukcm](
	[ID] [int] NOT NULL,
	[OutletId] [int] NOT NULL,
	[Month] [int] NULL,
	[GrossSellPriceTarget] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblOutletSalesTargets_ukcm_OutletID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblOutletSalesTargets_ukcm_OutletID] ON [dbo].[penguin_tblOutletSalesTargets_ukcm]
(
	[OutletId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
