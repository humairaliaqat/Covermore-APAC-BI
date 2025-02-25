USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblDataQueue_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblDataQueue_uscm](
	[DataQueueID] [int] NOT NULL,
	[DataID] [varchar](300) NOT NULL,
	[DataQueueTypeID] [int] NOT NULL,
	[DataValue] [xml] NULL,
	[JobID] [int] NULL,
	[Comment] [varchar](2000) NULL,
	[RetryCount] [int] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[TrooperName] [varchar](100) NULL,
	[LastSourceUpdated] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
