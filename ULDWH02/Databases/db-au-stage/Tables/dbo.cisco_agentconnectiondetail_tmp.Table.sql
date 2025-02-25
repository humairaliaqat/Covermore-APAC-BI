USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cisco_agentconnectiondetail_tmp]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisco_agentconnectiondetail_tmp](
	[sessionid] [numeric](18, 0) NOT NULL,
	[sessionseqnum] [smallint] NOT NULL,
	[nodeid] [smallint] NOT NULL,
	[profileid] [int] NOT NULL,
	[resourceid] [int] NOT NULL,
	[startdatetime] [datetime2](7) NOT NULL,
	[enddatetime] [datetime2](7) NOT NULL,
	[qindex] [smallint] NOT NULL,
	[gmtoffset] [smallint] NOT NULL,
	[ringtime] [smallint] NULL,
	[talktime] [smallint] NULL,
	[holdtime] [smallint] NULL,
	[worktime] [smallint] NULL,
	[callwrapupdata] [varchar](40) NULL,
	[callresult] [smallint] NULL,
	[dialinglistid] [int] NULL,
	[rna] [bit] NULL
) ON [PRIMARY]
GO
