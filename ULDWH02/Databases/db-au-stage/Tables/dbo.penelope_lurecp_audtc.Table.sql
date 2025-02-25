USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_lurecp_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_lurecp_audtc](
	[lurecpid] [int] NOT NULL,
	[kreceipttypeid] [int] NOT NULL,
	[recp] [nvarchar](60) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[iscctype] [varchar](5) NULL,
	[valisactive] [varchar](5) NOT NULL,
	[kdeposittypeid] [int] NULL,
	[reasonglcode] [nvarchar](10) NULL
) ON [PRIMARY]
GO
