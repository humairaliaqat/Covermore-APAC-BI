USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_QuoteCustomer]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_QuoteCustomer](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[QuoteCountryKey] [varchar](41) NULL,
	[QuoteID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[QuoteCustomerID] [int] NULL,
	[Title] [varchar](50) NULL,
	[FirstName] [varchar](100) NULL,
	[LastName] [varchar](100) NULL,
	[DOB] [datetime] NULL,
	[AddressStreet] [varchar](200) NULL,
	[AddressPostCode] [varchar](50) NULL,
	[AddressSuburb] [varchar](50) NULL,
	[AddressState] [varchar](50) NULL,
	[AddressCountry] [varchar](50) NULL,
	[HomePhone] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [varchar](255) NULL,
	[Age] [int] NULL,
	[IsPrimary] [bit] NULL,
	[PersonIsAdult] [bit] NULL,
	[HasEMC] [bit] NULL,
	[OptFurtherContact] [bit] NULL,
	[MemberNumber] [varchar](25) NULL
) ON [PRIMARY]
GO
