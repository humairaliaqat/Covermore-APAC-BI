USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPlanRateCard_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPlanRateCard_uscm](
	[RateCardId] [int] NOT NULL,
	[AreaId] [int] NOT NULL,
	[AgeBandID] [int] NOT NULL,
	[ExcessID] [int] NOT NULL,
	[DurationID] [int] NOT NULL,
	[RateCardSetID] [int] NOT NULL,
	[NetPremium] [money] NOT NULL
) ON [PRIMARY]
GO
