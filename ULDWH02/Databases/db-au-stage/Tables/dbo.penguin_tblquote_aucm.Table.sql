USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblquote_aucm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblquote_aucm](
	[QuoteID] [int] NOT NULL,
	[UniqueCustomerID] [nvarchar](255) NULL,
	[AlphaCode] [nvarchar](60) NOT NULL,
	[ShopName] [nvarchar](100) NULL,
	[ConsultantUserName] [nvarchar](100) NULL,
	[CRMUserName] [nvarchar](100) NULL,
	[QuoteDate] [datetime] NOT NULL,
	[PurchasePathType] [nvarchar](50) NOT NULL,
	[Area] [nvarchar](100) NOT NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[TripStart] [datetime] NOT NULL,
	[TripEnd] [datetime] NOT NULL,
	[NoOfTravellers] [int] NOT NULL,
	[IsFixedAge] [bit] NOT NULL,
	[AgeCalcFromDeparture] [bit] NOT NULL,
	[ChildCalculationRuleID] [int] NULL,
	[Legs] [varchar](8000) NULL,
	[PDFTemplate] [nvarchar](200) NULL,
	[IsExpo] [bit] NOT NULL,
	[IsAgentSpecial] [bit] NOT NULL,
	[PromoCode] [nvarchar](60) NULL,
	[IsCancellation] [bit] NOT NULL,
	[StoreCode] [varchar](10) NULL,
	[DomainId] [int] NOT NULL,
	[CurrencyCode] [varchar](3) NOT NULL,
	[PreviousPolicyNumber] [varchar](25) NULL,
	[CultureCode] [nvarchar](20) NULL,
	[AreaCode] [nvarchar](3) NULL,
	[ParentQuoteID] [int] NULL,
	[IsNoClaimBonus] [bit] NULL,
	[LeadTimeDate] [date] NULL,
	[IsResident] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblQuote_aucm_QuoteID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblQuote_aucm_QuoteID] ON [dbo].[penguin_tblquote_aucm]
(
	[QuoteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblQuote_aucm_DomainID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblQuote_aucm_DomainID] ON [dbo].[penguin_tblquote_aucm]
(
	[QuoteID] ASC
)
INCLUDE([DomainId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
