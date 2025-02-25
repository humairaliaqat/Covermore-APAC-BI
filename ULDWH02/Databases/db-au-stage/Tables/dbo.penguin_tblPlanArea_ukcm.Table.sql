USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPlanArea_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPlanArea_ukcm](
	[PlanAreaID] [int] NOT NULL,
	[PlanID] [int] NOT NULL,
	[AreaID] [int] NOT NULL,
	[PlanCode] [nvarchar](50) NULL,
	[AMTUpsellAreaId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPlanArea_ukcm_PlanID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPlanArea_ukcm_PlanID] ON [dbo].[penguin_tblPlanArea_ukcm]
(
	[PlanID] ASC,
	[AreaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
