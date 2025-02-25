USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penQuotePromo]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penQuotePromo](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PromoKey] [varchar](41) NULL,
	[QuoteCountryKey] [varchar](41) NULL,
	[QuoteID] [int] NULL,
	[PromoID] [int] NULL,
	[PromoCode] [varchar](20) NULL,
	[PromoName] [nvarchar](250) NULL,
	[PromoType] [nvarchar](50) NULL,
	[Discount] [numeric](10, 4) NULL,
	[IsApplied] [bit] NULL,
	[ApplyOrder] [int] NULL,
	[GoBelowNet] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penQuotePromo_QuoteCountryKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penQuotePromo_QuoteCountryKey] ON [dbo].[penQuotePromo]
(
	[QuoteCountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penQuotePromo_PromoCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penQuotePromo_PromoCode] ON [dbo].[penQuotePromo]
(
	[QuoteCountryKey] ASC,
	[PromoCode] ASC,
	[IsApplied] ASC
)
INCLUDE([PromoKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
