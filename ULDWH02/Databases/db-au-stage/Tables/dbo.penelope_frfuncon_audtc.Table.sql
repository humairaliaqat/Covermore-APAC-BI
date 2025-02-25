USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_frfuncon_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_frfuncon_audtc](
	[kfunderconid] [int] NOT NULL,
	[kfunderid] [int] NOT NULL,
	[fconname] [nvarchar](50) NOT NULL,
	[fconrole] [nvarchar](50) NOT NULL,
	[fconphone1] [nvarchar](13) NOT NULL,
	[fconext1] [nvarchar](6) NULL,
	[fconphone2] [nvarchar](13) NULL,
	[fconext2] [nvarchar](6) NULL,
	[fconfax] [nvarchar](13) NULL,
	[fconemail] [nvarchar](70) NULL,
	[fconcomments] [nvarchar](50) NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[fconnotes] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
