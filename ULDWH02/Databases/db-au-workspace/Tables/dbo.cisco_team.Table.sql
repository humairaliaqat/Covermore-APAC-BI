USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cisco_team]    Script Date: 24/02/2025 5:22:16 PM ******/
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
/****** Object:  Index [cidx_cisco_team]    Script Date: 24/02/2025 5:22:16 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_cisco_team] ON [dbo].[cisco_team]
(
	[teamid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
