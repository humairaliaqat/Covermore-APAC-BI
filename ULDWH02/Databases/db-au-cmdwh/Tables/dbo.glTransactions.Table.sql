USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glTransactions]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glTransactions](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
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
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[glTransactions]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [account]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [account] ON [dbo].[glTransactions]
(
	[AccountCode] ASC
)
INCLUDE([Period],[BusinessUnit],[ScenarioCode],[GLAmount],[ChannelCode],[DepartmentCode],[ProductCode],[ProjectCode],[StateCode],[ClientCode],[SourceCode],[JointVentureCode],[GSTCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [businessunit]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [businessunit] ON [dbo].[glTransactions]
(
	[BusinessUnit] ASC,
	[ScenarioCode] ASC,
	[AccountCode] ASC,
	[Period] ASC
)
INCLUDE([GLAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [period]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [period] ON [dbo].[glTransactions]
(
	[Period] ASC,
	[BusinessUnit] ASC,
	[ScenarioCode] ASC,
	[AccountCode] ASC
)
INCLUDE([JointVentureCode],[ClientCode],[SourceCode],[DepartmentCode],[GLAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
