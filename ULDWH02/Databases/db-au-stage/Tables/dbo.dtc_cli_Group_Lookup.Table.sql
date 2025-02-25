USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Group_Lookup]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Group_Lookup](
	[uniquedepartmentid] [nvarchar](4000) NOT NULL,
	[uniquefunderid] [nvarchar](4000) NOT NULL,
	[kfunderid] [int] NOT NULL,
	[kfunderdeptid] [int] NOT NULL
) ON [PRIMARY]
GO
