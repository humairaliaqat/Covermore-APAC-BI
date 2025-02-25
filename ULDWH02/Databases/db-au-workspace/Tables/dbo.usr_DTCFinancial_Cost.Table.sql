USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_DTCFinancial_Cost]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_DTCFinancial_Cost](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [date] NULL,
	[FunderSK] [int] NULL,
	[AllocatedName] [nvarchar](100) NULL,
	[ServiceSK] [int] NULL,
	[ServiceEventActivitySK] [int] NULL,
	[Revenue] [money] NULL,
	[Cost] [money] NULL,
	[GLCompanyID] [int] NULL,
	[GLJournalID] [nvarchar](50) NULL,
	[GLSequenceID] [int] NULL,
	[GLJournalDesc] [varchar](100) NULL,
	[UserSK] [int] NULL,
	[Type] [nvarchar](30) NULL,
	[ServiceEventActivityID] [varchar](50) NULL,
	[GLAccountCode] [varchar](20) NULL,
	[NatAmount] [money] NULL,
	[CurrencyCode] [varchar](10) NULL,
	[VoucherNo] [varchar](16) NULL,
	[OriginalCost] [float] NULL,
	[AdjustmentDailyRate] [bit] NULL,
	[AUDExchangeRate] [float] NULL,
	[InvoiceID] [varchar](20) NULL,
	[BatchID] [varchar](20) NULL,
	[Company] [varchar](80) NULL
) ON [PRIMARY]
GO
