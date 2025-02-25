USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cy2020_sales_sellprice_monthphase]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cy2020_sales_sellprice_monthphase](
	[AlphaCode] [nvarchar](255) NULL,
	[LastYearActualSellPrice] [float] NULL,
	[TargetSellPrice] [float] NULL,
	[Jan20] [float] NULL,
	[Feb20] [float] NULL,
	[Mar20] [float] NULL,
	[Apr20] [float] NULL,
	[May20] [float] NULL,
	[Jun20] [float] NULL,
	[Jul20] [float] NULL,
	[Aug20] [float] NULL,
	[Sep20] [float] NULL,
	[Oct20] [float] NULL,
	[Nov20] [float] NULL,
	[Dec20] [float] NULL,
	[F16] [nvarchar](255) NULL,
	[F17] [nvarchar](255) NULL,
	[F18] [nvarchar](255) NULL,
	[F19] [nvarchar](255) NULL
) ON [PRIMARY]
GO
