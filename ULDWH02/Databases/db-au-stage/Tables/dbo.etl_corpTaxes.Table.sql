USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpTaxes]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpTaxes](
	[CountryKey] [varchar](2) NOT NULL,
	[TaxKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[ItemKey] [varchar](10) NULL,
	[TaxID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[ItemID] [int] NULL,
	[CreateDate] [datetime] NULL,
	[AccountingPeriod] [datetime] NULL,
	[ItemType] [varchar](50) NULL,
	[PropBal] [char](1) NULL,
	[DomPremIncGST] [money] NULL,
	[DomStamp] [money] NULL,
	[IntStamp] [money] NULL,
	[GSTGross] [numeric](38, 6) NULL,
	[UWSaleExGST] [numeric](38, 6) NULL,
	[GSTAgtComm] [numeric](38, 6) NULL,
	[AgtCommExGST] [money] NULL,
	[GSTCMComm] [money] NULL,
	[CMCommExGST] [money] NULL
) ON [PRIMARY]
GO
