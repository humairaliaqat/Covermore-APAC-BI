USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_DimOffer_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_DimOffer_AU](
	[DimOfferID] [int] NOT NULL,
	[OfferName] [varchar](255) NOT NULL,
	[Enabled] [bit] NULL,
	[Excess] [smallint] NULL,
	[ProductID] [int] NOT NULL,
	[IsMultiOffer] [int] NOT NULL
) ON [PRIMARY]
GO
