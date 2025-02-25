USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTProAccounting_papaysch_more_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTProAccounting_papaysch_more_audtc](
	[trx_ctrl_num] [varchar](16) NOT NULL,
	[information] [varchar](40) NULL,
	[more_id] [numeric](18, 0) NOT NULL,
	[created_date] [datetime] NULL,
	[created_user] [varchar](31) NULL,
	[last_edit_date] [datetime] NULL,
	[last_edit_user] [varchar](31) NULL,
	[Schedule_Start_Date] [datetime] NULL,
	[Schedule_End_Date] [datetime] NULL
) ON [PRIMARY]
GO
