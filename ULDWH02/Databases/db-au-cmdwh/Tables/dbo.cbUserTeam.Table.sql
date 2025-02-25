USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbUserTeam]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbUserTeam](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[UserKey] [nvarchar](35) NOT NULL,
	[UserID] [nvarchar](30) NOT NULL,
	[TeamID] [nvarchar](10) NULL,
	[UserName] [nvarchar](50) NULL,
	[TeamName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cbUserTeam_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cbUserTeam_BIRowID] ON [dbo].[cbUserTeam]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbUserTeam_UserKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbUserTeam_UserKey] ON [dbo].[cbUserTeam]
(
	[UserKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
