USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[KPDemo]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KPDemo](
	[JVDesc] [nvarchar](100) NULL,
	[PostingDate] [datetime] NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[PolicyNumber] [varchar](50) NULL,
	[SellPrice] [money] NULL,
	[PolicyCount] [int] NOT NULL,
	[ChargedAdultsCount] [int] NOT NULL,
	[CustomerID] [bigint] NULL,
	[CustomerName] [nvarchar](255) NULL,
	[Age] [int] NULL,
	[TravelGroup] [varchar](13) NULL,
	[AllCount] [int] NULL,
	[SingleParentCount] [int] NULL,
	[FamilyCount] [int] NULL,
	[AdultFamilyCount] [int] NULL,
	[CoupleCount] [int] NULL,
	[SingleCount] [int] NULL,
	[GroupCount] [int] NULL,
	[TravellersCount] [int] NULL,
	[FamilyCount2] [int] NULL,
	[AdultCount] [int] NULL,
	[Segment] [varchar](26) NULL
) ON [PRIMARY]
GO
