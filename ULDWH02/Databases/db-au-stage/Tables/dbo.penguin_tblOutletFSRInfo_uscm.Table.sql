USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutletFSRInfo_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutletFSRInfo_uscm](
	[OutletID] [int] NOT NULL,
	[FSRTypeID] [int] NULL,
	[FSGCategoryID] [int] NULL,
	[LegalEntityName] [varchar](100) NULL,
	[ASICNumber] [varchar](50) NULL,
	[ABN] [nvarchar](50) NULL,
	[ASICCheckDate] [datetime] NULL,
	[AgreementDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblOutletFSRInfo_uscm_OutletID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblOutletFSRInfo_uscm_OutletID] ON [dbo].[penguin_tblOutletFSRInfo_uscm]
(
	[OutletID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
