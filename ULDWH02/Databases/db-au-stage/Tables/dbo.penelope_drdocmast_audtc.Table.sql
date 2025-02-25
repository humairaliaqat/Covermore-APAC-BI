USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_drdocmast_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_drdocmast_audtc](
	[kdocmastid] [int] NOT NULL,
	[doctitle] [ntext] NULL,
	[docshort] [nvarchar](10) NOT NULL,
	[docstatus] [varchar](5) NOT NULL,
	[kdocclassid] [int] NOT NULL,
	[kdocidcurrev] [int] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kuseridlogin] [int] NOT NULL,
	[kuseridlogmod] [int] NOT NULL,
	[kdocud1id] [int] NULL,
	[kdocud2id] [int] NULL,
	[docdescription] [ntext] NULL,
	[usecomdocrev] [varchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
