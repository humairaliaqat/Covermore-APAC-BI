USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOnCxRateCardCommission_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOnCxRateCardCommission_uscm](
	[ID] [int] NOT NULL,
	[CxAdjustmentSetID] [int] NOT NULL,
	[ExcessID] [int] NOT NULL,
	[AgeBandID] [int] NOT NULL,
	[LeadTimeID] [int] NOT NULL,
	[Commission] [numeric](10, 9) NOT NULL,
	[AreaID] [int] NULL
) ON [PRIMARY]
GO
