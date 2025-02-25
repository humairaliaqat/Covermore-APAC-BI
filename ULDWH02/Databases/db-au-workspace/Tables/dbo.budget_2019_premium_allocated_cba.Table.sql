USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[budget_2019_premium_allocated_cba]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[budget_2019_premium_allocated_cba](
	[Country] [varchar](2) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[Product] [varchar](4) NOT NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[Date] [smalldatetime] NOT NULL,
	[DailyAllocatedBudget] [float] NULL
) ON [PRIMARY]
GO
