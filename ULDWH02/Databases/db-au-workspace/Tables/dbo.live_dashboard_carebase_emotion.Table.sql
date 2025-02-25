USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_carebase_emotion]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_carebase_emotion](
	[Emotion] [nvarchar](100) NULL,
	[Age] [varchar](50) NULL,
	[CaseCount] [int] NULL
) ON [PRIMARY]
GO
