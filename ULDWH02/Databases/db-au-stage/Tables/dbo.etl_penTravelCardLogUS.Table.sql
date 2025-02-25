USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penTravelCardLogUS]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penTravelCardLogUS](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[TravelCardKey] [varchar](41) NULL,
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
