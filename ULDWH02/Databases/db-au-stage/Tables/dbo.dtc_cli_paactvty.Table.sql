USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_paactvty]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_paactvty](
	[activity_code] [varchar](10) NOT NULL,
	[activity_desc] [varchar](40) NOT NULL,
	[completed_flag] [tinyint] NOT NULL,
	[resource_type] [smallint] NOT NULL,
	[global_flag] [tinyint] NOT NULL,
	[created_date] [datetime] NULL,
	[created_user] [varchar](31) NULL,
	[last_edit_date] [datetime] NULL,
	[activity_type_code] [varchar](10) NULL,
	[revenue_posting_account] [varchar](32) NULL,
	[last_edit_user] [varchar](31) NULL,
	[tax_exempt_flag] [tinyint] NOT NULL,
	[expense_posting_account] [varchar](32) NULL,
	[default_nocharge_flag] [tinyint] NOT NULL
) ON [PRIMARY]
GO
