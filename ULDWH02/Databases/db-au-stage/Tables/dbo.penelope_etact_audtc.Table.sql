USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_etact_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_etact_audtc](
	[kactid] [int] NOT NULL,
	[acttitle] [nvarchar](80) NOT NULL,
	[actstime] [datetime2](7) NOT NULL,
	[actetime] [datetime2](7) NOT NULL,
	[actout] [varchar](5) NULL,
	[kactcatid] [int] NOT NULL,
	[actnotes] [ntext] NULL,
	[ksiteid] [int] NULL,
	[slogin] [datetime2](7) NULL,
	[slogmod] [datetime2](7) NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[actnotesfinished] [varchar](5) NULL,
	[followuprequired] [varchar](5) NULL,
	[actlock] [varchar](5) NULL,
	[firstsessinseries] [varchar](5) NULL,
	[snotemod] [datetime2](7) NOT NULL,
	[kuseridnotemod] [int] NULL,
	[unregclients] [int] NULL,
	[nonsched] [varchar](5) NOT NULL,
	[kbookitemidby] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
