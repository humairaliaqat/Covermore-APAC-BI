USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[SalesDataExtract]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesDataExtract](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[TransactionType] [nvarchar](50) NULL,
	[Date] [datetime] NOT NULL,
	[Fiscal_Year] [int] NOT NULL,
	[CurFiscalYearStart] [datetime] NULL,
	[CurFiscalYearEnd] [datetime] NULL,
	[CurQuarterStart] [datetime] NULL,
	[CurQuarterEnd] [datetime] NULL,
	[CurMonthStart] [datetime] NULL,
	[CurMonthEnd] [datetime] NULL,
	[LastMonthStart] [datetime] NULL,
	[LastMonthEnd] [datetime] NULL,
	[LastFiscalYearStart] [datetime] NULL,
	[LYCurFiscalMonthStart] [datetime] NULL,
	[TotalBusinessDays] [int] NULL,
	[RemainingBusinessDays] [int] NULL,
	[CountryCode] [nvarchar](20) NOT NULL,
	[SuperGroupName] [nvarchar](255) NULL,
	[GroupName] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[LatestBDMName] [nvarchar](100) NULL,
	[FCArea] [nvarchar](50) NULL,
	[FCEGMNation] [nvarchar](50) NULL,
	[FCNation] [nvarchar](50) NULL,
	[Duration] [int] NOT NULL,
	[ABSDurationBand] [nvarchar](50) NULL,
	[AreaName] [nvarchar](100) NULL,
	[AreaNumber] [varchar](20) NULL,
	[AreaType] [nvarchar](50) NULL,
	[Continent] [nvarchar](100) NULL,
	[Destination] [nvarchar](50) NULL,
	[Age] [int] NOT NULL,
	[ABSAgeBand] [nvarchar](50) NULL,
	[ProductName] [nvarchar](100) NULL,
	[PolicyType] [nvarchar](50) NULL,
	[ProductClassification] [nvarchar](100) NULL,
	[PlanType] [nvarchar](50) NULL,
	[TripType] [nvarchar](50) NULL,
	[CancellationCover] [int] NULL,
	[ConsultantName] [nvarchar](100) NULL,
	[ConsultantType] [nvarchar](50) NULL,
	[FirstSellDate] [datetime] NULL,
	[ConsultantSK] [int] NOT NULL,
	[Premium] [float] NULL,
	[SellPrice] [float] NULL,
	[Commission] [float] NULL,
	[PolicyCount] [int] NULL,
	[EMCPolicy] [int] NOT NULL,
	[QuoteCount] [int] NOT NULL,
	[QuoteSessionCount] [int] NOT NULL,
	[TicketCount] [int] NULL,
	[InternationalTravellersCount] [int] NULL,
	[InternationalChargedAdultsCount] [int] NULL,
	[InternationalPolicyCount] [int] NULL,
	[DomesticPolicyCount] [int] NULL,
	[LeadTime] [int] NOT NULL,
	[Excess] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_SalesDataExtract_BIRowID]    Script Date: 24/02/2025 5:22:16 PM ******/
CREATE CLUSTERED INDEX [idx_SalesDataExtract_BIRowID] ON [dbo].[SalesDataExtract]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_SalesDataExtract_Date]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_SalesDataExtract_Date] ON [dbo].[SalesDataExtract]
(
	[Date] ASC,
	[CountryCode] ASC,
	[SuperGroupName] ASC,
	[TransactionType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
