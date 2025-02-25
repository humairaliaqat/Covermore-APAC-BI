USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_PaStaff]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_PaStaff](
	[resource_code] [varchar](10) NOT NULL,
	[staff_alpha] [varchar](10) NULL,
	[staff_type] [smallint] NOT NULL,
	[report_if_not_submitted_flag] [tinyint] NOT NULL,
	[email_addr] [varchar](50) NULL,
	[master_distribution_type] [tinyint] NOT NULL,
	[created_date] [datetime] NULL,
	[created_user] [varchar](31) NULL,
	[last_edit_date] [datetime] NULL,
	[password] [varchar](50) NULL,
	[tr_type] [tinyint] NOT NULL,
	[DATABASE_USERNAME] [nvarchar](128) NULL,
	[last_edit_user] [varchar](31) NULL
) ON [PRIMARY]
GO
