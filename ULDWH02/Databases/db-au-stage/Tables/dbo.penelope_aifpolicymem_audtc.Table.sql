USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_aifpolicymem_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_aifpolicymem_audtc](
	[kpolicymemid] [int] NOT NULL,
	[kindid] [int] NOT NULL,
	[kpolicyid] [int] NOT NULL,
	[kpolicyrelid] [int] NOT NULL,
	[kpolicycoverbyid] [int] NOT NULL,
	[polmemstatus] [varchar](5) NOT NULL,
	[polmemno] [ntext] NULL,
	[polmemgno] [nvarchar](20) NULL,
	[polmemnote] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kmemnotypeid] [int] NULL,
	[kpolicymemidpirm] [int] NULL,
	[kinstypecode2id] [int] NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[kfunderdeptid] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
