USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[entCustomerDemography_BKP_20200320]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entCustomerDemography_BKP_20200320](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[RiskProfile] [varchar](50) NULL,
	[AgeGroup] [varchar](50) NULL,
	[ProductPreference] [varchar](50) NULL,
	[ChannelPreference] [varchar](50) NULL,
	[BrandAffiliation] [varchar](50) NULL,
	[TravelPattern] [varchar](50) NULL,
	[TravelGroup] [varchar](50) NULL,
	[DestinationGroup] [varchar](50) NULL,
	[LocationProfile] [varchar](50) NULL,
	[OwnershipProfile] [varchar](50) NULL,
	[SuburbRank] [decimal](4, 2) NULL,
	[UpdateBatchID] [bigint] NULL
) ON [PRIMARY]
GO
