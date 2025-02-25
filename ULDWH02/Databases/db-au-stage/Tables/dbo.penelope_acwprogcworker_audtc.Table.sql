USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_acwprogcworker_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_acwprogcworker_audtc](
	[kprogprovid] [int] NOT NULL,
	[kcworkerid] [int] NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[actlevelbooking] [varchar](5) NOT NULL,
	[kfahcsiastateid] [int] NULL,
	[workerattached] [varchar](5) NULL
) ON [PRIMARY]
GO
