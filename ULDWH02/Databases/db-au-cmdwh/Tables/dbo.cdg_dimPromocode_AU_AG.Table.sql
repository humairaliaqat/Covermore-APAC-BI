USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdg_dimPromocode_AU_AG]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimPromocode_AU_AG](
	[DimPromoCodeID] [int] NOT NULL,
	[Code] [nvarchar](20) NULL,
	[Type] [nvarchar](20) NULL,
	[CampaignID] [int] NOT NULL
) ON [PRIMARY]
GO
