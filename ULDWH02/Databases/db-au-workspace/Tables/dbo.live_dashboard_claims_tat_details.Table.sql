USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_claims_tat_details]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_claims_tat_details](
	[WorkType] [nvarchar](100) NOT NULL,
	[Reference] [int] NULL,
	[CreationDate] [datetime] NOT NULL,
	[TICS Reference Date] [datetime] NULL,
	[AssignedUser] [nvarchar](445) NOT NULL,
	[TAT] [int] NULL
) ON [PRIMARY]
GO
