USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_drdoc_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_drdoc_audtc](
	[kdocid] [int] NOT NULL,
	[docnotes] [ntext] NULL,
	[sigtitle] [ntext] NULL,
	[sigtexttop] [ntext] NULL,
	[sigtextbot] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kuseridlogin] [int] NOT NULL,
	[kuseridlogmod] [int] NOT NULL,
	[docrevfinalized] [varchar](5) NOT NULL,
	[kdocmastid] [int] NOT NULL,
	[docrevusestage] [varchar](5) NOT NULL,
	[docrevusepages] [varchar](5) NOT NULL,
	[kentitytypeidbookitem] [int] NULL,
	[isexternal] [varchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
