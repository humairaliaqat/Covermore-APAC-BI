USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Base_Job]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Base_Job](
	[Job_id] [varchar](32) NULL,
	[Job_num] [varchar](20) NULL,
	[id] [int] NOT NULL,
	[Pene_id] [varchar](34) NULL
) ON [PRIMARY]
GO
