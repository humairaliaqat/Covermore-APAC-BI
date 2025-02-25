USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrFCUSTargets]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrFCUSTargets](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Brand] [varchar](100) NULL,
	[AlphaCode] [varchar](50) NULL,
	[T3] [varchar](50) NULL,
	[TeamName] [varchar](100) NULL,
	[Region] [varchar](100) NULL,
	[Date] [datetime] NULL,
	[PremiumTarget] [money] NULL,
	[PolicyTarget] [decimal](18, 0) NULL,
	[ShopCount] [int] NULL,
	[BDM] [varchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ucidx_usrFCUSTargets]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ucidx_usrFCUSTargets] ON [dbo].[usrFCUSTargets]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
