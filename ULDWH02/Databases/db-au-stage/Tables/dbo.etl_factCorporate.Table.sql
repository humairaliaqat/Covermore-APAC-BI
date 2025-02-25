USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factCorporate]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factCorporate](
	[DateSK] [int] NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[UnderwriterCode] [varchar](50) NULL,
	[AccountingPeriod] [date] NULL,
	[IssueDate] [date] NULL,
	[QuoteKey] [varchar](10) NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNumber] [int] NULL,
	[PolicyStartDate] [date] NULL,
	[PolicyExpiryDate] [date] NULL,
	[Excess] [money] NOT NULL,
	[Premium] [money] NULL,
	[SellPrice] [money] NULL,
	[PremiumSD] [money] NULL,
	[PremiumGST] [money] NULL,
	[Commission] [money] NULL,
	[CommissionGST] [money] NULL,
	[PolicyCount] [int] NULL,
	[QuoteCount] [int] NULL,
	[DepartureDateSK] [date] NULL,
	[ReturnDateSK] [date] NULL,
	[IssueDateSK] [date] NULL
) ON [PRIMARY]
GO
