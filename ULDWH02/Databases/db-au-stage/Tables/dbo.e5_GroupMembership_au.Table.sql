USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_GroupMembership_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_GroupMembership_au](
	[SiteId] [uniqueidentifier] NOT NULL,
	[GroupId] [int] NOT NULL,
	[MemberId] [int] NOT NULL
) ON [PRIMARY]
GO
