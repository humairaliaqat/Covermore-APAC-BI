USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblJob_aucm_tst]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblJob_aucm_tst](
	[JobID] [int] NOT NULL,
	[JobName] [varchar](100) NOT NULL,
	[JobCode] [varchar](50) NOT NULL,
	[JobType] [varchar](50) NOT NULL,
	[JobDesc] [varchar](500) NOT NULL,
	[GroupCodes] [varchar](100) NULL,
	[DataQueueType] [varchar](50) NOT NULL,
	[MaxRetryCount] [int] NOT NULL,
	[CodeModule] [varchar](255) NOT NULL,
	[JobData] [xml] NULL,
	[Status] [varchar](15) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Company] [varchar](20) NOT NULL,
	[DomainID] [int] NOT NULL,
	[ApiKey] [varchar](200) NULL,
	[MinID] [int] NULL,
	[LastRunTime] [datetime] NULL,
	[IsPaused] [bit] NULL,
	[isThrottling] [bit] NULL,
	[ThrottlingLimit] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
