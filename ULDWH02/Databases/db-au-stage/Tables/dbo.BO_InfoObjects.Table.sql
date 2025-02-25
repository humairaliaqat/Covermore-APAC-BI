USE [db-au-stage]
GO
/****** Object:  Table [dbo].[BO_InfoObjects]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BO_InfoObjects](
	[ID] [varchar](255) NULL,
	[Name] [varchar](255) NULL,
	[Owner] [varchar](255) NULL,
	[Kind] [varchar](255) NULL,
	[Parent_ID] [varchar](255) NULL,
	[Cu_ID] [varchar](255) NULL,
	[Author] [varchar](255) NULL,
	[Create_Date] [datetime] NULL,
	[Update_Date] [datetime] NULL,
	[Load_Date] [datetime] NULL
) ON [PRIMARY]
GO
