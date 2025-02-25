USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ctprogprovexp_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ctprogprovexp_audtc](
	[kprogprovid] [int] NOT NULL,
	[progprovexp1] [nvarchar](100) NULL,
	[progprovexp2] [nvarchar](100) NULL,
	[progprovexp3] [int] NULL,
	[progprovexp4] [int] NULL,
	[progprovexp5] [varchar](5) NULL,
	[progprovexp6] [varchar](5) NULL,
	[progprovexp7] [date] NULL,
	[progprovexp8] [date] NULL,
	[progprovexp9] [ntext] NULL,
	[progprovexp10] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
