USE [db-au-stage]
GO
/****** Object:  Table [dbo].[temptab]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temptab](
	[AgentID] [int] NULL,
	[ProfileID] [int] NULL,
	[EventDateTime] [datetime] NULL,
	[EventType] [int] NULL,
	[ReasonCode] [int] NULL
) ON [PRIMARY]
GO
