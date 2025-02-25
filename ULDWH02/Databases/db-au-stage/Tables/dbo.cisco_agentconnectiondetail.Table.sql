USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cisco_agentconnectiondetail]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisco_agentconnectiondetail](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
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
	[rna] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_cisco_agentconnectiondetail]    Script Date: 24/02/2025 5:08:03 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_cisco_agentconnectiondetail] ON [dbo].[cisco_agentconnectiondetail]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[cisco_agentconnectiondetail]
(
	[sessionid] ASC,
	[sessionseqnum] ASC,
	[nodeid] ASC,
	[profileid] ASC,
	[resourceid] ASC,
	[startdatetime] ASC,
	[enddatetime] ASC,
	[qindex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
