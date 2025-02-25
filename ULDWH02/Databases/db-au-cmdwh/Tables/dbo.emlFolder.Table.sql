USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emlFolder]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emlFolder](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[MailBox] [nvarchar](200) NULL,
	[FolderID] [nvarchar](300) NULL,
	[Name] [nvarchar](200) NULL,
	[ParentFolderID] [nvarchar](300) NULL,
	[FullPath] [nvarchar](1000) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[emlFolder] ADD  DEFAULT ((-1)) FOR [CreateBatchID]
GO
ALTER TABLE [dbo].[emlFolder] ADD  DEFAULT (NULL) FOR [UpdateBatchID]
GO
