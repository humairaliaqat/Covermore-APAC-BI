USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpBank]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpBank](
	[CountryKey] [varchar](2) NOT NULL,
	[BankRecordKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
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
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpBank_BankRecordKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_corpBank_BankRecordKey] ON [dbo].[corpBank]
(
	[BankRecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_corpBank_BankDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpBank_BankDate] ON [dbo].[corpBank]
(
	[BankDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
