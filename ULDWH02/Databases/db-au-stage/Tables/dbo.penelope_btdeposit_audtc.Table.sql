USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_btdeposit_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_btdeposit_audtc](
	[kdepositid] [int] NOT NULL,
	[depositdate] [date] NOT NULL,
	[depositstatus] [varchar](5) NOT NULL,
	[kbankaccountid] [int] NOT NULL,
	[ksiteid] [int] NOT NULL,
	[depositnotes] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kuseridlogin] [int] NOT NULL,
	[kuseridlogmod] [int] NOT NULL,
	[kdeposittypeid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
