USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_BO_ObjectHier]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_BO_ObjectHier](
	[ID] [varchar](255) NULL,
	[Name] [varchar](255) NULL,
	[Kind] [varchar](255) NULL,
	[Hierarchy] [varchar](max) NULL,
	[OrderNo] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
