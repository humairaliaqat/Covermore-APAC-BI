USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_prncaseprogser_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_prncaseprogser_audtc](
	[kncaseserid] [int] NOT NULL,
	[kncaseprogid] [int] NOT NULL,
	[kuserid] [int] NOT NULL,
	[ncsername] [nvarchar](50) NOT NULL,
	[ncseropen] [date] NOT NULL,
	[ncserend] [date] NULL,
	[kncserstatusid] [int] NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[ncsersecure] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
