USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAutoComments_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAutoComments_ukcm](
	[AutoCommentID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[AlphaCode] [nvarchar](50) NOT NULL,
	[CSRID] [int] NOT NULL,
	[AutoComments] [nvarchar](max) NOT NULL,
	[CommentDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
