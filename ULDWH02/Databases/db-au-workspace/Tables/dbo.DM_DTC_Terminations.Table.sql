USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DM_DTC_Terminations]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_DTC_Terminations](
	[Status] [nvarchar](255) NULL,
	[ID Number] [float] NULL,
	[Level 1] [float] NULL,
	[Full Name] [nvarchar](255) NULL,
	[Gender] [nvarchar](255) NULL,
	[Full Title] [nvarchar](255) NULL,
	[Employment Type Desc] [nvarchar](255) NULL,
	[Personnel Type Desc] [nvarchar](255) NULL,
	[Base Hours Amount] [float] NULL,
	[Term Date] [datetime] NULL,
	[Org Lvl 2 Title] [nvarchar](255) NULL,
	[Org Unit 3] [float] NULL,
	[Department Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
