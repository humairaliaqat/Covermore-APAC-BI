USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[count_2020_daily_weight]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[count_2020_daily_weight](
	[DateSK] [int] NOT NULL,
	[Country] [nvarchar](10) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[ProductSK] [int] NULL,
	[Month] [date] NULL,
	[LYPolicyCount] [int] NULL,
	[LYPremium] [float] NULL,
	[Ratio] [numeric](31, 19) NULL,
	[DayWeight] [numeric](2, 1) NULL
) ON [PRIMARY]
GO
