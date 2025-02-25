USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblTravelCard_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblTravelCard_ukcm](
	[AccessTransactionReference] [varchar](50) NOT NULL,
	[DistributorCode] [varchar](17) NOT NULL,
	[BranchName] [varchar](20) NULL,
	[AccessCustomerId] [numeric](38, 0) NOT NULL,
	[EmailAddress] [varchar](50) NOT NULL,
	[AccountCreationDate] [varchar](10) NULL,
	[AccountStatusChangeDate] [varchar](10) NULL,
	[CardholderFullName] [varchar](35) NOT NULL,
	[CardNumber] [varchar](16) NOT NULL,
	[DateOfBirth] [varchar](10) NULL,
	[TransactionGroup] [varchar](3) NULL,
	[TransactionGroupDesc] [varchar](40) NULL,
	[TransactionCode] [real] NULL,
	[TransactionCodeDesc] [varchar](40) NULL,
	[ProgramAccountType] [varchar](3) NULL,
	[ProgramName] [varchar](40) NULL,
	[CustomerPostingDateTime] [varchar](19) NULL,
	[TransactionLocalDateTime] [datetime] NOT NULL,
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
	[ModifiedDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
