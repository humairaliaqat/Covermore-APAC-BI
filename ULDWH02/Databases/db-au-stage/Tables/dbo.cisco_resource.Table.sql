USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cisco_resource]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisco_resource](
	[resourceid] [int] NOT NULL,
	[profileid] [int] NOT NULL,
	[resourceloginid] [varchar](50) NOT NULL,
	[resourcename] [varchar](50) NOT NULL,
	[resourcegroupid] [int] NULL,
	[resourcetype] [smallint] NOT NULL,
	[active] [bit] NOT NULL,
	[autoavail] [bit] NOT NULL,
	[extension] [varchar](50) NOT NULL,
	[orderinrg] [int] NULL,
	[dateinactive] [datetime2](7) NULL,
	[resourceskillmapid] [int] NOT NULL,
	[assignedteamid] [int] NOT NULL,
	[resourcefirstname] [varchar](50) NOT NULL,
	[resourcelastname] [varchar](50) NOT NULL,
	[resourcealias] [varchar](50) NULL
) ON [PRIMARY]
GO
