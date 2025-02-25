USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[bobjFolders]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bobjFolders](
	[ObjectID] [int] NOT NULL,
	[TopFolder] [varchar](8000) NULL,
	[Folder] [varchar](8000) NULL,
	[SubFolder1] [varchar](8000) NULL,
	[SubFolder2] [varchar](8000) NULL
) ON [PRIMARY]
GO
