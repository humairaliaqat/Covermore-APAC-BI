USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTC_TimesheetCreations]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_TimesheetCreations](
	[id] [int] NOT NULL,
	[CompositeKey] [varchar](30) NOT NULL,
	[act_id] [int] NOT NULL,
	[actline_id] [int] NOT NULL,
	[ResourceCode] [varchar](20) NOT NULL,
	[project_code] [varchar](20) NULL,
	[tran_date] [date] NULL,
	[Activity] [varchar](20) NULL,
	[Qty] [money] NULL,
	[TS_CreatedDate] [datetime] NULL,
	[Modifier] [int] NOT NULL,
	[trx_detail_id] [varchar](40) NULL,
	[Outcome] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
