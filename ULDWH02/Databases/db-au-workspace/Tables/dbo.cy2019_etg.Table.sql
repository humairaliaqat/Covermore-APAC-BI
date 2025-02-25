USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cy2019_etg]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cy2019_etg](
	[OutletAlphaKey] [varchar](50) NULL,
	[AlphaCode] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[LYSales] [decimal](18, 8) NULL,
	[LYPremium] [decimal](18, 8) NULL,
	[Target] [decimal](18, 8) NULL,
	[Budget] [decimal](18, 8) NULL
) ON [PRIMARY]
GO
