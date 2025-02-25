USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisCallData_bkp01092020]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCallData_bkp01092020](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[SessionKey] [nvarchar](50) NOT NULL,
	[SessionID] [numeric](18, 0) NOT NULL,
	[AgentKey] [nvarchar](50) NOT NULL,
	[CSQKey] [nvarchar](50) NOT NULL,
	[Disposition] [char](20) NOT NULL,
	[CallStartDateTime] [datetime2](7) NOT NULL,
	[CallEndDateTime] [datetime2](7) NOT NULL,
	[OriginatorNumber] [nvarchar](30) NOT NULL,
	[DestinationNumber] [nvarchar](30) NOT NULL,
	[CalledNumber] [nvarchar](30) NOT NULL,
	[OrigCalledNumber] [nvarchar](30) NOT NULL,
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
	[Conference] [bit] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[EmployeeKey] [int] NULL,
	[OrganisationKey] [int] NULL,
	[Team] [varchar](50) NULL,
	[Agent] [varchar](50) NULL,
	[LoginID] [varchar](50) NULL,
	[SupervisorFlag] [bit] NULL,
	[ApplicationID] [int] NULL,
	[ApplicationName] [varchar](30) NULL,
	[ContactType] [int] NULL
) ON [PRIMARY]
GO
