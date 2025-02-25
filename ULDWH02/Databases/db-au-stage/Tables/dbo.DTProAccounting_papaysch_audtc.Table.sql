USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTProAccounting_papaysch_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTProAccounting_papaysch_audtc](
	[trx_ctrl_num] [varchar](16) NOT NULL,
	[client_code] [varchar](20) NOT NULL,
	[project_code] [varchar](10) NOT NULL,
	[schedule_date] [datetime] NULL,
	[project_id] [int] NOT NULL,
	[progressive_flag] [tinyint] NOT NULL,
	[posting_code] [varchar](8) NULL,
	[inv_ctrl_num] [varchar](16) NULL,
	[project_sell_invoice_amt] [money] NOT NULL,
	[invoice_due_date] [datetime] NULL,
	[discount_type] [tinyint] NOT NULL,
	[discount_pct] [numeric](5, 2) NOT NULL,
	[discount_text] [varchar](255) NULL,
	[generate_event_type] [tinyint] NOT NULL,
	[generate_event_value] [varchar](20) NULL,
	[created_date] [datetime] NULL,
	[created_user] [varchar](31) NULL,
	[last_edit_date] [datetime] NULL,
	[debtor_code] [varchar](16) NULL,
	[company_code] [varchar](10) NOT NULL,
	[use_debtor_addr_flag] [tinyint] NOT NULL,
	[subproject_code] [varchar](10) NULL,
	[subproject_id] [int] NULL,
	[invoice_text] [text] NULL,
	[fee_basis_code] [varchar](10) NULL,
	[term_code] [varchar](10) NULL,
	[use_debtor_term_flag] [tinyint] NOT NULL,
	[last_edit_user] [varchar](31) NULL,
	[use_client_contacts_flag] [tinyint] NOT NULL,
	[use_project_contacts_flag] [tinyint] NOT NULL,
	[use_subproject_contacts_flag] [tinyint] NOT NULL,
	[use_company_contacts_flag] [tinyint] NOT NULL,
	[invoice_type] [varchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
