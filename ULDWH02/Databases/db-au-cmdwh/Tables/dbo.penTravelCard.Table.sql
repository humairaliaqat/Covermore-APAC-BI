USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penTravelCard]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penTravelCard](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NULL,
	[TravelCardKey] [varchar](50) NOT NULL,
	[AccessTransactionReference] [varchar](50) NOT NULL,
	[DistributorCode] [varchar](17) NOT NULL,
	[BranchName] [varchar](20) NULL,
	[AccessCustomerId] [numeric](38, 0) NOT NULL,
	[EmailAddress] [varchar](50) NOT NULL,
	[AccountCreationDate] [datetime] NULL,
	[AccountCreationDateUTC] [datetime] NULL,
	[AccountStatusChangeDate] [datetime] NULL,
	[AccountStatusChangeDateUTC] [datetime] NULL,
	[CardholderFullName] [varchar](35) NOT NULL,
	[CardNumber] [varchar](16) NOT NULL,
	[DateOfBirth] [datetime] NULL,
	[TransactionGroup] [varchar](3) NULL,
	[TransactionGroupDesc] [varchar](40) NULL,
	[TransactionCode] [real] NULL,
	[TransactionCodeDesc] [varchar](40) NULL,
	[ProgramAccountType] [varchar](3) NULL,
	[ProgramName] [varchar](40) NULL,
	[CustomerPostingDateTime] [datetime] NULL,
	[CustomerPostingDateTimeUTC] [datetime] NULL,
	[TransactionLocalDateTime] [datetime] NOT NULL,
	[TransactionLocalDateTimeUTC] [datetime] NOT NULL,
	[TransactionBINCurrency] [varchar](3) NULL,
	[TransactionBINCurrencyAmount] [numeric](38, 2) NULL,
	[TransactionCurrency] [varchar](3) NULL,
	[TransactionAmount] [real] NULL,
	[PurseCurrency] [varchar](3) NULL,
	[PurseAmount] [numeric](15, 2) NULL,
	[TransactionCountry] [varchar](3) NULL,
	[TransactionDesc] [varchar](40) NULL,
	[MerchantId] [varchar](15) NULL,
	[MerchantName] [varchar](25) NULL,
	[MerchantAddressCity] [varchar](15) NULL,
	[MerchantAddressPostcode] [varchar](10) NULL,
	[MerchantAddressRegion] [varchar](3) NULL,
	[MerchantAddressCountryCode] [varchar](3) NULL,
	[MerchantCategoryCode] [numeric](38, 0) NULL,
	[CrossBorderIndicator] [varchar](1) NULL,
	[POSEntryMode] [varchar](2) NULL,
	[DomainCode] [varchar](2) NULL,
	[CompanyCode] [varchar](5) NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[CreateDateTimeUTC] [datetime] NOT NULL,
	[ModifiedDateTime] [datetime] NOT NULL,
	[ModifiedDateTimeUTC] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penTravelCard_TravelCardKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penTravelCard_TravelCardKey] ON [dbo].[penTravelCard]
(
	[TravelCardKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penTravelCard_CompanyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penTravelCard_CompanyKey] ON [dbo].[penTravelCard]
(
	[CompanyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penTravelCard_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penTravelCard_CountryKey] ON [dbo].[penTravelCard]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penTravelCard_ModifiedDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penTravelCard_ModifiedDateTime] ON [dbo].[penTravelCard]
(
	[ModifiedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
