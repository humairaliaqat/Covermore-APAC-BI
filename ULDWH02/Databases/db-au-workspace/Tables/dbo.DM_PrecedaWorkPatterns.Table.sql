USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DM_PrecedaWorkPatterns]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_PrecedaWorkPatterns](
	[Code] [float] NULL,
	[WorkPatternDetail] [nvarchar](255) NULL,
	[PatternWeek] [float] NULL,
	[DayOfWeek] [float] NULL,
	[WorkHours] [float] NULL
) ON [PRIMARY]
GO
