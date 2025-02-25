USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[call_data_analysis]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[call_data_analysis](
	[Team] [varchar](50) NULL,
	[Agent] [varchar](50) NULL,
	[LoginID] [varchar](50) NULL,
	[SessionID] [numeric](18, 0) NOT NULL,
	[CSQKey] [nvarchar](50) NOT NULL,
	[Disposition] [char](20) NOT NULL,
	[CallStartDateTime] [datetime2](7) NOT NULL,
	[CallEndDateTime] [datetime2](7) NOT NULL,
	[CallsPresented] [int] NOT NULL,
	[CallsHandled] [int] NOT NULL,
	[CallsAbandoned] [int] NOT NULL,
	[RingTime] [int] NOT NULL,
	[TalkTime] [int] NOT NULL,
	[Transfer] [bit] NOT NULL,
	[ApplicationName] [varchar](30) NULL,
	[ContactType] [int] NULL,
	[CalledNumber] [nvarchar](30) NOT NULL,
	[OrigCalledNumber] [nvarchar](30) NOT NULL,
	[OriginatorNumber] [nvarchar](30) NOT NULL,
	[Call Classification] [varchar](250) NULL,
	[Call Type] [varchar](50) NULL,
	[Caller] [varchar](50) NULL,
	[Team Type] [varchar](50) NULL,
	[Agent Group] [varchar](50) NULL,
	[Company] [varchar](24) NOT NULL,
	[OnlinePayment] [int] NULL,
	[CardType] [varchar](50) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[GroupName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
