USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTNSWDW_apvodet_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTNSWDW_apvodet_audtc](
	[timestamp] [binary](8) NULL,
	[trx_ctrl_num] [varchar](16) NULL,
	[sequence_id] [int] NULL,
	[location_code] [varchar](8) NULL,
	[item_code] [varchar](30) NULL,
	[qty_ordered] [float] NULL,
	[qty_received] [float] NULL,
	[qty_returned] [float] NULL,
	[code_1099] [varchar](8) NULL,
	[tax_code] [varchar](8) NULL,
	[unit_code] [varchar](8) NULL,
	[unit_price] [float] NULL,
	[amt_discount] [float] NULL,
	[amt_freight] [float] NULL,
	[amt_tax] [float] NULL,
	[amt_misc] [float] NULL,
	[amt_extended] [float] NULL,
	[calc_tax] [float] NULL,
	[gl_exp_acct] [varchar](32) NULL,
	[line_desc] [varchar](60) NULL,
	[serial_id] [int] NULL,
	[rec_company_code] [varchar](8) NULL,
	[reference_code] [varchar](32) NULL,
	[po_orig_flag] [smallint] NULL,
	[po_ctrl_num] [varchar](16) NULL,
	[org_id] [varchar](30) NULL,
	[amt_nonrecoverable_tax] [float] NULL,
	[amt_tax_det] [float] NULL,
	[companyId] [int] NULL
) ON [PRIMARY]
GO
