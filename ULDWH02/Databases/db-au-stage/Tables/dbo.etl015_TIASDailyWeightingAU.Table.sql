USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl015_TIASDailyWeightingAU]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl015_TIASDailyWeightingAU](
	[Date] [datetime] NULL,
	[FL] [float] NULL,
	[Non-FL] [float] NULL
) ON [PRIMARY]
GO
