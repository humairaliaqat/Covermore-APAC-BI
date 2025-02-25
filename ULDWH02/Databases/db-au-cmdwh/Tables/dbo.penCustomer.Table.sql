USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penCustomer]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penCustomer](
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
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penCustomer_CustomerKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_penCustomer_CustomerKey] ON [dbo].[penCustomer]
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
