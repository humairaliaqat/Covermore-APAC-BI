USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Base_Group]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Base_Group](
	[Group_id] [varchar](32) NULL,
	[GroupName] [varchar](80) NULL,
	[id] [int] NOT NULL,
	[Pene_id] [varchar](35) NULL
) ON [PRIMARY]
GO
