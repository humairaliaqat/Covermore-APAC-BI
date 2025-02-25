USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impQuote_DECOMMISSIONED]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impQuote_DECOMMISSIONED](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[QuoteIDKey] [nvarchar](50) NULL,
	[id] [nvarchar](50) NULL,
	[tripCost] [money] NULL,
	[tripStartDate] [date] NULL,
	[tripEndDate] [date] NULL,
	[tripRegionID] [int] NULL,
	[excess] [money] NULL,
	[duration] [int] NULL,
	[regionID] [int] NULL,
	[regionName] [nvarchar](50) NULL,
	[regionSiteID] [int] NULL,
	[regionAreaCode] [nvarchar](50) NULL,
	[regionRiskRank] [int] NULL,
	[regionHealixCode] [int] NULL,
	[regionDestinationType] [nvarchar](50) NULL,
	[productID] [int] NULL,
	[policyPriceGross] [money] NULL,
	[policyPriceIsDiscount] [bit] NULL,
	[policyPriceDisplayPrice] [money] NULL,
	[token] [nvarchar](50) NULL,
	[issuerConsultant] [nvarchar](50) NULL,
	[issuerAffiliateCode] [nvarchar](50) NULL,
	[contactEmail] [nvarchar](50) NULL,
	[contactCity] [nvarchar](50) NULL,
	[contactState] [nvarchar](50) NULL,
	[contactCountry] [nvarchar](50) NULL,
	[contactStreet1] [nvarchar](50) NULL,
	[contactStreet2] [nvarchar](50) NULL,
	[contactPostCode] [nvarchar](50) NULL,
	[contactOptInMarketing] [bit] NULL,
	[culture] [nvarchar](50) NULL,
	[paymentDate] [datetime] NULL,
	[paymentAmount] [money] NULL,
	[paymentType] [nvarchar](50) NULL,
	[paymentReferenceNumber] [nvarchar](50) NULL,
	[isClosed] [bit] NULL,
	[channelID] [int] NULL,
	[quoteDate] [datetime] NULL,
	[campaignID] [int] NULL,
	[isPurchased] [bit] NULL,
	[businessUnitID] [int] NULL,
	[chargedRegionID] [int] NULL,
	[createdDateTime] [datetime] NULL,
	[memberPointsAccrualRate] [numeric](10, 5) NULL,
	[memberPointsAccrued] [int] NULL,
	[chargedCountryCode] [nvarchar](50) NULL,
	[lastTransactionTime] [datetime] NULL,
	[partnerTransactionID] [nvarchar](50) NULL,
	[transaction_time] [datetime] NOT NULL,
	[CreateBatchID] [int] NOT NULL,
 CONSTRAINT [pk_impQuote] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_impQuote_businessUnitID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impQuote_businessUnitID] ON [dbo].[impQuote_DECOMMISSIONED]
(
	[businessUnitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impQuote_id]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impQuote_id] ON [dbo].[impQuote_DECOMMISSIONED]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impQuote_QuoteIDKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impQuote_QuoteIDKey] ON [dbo].[impQuote_DECOMMISSIONED]
(
	[QuoteIDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impQuote_token]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impQuote_token] ON [dbo].[impQuote_DECOMMISSIONED]
(
	[token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
