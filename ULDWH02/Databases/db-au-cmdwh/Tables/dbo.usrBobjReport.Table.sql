USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrBobjReport]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrBobjReport](
	[Object_Name] [varchar](255) NULL,
	[Owner] [varchar](255) NULL,
	[Folder] [varchar](255) NULL,
	[Type] [varchar](255) NULL,
	[Cu_ID] [varchar](255) NULL,
	[Author] [varchar](255) NULL,
	[Create_Date] [datetime] NULL,
	[Update_Date] [datetime] NULL,
	[Load_Date] [datetime] NULL
) ON [PRIMARY]
GO
