USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_wruser1exp_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_wruser1exp_audtc](
	[kuserid] [int] NOT NULL,
	[user1exp1] [nvarchar](100) NULL,
	[user1exp2] [nvarchar](100) NULL,
	[user1exp3] [int] NULL,
	[user1exp4] [int] NULL,
	[user1exp5] [varchar](5) NULL,
	[user1exp6] [varchar](5) NULL,
	[user1exp7] [date] NULL,
	[user1exp8] [date] NULL,
	[user1exp9] [ntext] NULL,
	[user1exp10] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
