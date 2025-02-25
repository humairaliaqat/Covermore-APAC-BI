USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cisco_contactcalldetail_tmp]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisco_contactcalldetail_tmp](
	[sessionid] [numeric](18, 0) NOT NULL,
	[sessionseqnum] [smallint] NOT NULL,
	[nodeid] [smallint] NOT NULL,
	[profileid] [int] NOT NULL,
	[contacttype] [smallint] NOT NULL,
	[contactdisposition] [smallint] NOT NULL,
	[dispositionreason] [varchar](100) NULL,
	[originatortype] [smallint] NOT NULL,
	[originatorid] [int] NULL,
	[originatordn] [varchar](30) NULL,
	[destinationtype] [smallint] NULL,
	[destinationid] [int] NULL,
	[destinationdn] [varchar](30) NULL,
	[startdatetime] [datetime2](7) NOT NULL,
	[enddatetime] [datetime2](7) NOT NULL,
	[gmtoffset] [smallint] NOT NULL,
	[callednumber] [varchar](30) NULL,
	[origcallednumber] [varchar](30) NULL,
	[applicationtaskid] [numeric](18, 0) NULL,
	[applicationid] [int] NULL,
	[applicationname] [varchar](30) NULL,
	[connecttime] [smallint] NULL,
	[customvariable1] [varchar](40) NULL,
	[customvariable2] [varchar](40) NULL,
	[customvariable3] [varchar](40) NULL,
	[customvariable4] [varchar](40) NULL,
	[customvariable5] [varchar](40) NULL,
	[customvariable6] [varchar](40) NULL,
	[customvariable7] [varchar](40) NULL,
	[customvariable8] [varchar](40) NULL,
	[customvariable9] [varchar](40) NULL,
	[customvariable10] [varchar](40) NULL,
	[accountnumber] [varchar](40) NULL,
	[callerentereddigits] [varchar](40) NULL,
	[badcalltag] [char](1) NULL,
	[transfer] [bit] NULL,
	[redirect] [bit] NULL,
	[conference] [bit] NULL,
	[flowout] [bit] NULL,
	[metservicelevel] [bit] NULL,
	[campaignid] [int] NULL,
	[origprotocolcallref] [varchar](32) NULL,
	[destprotocolcallref] [varchar](32) NULL,
	[callresult] [smallint] NULL,
	[dialinglistid] [int] NULL
) ON [PRIMARY]
GO
