USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTC_PrecedaPublicHolidays]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_PrecedaPublicHolidays](
	[Level 1 Code] [float] NULL,
	[Date] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[Days] [float] NULL,
	[Level 2 Code] [nvarchar](255) NULL,
	[Level 2 Description] [nvarchar](255) NULL,
	[Level 1 Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
