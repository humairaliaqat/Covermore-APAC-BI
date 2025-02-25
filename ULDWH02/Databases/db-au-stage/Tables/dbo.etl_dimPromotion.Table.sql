USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_dimPromotion]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_dimPromotion](
	[Country] [nvarchar](20) NOT NULL,
	[PromotionKey] [varchar](41) NULL,
	[PromotionCode] [nvarchar](40) NULL,
	[PromotionName] [nvarchar](250) NULL,
	[PromotionType] [nvarchar](50) NULL,
	[LoadDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL
) ON [PRIMARY]
GO
