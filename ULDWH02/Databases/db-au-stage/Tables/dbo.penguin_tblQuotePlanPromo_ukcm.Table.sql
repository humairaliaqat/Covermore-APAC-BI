USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblQuotePlanPromo_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblQuotePlanPromo_ukcm](
	[QuotePlanPromoID] [int] NOT NULL,
	[PromoID] [int] NOT NULL,
	[Discount] [numeric](10, 4) NOT NULL,
	[IsApplied] [bit] NOT NULL,
	[ApplyOrder] [smallint] NOT NULL,
	[QuotePlanID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblQuotePlanPromo_ukcm_QuotePlanID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblQuotePlanPromo_ukcm_QuotePlanID] ON [dbo].[penguin_tblQuotePlanPromo_ukcm]
(
	[QuotePlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
