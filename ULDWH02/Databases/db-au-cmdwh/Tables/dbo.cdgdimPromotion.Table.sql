USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgdimPromotion]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgdimPromotion](
	[dimPromoCodeListID] [int] NOT NULL,
	[PromoCode] [varchar](8000) NULL,
	[PromoType] [varchar](100) NULL
) ON [PRIMARY]
GO
