USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_attriggerrules_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_attriggerrules_audtc](
	[ktriggerid] [int] NOT NULL,
	[ktriggertypeid] [int] NOT NULL,
	[kdocmastid] [int] NULL,
	[kdocconditionid] [int] NULL,
	[kassessscoreid] [int] NULL,
	[kdocattacheddirectiveid] [int] NULL,
	[kentitytableattachedtoid] [int] NULL,
	[active] [varchar](5) NOT NULL,
	[rulessql] [ntext] NULL,
	[rulename] [nvarchar](100) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kbookitemidlogin] [int] NOT NULL,
	[kbookitemidlogmod] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
