USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPolicyEMC]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicyEMC](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PolicyEMCKey] [varchar](71) NULL,
	[PolicyTravellerTransactionKey] [varchar](71) NULL,
	[EMCApplicationKey] [varchar](103) NULL,
	[DomainID] [int] NULL,
	[PolicyEMCID] [int] NOT NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[DOB] [datetime] NULL,
	[EMCRef] [varchar](100) NOT NULL,
	[EMCScore] [numeric](10, 4) NULL,
	[PremiumIncrease] [numeric](18, 5) NULL,
	[isPercentage] [bit] NULL,
	[AddOnID] [int] NULL
) ON [PRIMARY]
GO
