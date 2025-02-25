USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cisco_supervisor]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisco_supervisor](
	[recordid] [int] NOT NULL,
	[resourceloginid] [varchar](50) NOT NULL,
	[managedteamid] [int] NOT NULL,
	[profileid] [int] NOT NULL,
	[supervisortype] [smallint] NOT NULL,
	[active] [bit] NOT NULL,
	[dateinactive] [datetime2](7) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[cisco_supervisor]
(
	[resourceloginid] ASC
)
INCLUDE([active],[managedteamid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
