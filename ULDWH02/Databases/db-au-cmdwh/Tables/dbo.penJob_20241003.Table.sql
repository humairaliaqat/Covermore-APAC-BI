USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penJob_20241003]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penJob_20241003](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](3) NULL,
	[JobKey] [varchar](41) NULL,
	[JobID] [int] NULL,
	[JobName] [varchar](100) NULL,
	[JobCode] [varchar](50) NULL,
	[JobType] [varchar](50) NULL,
	[JobDesc] [varchar](500) NULL,
	[GroupCodes] [varchar](100) NULL,
	[DataQueueType] [varchar](50) NULL,
	[MaxRetryCount] [int] NULL,
	[CodeModule] [varchar](255) NULL,
	[JobData] [xml] NULL,
	[Status] [varchar](15) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Domain] [varchar](20) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[Company] [varchar](20) NULL,
	[LastRunTime] [datetime] NULL,
	[IsPaused] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
