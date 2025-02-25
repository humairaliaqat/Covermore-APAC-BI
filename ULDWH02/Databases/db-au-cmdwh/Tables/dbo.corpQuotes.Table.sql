USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpQuotes]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpQuotes](
	[CountryKey] [varchar](2) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[AgencyKey] [varchar](10) NULL,
	[CompanyKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[CountryPolicyKey] [varchar](13) NULL,
	[QuoteID] [int] NOT NULL,
	[QuoteDate] [datetime] NULL,
	[AgencyCode] [varchar](7) NULL,
	[CompanyID] [int] NULL,
	[QuoteType] [char](1) NULL,
	[isPolicy] [bit] NULL,
	[IssuedDate] [datetime] NULL,
	[PolicyNo] [int] NULL,
	[PolicyStartDate] [datetime] NULL,
	[PolicyExpiryDate] [datetime] NULL,
	[Excess] [money] NULL,
	[hasPreviousClaim] [bit] NULL,
	[hasCANX] [bit] NULL,
	[hasRefused] [bit] NULL,
	[RefusalDesc] [varchar](50) NULL,
	[CANXReasonDesc] [varchar](50) NULL,
	[PreviousPolicyNo] [int] NULL,
	[BDMID] [int] NULL,
	[DirectSalesExecutiveID] [int] NULL,
	[LeadTypeID] [int] NULL,
	[LeadTypeDesc] [varchar](50) NULL,
	[Operator] [varchar](10) NULL,
	[isGroupPolicy] [bit] NULL,
	[FreeDays] [int] NULL,
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[OutletKey] [varchar](33) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_corpQuote]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_corpQuote] ON [dbo].[corpQuotes]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpQuotes_AgencyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpQuotes_AgencyKey] ON [dbo].[corpQuotes]
(
	[AgencyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpQuotes_CountryPolicyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpQuotes_CountryPolicyKey] ON [dbo].[corpQuotes]
(
	[CountryPolicyKey] ASC,
	[IssuedDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpQuotes_OutletKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpQuotes_OutletKey] ON [dbo].[corpQuotes]
(
	[OutletKey] ASC,
	[QuoteKey] ASC,
	[QuoteDate] ASC,
	[isPolicy] ASC,
	[IssuedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpQuotes_PolicyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpQuotes_PolicyKey] ON [dbo].[corpQuotes]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_corpQuotes_QuoteDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpQuotes_QuoteDate] ON [dbo].[corpQuotes]
(
	[QuoteDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_corpQuotes_QuoteID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpQuotes_QuoteID] ON [dbo].[corpQuotes]
(
	[QuoteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpQuotes_QuoteKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpQuotes_QuoteKey] ON [dbo].[corpQuotes]
(
	[QuoteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
