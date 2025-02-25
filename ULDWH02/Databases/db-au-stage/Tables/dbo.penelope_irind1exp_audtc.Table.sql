USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_irind1exp_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_irind1exp_audtc](
	[kindid] [int] NOT NULL,
	[ind1exp1] [nvarchar](100) NULL,
	[ind1exp2] [nvarchar](100) NULL,
	[ind1exp3] [int] NULL,
	[ind1exp4] [int] NULL,
	[ind1exp5] [varchar](5) NULL,
	[ind1exp6] [varchar](5) NULL,
	[ind1exp7] [date] NULL,
	[ind1exp8] [date] NULL,
	[ind1exp9] [ntext] NULL,
	[ind1exp10] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
