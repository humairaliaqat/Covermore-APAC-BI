USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ImpPromocode]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImpPromocode](
	[SessionID] [varchar](250) NULL,
	[PromoCodeID] [varchar](250) NULL,
	[PROMOCODE] [varchar](250) NULL,
	[PromoType] [varchar](250) NULL,
	[DiscountPercent] [varchar](250) NULL,
	[DollarDiscount] [varchar](250) NULL,
	[StartDate] [varchar](250) NULL,
	[EndDate] [varchar](250) NULL,
	[PointsAwarded] [varchar](250) NULL,
	[AccrualRate] [varchar](250) NULL,
	[ActivityDescriptionKey] [varchar](250) NULL,
	[BonusPoints] [varchar](250) NULL,
	[IsPointsAwardPromo] [varchar](250) NULL,
	[PolicyNumber] [varchar](250) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[PROMOCODE_Additional] [varchar](500) NULL,
	[IsMember] [varchar](500) NULL
) ON [PRIMARY]
GO
