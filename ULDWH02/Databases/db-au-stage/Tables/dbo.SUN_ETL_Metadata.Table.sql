USE [db-au-stage]
GO
/****** Object:  Table [dbo].[SUN_ETL_Metadata]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SUN_ETL_Metadata](
	[BusinessUnit] [char](3) NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[ScenarioType] [char](1) NULL,
	[StructureType] [varchar](20) NOT NULL
) ON [PRIMARY]
GO
