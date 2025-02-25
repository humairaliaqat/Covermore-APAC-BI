USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimPromoCode_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimPromoCode_AU](
	[DimPromoCodeID] [int] NOT NULL,
	[Code] [varchar](20) NULL,
	[Type] [nvarchar](20) NULL,
	[CampaignID] [int] NOT NULL
) ON [PRIMARY]
GO
