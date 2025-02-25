USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[PenPolicyEMC_BKP20200520_ASP150]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PenPolicyEMC_BKP20200520_ASP150](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyEMCKey] [varchar](41) NULL,
	[PolicyTravellerTransactionKey] [varchar](41) NULL,
	[PolicyEMCID] [int] NOT NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NOT NULL,
	[EMCRef] [varchar](100) NOT NULL,
	[EMCScore] [numeric](10, 4) NULL,
	[PremiumIncrease] [numeric](18, 5) NULL,
	[isPercentage] [bit] NULL,
	[AddOnID] [int] NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[EMCApplicationKey] [varchar](41) NULL
) ON [PRIMARY]
GO
