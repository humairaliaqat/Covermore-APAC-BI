USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_carebase]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_carebase](
	[ClientName] [nvarchar](100) NULL,
	[Country] [nvarchar](max) NULL,
	[TotalActiveCases] [int] NULL,
	[ActiveHighRisk] [int] NULL,
	[ActiveMediumRisk] [int] NULL,
	[ActiveLowRisk] [int] NULL,
	[ActiveEVAC] [int] NULL,
	[ActiveDeath] [int] NULL,
	[OpenedToday] [int] NULL,
	[EVACToday] [int] NULL,
	[HighRiskToday] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
