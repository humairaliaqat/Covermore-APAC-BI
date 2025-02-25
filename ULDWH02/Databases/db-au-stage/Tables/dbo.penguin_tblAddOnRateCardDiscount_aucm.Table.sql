USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOnRateCardDiscount_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOnRateCardDiscount_aucm](
	[AddOnDiscID] [int] NOT NULL,
	[AdjustmentSetID] [int] NOT NULL,
	[AreaID] [int] NOT NULL,
	[AgeBandID] [int] NOT NULL,
	[DurationID] [int] NOT NULL,
	[Discount] [numeric](12, 9) NULL
) ON [PRIMARY]
GO
