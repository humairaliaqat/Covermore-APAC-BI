USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_crcaseexp_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_crcaseexp_audtc](
	[kcaseid] [int] NOT NULL,
	[caseexp1] [nvarchar](100) NULL,
	[caseexp2] [nvarchar](100) NULL,
	[caseexp3] [int] NULL,
	[caseexp4] [int] NULL,
	[caseexp5] [varchar](5) NULL,
	[caseexp6] [varchar](5) NULL,
	[caseexp7] [date] NULL,
	[caseexp8] [date] NULL,
	[caseexp9] [ntext] NULL,
	[caseexp10] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
