USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_frfunderpop_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_frfunderpop_audtc](
	[kfunderpopid] [int] NOT NULL,
	[kfunderid] [int] NOT NULL,
	[population] [int] NOT NULL,
	[popdate] [date] NOT NULL,
	[popnotes] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kfunderdeptid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
