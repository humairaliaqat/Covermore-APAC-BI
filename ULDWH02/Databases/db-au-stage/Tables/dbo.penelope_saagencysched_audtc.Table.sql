USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_saagencysched_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_saagencysched_audtc](
	[kagencyschedid] [int] NOT NULL,
	[ludayid] [int] NOT NULL,
	[aschedin] [time](0) NOT NULL,
	[aschedout] [time](0) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[ksiteid] [int] NULL
) ON [PRIMARY]
GO
