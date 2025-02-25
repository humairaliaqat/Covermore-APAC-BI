USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[dimDemography_20200107]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimDemography_20200107](
	[DemographySK] [int] IDENTITY(1,1) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[CustomerID] [bigint] NULL,
	[RiskProfile] [varchar](50) NULL,
	[EmailDomain] [nvarchar](255) NULL,
	[AgeGroup] [varchar](50) NULL,
	[ProductPreference] [varchar](50) NULL,
	[ChannelPreference] [varchar](50) NULL,
	[BrandAffiliation] [varchar](50) NULL,
	[TravelPattern] [varchar](50) NULL,
	[TravelGroup] [varchar](50) NULL,
	[DestinationGroup] [varchar](50) NULL,
	[LocationProfile] [varchar](50) NULL,
	[OwnershipProfile] [varchar](50) NULL,
	[SuburbRank] [decimal](18, 0) NULL,
	[Suburb] [nvarchar](50) NULL,
	[PostCode] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[UpdateBatchID] [bigint] NULL,
	[PolicySK] [bigint] NULL
) ON [PRIMARY]
GO
