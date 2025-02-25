USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penCustomer]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penCustomer](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[CustomerKey] [varchar](71) NULL,
	[DomainID] [int] NULL,
	[CustomerID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
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
	[MarketingConsent] [bit] NULL,
	[Gender] [nchar](1) NULL,
	[PIDType] [nvarchar](100) NULL,
	[PIDCode] [varchar](50) NULL,
	[PIDValue] [nvarchar](256) NULL,
	[DOBUTC] [datetime] NULL,
	[StateOfArrival] [varchar](100) NULL,
	[MemberTypeId] [int] NULL
) ON [PRIMARY]
GO
