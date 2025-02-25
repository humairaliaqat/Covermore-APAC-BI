USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_frfundexp_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_frfundexp_audtc](
	[kfunderid] [int] NOT NULL,
	[fundexp1] [nvarchar](100) NULL,
	[fundexp2] [nvarchar](100) NULL,
	[fundexp3] [int] NULL,
	[fundexp4] [int] NULL,
	[fundexp5] [varchar](5) NULL,
	[fundexp6] [varchar](5) NULL,
	[fundexp7] [date] NULL,
	[fundexp8] [date] NULL,
	[fundexp9] [ntext] NULL,
	[fundexp10] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
