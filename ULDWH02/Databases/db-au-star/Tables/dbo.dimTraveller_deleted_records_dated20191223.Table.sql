USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimTraveller_deleted_records_dated20191223]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimTraveller_deleted_records_dated20191223](
	[TravellerSK] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](10) NOT NULL,
	[TravellerKey] [nvarchar](50) NOT NULL,
	[PolicyKey] [nvarchar](50) NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[FullName] [nvarchar](200) NULL,
	[DOB] [datetime] NULL,
	[Age] [int] NULL,
	[isAdult] [bit] NULL,
	[AdultCharge] [numeric](18, 5) NULL,
	[isPrimary] [bit] NULL,
	[StreetAddress] [nvarchar](200) NULL,
	[PostCode] [nvarchar](50) NULL,
	[Suburb] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[AddressCountry] [nvarchar](100) NULL,
	[HomePhone] [nvarchar](50) NULL,
	[WorkPhone] [nvarchar](50) NULL,
	[MobilePhone] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[OptFurtherContact] [bit] NULL,
	[MemberNumber] [nvarchar](25) NULL,
	[EMCRef] [nvarchar](100) NULL,
	[EMCScore] [numeric](10, 4) NULL,
	[DisplayName] [nvarchar](100) NULL,
	[AssessmentType] [nvarchar](20) NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL
) ON [PRIMARY]
GO
