USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_wruser2exp_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_wruser2exp_audtc](
	[kuserid] [int] NOT NULL,
	[user2exp1] [nvarchar](100) NULL,
	[user2exp2] [nvarchar](100) NULL,
	[user2exp3] [int] NULL,
	[user2exp4] [int] NULL,
	[user2exp5] [varchar](5) NULL,
	[user2exp6] [varchar](5) NULL,
	[user2exp7] [date] NULL,
	[user2exp8] [date] NULL,
	[user2exp9] [ntext] NULL,
	[user2exp10] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[user2exp11] [nvarchar](200) NULL,
	[user2exp12] [nvarchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
