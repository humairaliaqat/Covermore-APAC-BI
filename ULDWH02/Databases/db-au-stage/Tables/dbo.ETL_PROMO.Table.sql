USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_PROMO]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_PROMO](
	[SessionID] [int] NOT NULL,
	[PromoCodeID] [int] NOT NULL,
	[PROMOCODE] [nvarchar](255) NULL,
	[PromoType] [nvarchar](20) NULL,
	[DiscountPercent] [nvarchar](255) NULL,
	[DollarDiscount] [nvarchar](255) NULL,
	[StartDate] [nvarchar](255) NULL,
	[EndDate] [nvarchar](255) NULL,
	[PointsAwarded] [nvarchar](255) NULL,
	[AccrualRate] [nvarchar](255) NULL,
	[ActivityDescriptionKey] [nvarchar](255) NULL,
	[BonusPoints] [nvarchar](255) NULL,
	[IsPointsAwardPromo] [nvarchar](255) NULL,
	[PolicyNumber] [nvarchar](40) NOT NULL,
	[PROMOCODE_Additional] [nvarchar](4000) NULL,
	[IsMember] [varchar](3) NOT NULL
) ON [PRIMARY]
GO
