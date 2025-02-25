USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_irindback_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_irindback_audtc](
	[kindid] [int] NOT NULL,
	[luibackbirthplaceid] [int] NULL,
	[luibackcitizenshipid] [int] NULL,
	[ibackcitizendate] [date] NULL,
	[ibacknewcanadian] [varchar](5) NULL,
	[luibackeducationid] [int] NULL,
	[luibackoccupationid] [int] NULL,
	[luibackempstatusid] [int] NULL,
	[luibackincrangeid] [int] NULL,
	[luibackincsourceid] [int] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[ibackcom1] [nvarchar](100) NULL,
	[ibackcom2] [nvarchar](100) NULL
) ON [PRIMARY]
GO
