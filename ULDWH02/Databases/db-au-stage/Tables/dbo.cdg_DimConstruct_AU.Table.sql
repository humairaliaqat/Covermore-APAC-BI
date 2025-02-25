USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_DimConstruct_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_DimConstruct_AU](
	[DimConstructID] [int] NOT NULL,
	[CampaignID] [int] NOT NULL,
	[ConstructName] [varchar](255) NOT NULL,
	[TripType] [varchar](10) NULL,
	[MinAdults] [int] NULL,
	[MaxAdults] [int] NULL,
	[MinChildren] [int] NULL,
	[MaxChildren] [int] NULL,
	[DestinationType] [varchar](2) NULL,
	[Priority] [tinyint] NULL,
	[CarRental] [int] NULL,
	[CheckedBags] [int] NULL,
	[BookedHotel] [int] NULL,
	[AdvancedPurchase] [int] NULL,
	[MemberLevel] [nvarchar](20) NULL,
	[PaidWithPoints] [int] NULL,
	[TravelClass] [nvarchar](20) NULL
) ON [PRIMARY]
GO
