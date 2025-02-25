USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[RPT0728b_Traveller]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPT0728b_Traveller](
	[RowType] [varchar](20) NOT NULL,
	[CustomerID] [varchar](20) NULL,
	[QuoteID] [varchar](20) NULL,
	[PolicyTravellerID] [varchar](20) NULL,
	[PolicyID] [varchar](20) NULL,
	[Title] [varchar](100) NULL,
	[FirstName] [varchar](100) NULL,
	[LastName] [varchar](100) NULL,
	[DOB] [varchar](30) NULL,
	[Age] [varchar](10) NULL,
	[Gender] [varchar](10) NULL,
	[isAdult] [varchar](10) NULL,
	[AdultCharge] [varchar](10) NULL,
	[isPrimary] [varchar](10) NULL,
	[AddressLine1] [varchar](100) NULL,
	[AddressLine2] [varchar](100) NULL,
	[Suburb] [varchar](50) NULL,
	[Postcode] [varchar](50) NULL,
	[State] [varchar](100) NULL,
	[Country] [varchar](100) NULL,
	[HomePhone] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [varchar](255) NULL,
	[EMCReference] [varchar](100) NULL,
	[OptFurtherContact] [varchar](10) NULL,
	[MarketingConsent] [varchar](10) NULL,
	[hasEMC] [varchar](10) NULL,
	[IDKey] [varchar](50) NULL
) ON [PRIMARY]
GO
