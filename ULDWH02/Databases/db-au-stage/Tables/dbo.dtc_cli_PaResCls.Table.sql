USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_PaResCls]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_PaResCls](
	[resource_class_code] [varchar](10) NOT NULL,
	[resource_class_desc] [varchar](40) NOT NULL,
	[created_date] [datetime] NULL,
	[created_user] [varchar](31) NULL,
	[last_edit_date] [datetime] NULL,
	[suppress_invoice_rates_flag] [tinyint] NOT NULL,
	[last_edit_user] [varchar](31) NULL,
	[revenue_posting_account] [varchar](32) NULL,
	[expense_posting_account] [varchar](32) NULL
) ON [PRIMARY]
GO
