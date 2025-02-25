USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_PaResrce]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_PaResrce](
	[resource_code] [varchar](10) NOT NULL,
	[resource_class_code] [varchar](10) NOT NULL,
	[resource_desc] [varchar](40) NOT NULL,
	[resource_type_code] [smallint] NOT NULL,
	[review_staff_code] [varchar](10) NULL,
	[resource_markup_pct] [numeric](5, 2) NOT NULL,
	[target_chargeable_pct] [numeric](5, 2) NOT NULL,
	[standard_weekly_hours] [numeric](18, 2) NOT NULL,
	[operational_target_hourly_rate] [numeric](20, 8) NOT NULL,
	[company_code] [varchar](10) NOT NULL,
	[posting_code] [varchar](8) NULL,
	[global_flag] [tinyint] NOT NULL,
	[closed_flag] [tinyint] NOT NULL,
	[created_date] [datetime] NULL,
	[created_user] [varchar](31) NULL,
	[last_edit_date] [datetime] NULL,
	[workgroup_code] [varchar](10) NULL,
	[department_code] [varchar](10) NULL,
	[manager_staff_code] [varchar](10) NULL,
	[section_code] [varchar](10) NULL,
	[suppress_invoice_rates_flag] [tinyint] NOT NULL,
	[reimb_method_code] [varchar](10) NULL,
	[reimb_ven_num] [varchar](20) NULL,
	[reimb_payroll_num] [varchar](20) NULL,
	[commenced_date] [datetime] NULL,
	[terminated_date] [datetime] NULL,
	[review_exp_staff_code] [varchar](10) NULL,
	[revenue_posting_account] [varchar](32) NULL,
	[expense_posting_account] [varchar](32) NULL,
	[reimbursement_currency_code] [varchar](8) NOT NULL,
	[last_edit_user] [varchar](31) NULL,
	[allow_global_security_flag] [tinyint] NOT NULL,
	[tax_exempt_flag] [tinyint] NOT NULL
) ON [PRIMARY]
GO
