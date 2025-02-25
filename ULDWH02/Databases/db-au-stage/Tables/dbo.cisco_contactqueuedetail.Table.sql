USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cisco_contactqueuedetail]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisco_contactqueuedetail](
	[sessionid] [numeric](18, 0) NOT NULL,
	[sessionseqnum] [smallint] NOT NULL,
	[profileid] [int] NOT NULL,
	[nodeid] [smallint] NOT NULL,
	[targetid] [int] NOT NULL,
	[targettype] [smallint] NOT NULL,
	[qindex] [smallint] NOT NULL,
	[queueorder] [smallint] NOT NULL,
	[disposition] [smallint] NULL,
	[metservicelevel] [bit] NULL,
	[queuetime] [smallint] NULL
) ON [PRIMARY]
GO
