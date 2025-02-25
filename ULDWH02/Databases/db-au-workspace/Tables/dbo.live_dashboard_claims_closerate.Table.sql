USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_claims_closerate]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_claims_closerate](
	[CloseDate] [date] NULL,
	[TeleFlag] [bit] NULL,
	[ClosedClaimCount] [int] NULL,
	[Closed1Week] [int] NULL,
	[Closed2Week] [int] NULL
) ON [PRIMARY]
GO
