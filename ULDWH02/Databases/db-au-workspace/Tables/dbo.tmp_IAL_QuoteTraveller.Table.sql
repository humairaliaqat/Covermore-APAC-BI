USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_IAL_QuoteTraveller]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_IAL_QuoteTraveller](
	[CustomerID] [int] NULL,
	[QuoteID] [int] NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
	[Age] [int] NULL,
	[Gender] [nchar](2) NULL,
	[isAdult] [bit] NULL,
	[isPrimary] [bit] NULL,
	[MemberNumber] [nvarchar](25) NULL,
	[AddressLine1] [nvarchar](100) NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[Suburb] [nvarchar](50) NULL,
	[Postcode] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[HomePhone] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[hasEMC] [bit] NULL,
	[OptFurtherContact] [bit] NULL,
	[MarketingConsent] [bit] NULL
) ON [PRIMARY]
GO
