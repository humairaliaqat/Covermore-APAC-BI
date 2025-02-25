USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[webi_objects]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webi_objects](
	[CUID] [nvarchar](255) NULL,
	[Id] [float] NULL,
	[Name] [nvarchar](255) NULL,
	[Kind] [nvarchar](255) NULL,
	[ParentFolder] [float] NULL,
	[FolderPath] [nvarchar](255) NULL
) ON [PRIMARY]
GO
