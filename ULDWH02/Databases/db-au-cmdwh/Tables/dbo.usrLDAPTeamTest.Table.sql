USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrLDAPTeamTest]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrLDAPTeamTest](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [nvarchar](320) NULL,
	[TeamLeaderID] [nvarchar](320) NULL,
	[isActive] [bit] NULL,
	[UserName] [varchar](255) NULL,
	[TeamMember] [varchar](255) NULL,
	[Email] [varchar](255) NULL,
	[TLUserName] [varchar](255) NULL,
	[TeamLeader] [varchar](255) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[usrLDAPTeamTest] ADD  DEFAULT ((0)) FOR [isActive]
GO
