USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_brtaxsched_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_brtaxsched_audtc](
	[ktaxschedid] [int] NOT NULL,
	[taxschedname] [nvarchar](30) NOT NULL,
	[taxschedshort] [nvarchar](4) NOT NULL,
	[taxschednotes] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NULL,
	[slogmodby] [nvarchar](10) NULL,
	[valisactive] [varchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
