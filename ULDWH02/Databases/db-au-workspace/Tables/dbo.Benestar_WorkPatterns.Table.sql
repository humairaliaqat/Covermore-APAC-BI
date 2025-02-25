USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_WorkPatterns]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_WorkPatterns](
	[Code] [float] NULL,
	[Work Patter Detail] [nvarchar](255) NULL,
	[Period of Work Pattern - in Weeks] [float] NULL,
	[Day of the Week] [float] NULL,
	[Work Hours] [float] NULL
) ON [PRIMARY]
GO
