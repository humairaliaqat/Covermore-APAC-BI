USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_PLAN_RESCHEDULE_REASONS_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_PLAN_RESCHEDULE_REASONS_aucm](
	[PRR_ID] [numeric](2, 0) NOT NULL,
	[PLANRESCHREASON] [nvarchar](120) NULL,
	[SORTORDER] [numeric](2, 0) NULL
) ON [PRIMARY]
GO
