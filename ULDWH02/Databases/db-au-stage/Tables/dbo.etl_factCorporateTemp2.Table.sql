USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factCorporateTemp2]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factCorporateTemp2](
	[Date] [datetime] NULL,
	[Country] [varchar](2) NOT NULL,
	[AlphaCode] [varchar](7) NULL,
	[AccountingPeriod] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[DomainID] [int] NOT NULL,
	[QuoteKey] [varchar](10) NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNumber] [int] NULL,
	[PolicyStartDate] [datetime] NULL,
	[PolicyExpiryDate] [datetime] NULL,
	[Excess] [money] NOT NULL,
	[ProductKey] [varchar](41) NULL,
	[ProductCode] [varchar](3) NOT NULL,
	[ProductName] [varchar](9) NOT NULL,
	[UnderWriterSaleExGST] [money] NULL,
	[GSTGross] [money] NULL,
	[GSTCMCommission] [money] NULL,
	[AgentCommissionExGST] [money] NULL,
	[DomesticStampDuty] [money] NULL,
	[InternationalStampDuty] [money] NULL,
	[CMCommissionExGST] [money] NULL,
	[GSTAgentCommission] [money] NULL,
	[DomesticPremiumIncGST] [money] NULL,
	[DomesticSellPriceExGST] [money] NULL,
	[DomesticPremium] [money] NULL,
	[InternationalSellPrice] [money] NULL,
	[StampDuty] [money] NULL,
	[PolicyCount] [int] NULL,
	[QuoteCount] [int] NULL
) ON [PRIMARY]
GO
