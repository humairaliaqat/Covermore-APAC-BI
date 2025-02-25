USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penSystemConfig]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penSystemConfig](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[SystemConfigKey] [varchar](41) NULL,
	[DomainID] [int] NOT NULL,
	[SystemConfigID] [int] NOT NULL,
	[ConfigKey] [varchar](50) NOT NULL,
	[ConfigValue] [varchar](max) NOT NULL,
	[ConfigDesc] [varchar](500) NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NOT NULL,
	[UpdateDateTimeUTC] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
