USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_usrLDAPTeam]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_usrLDAPTeam](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [nvarchar](320) NULL,
	[TeamLeaderID] [nvarchar](320) NULL
) ON [PRIMARY]
GO
