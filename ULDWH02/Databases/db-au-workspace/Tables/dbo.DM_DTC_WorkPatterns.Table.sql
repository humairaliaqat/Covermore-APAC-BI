USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DM_DTC_WorkPatterns]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_DTC_WorkPatterns](
	[Pattern] [nvarchar](255) NULL,
	[PatternCode] [float] NULL,
	[Week] [float] NULL,
	[Sun] [float] NULL,
	[Mon] [float] NULL,
	[Tue] [float] NULL,
	[Wed] [float] NULL,
	[Thu] [float] NULL,
	[Fri] [float] NULL,
	[Sat] [float] NULL,
	[F11] [nvarchar](255) NULL
) ON [PRIMARY]
GO
