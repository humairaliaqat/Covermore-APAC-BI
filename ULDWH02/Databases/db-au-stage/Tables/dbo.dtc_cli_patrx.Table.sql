USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_patrx]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_patrx](
	[trx_ctrl_num] [varchar](16) NOT NULL,
	[invoice_date] [datetime] NOT NULL,
	[invoice_number] [varchar](16) NULL,
	[project_code] [varchar](10) NOT NULL,
	[posted_state] [smallint] NOT NULL,
	[created_date] [datetime] NULL,
	[last_edit_date] [datetime] NULL,
	[created_user] [varchar](31) NULL,
	[last_edit_user] [varchar](31) NULL,
	[batch_ctrl_num] [varchar](16) NOT NULL,
	[due_date] [datetime] NOT NULL,
	[onhold_flag] [tinyint] NOT NULL,
	[fee_basis_code] [varchar](10) NULL,
	[apply_to] [varchar](16) NULL,
	[project_currency_code] [varchar](8) NOT NULL,
	[posting_date] [datetime] NULL,
	[project_sell_pretax_amt] [money] NOT NULL,
	[project_sell_tax_amt] [money] NOT NULL,
	[project_sell_taxinc_amt] [money] NOT NULL,
	[sell_tax_code] [varchar](10) NOT NULL,
	[invoice_flag] [tinyint] NOT NULL,
	[posting_code] [varchar](8) NULL,
	[company_code] [varchar](10) NOT NULL,
	[void_flag] [tinyint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_patrx]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_patrx] ON [dbo].[dtc_cli_patrx]
(
	[trx_ctrl_num] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
