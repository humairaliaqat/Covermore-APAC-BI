USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_drdomain_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_drdomain_audtc](
	[kdomainid] [int] NOT NULL,
	[domain] [nvarchar](100) NOT NULL,
	[domcomments] [ntext] NULL,
	[kassesscalcid] [int] NOT NULL,
	[domnrlimit] [int] NOT NULL,
	[kscoregroupid] [int] NULL,
	[kdomainidpar] [int] NULL,
	[dommean] [numeric](12, 4) NULL,
	[domsd] [numeric](12, 4) NULL,
	[showzscore] [varchar](5) NOT NULL,
	[storezscore] [varchar](5) NOT NULL,
	[domthreshold] [numeric](12, 4) NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[kuseridlogin] [int] NOT NULL,
	[kuseridlogmod] [int] NOT NULL,
	[kdocmastid] [int] NOT NULL,
	[kdomainclassid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
