USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usr_EWSMailboxes]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_EWSMailboxes](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[MailboxName] [varchar](100) NULL,
	[mailbox] [varchar](450) NOT NULL,
	[FolderTable] [varchar](100) NOT NULL,
	[EmailTable] [varchar](100) NOT NULL,
	[ProcessArchive] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_useEWSMailboxes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
