USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_attachment]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_attachment](
	[Work_id] [uniqueidentifier] NOT NULL,
	[Attachment_Id] [varchar](36) NOT NULL,
	[Library_Location] [nvarchar](200) NOT NULL,
	[DirName] [nvarchar](256) NOT NULL,
	[LeafName] [nvarchar](128) NOT NULL
) ON [PRIMARY]
GO
