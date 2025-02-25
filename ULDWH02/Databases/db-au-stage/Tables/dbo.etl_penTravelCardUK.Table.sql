USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penTravelCardUK]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penTravelCardUK](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[TravelCardKey] [varchar](41) NULL,
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
	[TransactionLocalDateTime] [datetime] NULL,
	[TransactionLocalDateTimeUTC] [datetime] NULL,
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
	[CreateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedDateTimeUTC] [datetime] NULL
) ON [PRIMARY]
GO
