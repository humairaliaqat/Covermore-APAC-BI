USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_cisCallData]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_cisCallData](
	[SessionID] [numeric](18, 0) NOT NULL,
	[AgentKey] [nvarchar](50) NULL,
	[CSQKey] [nvarchar](50) NULL,
	[Disposition] [char](20) NOT NULL,
	[CallStartDateTime] [datetime] NOT NULL,
	[CallEndDateTime] [datetime] NOT NULL,
	[OriginatorNumber] [varchar](30) NOT NULL,
	[DestinationNumber] [varchar](30) NOT NULL,
	[CalledNumber] [varchar](30) NOT NULL,
	[OrigCalledNumber] [varchar](30) NOT NULL,
	[CallsPresented] [int] NOT NULL,
	[CallsHandled] [int] NOT NULL,
	[CallsAbandoned] [int] NOT NULL,
	[RingTime] [int] NOT NULL,
	[TalkTime] [int] NOT NULL,
	[HoldTime] [int] NOT NULL,
	[WorkTime] [int] NOT NULL,
	[WrapUpTime] [int] NOT NULL,
	[QueueTime] [int] NOT NULL,
	[MetServiceLevel] [bit] NOT NULL,
	[Transfer] [bit] NOT NULL,
	[Redirect] [bit] NOT NULL,
	[Conference] [bit] NOT NULL
) ON [PRIMARY]
GO
