USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Public_Policy_Setup_Lookup]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Public_Policy_Setup_Lookup](
	[uniquefunderid] [nvarchar](4000) NOT NULL,
	[uniquepublicpolicysetupid] [nvarchar](4000) NOT NULL,
	[kfunderid] [int] NOT NULL,
	[kpublicpolicyid] [int] NOT NULL
) ON [PRIMARY]
GO
