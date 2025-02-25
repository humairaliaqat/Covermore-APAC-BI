USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_claims_closed]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_claims_closed](
	[CaseOfficer] [nvarchar](150) NULL,
	[Hour] [int] NULL,
	[TodayClosedCount] [float] NULL,
	[TodayReopenedCount] [float] NULL,
	[TodayNewCount] [float] NULL,
	[TodayNetClosedCount] [float] NULL,
	[YTDAvgClosedCount] [float] NULL,
	[YTDAvgReopenedCount] [float] NULL,
	[YTDAvgNewCount] [float] NULL,
	[YTDAvgNetClosedCount] [float] NULL
) ON [PRIMARY]
GO
