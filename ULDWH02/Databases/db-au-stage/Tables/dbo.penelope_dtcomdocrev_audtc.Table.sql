USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_dtcomdocrev_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_dtcomdocrev_audtc](
	[kcomdocrevid] [int] NOT NULL,
	[kcomdocid] [int] NOT NULL,
	[cdocdaterev] [date] NOT NULL,
	[cdoclettersent] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kuseridlogin] [int] NOT NULL,
	[kuseridlogmod] [int] NOT NULL,
	[kbookitemidlogin] [int] NOT NULL,
	[kbookitemidlogmod] [int] NOT NULL
) ON [PRIMARY]
GO
