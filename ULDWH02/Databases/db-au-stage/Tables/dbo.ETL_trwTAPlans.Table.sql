USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwTAPlans]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwTAPlans](
	[TAPlanID] [numeric](18, 0) NULL,
	[PlanName] [varchar](50) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
