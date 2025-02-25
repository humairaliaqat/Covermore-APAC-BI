USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_DimCampaignConstructOffer_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_DimCampaignConstructOffer_AU](
	[DimCampaignConstructOfferID] [int] NOT NULL,
	[BusinessUnitID] [int] NOT NULL,
	[BusinessUnitName] [nvarchar](100) NOT NULL,
	[CampaignID] [int] NOT NULL,
	[CampaignName] [nvarchar](255) NOT NULL,
	[ConstructID] [int] NOT NULL,
	[ConstructName] [nvarchar](255) NOT NULL,
	[OfferID] [int] NOT NULL,
	[OfferName] [nvarchar](255) NOT NULL
) ON [PRIMARY]
GO
