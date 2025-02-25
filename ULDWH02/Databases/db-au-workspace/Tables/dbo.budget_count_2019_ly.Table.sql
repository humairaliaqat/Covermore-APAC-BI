USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[budget_count_2019_ly]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[budget_count_2019_ly](
	[Country] [nvarchar](10) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[Date] [datetime] NOT NULL,
	[DW] [nvarchar](30) NULL,
	[Month] [date] NULL,
	[LYPolicyCount] [int] NULL
) ON [PRIMARY]
GO
