USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_DIAGNOSTIC_CATEGORY_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_DIAGNOSTIC_CATEGORY_aucm](
	[DX_CAT_ID] [numeric](2, 0) NOT NULL,
	[MDC] [varchar](10) NULL,
	[MDC_DESCRIPTION] [varchar](250) NULL,
	[AR_DRG_RANGE] [varchar](12) NULL
) ON [PRIMARY]
GO
