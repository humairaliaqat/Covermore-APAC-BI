USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penCustomer_Temp]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penCustomer_Temp](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[CustomerKey] [varchar](41) NULL,
	[CustomerID] [int] NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOBUTC] [datetime] NULL,
	[AddressLine1] [nvarchar](100) NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[PostCode] [nvarchar](50) NULL,
	[Town] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[HomePhone] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[OptFurtherContact] [bit] NULL,
	[MemberNumber] [nvarchar](25) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[MarketingConsent] [bit] NULL,
	[Gender] [nchar](2) NULL,
	[PIDType] [nvarchar](100) NULL,
	[PIDCode] [nvarchar](50) NULL,
	[PIDValue] [nvarchar](256) NULL,
	[DOB] [datetime] NULL,
	[StateOfArrival] [varchar](100) NULL,
	[MemberTypeId] [int] NULL
) ON [PRIMARY]
GO
