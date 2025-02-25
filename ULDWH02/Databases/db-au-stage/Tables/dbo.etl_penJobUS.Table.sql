USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penJobUS]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penJobUS](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[JobKey] [varchar](41) NULL,
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
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Company] [varchar](20) NOT NULL,
	[DomainID] [int] NOT NULL,
	[LastRunTime] [datetime] NULL,
	[IsPaused] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
