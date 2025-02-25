USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_QuoteEMC]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_QuoteEMC](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[QuoteCountryKey] [varchar](30) NULL,
	[QuoteID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[EMCScore] [numeric](10, 4) NULL,
	[PremiumIncrease] [numeric](10, 4) NULL,
	[IsPercentage] [bit] NULL,
	[EMCID] [int] NULL,
	[Condition] [varchar](50) NULL,
	[DeniedAccepted] [varchar](1) NULL
) ON [PRIMARY]
GO
