USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penTravelCardLog]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penTravelCardLog](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NULL,
	[TravelCardKey] [varchar](50) NOT NULL,
	[TransactionReferenceNumber] [varchar](50) NOT NULL,
	[RecordSequenceNumber] [varchar](8) NULL,
	[TransactionGroupDescription] [varchar](40) NULL,
	[CardNumber] [varchar](16) NULL,
	[CardholderFullName] [varchar](35) NULL,
	[ProgrammeIDAccountType] [varchar](3) NULL,
	[ProgramName] [varchar](40) NULL,
	[CustomerPostingDate] [datetime] NULL,
	[CustomerPostingDateUTC] [datetime] NULL,
	[LocalDateTime] [datetime] NULL,
	[LocalDateTimeUTC] [datetime] NULL,
	[TransactionBINCurrency] [varchar](15) NULL,
	[TransactionBINCurrencyAmount] [real] NULL,
	[TransactionLocalCurrency] [varchar](15) NULL,
	[TransactionAmountLocal] [real] NULL,
	[PurseCurrency] [varchar](3) NULL,
	[PurseAmount] [real] NULL,
	[TransactionCountry] [varchar](3) NULL,
	[TransactionDescription] [varchar](40) NULL,
	[MerchantTerminalId] [varchar](10) NULL,
	[MerchantID] [varchar](15) NULL,
	[MerchantName] [varchar](25) NULL,
	[MerchantAddressCity] [varchar](15) NULL,
	[MerchantAddressPostalCode] [varchar](10) NULL,
	[MerchantAddressRegion] [varchar](3) NULL,
	[MerchantAddressCountryCode] [varchar](3) NULL,
	[MerchantCategoryCode] [real] NULL,
	[Prel] [varchar](17) NULL,
	[BranchName] [varchar](20) NULL,
	[CrossBorderIndicator] [varchar](1) NULL,
	[POSEntryMode] [varchar](2) NULL,
	[IPSAccountNumber] [varchar](12) NULL,
	[CardholderEmail] [varchar](50) NULL,
	[AccountCreationDate] [datetime] NULL,
	[AccountCreationDateUTC] [datetime] NULL,
	[DOB] [datetime] NULL,
	[TransactionGroup] [varchar](3) NULL,
	[TransactionCode] [real] NULL,
	[AccountStatusChangeDate] [datetime] NULL,
	[AccountStatusChangeDateUTC] [datetime] NULL,
	[TransactionCodeDescription] [varchar](40) NULL,
	[Status] [varchar](20) NULL,
	[Comment] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penTravelCardLog_TravelCardKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penTravelCardLog_TravelCardKey] ON [dbo].[penTravelCardLog]
(
	[TravelCardKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penTravelCardLog_CompanyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penTravelCardLog_CompanyKey] ON [dbo].[penTravelCardLog]
(
	[CompanyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penTravelCardLog_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penTravelCardLog_CountryKey] ON [dbo].[penTravelCardLog]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
