USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdg_DimCampaign_AU_AG]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_DimCampaign_AU_AG](
	[DimCampaignID] [int] NOT NULL,
	[CampaignName] [varchar](255) NOT NULL,
	[DefaultAffiliateCode] [varchar](255) NULL,
	[DefaultCultureCode] [varchar](10) NULL
) ON [PRIMARY]
GO
