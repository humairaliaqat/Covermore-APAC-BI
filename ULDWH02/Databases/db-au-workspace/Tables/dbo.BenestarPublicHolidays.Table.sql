USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[BenestarPublicHolidays]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BenestarPublicHolidays](
	[Level 1 Code] [float] NULL,
	[Level 1 Description] [nvarchar](255) NULL,
	[Level 2 Code] [nvarchar](255) NULL,
	[Date] [datetime] NULL,
	[Days] [float] NULL,
	[Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
