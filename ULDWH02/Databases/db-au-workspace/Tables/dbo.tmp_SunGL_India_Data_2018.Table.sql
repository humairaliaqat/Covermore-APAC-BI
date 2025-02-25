USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_SunGL_India_Data_2018]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_SunGL_India_Data_2018](
	[BusinessUnit] [varchar](50) NULL,
	[AccountCode] [varchar](50) NULL,
	[AccountDescription] [nvarchar](255) NULL,
	[AccountingPeriod] [int] NULL,
	[JournalNo] [int] NULL,
	[JournalLine] [int] NULL,
	[TransactionDate] [date] NULL,
	[TransactionReference] [varchar](50) NULL,
	[BaseAmount] [numeric](18, 3) NULL,
	[CurrencyCode] [varchar](50) NULL,
	[JournalDescription] [varchar](50) NULL,
	[AccountType] [varchar](5) NULL,
	[JournalType] [varchar](50) NULL,
	[JournalName] [nvarchar](255) NULL,
	[JournalSource] [varchar](50) NULL,
	[OriginatorOperatorCode] [varchar](50) NULL,
	[PermanentlyPostedBy] [varchar](50) NULL,
	[EntryDate] [date] NULL,
	[EntryPeriod] [int] NULL,
	[LedgerAF] [varchar](50) NULL
) ON [PRIMARY]
GO
