USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_claims_tat]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_claims_tat](
	[AssignedUser] [nvarchar](455) NULL,
	[WorkType] [nvarchar](100) NULL,
	[TAT] [int] NULL,
	[TATCount] [int] NULL
) ON [PRIMARY]
GO
