USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ClaimsDashboardSummaryExtract]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaimsDashboardSummaryExtract](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Period] [date] NULL,
	[Category] [varchar](100) NULL,
	[Section] [varchar](100) NULL,
	[Claim Payments (First Closure)] [float] NULL,
	[Avg Claims (First Closure)] [float] NULL,
	[Claim Count (First Closure)] [float] NULL,
	[Claim Count (Reopen)] [float] NULL,
	[Reopen Rate] [float] NULL,
	[Claim Value] [float] NULL,
	[Avg Claim Value] [float] NULL,
	[Total Claim Payment] [float] NULL,
	[Cost per Claim] [float] NULL,
	[Cost to Process] [float] NULL,
	[Claim Count] [float] NULL,
	[Policy Count] [float] NULL,
	[Claims Attachment Rate] [float] NULL,
	[Sell Price] [float] NULL,
	[Loss Ratio] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:22:16 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[ClaimsDashboardSummaryExtract]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[ClaimsDashboardSummaryExtract]
(
	[Period] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
