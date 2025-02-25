USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emlFolder_stg]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emlFolder_stg](
	[MailBox] [nvarchar](200) NULL,
	[FolderID] [nvarchar](300) NULL,
	[Name] [nvarchar](200) NULL,
	[ParentFolderID] [nvarchar](300) NULL,
	[FullPath] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
