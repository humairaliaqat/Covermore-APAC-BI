USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_irind2exp_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_irind2exp_audtc](
	[kindid] [int] NOT NULL,
	[ind2exp1] [nvarchar](100) NULL,
	[ind2exp2] [nvarchar](100) NULL,
	[ind2exp3] [int] NULL,
	[ind2exp4] [int] NULL,
	[ind2exp5] [varchar](5) NULL,
	[ind2exp6] [varchar](5) NULL,
	[ind2exp7] [date] NULL,
	[ind2exp8] [date] NULL,
	[ind2exp9] [ntext] NULL,
	[ind2exp10] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
