USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ews_folder_investigate]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ews_folder_investigate](
	[mailbox] [nvarchar](450) NULL,
	[id] [nvarchar](450) NULL,
	[name] [nvarchar](max) NULL,
	[parentid] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
