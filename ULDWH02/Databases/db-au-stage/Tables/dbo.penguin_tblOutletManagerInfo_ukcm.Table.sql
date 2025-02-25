USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutletManagerInfo_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutletManagerInfo_ukcm](
	[OutletID] [int] NOT NULL,
	[BDMID] [int] NULL,
	[BDMCallFreqID] [int] NULL,
	[AcctManagerID] [int] NULL,
	[AcctMgrCallFreqID] [int] NULL,
	[AdminExecID] [int] NULL,
	[ExtID] [varchar](20) NULL,
	[ExtBDMID] [int] NULL,
	[SalesSegment] [nvarchar](50) NULL,
	[PotentialSales] [money] NULL,
	[SalesTierID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblOutletManagerInfo_ukcm_OutletID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblOutletManagerInfo_ukcm_OutletID] ON [dbo].[penguin_tblOutletManagerInfo_ukcm]
(
	[OutletID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
