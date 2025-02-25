USE [db-au-actuary]
GO
/****** Object:  Table [ws].[penPolicy]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[penPolicy](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[OutletSKey] [bigint] NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNoKey] [varchar](100) NULL,
	[PolicyID] [int] NOT NULL,
	[PolicyNumber] [varchar](50) NULL,
	[AlphaCode] [nvarchar](60) NULL,
	[IssueDate] [datetime] NOT NULL,
	[IssueDateNoTime] [datetime] NOT NULL,
	[CancelledDate] [datetime] NULL,
	[StatusCode] [int] NULL,
	[StatusDescription] [nvarchar](50) NULL,
	[Area] [nvarchar](100) NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[AffiliateReference] [nvarchar](200) NULL,
	[HowDidYouHear] [nvarchar](200) NULL,
	[AffiliateComments] [varchar](500) NULL,
	[GroupName] [nvarchar](100) NULL,
	[CompanyName] [nvarchar](100) NULL,
	[PolicyType] [nvarchar](50) NULL,
	[isCancellation] [bit] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductCode] [nvarchar](50) NULL,
	[ProductName] [nvarchar](50) NULL,
	[ProductDisplayName] [nvarchar](50) NULL,
	[UniquePlanID] [int] NOT NULL,
	[Excess] [money] NOT NULL,
	[AreaName] [nvarchar](100) NULL,
	[PolicyStart] [datetime] NOT NULL,
	[PolicyEnd] [datetime] NOT NULL,
	[DaysCovered] [int] NULL,
	[MaxDuration] [int] NULL,
	[PlanName] [nvarchar](50) NULL,
	[TripType] [nvarchar](50) NULL,
	[PlanID] [int] NULL,
	[PlanDisplayName] [nvarchar](100) NULL,
	[CancellationCover] [nvarchar](50) NULL,
	[TripCost] [nvarchar](50) NULL,
	[TripDuration] [int] NULL,
	[EmailConsent] [bit] NULL,
	[AreaType] [varchar](25) NULL,
	[PurchasePath] [nvarchar](50) NULL,
	[IsShowDiscount] [bit] NULL,
	[ExternalReference] [nvarchar](100) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[IssueDateUTC] [datetime] NULL,
	[IssueDateNoTimeUTC] [datetime] NULL,
	[AreaNumber] [varchar](20) NULL,
	[isTripsPolicy] [int] NULL,
	[ImportDate] [datetime] NULL,
	[PreviousPolicyNumber] [varchar](50) NULL,
	[CurrencyCode] [varchar](3) NULL,
	[CultureCode] [nvarchar](20) NULL,
	[AreaCode] [nvarchar](3) NULL,
	[TaxInvoiceNumber] [nvarchar](50) NULL,
	[MultiDestination] [nvarchar](max) NULL,
	[FinanceProductID] [int] NULL,
	[FinanceProductCode] [nvarchar](10) NULL,
	[FinanceProductName] [nvarchar](125) NULL,
	[InitialDepositDate] [date] NULL,
	[PlanCode] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_PolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_penPolicy_PolicyKey] ON [ws].[penPolicy]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_AlphaCode]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_AlphaCode] ON [ws].[penPolicy]
(
	[AlphaCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_ExternalReference]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_ExternalReference] ON [ws].[penPolicy]
(
	[ExternalReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicy_ImportDate]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_ImportDate] ON [ws].[penPolicy]
(
	[ImportDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_IssueDate]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_IssueDate] ON [ws].[penPolicy]
(
	[IssueDate] ASC,
	[StatusDescription] ASC
)
INCLUDE([OutletAlphaKey],[PolicyKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_OutletAlphaKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_OutletAlphaKey] ON [ws].[penPolicy]
(
	[OutletAlphaKey] ASC
)
INCLUDE([PolicyKey],[PolicyNumber],[AffiliateReference],[ProductCode],[ProductName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicy_OutletSKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_OutletSKey] ON [ws].[penPolicy]
(
	[OutletSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicy_PolicyID]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_PolicyID] ON [ws].[penPolicy]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_PolicyNoKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_PolicyNoKey] ON [ws].[penPolicy]
(
	[PolicyNoKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_PolicyNumber]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_PolicyNumber] ON [ws].[penPolicy]
(
	[PolicyNumber] ASC,
	[AlphaCode] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicy_TravelDates]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_TravelDates] ON [ws].[penPolicy]
(
	[TripStart] ASC,
	[TripEnd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
