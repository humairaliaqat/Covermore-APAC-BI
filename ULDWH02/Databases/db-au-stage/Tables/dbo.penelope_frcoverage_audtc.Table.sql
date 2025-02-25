USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_frcoverage_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_frcoverage_audtc](
	[kcoverageid] [int] NOT NULL,
	[kpolicyid] [int] NOT NULL,
	[kpolagreid] [int] NULL,
	[covulimita] [varchar](5) NOT NULL,
	[covulimit] [numeric](10, 2) NULL,
	[covnoshow] [numeric](6, 4) NOT NULL,
	[covdatea] [varchar](5) NOT NULL,
	[covstart] [date] NULL,
	[covend] [date] NULL,
	[covautha] [varchar](5) NOT NULL,
	[covauthno] [nvarchar](25) NULL,
	[covauthconf] [varchar](5) NULL,
	[kcovreauthid] [int] NULL,
	[covcom] [ntext] NULL,
	[covdollara] [varchar](5) NOT NULL,
	[covdollaramt] [numeric](10, 2) NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[covstatus] [varchar](5) NOT NULL,
	[kbilltypeid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
