USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTProAccounting_dt_patrxAccountCode_vw]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTProAccounting_dt_patrxAccountCode_vw](
	[trx_ctrl_num] [varchar](16) NOT NULL,
	[posting_code] [varchar](8) NULL,
	[company_code] [varchar](10) NOT NULL,
	[AccountCode] [varchar](10) NULL
) ON [PRIMARY]
GO
