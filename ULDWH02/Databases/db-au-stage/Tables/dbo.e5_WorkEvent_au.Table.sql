USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_WorkEvent_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_WorkEvent_au](
	[Work_Id] [uniqueidentifier] NOT NULL,
	[Id] [bigint] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[Event_Id] [int] NOT NULL,
	[EventUser] [nvarchar](100) NOT NULL,
	[Status_Id] [int] NOT NULL,
	[Detail] [nvarchar](200) NULL,
	[Allocation] [varchar](20) NULL
) ON [PRIMARY]
GO
