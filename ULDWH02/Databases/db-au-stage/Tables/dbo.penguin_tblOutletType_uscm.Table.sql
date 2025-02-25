USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutletType_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutletType_uscm](
	[OutletTypeID] [int] NOT NULL,
	[OutletType] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblOutletType_uscm_OutletTypeID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblOutletType_uscm_OutletTypeID] ON [dbo].[penguin_tblOutletType_uscm]
(
	[OutletTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
