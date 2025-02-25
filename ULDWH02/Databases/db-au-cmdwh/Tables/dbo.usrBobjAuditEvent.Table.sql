USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrBobjAuditEvent]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrBobjAuditEvent](
	[Cluster] [nvarchar](255) NULL,
	[LastPollTime] [datetime] NULL,
	[ServerName] [varchar](255) NULL,
	[ServerType] [nvarchar](255) NULL,
	[ServiceType] [nvarchar](255) NULL,
	[ApplicationType] [nvarchar](255) NULL,
	[Version] [varchar](64) NULL,
	[State] [int] NULL,
	[PotentiallyIncompleteData] [varchar](3) NOT NULL,
	[RetrievedEventsCompletedBy] [datetime] NULL,
	[EventID] [varchar](64) NULL,
	[StartTime] [datetime] NULL,
	[DurationMS] [int] NULL,
	[DurationSec] [float] NULL,
	[UserName] [nvarchar](255) NULL,
	[ObjectID] [varchar](64) NULL,
	[ObjectName] [nvarchar](255) NULL,
	[ObjectFolderPath] [nvarchar](255) NULL,
	[TopFolderName] [nvarchar](255) NULL,
	[TopFolderID] [varchar](64) NULL,
	[FolderID] [varchar](64) NULL,
	[ClientType] [nvarchar](255) NULL,
	[EventCategoryType] [nvarchar](255) NULL,
	[EventType] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[ObjectType] [nvarchar](255) NULL,
	[StartTimeUTC] [datetime] NULL,
	[EventDetailID] [int] NULL,
	[EventDetail] [nvarchar](256) NULL,
	[EventDetailType] [nvarchar](255) NULL,
	[EventDetailBunch] [int] NULL,
	[StartDate] [datetime] NULL,
	[isObject] [int] NULL,
	[hasUser] [int] NULL,
	[isReportable] [int] NULL,
	[Country] [nvarchar](20) NULL,
	[BusinessLine] [nvarchar](50) NULL,
	[Department] [nvarchar](200) NULL,
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
