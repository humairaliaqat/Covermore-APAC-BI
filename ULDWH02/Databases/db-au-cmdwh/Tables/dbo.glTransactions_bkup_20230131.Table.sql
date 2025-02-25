USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glTransactions_bkup_20230131]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glTransactions_bkup_20230131](
	[BIRowID] [bigint] NOT NULL,
	[BusinessUnit] [varchar](50) NULL,
	[ScenarioCode] [varchar](50) NULL,
	[AccountCode] [varchar](50) NULL,
	[Period] [int] NULL,
	[JournalNo] [int] NULL,
	[JournalLine] [int] NULL,
	[JournalType] [varchar](50) NULL,
	[JournalSource] [varchar](50) NULL,
	[TransactionDate] [date] NULL,
	[EntryDate] [date] NULL,
	[DueDate] [date] NULL,
	[PostingDate] [date] NULL,
	[OriginatedDate] [date] NULL,
	[AfterPostingDate] [date] NULL,
	[BaseRate] [numeric](18, 9) NULL,
	[ConversionRate] [numeric](18, 9) NULL,
	[ReversalFlag] [varchar](50) NULL,
	[GLAmount] [numeric](18, 3) NULL,
	[OtherAmount] [numeric](18, 3) NULL,
	[ReportAmount] [numeric](18, 3) NULL,
	[DebitCreditFlag] [varchar](50) NULL,
	[AllocationFlag] [varchar](50) NULL,
	[TransactionReference] [varchar](50) NULL,
	[Description] [varchar](50) NULL,
	[ChannelCode] [varchar](50) NULL,
	[DepartmentCode] [varchar](50) NULL,
	[ProductCode] [varchar](50) NULL,
	[BDMCode] [varchar](50) NULL,
	[ProjectCode] [varchar](50) NULL,
	[StateCode] [varchar](50) NULL,
	[ClientCode] [varchar](50) NULL,
	[SourceCode] [varchar](50) NULL,
	[JointVentureCode] [varchar](50) NULL,
	[GSTCode] [varchar](50) NULL,
	[CaseNumber] [varchar](50) NULL,
	[CreateBatchID] [int] NULL,
	[CCATeamsCode] [varchar](50) NULL
) ON [PRIMARY]
GO
