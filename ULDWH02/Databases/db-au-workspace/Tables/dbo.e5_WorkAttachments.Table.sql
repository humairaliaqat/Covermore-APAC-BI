USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[e5_WorkAttachments]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_WorkAttachments](
	[Work_Id] [uniqueidentifier] NOT NULL,
	[Reference] [int] NULL,
	[Attachment_Id] [varchar](36) NOT NULL,
	[Library_Location] [nvarchar](200) NOT NULL,
	[DirName] [nvarchar](256) NOT NULL,
	[LeafName] [nvarchar](260) NOT NULL,
	[Extension] [nvarchar](260) NULL,
	[AttachmentType] [nvarchar](100) NULL,
	[TimeCreated] [datetime] NOT NULL,
	[TimeLastModified] [datetime] NOT NULL
) ON [PRIMARY]
GO
