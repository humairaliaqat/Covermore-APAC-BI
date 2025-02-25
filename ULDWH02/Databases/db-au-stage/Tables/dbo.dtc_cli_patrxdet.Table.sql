USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_patrxdet]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_patrxdet](
	[trx_ctrl_num] [varchar](16) NOT NULL,
	[project_code] [varchar](10) NOT NULL,
	[tran_date] [datetime] NOT NULL,
	[resource_code] [varchar](10) NULL,
	[tran_type] [smallint] NOT NULL,
	[activity_code] [varchar](10) NULL,
	[qty] [numeric](18, 2) NOT NULL,
	[created_date] [datetime] NULL,
	[last_edit_date] [datetime] NULL,
	[created_user] [varchar](31) NULL,
	[last_edit_user] [varchar](31) NULL,
	[project_sell_rate] [numeric](20, 8) NOT NULL,
	[project_sell_amt] [money] NOT NULL,
	[project_sell_nocharge_amt] [money] NOT NULL,
	[project_sell_fee_amt] [money] NOT NULL,
	[inv_ctrl_num] [varchar](16) NULL,
	[batch_ctrl_num] [varchar](16) NULL,
	[description] [varchar](80) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_patrxdet_project_code]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_patrxdet_project_code] ON [dbo].[dtc_cli_patrxdet]
(
	[project_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
