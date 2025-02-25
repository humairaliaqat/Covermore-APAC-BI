USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpTaxes]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpTaxes](
	[CountryKey] [varchar](2) NOT NULL,
	[TaxKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[ItemKey] [varchar](10) NULL,
	[TaxID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[ItemID] [int] NULL,
	[CreateDate] [datetime] NULL,
	[AccountingPeriod] [datetime] NULL,
	[ItemType] [varchar](50) NULL,
	[PropBal] [char](1) NULL,
	[DomPremIncGST] [money] NULL,
	[DomStamp] [money] NULL,
	[IntStamp] [money] NULL,
	[GSTGross] [money] NULL,
	[UWSaleExGST] [money] NULL,
	[GSTAgtComm] [money] NULL,
	[AgtCommExGST] [money] NULL,
	[GSTCMComm] [money] NULL,
	[CMCommExGST] [money] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpTaxes_QuoteKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_corpTaxes_QuoteKey] ON [dbo].[corpTaxes]
(
	[QuoteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_corpTaxes_AccountingPeriod]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpTaxes_AccountingPeriod] ON [dbo].[corpTaxes]
(
	[AccountingPeriod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpTaxes_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpTaxes_CountryKey] ON [dbo].[corpTaxes]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpTaxes_ItemKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpTaxes_ItemKey] ON [dbo].[corpTaxes]
(
	[ItemKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpTaxes_TaxKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpTaxes_TaxKey] ON [dbo].[corpTaxes]
(
	[TaxKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
