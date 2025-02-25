USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutlet_OTC_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutlet_OTC_ukcm](
	[ID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[IsFixedAge] [bit] NOT NULL,
	[AdultAge] [int] NULL,
	[DefaultAccordionView] [int] NULL,
	[AgeSwitch] [bit] NOT NULL,
	[PromoCodeSwitch] [bit] NOT NULL,
	[HowDidYouHearSwitch] [bit] NOT NULL,
	[AffiliateRefSwitch] [bit] NOT NULL,
	[ReturnURL] [nvarchar](500) NULL,
	[AdjPricingSwitch] [bit] NOT NULL,
	[IsEmailCertificate] [bit] NOT NULL,
	[AgentSpecial] [int] NULL,
	[MinimumCommissionLevel] [numeric](18, 9) NULL,
	[ShowDiscount] [bit] NULL,
	[HideMaxTripDuration] [bit] NOT NULL,
	[RoundDiscountedSellPrice] [bit] NULL,
	[CommissionCapAgeThreshold] [int] NULL,
	[CommissionCapId] [int] NULL,
	[ChannelId] [int] NULL
) ON [PRIMARY]
GO
