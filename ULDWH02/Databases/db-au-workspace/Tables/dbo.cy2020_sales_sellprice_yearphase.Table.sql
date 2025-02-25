USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cy2020_sales_sellprice_yearphase]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cy2020_sales_sellprice_yearphase](
	[AlphaCode] [nvarchar](255) NULL,
	[LastYearActualSellPrice] [float] NULL,
	[TargetSellPrice] [float] NULL
) ON [PRIMARY]
GO
