USE [db-au-star]
GO
/****** Object:  Table [dbo].[factCalls]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factCalls](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[DateSK] [int] NOT NULL,
	[EmployeeSK] [int] NOT NULL,
	[SupervisorSK] [int] NOT NULL,
	[TeamSK] [int] NOT NULL,
	[CSQSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[CallsPresented] [int] NOT NULL,
	[CallsHandled] [int] NOT NULL,
	[CallsAbandoned] [int] NOT NULL,
	[RingTime] [int] NOT NULL,
	[TalkTime] [int] NOT NULL,
	[HoldTime] [int] NOT NULL,
	[WorkTime] [int] NOT NULL,
	[WrapUpTime] [int] NOT NULL,
	[QueueTime] [int] NOT NULL,
	[MetServiceLevel] [int] NOT NULL,
	[Transfered] [int] NOT NULL,
	[Redirect] [int] NOT NULL,
	[Conference] [int] NOT NULL,
	[RingNoAnswer] [int] NOT NULL,
	[CreateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_factCalls_BIRowID]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [idx_factCalls_BIRowID] ON [dbo].[factCalls]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factCalls_DateSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factCalls_DateSK] ON [dbo].[factCalls]
(
	[DateSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
