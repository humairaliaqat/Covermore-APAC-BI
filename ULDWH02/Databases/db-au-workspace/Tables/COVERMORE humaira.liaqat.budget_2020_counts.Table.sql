USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\humaira.liaqat].[budget_2020_counts]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\humaira.liaqat].[budget_2020_counts](
	[Domain] [varchar](2) NULL,
	[JV] [nvarchar](3) NULL,
	[Channel] [varchar](19) NULL,
	[Product] [nvarchar](4000) NULL,
	[Month] [date] NULL,
	[PolicyCountTarget] [float] NULL
) ON [PRIMARY]
GO
