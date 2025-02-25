USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_etactcase_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_etactcase_audtc](
	[kactid] [int] NOT NULL,
	[kprogprovid] [int] NOT NULL,
	[kactivitytypeid] [int] NOT NULL,
	[kactstatusid] [int] NOT NULL,
	[kcworkshopid] [int] NULL,
	[slogin] [datetime2](7) NULL,
	[slogmod] [datetime2](7) NULL,
	[ksessid] [int] NULL,
	[useseqovr] [varchar](5) NULL,
	[kcworkeridprimact] [int] NULL,
	[kcworkeridsecact] [int] NULL,
	[confirmed] [varchar](5) NULL,
	[acceptcancellationpolicy] [varchar](5) NULL,
	[resolveddate] [date] NULL,
	[reviewrequired] [varchar](5) NOT NULL,
	[forreview] [varchar](5) NOT NULL,
	[lusiteregionid] [int] NULL,
	[kbillindidactovr] [int] NULL
) ON [PRIMARY]
GO
