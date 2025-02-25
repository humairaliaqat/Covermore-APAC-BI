USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTProAccounting_dt_TimesheetOrg_vw]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTProAccounting_dt_TimesheetOrg_vw](
	[OrgName] [varchar](80) NULL,
	[Org_id] [varchar](32) NOT NULL,
	[trx_ctrl_num] [varchar](16) NOT NULL,
	[Contract_id] [varchar](32) NULL,
	[contractService_id] [varchar](32) NULL,
	[source] [varchar](6) NOT NULL
) ON [PRIMARY]
GO
