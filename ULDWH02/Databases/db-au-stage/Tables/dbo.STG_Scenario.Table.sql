USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Scenario]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Scenario](
	[Scenario_Code] [varchar](50) NOT NULL,
	[Scenario_Desc] [varchar](200) NULL,
	[Scenario_GL_Code] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
