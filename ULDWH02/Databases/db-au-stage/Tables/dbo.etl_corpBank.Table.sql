USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpBank]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpBank](
	[CountryKey] [varchar](2) NOT NULL,
	[BankRecordKey] [varchar](10) NULL,
	[ClosingQuoteID] [varchar](10) NULL,
	[DaysPaidQuoteID] [varchar](10) NULL,
	[EMCQuoteID] [varchar](10) NULL,
	[LuggageQuoteID] [varchar](10) NULL,
	[BankRecord] [int] NOT NULL,
	[BankDate] [datetime] NULL,
	[AccountingDate] [datetime] NULL,
	[Account] [varchar](6) NULL,
	[ProductCode] [varchar](3) NULL,
	[AgencyCode] [varchar](7) NULL,
	[CompanyID] [int] NULL,
	[Gross] [money] NULL,
	[Commission] [money] NULL,
	[Adjustment] [money] NULL,
	[Refund] [money] NULL,
	[RefundCheque] [int] NULL,
	[Operator] [varchar](10) NULL,
	[Comments] [varchar](100) NULL,
	[MMBonus] [money] NULL
) ON [PRIMARY]
GO
