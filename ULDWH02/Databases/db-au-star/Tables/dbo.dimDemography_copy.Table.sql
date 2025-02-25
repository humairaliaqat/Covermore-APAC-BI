USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimDemography_copy]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimDemography_copy](
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
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimDemography_PolicyKey]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimDemography_PolicyKey] ON [dbo].[dimDemography_copy]
(
	[PolicyKey] ASC
)
INCLUDE([DemographySK]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ccsi_dimDemography]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED COLUMNSTORE INDEX [ccsi_dimDemography] ON [dbo].[dimDemography_copy] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [PRIMARY]
GO
