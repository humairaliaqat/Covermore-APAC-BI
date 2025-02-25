USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factPolicyTraveller_CHG0039677]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicyTraveller_CHG0039677](
	[DateSK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[TravellerSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[PolicySK] [int] NOT NULL,
	[AreaSK] [int] NOT NULL,
	[DestinationSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[AgeBandSK] [int] NOT NULL,
	[PolicyTransactionKey] [nvarchar](50) NULL,
	[TravellersCount] [int] NULL,
	[LoadDate] [datetime] NOT NULL,
	[LoadID] [int] NOT NULL,
	[updateDate] [datetime] NULL,
	[updateID] [int] NULL
) ON [PRIMARY]
GO
