USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_gtbluebook_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_gtbluebook_audtc](
	[kbluebookid] [int] NOT NULL,
	[lastorgname] [ntext] NULL,
	[firstname] [ntext] NULL,
	[role] [ntext] NULL,
	[private] [varchar](5) NOT NULL,
	[kbookitemid] [int] NOT NULL,
	[kbluebookidparent] [int] NULL,
	[kbluebookidmaster] [int] NULL,
	[luccuserdef1id] [int] NULL,
	[notes] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[kbbtypeid] [int] NOT NULL,
	[kbbcontactidprim] [int] NULL,
	[kreferredtoid] [int] NULL,
	[fahcsiaid] [ntext] NULL,
	[allowforbillinguse] [varchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
