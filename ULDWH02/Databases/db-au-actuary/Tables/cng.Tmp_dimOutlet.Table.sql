USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_dimOutlet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_dimOutlet](
	[OutletSK] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](10) NOT NULL,
	[JV] [nvarchar](20) NULL,
	[JVDesc] [nvarchar](100) NULL,
	[Distributor] [nvarchar](255) NULL,
	[SuperGroupName] [nvarchar](255) NULL,
	[Channel] [nvarchar](100) NULL,
	[BDMName] [nvarchar](100) NULL,
	[LatestBDMName] [nvarchar](100) NULL,
	[NationalManager] [nvarchar](100) NULL,
	[TerritoryManager] [nvarchar](100) NULL,
	[DistributorManager] [nvarchar](100) NULL,
	[OutletKey] [nvarchar](50) NOT NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[OutletType] [nvarchar](50) NULL,
	[OutletName] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[TradingStatus] [nvarchar](50) NULL,
	[CommencementDate] [datetime] NULL,
	[CloseDate] [datetime] NULL,
	[PreviousAlphaCode] [nvarchar](20) NULL,
	[CloseReason] [nvarchar](50) NULL,
	[ContactName] [nvarchar](150) NULL,
	[ContactPhone] [nvarchar](50) NULL,
	[ContactFax] [nvarchar](50) NULL,
	[ContactEmail] [nvarchar](100) NULL,
	[ContactStreet] [nvarchar](100) NULL,
	[ContactSuburb] [nvarchar](50) NULL,
	[ContactPostCode] [nvarchar](50) NULL,
	[GroupName] [nvarchar](50) NULL,
	[GroupCode] [nvarchar](50) NULL,
	[GroupStartDate] [datetime] NULL,
	[GroupPhone] [nvarchar](50) NULL,
	[GroupFax] [nvarchar](50) NULL,
	[GroupEmail] [nvarchar](100) NULL,
	[GroupStreet] [nvarchar](100) NULL,
	[GroupSuburb] [nvarchar](50) NULL,
	[GroupPostCode] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[SubGroupCode] [nvarchar](50) NULL,
	[SubGroupStartDate] [datetime] NULL,
	[SubGroupPhone] [nvarchar](50) NULL,
	[SubGroupFax] [nvarchar](50) NULL,
	[SubGroupEmail] [nvarchar](100) NULL,
	[SubGroupStreet] [nvarchar](100) NULL,
	[SubGroupSuburb] [nvarchar](50) NULL,
	[SubGroupPostcode] [nvarchar](50) NULL,
	[PaymentType] [nvarchar](50) NULL,
	[FSRType] [nvarchar](50) NULL,
	[FSGCategory] [nvarchar](50) NULL,
	[LegalEntityName] [nvarchar](100) NULL,
	[ASICNumber] [nvarchar](50) NULL,
	[ABN] [nvarchar](50) NULL,
	[ASICCheckDate] [datetime] NULL,
	[AgreementDate] [datetime] NULL,
	[AdminExecutiveName] [nvarchar](150) NULL,
	[ExternalID] [nvarchar](50) NULL,
	[SalesSegment] [nvarchar](50) NULL,
	[SalesTier] [nvarchar](50) NULL,
	[Branch] [nvarchar](100) NULL,
	[FCEGMNation] [nvarchar](50) NULL,
	[FCNation] [nvarchar](50) NULL,
	[FCArea] [nvarchar](50) NULL,
	[StateSalesArea] [nvarchar](50) NULL,
	[isLatest] [nvarchar](1) NOT NULL,
	[ValidStartDate] [datetime] NOT NULL,
	[ValidEndDate] [datetime] NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[LatestOutletSK] [int] NULL,
	[AlphaLineage] [nvarchar](max) NULL,
	[SalesQuadrant] [nvarchar](255) NULL,
	[Quadrant] [nvarchar](255) NULL,
	[QuadrantPotential] [nvarchar](255) NULL,
	[DigitalStrategist] [nvarchar](255) NULL,
	[JVFix] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_dimOutlet_OutletSK]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_dimOutlet_OutletSK] ON [cng].[Tmp_dimOutlet]
(
	[OutletSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimOutlet_OutletKeyisLatest]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_dimOutlet_OutletKeyisLatest] ON [cng].[Tmp_dimOutlet]
(
	[OutletKey] ASC,
	[isLatest] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
