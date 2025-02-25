USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_frcovrates_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_frcovrates_audtc](
	[kcoverageid] [int] NOT NULL,
	[kitemid] [int] NOT NULL,
	[primdp] [varchar](5) NOT NULL,
	[primrate] [numeric](12, 4) NULL,
	[primcp] [numeric](10, 2) NOT NULL,
	[subpr] [numeric](6, 4) NOT NULL,
	[subdr] [numeric](10, 2) NOT NULL,
	[subcp] [numeric](10, 2) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[subseqratesused] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
