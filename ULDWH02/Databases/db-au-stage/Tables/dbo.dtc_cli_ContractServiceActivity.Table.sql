USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_ContractServiceActivity]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_ContractServiceActivity](
	[ContractServiceActivity_ID] [varchar](32) NOT NULL,
	[ContractService_id] [varchar](32) NULL,
	[ActivityCode] [varchar](30) NULL,
	[Description] [varchar](255) NULL,
	[FeeForServiceHrRate] [float] NULL,
	[GSTFlag] [int] NULL,
	[AddDate] [datetime] NULL,
	[AddUser] [varchar](20) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](20) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL
) ON [PRIMARY]
GO
