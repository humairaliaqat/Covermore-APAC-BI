USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_bank]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_bank](
	[CountryKey] [varchar](2) NOT NULL,
	[AgencyKey] [varchar](10) NULL,
	[BankRecordKey] [varchar](13) NULL,
	[RecordNo] [int] NOT NULL,
	[BankDate] [datetime] NULL,
	[AccountingDate] [datetime] NULL,
	[Account] [varchar](4) NULL,
	[Product] [varchar](3) NULL,
	[AgencyCode] [varchar](7) NULL,
	[Gross] [money] NULL,
	[Commission] [money] NULL,
	[Adjustment] [money] NULL,
	[Refund] [money] NULL,
	[RefundChq] [int] NULL,
	[Op] [varchar](2) NULL,
	[Comments] [varchar](100) NULL,
	[MMBonus] [money] NULL,
	[AdjTypeID] [smallint] NULL
) ON [PRIMARY]
GO
