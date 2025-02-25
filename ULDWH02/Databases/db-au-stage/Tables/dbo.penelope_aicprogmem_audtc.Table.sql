USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_aicprogmem_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_aicprogmem_audtc](
	[kprogmemid] [int] NOT NULL,
	[kprogprovid] [int] NOT NULL,
	[kcasemembersid] [int] NOT NULL,
	[lupresissueid1] [int] NULL,
	[lupresissueid2] [int] NULL,
	[lupresissueid3] [int] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[luppmemberud1id] [int] NULL,
	[luppmemberud2id] [int] NULL,
	[ppmemberud3] [varchar](5) NULL,
	[ppmemberud4] [varchar](5) NULL,
	[consentpcehr] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
