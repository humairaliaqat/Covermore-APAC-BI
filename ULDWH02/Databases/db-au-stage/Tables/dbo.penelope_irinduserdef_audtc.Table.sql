USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_irinduserdef_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_irinduserdef_audtc](
	[kindid] [int] NOT NULL,
	[indud1] [nvarchar](100) NULL,
	[indud2] [nvarchar](100) NULL,
	[indud3] [int] NULL,
	[indud4] [int] NULL,
	[indud5] [varchar](5) NULL,
	[indud6] [varchar](5) NULL,
	[indud7] [date] NULL,
	[indud8] [date] NULL,
	[indud9] [ntext] NULL,
	[indud10] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
