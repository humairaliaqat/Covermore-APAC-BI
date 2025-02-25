USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[budget_2019_premium_allocated]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[budget_2019_premium_allocated](
	[Country] [nvarchar](10) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[Product] [nvarchar](4000) NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[Date] [smalldatetime] NOT NULL,
	[DailyAllocatedBudget] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[budget_2019_premium_allocated]
(
	[OutletAlphaKey] ASC
)
INCLUDE([DailyAllocatedBudget]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
