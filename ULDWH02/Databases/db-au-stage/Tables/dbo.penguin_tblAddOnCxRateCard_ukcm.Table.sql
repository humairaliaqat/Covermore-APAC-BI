USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOnCxRateCard_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOnCxRateCard_ukcm](
	[ID] [int] NOT NULL,
	[AddOnCxRateCardSetID] [int] NOT NULL,
	[AgeBandID] [int] NOT NULL,
	[LeadTimeID] [int] NOT NULL,
	[ExcessID] [int] NOT NULL,
	[Premium] [numeric](10, 5) NOT NULL,
	[AreaID] [int] NULL
) ON [PRIMARY]
GO
