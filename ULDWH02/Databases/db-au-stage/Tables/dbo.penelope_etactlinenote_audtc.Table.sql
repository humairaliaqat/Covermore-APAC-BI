USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_etactlinenote_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_etactlinenote_audtc](
	[kactlinenoteid] [int] NOT NULL,
	[kactlineid] [int] NOT NULL,
	[iserror] [varchar](5) NOT NULL,
	[actlinenote] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
