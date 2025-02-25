USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penDataQueueUS]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penDataQueueUS](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[DataQueueKey] [varchar](41) NULL,
	[JobKey] [varchar](41) NULL,
	[DataQueueID] [int] NOT NULL,
	[JobID] [int] NULL,
	[DataID] [varchar](300) NOT NULL,
	[DataQueueTypeID] [int] NOT NULL,
	[DataValue] [xml] NULL,
	[Comment] [varchar](2000) NULL,
	[RetryCount] [int] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[TrooperName] [varchar](100) NULL,
	[LastSourceUpdated] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
