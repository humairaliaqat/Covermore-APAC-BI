USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5workevent_v3_bkp]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5workevent_v3_bkp](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Domain] [varchar](5) NULL,
	[Work_ID] [varchar](50) NULL,
	[Original_Work_Id] [uniqueidentifier] NOT NULL,
	[Id] [bigint] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[Event_Id] [int] NOT NULL,
	[EventName] [nvarchar](50) NULL,
	[EventUserID] [nvarchar](100) NULL,
	[EventUser] [nvarchar](455) NULL,
	[Status_Id] [int] NOT NULL,
	[StatusName] [nvarchar](100) NULL,
	[Detail] [nvarchar](200) NULL,
	[Allocation] [varchar](20) NULL,
	[ResumeEventId] [int] NULL,
	[ResumeEventStatusName] [nvarchar](100) NULL,
	[BookmarkId] [uniqueidentifier] NULL,
	[ProcessStatus_Id] [int] NULL,
	[ProcessStatus] [nvarchar](100) NULL,
	[ResumeEventDetail] [nvarchar](200) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[DeleteBatchID] [int] NULL
) ON [PRIMARY]
GO
