USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimPromoCodeList_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimPromoCodeList_AU](
	[DimPromoCodeListID] [int] NOT NULL,
	[PromoCodeID1] [int] NOT NULL,
	[PromoCodeID2] [int] NULL,
	[PromoCodeID3] [int] NULL,
	[PromoCodeID4] [int] NULL,
	[PromoCodeID5] [int] NULL
) ON [PRIMARY]
GO
