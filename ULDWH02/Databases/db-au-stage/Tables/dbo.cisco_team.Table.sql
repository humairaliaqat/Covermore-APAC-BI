USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cisco_team]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisco_team](
	[teamid] [int] NOT NULL,
	[profileid] [int] NOT NULL,
	[teamname] [varchar](50) NOT NULL,
	[active] [bit] NOT NULL,
	[dateinactive] [datetime2](7) NULL
) ON [PRIMARY]
GO
