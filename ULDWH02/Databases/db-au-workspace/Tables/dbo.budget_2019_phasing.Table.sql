USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[budget_2019_phasing]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[budget_2019_phasing](
	[Country] [nvarchar](10) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[Date] [smalldatetime] NOT NULL,
	[DayWeight] [float] NULL
) ON [PRIMARY]
GO
