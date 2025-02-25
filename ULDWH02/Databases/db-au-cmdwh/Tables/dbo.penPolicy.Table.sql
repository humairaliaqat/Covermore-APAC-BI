USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicy]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicy](
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
	[PlanCode] [nvarchar](50) NULL,
	[ExternalReference1] [varchar](255) NULL,
	[ExternalReference2] [nvarchar](225) NULL,
	[ExternalReference3] [varchar](250) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_PolicyKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE UNIQUE CLUSTERED INDEX [idx_penPolicy_PolicyKey] ON [dbo].[penPolicy]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_IssueDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_IssueDate] ON [dbo].[penPolicy]
(
	[IssueDate] ASC,
	[StatusDescription] ASC
)
INCLUDE([OutletAlphaKey],[PolicyKey],[CountryKey],[TripStart],[TripEnd],[TripDuration],[TripType],[PolicyNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_OutletAlphaKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_OutletAlphaKey] ON [dbo].[penPolicy]
(
	[OutletAlphaKey] ASC
)
INCLUDE([PolicyKey],[PolicyNumber],[AffiliateReference],[ProductCode],[ProductName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicy_PolicyID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_PolicyID] ON [dbo].[penPolicy]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_PolicyNumber]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_PolicyNumber] ON [dbo].[penPolicy]
(
	[PolicyNumber] ASC,
	[AlphaCode] ASC,
	[CountryKey] ASC
)
INCLUDE([PolicyKey],[CompanyKey],[AreaType],[AreaNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_PreviousPolicyNumber]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_PreviousPolicyNumber] ON [dbo].[penPolicy]
(
	[PreviousPolicyNumber] ASC,
	[CountryKey] ASC
)
INCLUDE([PolicyKey],[PolicyNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_PurchasePath]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_PurchasePath] ON [dbo].[penPolicy]
(
	[PolicyKey] ASC
)
INCLUDE([PurchasePath]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicy_TravelDates]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_TravelDates] ON [dbo].[penPolicy]
(
	[TripStart] ASC,
	[TripEnd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
