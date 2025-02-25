USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutlet_ProductPlan_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutlet_ProductPlan_ukcm](
	[ID] [int] NOT NULL,
	[OutletProductID] [int] NOT NULL,
	[UniquePlanID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblOutlet_ProductPlan_ukcm_OutletProductID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblOutlet_ProductPlan_ukcm_OutletProductID] ON [dbo].[penguin_tblOutlet_ProductPlan_ukcm]
(
	[OutletProductID] ASC
)
INCLUDE([UniquePlanID],[ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
