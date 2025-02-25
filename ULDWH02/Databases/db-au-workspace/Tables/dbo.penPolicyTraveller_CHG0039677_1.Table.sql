USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[penPolicyTraveller_CHG0039677_1]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTraveller_CHG0039677_1](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyTravellerKey] [varchar](41) NULL,
	[PolicyKey] [varchar](41) NULL,
	[QuoteCustomerKey] [varchar](41) NULL,
	[PolicyTravellerID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[QuoteCustomerID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
	[Age] [int] NULL,
	[isAdult] [bit] NULL,
	[AdultCharge] [numeric](18, 5) NULL,
	[isPrimary] [bit] NULL,
	[AddressLine1] [nvarchar](100) NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[PostCode] [nvarchar](50) NULL,
	[Suburb] [nvarchar](50) NULL,
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
	[EMCRef] [varchar](100) NULL,
	[EMCScore] [numeric](10, 4) NULL,
	[DisplayName] [nvarchar](100) NULL,
	[AssessmentType] [varchar](20) NULL,
	[EmcCoverLimit] [numeric](18, 2) NULL,
	[MarketingConsent] [bit] NULL,
	[Gender] [nchar](2) NULL,
	[PIDType] [nvarchar](100) NULL,
	[PIDCode] [nvarchar](50) NULL,
	[PIDValue] [nvarchar](256) NULL,
	[MemberRewardPointsEarned] [money] NULL,
	[StateOfArrival] [varchar](100) NULL,
	[MemberTypeId] [int] NULL,
	[TicketType] [nvarchar](50) NULL,
	[VelocityNumber] [nvarchar](50) NULL,
	[GAID] [varchar](500) NULL,
	[FullAddress] [varchar](1500) NULL
) ON [PRIMARY]
GO
