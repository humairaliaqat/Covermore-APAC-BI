USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimMultiOffer_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimMultiOffer_AU](
	[DimMultiOfferID] [int] NOT NULL,
	[ChildOffer1ID] [int] NOT NULL,
	[ChildOffer2ID] [int] NOT NULL,
	[ChildOffer3ID] [int] NOT NULL,
	[ChildOffer4ID] [int] NOT NULL,
	[ChildOffer5ID] [int] NOT NULL
) ON [PRIMARY]
GO
