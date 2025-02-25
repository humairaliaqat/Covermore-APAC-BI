USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impPolicy]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impPolicy](
	[BIRowID] [bigint] IDENTITY(0,1) NOT NULL,
	[PolicyIDKey] [nvarchar](50) NOT NULL,
	[id] [nvarchar](50) NULL,
	[QuoteIDKey] [nvarchar](50) NULL,
	[sessionID] [nvarchar](50) NULL,
	[businessUnitID] [int] NULL,
	[channelID] [int] NULL,
	[productID] [int] NULL,
	[issuedDate] [datetime] NULL,
	[policyNumber] [nvarchar](50) NULL,
	[consultant] [nvarchar](50) NULL,
	[affiliateCode] [nvarchar](50) NULL,
	[duration] [int] NULL,
	[tripCost] [money] NULL,
	[tripStartDate] [date] NULL,
	[tripEndDate] [date] NULL,
	[tripRegionID] [int] NULL,
	[tripPrimaryCountryCode] [nvarchar](50) NULL,
	[domain] [nvarchar](50) NULL,
	[culture] [nvarchar](50) NULL,
	[excess] [money] NULL,
	[sessionToken] [nvarchar](50) NULL,
	[seqNumberByDomain] [int] NULL,
	[totalGrossPremium] [money] NULL,
	[partnerTransactionID] [nvarchar](100) NULL,
	[totalAdjustedGrossPremium] [money] NULL,
	[optInMarketing] [bit] NULL,
	[paymentDate] [datetime] NULL,
	[paymentAmount] [money] NULL,
	[paymentType] [nvarchar](50) NULL,
	[paymentReferenceNumber] [nvarchar](100) NULL,
	[contactEmail] [nvarchar](100) NULL,
	[contactCity] [nvarchar](100) NULL,
	[contactState] [nvarchar](50) NULL,
	[contactSuburb] [nvarchar](50) NULL,
	[contactCountry] [nvarchar](50) NULL,
	[contactStreet1] [nvarchar](200) NULL,
	[contactStreet2] [nvarchar](200) NULL,
	[contactPostCode] [nvarchar](50) NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[PolicyKey] [nvarchar](50) NULL,
	[batchID] [int] NULL,
 CONSTRAINT [pk_impPolicy] PRIMARY KEY CLUSTERED 
(
	[PolicyIDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_impPolicy_businessUnitID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impPolicy_businessUnitID] ON [dbo].[impPolicy]
(
	[businessUnitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impPolicy_id]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impPolicy_id] ON [dbo].[impPolicy]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impPolicy_policyNumber]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impPolicy_policyNumber] ON [dbo].[impPolicy]
(
	[policyNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impPolicy_QuoteIDKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impPolicy_QuoteIDKey] ON [dbo].[impPolicy]
(
	[QuoteIDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impPolicy_sessionID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impPolicy_sessionID] ON [dbo].[impPolicy]
(
	[sessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
