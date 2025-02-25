USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrCardVolume]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrCardVolume](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Bank] [varchar](50) NULL,
	[CC Type] [varchar](250) NULL,
	[CC Group] [varchar](250) NULL,
	[Reference Date] [date] NULL,
	[Card Volume] [int] NULL,
	[ITI] [decimal](10, 2) NULL,
	[EW] [decimal](10, 2) NULL,
	[PS] [decimal](10, 2) NULL,
	[GP] [decimal](10, 2) NULL,
	[TA] [decimal](10, 2) NULL,
	[STA] [decimal](10, 2) NULL,
	[IFI] [decimal](10, 2) NULL,
	[UT] [decimal](10, 2) NULL,
	[NAC Other] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [dbo].[usrCardVolume]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
