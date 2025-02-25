USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_ma_calls]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_ma_calls](
	[Period] [varchar](5) NULL,
	[Call Type] [varchar](8) NULL,
	[Company Name] [nvarchar](100) NULL,
	[CSQName] [nvarchar](50) NULL,
	[Agent] [varchar](50) NULL,
	[Team] [varchar](50) NULL,
	[SupervisorFlag] [int] NULL,
	[CallStartDateTime] [datetime2](7) NULL,
	[CallEndDateTime] [datetime2](7) NULL,
	[OriginatorNumber] [nvarchar](30) NULL,
	[DestinationNumber] [nvarchar](30) NULL,
	[CalledNumber] [nvarchar](30) NULL,
	[OrigCalledNumber] [nvarchar](30) NULL,
	[RingNoAnswer] [int] NULL,
	[CallsPresented] [int] NULL,
	[CallsHandled] [int] NULL,
	[CallsAbandoned] [int] NULL,
	[RingTime] [int] NULL,
	[TalkTime] [int] NULL,
	[HoldTime] [int] NULL,
	[WorkTime] [int] NULL,
	[WrapUpTime] [int] NULL,
	[QueueTime] [int] NULL,
	[MetServiceLevel] [int] NULL,
	[Transfer] [int] NULL,
	[Redirect] [int] NULL,
	[Conference] [int] NULL
) ON [PRIMARY]
GO
