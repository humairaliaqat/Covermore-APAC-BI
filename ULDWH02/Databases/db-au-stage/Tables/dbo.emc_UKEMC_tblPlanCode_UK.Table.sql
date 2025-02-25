USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblPlanCode_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblPlanCode_UK](
	[PlanCodeId] [int] NOT NULL,
	[PolTypeId] [int] NOT NULL,
	[SingMultiId] [int] NOT NULL,
	[AreaId] [int] NOT NULL,
	[PlanCode] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO
