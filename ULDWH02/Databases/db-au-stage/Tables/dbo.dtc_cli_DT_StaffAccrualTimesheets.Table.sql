USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_DT_StaffAccrualTimesheets]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_DT_StaffAccrualTimesheets](
	[trx_ctrl_num] [varchar](16) NOT NULL,
	[AccrualDate] [varchar](10) NOT NULL,
	[qty] [numeric](18, 2) NOT NULL,
	[project_sell_amt] [money] NOT NULL
) ON [PRIMARY]
GO
