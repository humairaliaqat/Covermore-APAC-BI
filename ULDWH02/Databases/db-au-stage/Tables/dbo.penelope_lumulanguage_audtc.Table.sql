USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_lumulanguage_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_lumulanguage_audtc](
	[lumulanguageid] [int] NOT NULL,
	[language] [ntext] NULL,
	[codebib] [ntext] NULL,
	[codeterm] [ntext] NULL,
	[valisactive] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
